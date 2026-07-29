const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const crypto = require('crypto');
const path = require('path');
const fs = require('fs');

let s3 = null;
const hasS3 = process.env.S3_ENDPOINT && process.env.S3_ACCESS_KEY_ID && process.env.S3_SECRET_ACCESS_KEY && process.env.S3_BUCKET;

if (hasS3) {
  s3 = new S3Client({
    endpoint: process.env.S3_ENDPOINT,
    region: process.env.S3_REGION,
    credentials: {
      accessKeyId: process.env.S3_ACCESS_KEY_ID,
      secretAccessKey: process.env.S3_SECRET_ACCESS_KEY
    },
    forcePathStyle: true
  });
}

const BUCKET = process.env.S3_BUCKET;
const PUBLIC_URL = BUCKET ? `https://ornflvmefieggnezxeza.storage.supabase.co/storage/v1/object/public/${BUCKET}` : '';

function getExt(mime) {
  const map = { 'image/jpeg': '.jpg', 'image/png': '.png', 'image/webp': '.webp', 'image/gif': '.gif' };
  return map[mime] || '.jpg';
}

async function uploadFile(buffer, mimeType, req = null) {
  const ext = getExt(mimeType);
  const filename = `${crypto.randomUUID()}${ext}`;

  if (!hasS3) {
    const localPath = path.join(__dirname, '..', '..', 'uploads', filename);
    fs.writeFileSync(localPath, buffer);
    const host = req ? req.get('host') : `localhost:${process.env.PORT || 3000}`;
    const protocol = req ? (req.get('x-forwarded-proto') || req.protocol) : 'http';
    return `${protocol}://${host}/uploads/${filename}`;
  }

  const key = `uploads/${filename}`;

  await s3.send(new PutObjectCommand({
    Bucket: BUCKET,
    Key: key,
    Body: buffer,
    ContentType: mimeType,
    ACL: 'public-read'
  }));

  return `${PUBLIC_URL}/${key}`;
}

module.exports = { uploadFile };
