// POST /themes/upload-url (auth) → returns a short-lived presigned S3 PUT URL
// scoped to the caller's own folder, plus the final public image URL.
// The app PUTs the JPEG bytes to `uploadUrl`, then saves the theme with
// `imageUrl`. Keys live under the public `themes/` prefix so the app can read
// them directly (the object name is a UUID, unguessable).

import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { randomUUID } from "crypto";
import { userId, json } from "./_auth.mjs";

const s3 = new S3Client({});
const BUCKET = process.env.BUCKET;
const REGION = process.env.AWS_REGION;

export const handler = async (event) => {
  const uid = userId(event);
  if (!uid) return json(401, { error: "unauthorized" });

  const key = `themes/users/${uid}/${randomUUID()}.jpg`;
  const cmd = new PutObjectCommand({
    Bucket: BUCKET,
    Key: key,
    ContentType: "image/jpeg",
    CacheControl: "public, max-age=31536000, immutable",
  });
  const uploadUrl = await getSignedUrl(s3, cmd, { expiresIn: 300 });
  const imageUrl = `https://${BUCKET}.s3.${REGION}.amazonaws.com/${key}`;
  return json(200, { uploadUrl, imageUrl });
};
