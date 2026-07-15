const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

router.get('/pending-collectors', adminController.getPendingCollectors);
router.put('/verify-collector/:id', adminController.verifyCollector);

module.exports = router;
