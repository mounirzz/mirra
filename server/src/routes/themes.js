import { Router } from "express";
import { randomUUID } from "node:crypto";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";
import { ensureUser, query } from "../db.js";

export const themesRouter = Router();

const REGION = process.env.AWS_REGION || "us-east-1";
const BUCKET = process.env.S3_BUCKET;
const s3 = new S3Client({ region: REGION });

const SELECT =
  `id AS "themeId", image_url AS "imageUrl", font, text_color AS "textColor", dark`;

// Presigned S3 PUT scoped to the caller's folder (image stays on S3; metadata
// is saved via POST /themes below).
themesRouter.post("/upload-url", async (req, res) => {
  const key = `themes/users/${req.userId}/${randomUUID()}.jpg`;
  const uploadUrl = await getSignedUrl(
    s3,
    new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      ContentType: "image/jpeg",
      CacheControl: "public, max-age=31536000, immutable",
    }),
    { expiresIn: 300 },
  );
  res.json({ uploadUrl, imageUrl: `https://${BUCKET}.s3.${REGION}.amazonaws.com/${key}` });
});

themesRouter.get("/", async (req, res) => {
  const r = await query(
    `SELECT ${SELECT} FROM themes WHERE user_id = $1 ORDER BY created_at DESC`,
    [req.userId],
  );
  res.json({ themes: r.rows });
});

themesRouter.post("/", async (req, res) => {
  await ensureUser(req.userId, req.email);
  const b = req.body ?? {};
  if (!b.imageUrl) return res.status(400).json({ error: "imageUrl required" });
  const r = await query(
    `INSERT INTO themes (user_id, image_url, font, text_color, dark)
     VALUES ($1,$2,$3,$4,$5) RETURNING ${SELECT}`,
    [req.userId, b.imageUrl, b.font ?? "serif", b.textColor ?? "FFFFFFFF", b.dark ?? true],
  );
  res.json(r.rows[0]);
});

themesRouter.delete("/:themeId", async (req, res) => {
  await query("DELETE FROM themes WHERE user_id = $1 AND id = $2", [req.userId, req.params.themeId]);
  res.json({ ok: true });
});
