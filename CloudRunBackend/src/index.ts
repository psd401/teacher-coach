import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { authRoutes } from './routes/auth';
import { analyzeRoutes } from './routes/analyze';
import { analyzeVideoRoutes } from './routes/analyze-video';
import { uploadRoutes } from './routes/upload';

// Environment configuration
export interface Env {
  CLAUDE_API_KEY: string;
  GOOGLE_CLIENT_ID: string;
  JWT_SECRET: string;
  ALLOWED_DOMAIN: string;
  RATE_LIMIT_PER_HOUR: number;
  CLAUDE_MODEL: string;
  GEMINI_API_KEY: string;
  GEMINI_MODEL: string;
  VIDEO_RATE_LIMIT_PER_HOUR: number;
}

// Load environment variables
export const env: Env = {
  CLAUDE_API_KEY: process.env.CLAUDE_API_KEY || '',
  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || '',
  JWT_SECRET: process.env.JWT_SECRET || '',
  ALLOWED_DOMAIN: process.env.ALLOWED_DOMAIN || 'psd401.net',
  RATE_LIMIT_PER_HOUR: parseInt(process.env.RATE_LIMIT_PER_HOUR || '20', 10),
  CLAUDE_MODEL: process.env.CLAUDE_MODEL || 'claude-opus-4-5-20251101',
  GEMINI_API_KEY: process.env.GEMINI_API_KEY || '',
  GEMINI_MODEL: process.env.GEMINI_MODEL || 'gemini-2.5-flash',
  VIDEO_RATE_LIMIT_PER_HOUR: parseInt(process.env.VIDEO_RATE_LIMIT_PER_HOUR || '5', 10),
};

// In-memory rate limiting (resets on restart - adequate for low traffic)
export const rateLimitStore = new Map<string, { count: number; resetTime: number }>();

export function checkRateLimit(key: string, limit: number): { allowed: boolean; current: number; resetIn: number } {
  const now = Date.now();
  const hourMs = 3600000;
  const entry = rateLimitStore.get(key);

  if (!entry || now > entry.resetTime) {
    rateLimitStore.set(key, { count: 1, resetTime: now + hourMs });
    return { allowed: true, current: 1, resetIn: hourMs / 1000 };
  }

  if (entry.count >= limit) {
    return { allowed: false, current: entry.count, resetIn: (entry.resetTime - now) / 1000 };
  }

  entry.count++;
  return { allowed: true, current: entry.count, resetIn: (entry.resetTime - now) / 1000 };
}

export function getRateLimitStatus(key: string, limit: number): { used: number; limit: number; remaining: number; resets_in: number } {
  const now = Date.now();
  const entry = rateLimitStore.get(key);

  if (!entry || now > entry.resetTime) {
    return { used: 0, limit, remaining: limit, resets_in: 3600 };
  }

  return {
    used: entry.count,
    limit,
    remaining: Math.max(0, limit - entry.count),
    resets_in: (entry.resetTime - now) / 1000,
  };
}

const app = new Hono();

// CORS configuration
app.use('*', cors({
  origin: '*',
  allowHeaders: ['Content-Type', 'Authorization'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
}));

// Health check
app.get('/', (c) => {
  return c.json({
    name: 'Teacher Coach API',
    version: '1.0.0',
    status: 'healthy',
    runtime: 'Cloud Run'
  });
});

// Mount routes
app.route('/auth', authRoutes);
app.route('/analyze', analyzeRoutes);
app.route('/analyze/video', analyzeVideoRoutes);
app.route('/upload', uploadRoutes);

// Error handler
app.onError((err, c) => {
  console.error('Unhandled error:', err);
  return c.json({
    error: 'Internal server error',
    message: err.message
  }, 500);
});

// 404 handler
app.notFound((c) => {
  return c.json({
    error: 'Not found',
    path: c.req.path
  }, 404);
});

// Start server
const port = parseInt(process.env.PORT || '8080', 10);
console.log(`Starting server on port ${port}...`);

export default {
  port,
  fetch: app.fetch,
};
