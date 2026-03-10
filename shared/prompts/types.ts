/**
 * Shared types for LLM prompt generation
 */

export interface TechniqueDefinition {
  id: string;
  name: string;
  description: string;
  lookFors: string[];
  exemplarPhrases: string[];
}

export interface PauseInfo {
  startTime: number;
  endTime: number;
  duration: number;
  precedingText: string;
  followingText: string;
}

export interface PauseData {
  pauses: PauseInfo[];
  summary: {
    count: number;
    averageDuration: number;
    maxDuration: number;
    totalPauseTime: number;
  };
}

export interface TextAnalysisPromptOptions {
  transcript: string;
  techniques: TechniqueDefinition[];
  includeRatings: boolean;
  pauseData?: PauseData;
}

export interface VideoAnalysisPromptOptions {
  techniques: TechniqueDefinition[];
  includeRatings: boolean;
}

export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface ChatPromptOptions {
  transcript: string;
  analysisSummary: string;
  techniqueEvaluationsSummary: string;
  reflectionSummary?: string;
  messages: ChatMessage[];
  techniqueNames: string[];
}

export interface GeminiGenerateResponse {
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
