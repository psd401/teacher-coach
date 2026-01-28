import { Hono } from 'hono';
import { verifySession } from './auth';
import { env, checkRateLimit, getRateLimitStatus } from '../index';
import { buildAnalysisPrompt, type TechniqueDefinition, type PauseData } from '../../../shared/prompts';

export const analyzeRoutes = new Hono();

interface AnalyzeRequest {
  transcript: string;
  techniques: TechniqueDefinition[];
  includeRatings?: boolean;
  pauseData?: PauseData;
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
  const authResult = await verifySession(authHeader);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  const userId = authResult.userId!;

  // Check rate limit
  const rateLimitKey = `rate:text:${userId}`;
  const rateCheck = checkRateLimit(rateLimitKey, env.RATE_LIMIT_PER_HOUR);

  if (!rateCheck.allowed) {
    return c.json({
      error: 'Rate limit exceeded',
      message: `Maximum ${env.RATE_LIMIT_PER_HOUR} analyses per hour. Please try again later.`,
      retry_after: rateCheck.resetIn,
    }, 429);
  }

  // Parse request
  let body: AnalyzeRequest;
  try {
    body = await c.req.json<AnalyzeRequest>();
  } catch (err) {
    return c.json({ error: 'Invalid JSON body' }, 400);
  }

  const { transcript, techniques, includeRatings = true, pauseData } = body;

  if (!transcript || !techniques || techniques.length === 0) {
    return c.json({ error: 'Missing transcript or techniques' }, 400);
  }

  // Input size validation to prevent DoS and excessive API costs
  const MAX_TRANSCRIPT_LENGTH = 100000; // ~100KB of text
  const MAX_TECHNIQUES = 20;
  const MAX_PAUSES = 100;

  if (transcript.length > MAX_TRANSCRIPT_LENGTH) {
    return c.json({ error: 'Transcript too large', maxLength: MAX_TRANSCRIPT_LENGTH }, 400);
  }

  if (techniques.length > MAX_TECHNIQUES) {
    return c.json({ error: 'Too many techniques', maxTechniques: MAX_TECHNIQUES }, 400);
  }

  if (pauseData?.pauses && pauseData.pauses.length > MAX_PAUSES) {
    return c.json({ error: 'Too many pauses', maxPauses: MAX_PAUSES }, 400);
  }

  // Build the analysis prompt
  const prompt = buildAnalysisPrompt({ transcript, techniques, includeRatings, pauseData });

  // Call Claude API
  try {
    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': env.CLAUDE_API_KEY,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: env.CLAUDE_MODEL,
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
      // Log error details server-side only (redact transcript content)
      console.error('Failed to parse Claude response:', parseErr);
      console.error('Response length:', analysisText.length);
      return c.json({
        error: 'Invalid response format from analysis service'
      }, 502);
    }

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
      error: 'Analysis request failed'
    }, 500);
  }
});

/**
 * GET /analyze/rate-limit
 * Returns current rate limit status for the user
 */
analyzeRoutes.get('/rate-limit', async (c) => {
  const authHeader = c.req.header('Authorization');
  const authResult = await verifySession(authHeader);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  const userId = authResult.userId!;
  const rateLimitKey = `rate:text:${userId}`;
  const status = getRateLimitStatus(rateLimitKey, env.RATE_LIMIT_PER_HOUR);

  return c.json(status);
});
