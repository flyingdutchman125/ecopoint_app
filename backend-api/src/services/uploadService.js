const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const crypto = require('crypto');

const s3 = new S3Client({
  endpoint: process.env.S3_ENDPOINT,
  region: process.env.S3_REGION,
  credentials: {
    accessKeyId: process.env.S3_ACCESS_KEY_ID,
    secretAccessKey: process.env.S3_SECRET_ACCESS_KEY
  },
  forcePathStyle: true
});

const BUCKET = process.env.S3_BUCKET;
const PUBLIC_URL = `https://ornflvmefieggnezxeza.storage.supabase.co/storage/v1/object/public/${BUCKET}`;

function getExt(mime) {
  const map = { 'image/jpeg': '.jpg', 'image/png': '.png', 'image/webp': '.webp', 'image/gif': '.gif' };
  return map[mime] || '.jpg';
}

async function uploadFile(buffer, mimeType) {
  const ext = getExt(mimeType);
  const key = `uploads/${crypto.randomUUID()}${ext}`;

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
