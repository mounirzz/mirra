// GET /themes (auth) → all of the caller's saved custom themes.

import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";
import { userId, json } from "./_auth.mjs";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE = process.env.THEMES_TABLE;

export const handler = async (event) => {
  const uid = userId(event);
  if (!uid) return json(401, { error: "unauthorized" });

  const res = await ddb.send(
    new QueryCommand({
      TableName: TABLE,
      KeyConditionExpression: "userId = :u",
      ExpressionAttributeValues: { ":u": uid },
    }),
  );
  return json(200, { themes: res.Items ?? [] });
};
