import { Hono } from 'hono';
import { verifySession } from './auth';
import type { Env } from '../index';

export const analyzeVideoRoutes = new Hono<{ Bindings: Env }>();

interface TechniqueDefinition {
  id: string;
  name: string;
  description: string;
  lookFors: string[];
  exemplarPhrases: string[];
}

interface AnalyzeVideoRequest {
  geminiFileName: string;  // e.g., "files/abc123"
  techniques: TechniqueDefinition[];
  includeRatings?: boolean;
}

interface GeminiFileStatusResponse {
  name: string;
  displayName: string;
  mimeType: string;
  sizeBytes: string;
  createTime: string;
  updateTime: string;
  expirationTime: string;
  sha256Hash: string;
  uri: string;
  state: 'PROCESSING' | 'ACTIVE' | 'FAILED';
}

interface GeminiGenerateResponse {
  candidates: Array<{
    content: {
      parts: Array<{ text: string }>;
      role: string;
    };
    finishReason: string;
  }>;
  usageMetadata: {
    promptTokenCount: number;
    candidatesTokenCount: number;
    totalTokenCount: number;
  };
}

const GEMINI_API_BASE = 'https://generativelanguage.googleapis.com';
const FILE_PROCESSING_TIMEOUT_MS = 5 * 60 * 1000; // 5 minutes
const FILE_PROCESSING_POLL_INTERVAL_MS = 5000; // 5 seconds

/**
 * POST /analyze/video
 * Analyze a video that has been uploaded to Gemini
 */
analyzeVideoRoutes.post('/', async (c) => {
  // Verify authentication
  const authHeader = c.req.header('Authorization');
  const authResult = await verifySession(authHeader, c.env);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  const userId = authResult.userId!;

  // Check video-specific rate limit (separate from text analysis)
  const rateLimitKey = `rate:video:${userId}:${new Date().toISOString().slice(0, 13)}`;
  const currentCount = await c.env.RATE_LIMIT.get(rateLimitKey);
  const count = currentCount ? parseInt(currentCount, 10) : 0;
  const limit = parseInt(c.env.VIDEO_RATE_LIMIT_PER_HOUR || '5', 10);

  if (count >= limit) {
    return c.json({
      error: 'Rate limit exceeded',
      message: `Maximum ${limit} video analyses per hour. Please try again later.`,
      retry_after: 3600 - (Date.now() % 3600000) / 1000,
    }, 429);
  }

  // Parse request
  let body: AnalyzeVideoRequest;
  try {
    body = await c.req.json<AnalyzeVideoRequest>();
  } catch (err) {
    return c.json({ error: 'Invalid JSON body' }, 400);
  }

  const { geminiFileName, techniques, includeRatings = true } = body;

  if (!geminiFileName || !techniques || techniques.length === 0) {
    return c.json({ error: 'Missing geminiFileName or techniques' }, 400);
  }

  try {
    // 1. Wait for Gemini file processing to complete
    const processedFile = await waitForFileProcessing(
      geminiFileName,
      c.env.GEMINI_API_KEY
    );

    if (processedFile.state !== 'ACTIVE') {
      throw new Error(`File processing failed: ${processedFile.state}`);
    }

    // 2. Call Gemini with video and prompt
    const prompt = buildVideoAnalysisPrompt(techniques, includeRatings);
    const geminiResponse = await callGeminiWithVideo(
      processedFile.uri,
      processedFile.mimeType,
      prompt,
      c.env.GEMINI_MODEL || 'gemini-2.5-flash',
      c.env.GEMINI_API_KEY
    );

    // 3. Parse response
    const analysisText = geminiResponse.candidates[0]?.content?.parts[0]?.text;

    if (!analysisText) {
      return c.json({ error: 'Empty response from analysis service' }, 502);
    }

    let analysisResult;
    try {
      let jsonText = analysisText;
      const jsonMatch = analysisText.match(/```json\s*([\s\S]*?)\s*```/);
      if (jsonMatch) {
        jsonText = jsonMatch[1];
      }
      analysisResult = JSON.parse(jsonText);
    } catch (parseErr) {
      console.error('Failed to parse Gemini response:', parseErr);
      console.error('Response text:', analysisText);
      return c.json({
        error: 'Invalid response format from analysis service',
        raw_response: analysisText.slice(0, 500),
      }, 502);
    }

    // 4. Increment rate limit counter
    await c.env.RATE_LIMIT.put(rateLimitKey, String(count + 1), {
      expirationTtl: 3600,
    });

    // 5. Cleanup: delete from Gemini (best effort)
    await deleteGeminiFile(geminiFileName, c.env.GEMINI_API_KEY).catch(() => {});

    // Return formatted response (same structure as Claude analysis)
    return c.json({
      overall_summary: analysisResult.overallSummary,
      strengths: analysisResult.strengths || [],
      growth_areas: analysisResult.growthAreas || [],
      actionable_next_steps: analysisResult.actionableNextSteps || [],
      technique_evaluations: (analysisResult.techniqueEvaluations || []).map((te: any) => ({
        technique_id: te.techniqueId,
        was_observed: te.wasObserved,
        rating: te.rating,
        evidence: te.evidence || [],
        feedback: te.feedback,
        suggestions: te.suggestions || [],
      })),
      model_used: c.env.GEMINI_MODEL || 'gemini-2.5-flash',
      usage: {
        input_tokens: geminiResponse.usageMetadata?.promptTokenCount,
        output_tokens: geminiResponse.usageMetadata?.candidatesTokenCount,
      },
    });

  } catch (err) {
    console.error('Video analysis failed:', err);

    // Cleanup on error (best effort)
    await deleteGeminiFile(geminiFileName, c.env.GEMINI_API_KEY).catch(() => {});

    return c.json({
      error: 'Video analysis failed',
      message: err instanceof Error ? err.message : 'Unknown error',
    }, 500);
  }
});

/**
 * GET /analyze/video/rate-limit
 * Returns current video rate limit status for the user
 */
analyzeVideoRoutes.get('/rate-limit', async (c) => {
  const authHeader = c.req.header('Authorization');
  const authResult = await verifySession(authHeader, c.env);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  const userId = authResult.userId!;
  const rateLimitKey = `rate:video:${userId}:${new Date().toISOString().slice(0, 13)}`;
  const currentCount = await c.env.RATE_LIMIT.get(rateLimitKey);
  const count = currentCount ? parseInt(currentCount, 10) : 0;
  const limit = parseInt(c.env.VIDEO_RATE_LIMIT_PER_HOUR || '5', 10);

  return c.json({
    used: count,
    limit: limit,
    remaining: Math.max(0, limit - count),
    resets_in: 3600 - (Date.now() % 3600000) / 1000,
  });
});

/**
 * Poll Gemini File API until file is processed
 */
async function waitForFileProcessing(
  fileName: string,
  apiKey: string
): Promise<GeminiFileStatusResponse> {
  const startTime = Date.now();

  while (Date.now() - startTime < FILE_PROCESSING_TIMEOUT_MS) {
    const response = await fetch(
      `${GEMINI_API_BASE}/v1beta/${fileName}?key=${apiKey}`
    );

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Failed to check file status: ${response.status} ${errorText}`);
    }

    const fileStatus = await response.json<GeminiFileStatusResponse>();

    if (fileStatus.state === 'ACTIVE') {
      return fileStatus;
    }

    if (fileStatus.state === 'FAILED') {
      throw new Error('File processing failed');
    }

    // Wait before polling again
    await new Promise(resolve => setTimeout(resolve, FILE_PROCESSING_POLL_INTERVAL_MS));
  }

  throw new Error('File processing timed out');
}

/**
 * Call Gemini API with video and prompt
 */
async function callGeminiWithVideo(
  fileUri: string,
  mimeType: string,
  prompt: string,
  model: string,
  apiKey: string
): Promise<GeminiGenerateResponse> {
  const response = await fetch(
    `${GEMINI_API_BASE}/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                fileData: {
                  mimeType,
                  fileUri,
                },
              },
              {
                text: prompt,
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0.4,
          maxOutputTokens: 8192,
        },
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Gemini API error: ${response.status} ${errorText}`);
  }

  return response.json<GeminiGenerateResponse>();
}

/**
 * Delete a file from Gemini File API
 */
async function deleteGeminiFile(fileName: string, apiKey: string): Promise<void> {
  const response = await fetch(
    `${GEMINI_API_BASE}/v1beta/${fileName}?key=${apiKey}`,
    { method: 'DELETE' }
  );

  if (!response.ok && response.status !== 404) {
    console.error('Failed to delete Gemini file:', await response.text());
  }
}

/**
 * Build the video analysis prompt for Gemini
 */
function buildVideoAnalysisPrompt(techniques: TechniqueDefinition[], includeRatings: boolean): string {
  let prompt = `You are an expert instructional coach analyzing a teaching session video. Your task is to evaluate the teacher's use of specific teaching techniques and provide constructive feedback.

Watch the entire video carefully, paying attention to:
- Teacher verbal communication and questioning techniques
- Teacher non-verbal communication (body language, positioning, gestures)
- Student engagement and responses
- Classroom management and pacing
- Use of instructional materials and technology

## Techniques to Evaluate
Analyze the video for evidence of the following teaching techniques:

`;

  for (const technique of techniques) {
    prompt += `
### ${technique.name}
**ID:** ${technique.id}
**Description:** ${technique.description}

**Look-fors (observable indicators):**
${technique.lookFors.map(lf => `- ${lf}`).join('\n')}

**Exemplar phrases:**
${technique.exemplarPhrases.map(p => `- "${p}"`).join('\n')}

`;
  }

  const techniqueEvalSchema = includeRatings
    ? `{
            "techniqueId": "exact-id-from-technique-definition",
            "wasObserved": true/false,
            "rating": 1-5 (null if not observed),
            "evidence": ["specific observed behavior or quote from video"],
            "feedback": "Detailed feedback about technique usage",
            "suggestions": ["specific improvement suggestion"]
        }`
    : `{
            "techniqueId": "exact-id-from-technique-definition",
            "wasObserved": true/false,
            "evidence": ["specific observed behavior or quote from video"],
            "feedback": "Detailed feedback about technique usage",
            "suggestions": ["specific improvement suggestion"]
        }`;

  prompt += `
## Response Format
Provide your analysis as a JSON object with the following structure:
{
    "overallSummary": "2-3 sentence summary of the teaching session's effectiveness based on video observation",
    "strengths": ["strength 1", "strength 2", "strength 3"],
    "growthAreas": ["growth area 1", "growth area 2"],
    "actionableNextSteps": ["specific action 1", "specific action 2", "specific action 3"],
    "techniqueEvaluations": [
        ${techniqueEvalSchema}
    ]
}
`;

  if (includeRatings) {
    prompt += `
## Rating Scale
1 - Developing: Technique not observed or needs significant development
2 - Emerging: Beginning to implement technique with inconsistent results
3 - Proficient: Solid implementation of technique with room for refinement
4 - Accomplished: Effective and consistent use of technique
5 - Exemplary: Masterful implementation that could serve as a model
`;
  }

  const ratingGuideline = includeRatings
    ? '- If a technique was not observed, set wasObserved to false and rating to null'
    : '- If a technique was not observed, set wasObserved to false';

  prompt += `
## Guidelines
- IMPORTANT: Use the exact "ID" value shown for each technique as the "techniqueId" in your response
- Be specific and cite observable evidence from the video (actions, quotes, interactions)
- Include timestamps when referencing specific moments if possible
- Consider both verbal and non-verbal teacher behaviors
- Provide actionable, growth-oriented feedback
- Balance recognition of strengths with constructive suggestions
${ratingGuideline}
- Focus on patterns rather than isolated instances

Respond ONLY with the JSON object, no additional text.`;

  return prompt;
}
