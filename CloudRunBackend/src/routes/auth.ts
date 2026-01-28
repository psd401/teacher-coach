import { Hono } from 'hono';
import * as jose from 'jose';
import { env, type Env } from '../index';

export const authRoutes = new Hono();

// Google's public keys endpoint
const GOOGLE_CERTS_URL = 'https://www.googleapis.com/oauth2/v3/certs';

interface GoogleTokenPayload {
  iss: string;
  azp: string;
  aud: string;
  sub: string;
  hd?: string;  // Hosted domain
  email: string;
  email_verified: boolean;
  name: string;
  picture?: string;
  given_name?: string;
  family_name?: string;
  iat: number;
  exp: number;
}

interface ValidateRequest {
  id_token: string;
}

/**
 * POST /auth/validate
 * Validates a Google ID token and returns a session token
 */
authRoutes.post('/validate', async (c) => {
  try {
    const body = await c.req.json<ValidateRequest>();
    const { id_token } = body;

    if (!id_token) {
      return c.json({ error: 'Missing id_token' }, 400);
    }

    // Fetch Google's public keys
    const JWKS = jose.createRemoteJWKSet(new URL(GOOGLE_CERTS_URL));

    // Verify the token
    let payload: GoogleTokenPayload;
    try {
      const { payload: verifiedPayload } = await jose.jwtVerify(id_token, JWKS, {
        issuer: ['https://accounts.google.com', 'accounts.google.com'],
        audience: env.GOOGLE_CLIENT_ID,
      });
      payload = verifiedPayload as unknown as GoogleTokenPayload;
    } catch (err) {
      console.error('Token verification failed:', err);
      return c.json({ error: 'Invalid token' }, 401);
    }

    // CRITICAL: Verify the hosted domain (server-side domain restriction)
    const allowedDomain = env.ALLOWED_DOMAIN;
    if (!payload.hd || payload.hd !== allowedDomain) {
      console.warn(`Domain rejection: ${payload.email} (hd: ${payload.hd})`);
      return c.json({
        error: 'Access denied',
        message: `Only @${allowedDomain} accounts are allowed`
      }, 403);
    }

    // Verify email is verified
    if (!payload.email_verified) {
      return c.json({ error: 'Email not verified' }, 403);
    }

    // Create user object
    const user = {
      id: payload.sub,
      email: payload.email,
      displayName: payload.name,
      photoURL: payload.picture || null,
    };

    // Generate session token (7-day expiration)
    const secret = new TextEncoder().encode(env.JWT_SECRET);
    const sessionToken = await new jose.SignJWT({ user })
      .setProtectedHeader({ alg: 'HS256' })
      .setIssuedAt()
      .setExpirationTime('7d')
      .setSubject(user.id)
      .sign(secret);

    // Generate refresh token (30-day expiration)
    const refreshToken = await new jose.SignJWT({ userId: user.id })
      .setProtectedHeader({ alg: 'HS256' })
      .setIssuedAt()
      .setExpirationTime('30d')
      .setSubject(user.id)
      .sign(secret);

    return c.json({
      access_token: sessionToken,
      refresh_token: refreshToken,
      expires_in: 7 * 24 * 60 * 60,  // 7 days in seconds
      user,
    });

  } catch (err) {
    console.error('Auth validation error:', err);
    return c.json({ error: 'Authentication failed' }, 500);
  }
});

/**
 * POST /auth/refresh
 * Refreshes an expired session token using a refresh token
 */
authRoutes.post('/refresh', async (c) => {
  try {
    const body = await c.req.json<{ refresh_token: string }>();
    const { refresh_token } = body;

    if (!refresh_token) {
      return c.json({ error: 'Missing refresh_token' }, 400);
    }

    // Verify refresh token
    const secret = new TextEncoder().encode(env.JWT_SECRET);
    let payload: { userId: string };

    try {
      const { payload: verifiedPayload } = await jose.jwtVerify(refresh_token, secret);
      payload = verifiedPayload as unknown as { userId: string };
    } catch (err) {
      return c.json({ error: 'Invalid or expired refresh token' }, 401);
    }

    // Note: In production, you'd fetch the user from a database
    // For now, we just issue a new token with the same user ID
    const newSessionToken = await new jose.SignJWT({ userId: payload.userId })
      .setProtectedHeader({ alg: 'HS256' })
      .setIssuedAt()
      .setExpirationTime('7d')
      .setSubject(payload.userId)
      .sign(secret);

    return c.json({
      access_token: newSessionToken,
      refresh_token: refresh_token,  // Return same refresh token
      expires_in: 7 * 24 * 60 * 60,
    });

  } catch (err) {
    console.error('Token refresh error:', err);
    return c.json({ error: 'Token refresh failed' }, 500);
  }
});

/**
 * Middleware to verify session token
 */
export async function verifySession(
  authHeader: string | undefined
): Promise<{ valid: boolean; userId?: string; error?: string }> {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return { valid: false, error: 'Missing or invalid Authorization header' };
  }

  const token = authHeader.slice(7);
  const secret = new TextEncoder().encode(env.JWT_SECRET);

  try {
    const { payload } = await jose.jwtVerify(token, secret);
    return { valid: true, userId: payload.sub };
  } catch (err) {
    return { valid: false, error: 'Invalid or expired token' };
  }
}
