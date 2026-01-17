import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { authRoutes } from './routes/auth';
import { analyzeRoutes } from './routes/analyze';

export interface Env {
  CLAUDE_API_KEY: string;
  GOOGLE_CLIENT_ID: string;
  JWT_SECRET: string;
  ALLOWED_DOMAIN: string;
  RATE_LIMIT_PER_HOUR: string;
  CLAUDE_MODEL: string;
  RATE_LIMIT: KVNamespace;
}

const app = new Hono<{ Bindings: Env }>();

// CORS configuration
app.use('*', cors({
  origin: '*',  // Allow all origins for native app
  allowHeaders: ['Content-Type', 'Authorization'],
  allowMethods: ['GET', 'POST', 'OPTIONS'],
}));

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

export default app;
