import { Hono } from 'hono';
import { verifySession } from './auth';
import type { Env } from '../index';

export const analyzeRoutes = new Hono<{ Bindings: Env }>();

interface TechniqueDefinition {
  id: string;
  name: string;
  description: string;
  lookFors: string[];
  exemplarPhrases: string[];
}

interface AnalyzeRequest {
  transcript: string;
  techniques: TechniqueDefinition[];
}

interface ClaudeMessage {
  role: 'user' | 'assistant';
  content: string;
}

interface ClaudeResponse {
  id: string;
  type: string;
  role: string;
  content: Array<{ type: string; text: string }>;
  model: string;
  stop_reason: string;
  usage: {
    input_tokens: number;
    output_tokens: number;
  };
}

/**
 * POST /analyze
 * Proxies analysis request to Claude API with rate limiting
 */
analyzeRoutes.post('/', async (c) => {
  // Verify authentication
  const authHeader = c.req.header('Authorization');
  const authResult = await verifySession(authHeader, c.env);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  const userId = authResult.userId!;

  // Check rate limit
  const rateLimitKey = `rate:${userId}:${new Date().toISOString().slice(0, 13)}`;  // Hourly bucket
  const currentCount = await c.env.RATE_LIMIT.get(rateLimitKey);
  const count = currentCount ? parseInt(currentCount, 10) : 0;
  const limit = parseInt(c.env.RATE_LIMIT_PER_HOUR, 10);

  if (count >= limit) {
    return c.json({
      error: 'Rate limit exceeded',
      message: `Maximum ${limit} analyses per hour. Please try again later.`,
      retry_after: 3600 - (Date.now() % 3600000) / 1000,
    }, 429);
  }

  // Parse request
  let body: AnalyzeRequest;
  try {
    body = await c.req.json<AnalyzeRequest>();
  } catch (err) {
    return c.json({ error: 'Invalid JSON body' }, 400);
  }

  const { transcript, techniques } = body;

  if (!transcript || !techniques || techniques.length === 0) {
    return c.json({ error: 'Missing transcript or techniques' }, 400);
  }

  // Build the analysis prompt
  const prompt = buildAnalysisPrompt(transcript, techniques);

  // Call Claude API
  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': c.env.CLAUDE_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: c.env.CLAUDE_MODEL,
        max_tokens: 4096,
        messages: [
          {
            role: 'user',
            content: prompt,
          },
        ],
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Claude API error:', response.status, errorText);
      return c.json({
        error: 'Analysis service error',
        status: response.status,
      }, 502);
    }

    const claudeResponse = await response.json<ClaudeResponse>();

    // Extract the JSON response from Claude
    const analysisText = claudeResponse.content[0]?.text;

    if (!analysisText) {
      return c.json({ error: 'Empty response from analysis service' }, 502);
    }

    // Parse Claude's JSON response
    let analysisResult;
    try {
      // Try to extract JSON from the response (handle potential markdown code blocks)
      let jsonText = analysisText;
      const jsonMatch = analysisText.match(/```json\s*([\s\S]*?)\s*```/);
      if (jsonMatch) {
        jsonText = jsonMatch[1];
      }
      analysisResult = JSON.parse(jsonText);
    } catch (parseErr) {
      console.error('Failed to parse Claude response:', parseErr);
      console.error('Response text:', analysisText);
      return c.json({
        error: 'Invalid response format from analysis service',
        raw_response: analysisText.slice(0, 500),
      }, 502);
    }

    // Increment rate limit counter
    await c.env.RATE_LIMIT.put(rateLimitKey, String(count + 1), {
      expirationTtl: 3600,  // 1 hour
    });

    // Return formatted response
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
      model_used: claudeResponse.model,
      usage: claudeResponse.usage,
    });

  } catch (err) {
    console.error('Analysis request failed:', err);
    return c.json({
      error: 'Analysis request failed',
      message: err instanceof Error ? err.message : 'Unknown error',
    }, 500);
  }
});

/**
 * GET /analyze/rate-limit
 * Returns current rate limit status for the user
 */
analyzeRoutes.get('/rate-limit', async (c) => {
  const authHeader = c.req.header('Authorization');
  const authResult = await verifySession(authHeader, c.env);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  const userId = authResult.userId!;
  const rateLimitKey = `rate:${userId}:${new Date().toISOString().slice(0, 13)}`;
  const currentCount = await c.env.RATE_LIMIT.get(rateLimitKey);
  const count = currentCount ? parseInt(currentCount, 10) : 0;
  const limit = parseInt(c.env.RATE_LIMIT_PER_HOUR, 10);

  return c.json({
    used: count,
    limit: limit,
    remaining: Math.max(0, limit - count),
    resets_in: 3600 - (Date.now() % 3600000) / 1000,
  });
});

/**
 * Builds the analysis prompt for Claude
 */
function buildAnalysisPrompt(transcript: string, techniques: TechniqueDefinition[]): string {
  let prompt = `You are an expert instructional coach analyzing a teaching session transcript. Your task is to evaluate the teacher's use of specific teaching techniques and provide constructive feedback.

## Teaching Session Transcript
\`\`\`
${transcript}
\`\`\`

## Techniques to Evaluate
Analyze the transcript for evidence of the following teaching techniques:

`;

  for (const technique of techniques) {
    prompt += `
### ${technique.name}
**Description:** ${technique.description}

**Look-fors (observable indicators):**
${technique.lookFors.map(lf => `- ${lf}`).join('\n')}

**Exemplar phrases:**
${technique.exemplarPhrases.map(p => `- "${p}"`).join('\n')}

`;
  }

  prompt += `
## Response Format
Provide your analysis as a JSON object with the following structure:
{
    "overallSummary": "2-3 sentence summary of the teaching session's effectiveness",
    "strengths": ["strength 1", "strength 2", "strength 3"],
    "growthAreas": ["growth area 1", "growth area 2"],
    "actionableNextSteps": ["specific action 1", "specific action 2", "specific action 3"],
    "techniqueEvaluations": [
        {
            "techniqueId": "technique-id",
            "wasObserved": true/false,
            "rating": 1-5 (null if not observed),
            "evidence": ["specific quote or behavior from transcript"],
            "feedback": "Detailed feedback about technique usage",
            "suggestions": ["specific improvement suggestion"]
        }
    ]
}

## Rating Scale
1 - Developing: Technique not observed or needs significant development
2 - Emerging: Beginning to implement technique with inconsistent results
3 - Proficient: Solid implementation of technique with room for refinement
4 - Accomplished: Effective and consistent use of technique
5 - Exemplary: Masterful implementation that could serve as a model

## Guidelines
- Be specific and cite evidence from the transcript
- Provide actionable, growth-oriented feedback
- Balance recognition of strengths with constructive suggestions
- If a technique was not observed, set wasObserved to false and rating to null
- Focus on patterns rather than isolated instances

Respond ONLY with the JSON object, no additional text.`;

  return prompt;
}
