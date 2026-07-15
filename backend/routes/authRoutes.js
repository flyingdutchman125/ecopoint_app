const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const authController = require('../controllers/authController');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});
const upload = multer({ storage: storage });

router.post('/register/user', authController.registerUser);
router.post('/register/collector', upload.single('ktp_photo'), authController.registerCollector);
router.post('/login', authController.login);

module.exports = router;
