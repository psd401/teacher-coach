import { Hono } from 'hono';
import { verifySession } from './auth';
import type { Env } from '../index';

export const uploadRoutes = new Hono<{ Bindings: Env }>();

const GEMINI_API_BASE = 'https://generativelanguage.googleapis.com';

interface InitiateUploadRequest {
  fileName: string;
  contentType: string;
  fileSize: number;
}

interface InitiateUploadResponse {
  uploadUrl: string;
  fileDisplayName: string;
}

const MAX_FILE_SIZE = 2 * 1024 * 1024 * 1024; // 2GB (Gemini File API limit)
const ALLOWED_CONTENT_TYPES = [
  'video/mp4',
  'video/quicktime',
  'video/x-m4v',
  'video/webm',
];

/**
 * POST /upload/initiate
 * Initiates a resumable upload directly to Gemini File API
 * Returns the Gemini upload URL for direct client upload
 */
uploadRoutes.post('/initiate', async (c) => {
  // Verify authentication
  const authHeader = c.req.header('Authorization');
  const authResult = await verifySession(authHeader, c.env);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  // Parse request
  let body: InitiateUploadRequest;
  try {
    body = await c.req.json<InitiateUploadRequest>();
  } catch (err) {
    return c.json({ error: 'Invalid JSON body' }, 400);
  }

  const { fileName, contentType, fileSize } = body;

  // Validate request
  if (!fileName || !contentType || !fileSize) {
    return c.json({ error: 'Missing fileName, contentType, or fileSize' }, 400);
  }

  if (!ALLOWED_CONTENT_TYPES.includes(contentType)) {
    return c.json({
      error: 'Invalid content type',
      message: `Allowed types: ${ALLOWED_CONTENT_TYPES.join(', ')}`,
    }, 400);
  }

  if (fileSize > MAX_FILE_SIZE) {
    return c.json({
      error: 'File too large',
      message: 'Maximum file size is 2GB',
      maxSize: MAX_FILE_SIZE,
    }, 400);
  }

  try {
    // Generate a unique display name
    const timestamp = Date.now();
    const sanitizedFileName = fileName.replace(/[^a-zA-Z0-9.-]/g, '_');
    const fileDisplayName = `${timestamp}-${sanitizedFileName}`;

    // Initiate resumable upload with Gemini
    const startResponse = await fetch(
      `${GEMINI_API_BASE}/upload/v1beta/files?key=${c.env.GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Upload-Protocol': 'resumable',
          'X-Goog-Upload-Command': 'start',
          'X-Goog-Upload-Header-Content-Length': String(fileSize),
          'X-Goog-Upload-Header-Content-Type': contentType,
        },
        body: JSON.stringify({
          file: { displayName: fileDisplayName },
        }),
      }
    );

    if (!startResponse.ok) {
      const errorText = await startResponse.text();
      console.error('Gemini upload initiation failed:', startResponse.status, errorText);
      return c.json({
        error: 'Failed to initiate upload',
        details: errorText,
      }, 502);
    }

    const uploadUrl = startResponse.headers.get('X-Goog-Upload-URL');
    if (!uploadUrl) {
      return c.json({ error: 'No upload URL returned from Gemini' }, 502);
    }

    return c.json<InitiateUploadResponse>({
      uploadUrl,
      fileDisplayName,
    });

  } catch (err) {
    console.error('Failed to initiate Gemini upload:', err);
    return c.json({
      error: 'Failed to initiate upload',
      message: err instanceof Error ? err.message : 'Unknown error',
    }, 500);
  }
});

/**
 * POST /upload/status
 * Checks the status of an uploaded file in Gemini
 */
uploadRoutes.post('/status', async (c) => {
  // Verify authentication
  const authHeader = c.req.header('Authorization');
  const authResult = await verifySession(authHeader, c.env);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  const { fileName } = await c.req.json<{ fileName: string }>();

  if (!fileName) {
    return c.json({ error: 'Missing fileName' }, 400);
  }

  try {
    const response = await fetch(
      `${GEMINI_API_BASE}/v1beta/${fileName}?key=${c.env.GEMINI_API_KEY}`
    );

    if (!response.ok) {
      const errorText = await response.text();
      return c.json({
        error: 'Failed to get file status',
        details: errorText,
      }, response.status);
    }

    const fileStatus = await response.json();
    return c.json(fileStatus);

  } catch (err) {
    console.error('Failed to get file status:', err);
    return c.json({
      error: 'Failed to get file status',
      message: err instanceof Error ? err.message : 'Unknown error',
    }, 500);
  }
});

/**
 * DELETE /upload/:fileName
 * Deletes a file from Gemini
 */
uploadRoutes.delete('/:fileName{.+}', async (c) => {
  // Verify authentication
  const authHeader = c.req.header('Authorization');
  const authResult = await verifySession(authHeader, c.env);

  if (!authResult.valid) {
    return c.json({ error: authResult.error }, 401);
  }

  const fileName = c.req.param('fileName');

  if (!fileName) {
    return c.json({ error: 'Missing fileName' }, 400);
  }

  try {
    const response = await fetch(
      `${GEMINI_API_BASE}/v1beta/${fileName}?key=${c.env.GEMINI_API_KEY}`,
      { method: 'DELETE' }
    );

    if (!response.ok && response.status !== 404) {
      const errorText = await response.text();
      return c.json({
        error: 'Failed to delete file',
        details: errorText,
      }, response.status);
    }

    return c.json({ success: true });

  } catch (err) {
    console.error('Failed to delete file:', err);
    return c.json({
      error: 'Failed to delete file',
      message: err instanceof Error ? err.message : 'Unknown error',
    }, 500);
  }
});
