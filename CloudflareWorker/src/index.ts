import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { authRoutes } from './routes/auth';
import { analyzeRoutes } from './routes/analyze';
import { analyzeVideoRoutes } from './routes/analyze-video';
import { uploadRoutes } from './routes/upload';

export interface Env {
  GOOGLE_CLIENT_ID: string;
  JWT_SECRET: string;
  ALLOWED_DOMAIN: string;
  RATE_LIMIT_PER_HOUR: string;
  RATE_LIMIT: KVNamespace;
  GEMINI_API_KEY: string;
  GEMINI_TEXT_MODEL: string;
  GEMINI_VIDEO_MODEL: string;
  VIDEO_RATE_LIMIT_PER_HOUR: string;
}

const app = new Hono<{ Bindings: Env }>();

// SECURITY DESIGN DECISION: Permissive CORS (origin: '*')
// - iOS app uses native networking (CORS doesn't apply to native apps)
// - No web frontend exists for this application
// - All endpoints require @psd401.net Google OAuth authentication
// - CORS restrictions would only affect browser-based requests, which can't authenticate anyway
// - Keeping permissive avoids maintenance overhead with no security benefit for this architecture
app.use('*', cors({
  origin: '*',
  allowHeaders: ['Content-Type', 'Authorization'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
}));

// Security headers middleware
app.use('*', async (c, next) => {
  await next();
  c.header('X-Content-Type-Options', 'nosniff');
  c.header('X-Frame-Options', 'DENY');
});

// Health check
app.get('/', (c) => {
  return c.json({
    name: 'Teacher Coach API',
    version: '1.0.0',
    status: 'healthy'
  });
});

// Mount routes
app.route('/auth', authRoutes);
app.route('/analyze', analyzeRoutes);
app.route('/analyze/video', analyzeVideoRoutes);
app.route('/upload', uploadRoutes);

// Error handler - logs details server-side, returns generic message to client
app.onError((err, c) => {
  console.error('Unhandled error:', err);
  return c.json({
    error: 'Internal server error'
  }, 500);
});

// 404 handler
app.notFound((c) => {
  return c.json({
    error: 'Not found',
    path: c.req.path
  }, 404);
});

export default app;
