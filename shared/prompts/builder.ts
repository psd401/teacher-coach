/**
 * Prompt builder functions for LLM analysis
 */

import type { TechniqueDefinition, PauseData, TextAnalysisPromptOptions, VideoAnalysisPromptOptions } from './types';
import {
  RATING_SCALE,
  RESPONSE_SCHEMA_WITH_RATINGS,
  RESPONSE_SCHEMA_WITHOUT_RATINGS,
  GUIDELINES_BASE,
  GUIDELINES_VIDEO_BASE,
  RATING_GUIDELINE_WITH,
  RATING_GUIDELINE_WITHOUT,
} from './templates/components';
import {
  TEXT_ANALYSIS_SYSTEM,
  TEXT_ANALYSIS_TRANSCRIPT_SECTION,
  PAUSE_DATA_SECTION,
  TECHNIQUES_SECTION_HEADER,
} from './templates/text-analysis';
import {
  VIDEO_ANALYSIS_SYSTEM,
  VIDEO_TECHNIQUES_SECTION_HEADER,
} from './templates/video-analysis';

/**
 * Simple template processor for {{variable}} substitution
 */
function processTemplate(template: string, vars: Record<string, string>): string {
  let result = template;
  for (const [key, value] of Object.entries(vars)) {
    result = result.replace(new RegExp(`\\{\\{${key}\\}\\}`, 'g'), value);
  }
  return result;
}

/**
 * Format a single technique for inclusion in the prompt
 */
function formatTechnique(technique: TechniqueDefinition): string {
  return `
### ${technique.name}
**ID:** ${technique.id}
**Description:** ${technique.description}

**Look-fors (observable indicators):**
${technique.lookFors.map(lf => `- ${lf}`).join('\n')}

**Exemplar phrases:**
${technique.exemplarPhrases.map(p => `- "${p}"`).join('\n')}
`;
}

/**
 * Format all techniques for inclusion in the prompt
 */
function formatTechniques(techniques: TechniqueDefinition[]): string {
  return techniques.map(formatTechnique).join('\n');
}

/**
 * Format pause data for inclusion in the prompt
 */
function formatPauseData(pauseData: PauseData): string {
  const pauseDetails = pauseData.pauses
    .map((p, i) => `${i + 1}. ${p.duration.toFixed(1)}s pause after "${p.precedingText}" → before "${p.followingText}"`)
    .join('\n');

  return processTemplate(PAUSE_DATA_SECTION, {
    pauseCount: pauseData.summary.count.toString(),
    pauseAvgDuration: pauseData.summary.averageDuration.toFixed(1),
    pauseMaxDuration: pauseData.summary.maxDuration.toFixed(1),
    pauseTotalTime: pauseData.summary.totalPauseTime.toFixed(1),
    pauseDetails,
  });
}

/**
 * Build the complete text analysis prompt
 */
export function buildAnalysisPrompt(options: TextAnalysisPromptOptions): string {
  const { transcript, techniques, includeRatings, pauseData } = options;

  let prompt = TEXT_ANALYSIS_SYSTEM;

  // Add transcript section
  prompt += processTemplate(TEXT_ANALYSIS_TRANSCRIPT_SECTION, { transcript });

  // Add pause data section if provided and wait-time technique is selected
  if (pauseData && techniques.some(t => t.id === 'wait-time')) {
    prompt += formatPauseData(pauseData);
  }

  // Add techniques section
  prompt += TECHNIQUES_SECTION_HEADER;
  prompt += formatTechniques(techniques);

  // Add response schema
  prompt += includeRatings ? RESPONSE_SCHEMA_WITH_RATINGS : RESPONSE_SCHEMA_WITHOUT_RATINGS;

  // Add rating scale if ratings enabled
  if (includeRatings) {
    prompt += RATING_SCALE;
  }

  // Add guidelines
  const ratingGuideline = includeRatings ? RATING_GUIDELINE_WITH : RATING_GUIDELINE_WITHOUT;
  prompt += processTemplate(GUIDELINES_BASE, { ratingGuideline });

  return prompt;
}

/**
 * Build the complete video analysis prompt for Gemini
 */
export function buildVideoAnalysisPrompt(options: VideoAnalysisPromptOptions): string {
  const { techniques, includeRatings } = options;

  let prompt = VIDEO_ANALYSIS_SYSTEM;

  // Add techniques section
  prompt += VIDEO_TECHNIQUES_SECTION_HEADER;
  prompt += formatTechniques(techniques);

  // Add response schema
  prompt += includeRatings ? RESPONSE_SCHEMA_WITH_RATINGS : RESPONSE_SCHEMA_WITHOUT_RATINGS;

  // Add rating scale if ratings enabled
  if (includeRatings) {
    prompt += RATING_SCALE;
  }

  // Add guidelines
  const ratingGuideline = includeRatings ? RATING_GUIDELINE_WITH : RATING_GUIDELINE_WITHOUT;
  prompt += processTemplate(GUIDELINES_VIDEO_BASE, { ratingGuideline });

  return prompt;
}
