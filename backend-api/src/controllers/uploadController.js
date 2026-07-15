const { uploadFile } = require('../services/uploadService');

async function uploadPhoto(req, res, next) {
  try {
    if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });

    const url = await uploadFile(req.file.buffer, req.file.mimetype);
    res.json({ success: true, data: { url } });
  } catch (error) { next(error); }
}

module.exports = { uploadPhoto };
