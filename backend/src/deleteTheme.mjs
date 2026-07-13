// DELETE /themes/{themeId} (auth) → remove one of the caller's saved themes.

import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, DeleteCommand } from "@aws-sdk/lib-dynamodb";
import { userId, json } from "./_auth.mjs";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.THEMES_TABLE;

export const handler = async (event) => {
  const uid = userId(event);
  if (!uid) return json(401, { error: "unauthorized" });

  const themeId = event.pathParameters?.themeId;
  if (!themeId) return json(400, { error: "themeId required" });

  await ddb.send(
    new DeleteCommand({ TableName: TABLE, Key: { userId: uid, themeId } }),
  );
  return json(200, { ok: true });
};
