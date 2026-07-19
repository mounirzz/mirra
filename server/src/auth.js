import { createRemoteJWKSet, jwtVerify } from "jose";

// Verifies Cognito **id tokens** against the pool's public JWKS — no secret, no
// auth rebuild. The app already gets these tokens from the Hosted UI flow.
const region = process.env.AWS_REGION || "us-east-1";
const userPoolId = process.env.COGNITO_USER_POOL_ID;
const clientId = process.env.COGNITO_CLIENT_ID;

const issuer = `https://cognito-idp.${region}.amazonaws.com/${userPoolId}`;
const jwks = createRemoteJWKSet(new URL(`${issuer}/.well-known/jwks.json`));

/** Express middleware: sets req.userId / req.email or replies 401. */
export async function requireAuth(req, res, next) {
  const header = req.headers.authorization || "";
  const token = header.startsWith("Bearer ") ? header.slice(7).trim() : null;
  if (!token) return res.status(401).json({ error: "unauthorized" });
  try {
    const { payload } = await jwtVerify(token, jwks, { issuer, audience: clientId });
    req.userId = payload.sub;
    req.email = typeof payload.email === "string" ? payload.email : null;
    next();
  } catch {
    res.status(401).json({ error: "invalid token" });
  }
}
