// POST /themes (auth) → persist one of the caller's custom themes.
// Body: { imageUrl, font?, textColor?, dark?, themeId? }.

import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { randomUUID } from "crypto";
import { userId, json } from "./_auth.mjs";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.THEMES_TABLE;

export const handler = async (event) => {
  const uid = userId(event);
  if (!uid) return json(401, { error: "unauthorized" });

  let b;
  try {
    b = JSON.parse(event.body || "{}");
  } catch {
    return json(400, { error: "invalid json" });
  }
  if (!b.imageUrl) return json(400, { error: "imageUrl required" });

  const item = {
    userId: uid,
    themeId: b.themeId || randomUUID(),
    imageUrl: b.imageUrl,
    font: b.font ?? "serif",
    textColor: b.textColor ?? "FFFFFFFF",
    dark: b.dark ?? true,
    createdAt: Date.now(),
  };
  await ddb.send(new PutCommand({ TableName: TABLE, Item: item }));
  return json(200, item);
};
