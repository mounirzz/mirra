// Helpers shared by the theme Lambdas. The HTTP API JWT authorizer puts the
// verified Cognito claims on the event; `sub` is the stable per-user id.

export const userId = (event) =>
  event?.requestContext?.authorizer?.jwt?.claims?.sub ?? null;

export const json = (statusCode, body) => ({
  statusCode,
  headers: { "content-type": "application/json" },
  body: JSON.stringify(body),
});
