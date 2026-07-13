#!/usr/bin/env bash
# Uploads the bundled theme photos (scripts/theme_sources/bg*.jpg) to a public S3 bucket
# and prints the public base URL to wire into the app.
#
# Prereqs: `aws configure` already done (keys + region).
# Usage:   BUCKET=my-bucket REGION=eu-west-3 ./scripts/upload_themes_s3.sh
set -euo pipefail

: "${BUCKET:?set BUCKET=your-bucket-name}"
: "${REGION:?set REGION=your-region e.g. eu-west-3}"
SRC="$(cd "$(dirname "$0")/.." && pwd)/scripts/theme_sources"

echo "→ Creating bucket $BUCKET in $REGION (ok if it already exists)…"
aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null || true

echo "→ Allowing public read…"
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false

aws s3api put-bucket-policy --bucket "$BUCKET" --policy "{
  \"Version\": \"2012-10-17\",
  \"Statement\": [{
    \"Sid\": \"PublicReadThemes\",
    \"Effect\": \"Allow\",
    \"Principal\": \"*\",
    \"Action\": \"s3:GetObject\",
    \"Resource\": \"arn:aws:s3:::$BUCKET/themes/*\"
  }]
}"

echo "→ Uploading images (long cache, image/jpeg)…"
aws s3 sync "$SRC" "s3://$BUCKET/themes/" \
  --content-type image/jpeg \
  --cache-control "public, max-age=31536000, immutable" \
  --exclude "*" --include "bg*.jpg"

echo ""
echo "✅ Done. Public base URL:"
echo "   https://$BUCKET.s3.$REGION.amazonaws.com/themes"
