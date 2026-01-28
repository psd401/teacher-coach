/**
 * Shared LLM prompt module
 *
 * This module provides centralized prompt building for both text and video analysis.
 * Edit templates in ./templates/ to modify prompt content without changing logic.
 */

// Re-export types
export type {
  TechniqueDefinition,
  PauseInfo,
  PauseData,
  TextAnalysisPromptOptions,
  VideoAnalysisPromptOptions,
} from './types';

// Re-export builder functions
export { buildAnalysisPrompt, buildVideoAnalysisPrompt } from './builder';
