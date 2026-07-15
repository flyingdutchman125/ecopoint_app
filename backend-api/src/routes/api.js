const express = require('express');
const multer = require('multer');
const router = express.Router();
const { auth, role } = require('../middleware/auth');
const authCtrl = require('../controllers/authController');
const userCtrl = require('../controllers/userController');
const collectorCtrl = require('../controllers/collectorController');
const adminCtrl = require('../controllers/adminController');
const uploadCtrl = require('../controllers/uploadController');
const mobileCtrl = require('../controllers/mobileFeaturesController');

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } });

router.post('/login', authCtrl.login);
router.post('/register', authCtrl.register);
router.post('/forgot-password', authCtrl.forgotPassword);
router.post('/analyze-image', userCtrl.analyzeImage);
router.post('/upload', auth, upload.single('photo'), uploadCtrl.uploadPhoto);

// Profile & Addresses
router.put('/profile', auth, mobileCtrl.updateProfile);
router.get('/addresses', auth, mobileCtrl.getAddresses);
router.post('/addresses', auth, mobileCtrl.addAddress);
router.delete('/addresses/:id', auth, mobileCtrl.deleteAddress);

router.get('/prices', auth, role('user'), userCtrl.getPrices);

router.post('/order', auth, role('user'), userCtrl.createOrder);
router.get('/orders', auth, role('user'), userCtrl.getUserOrders);
router.get('/order/:id', auth, role('user'), userCtrl.getOrderById);
router.put('/order/:id/cancel', auth, role('user'), userCtrl.cancelOrder);
router.get('/wallet', auth, role('user'), userCtrl.getWallet);
router.get('/transactions', auth, role('user'), userCtrl.getTransactions);
router.post('/redeem', auth, role('user'), userCtrl.redeemCoins);

// Wallet (Topup & Withdraw)
router.post('/wallet/topup', auth, mobileCtrl.requestTopup);
router.post('/wallet/withdraw', auth, mobileCtrl.requestWithdrawal);

// Chat & Review (For both User & Collector)
router.post('/order/:id/messages', auth, mobileCtrl.sendMessage);
router.get('/order/:id/messages', auth, mobileCtrl.getMessages);
router.post('/order/:id/review', auth, mobileCtrl.addReview);

router.put('/location', auth, role('collector'), collectorCtrl.updateLocation);
router.get('/nearby-orders', auth, role('collector'), collectorCtrl.getNearbyOrders);
router.post('/order/:id/accept', auth, role('collector'), collectorCtrl.acceptOrder);
router.put('/order/:id/en-route', auth, role('collector'), collectorCtrl.startEnRoute);
router.get('/order/:id/route', auth, role('collector'), collectorCtrl.getOrderRoute);
router.post('/order/:id/pay', auth, role('collector'), collectorCtrl.completeOrderWithPayment);
router.get('/collector/orders', auth, role('collector'), collectorCtrl.getCollectorOrders);
router.get('/collector/earnings', auth, role('collector'), collectorCtrl.getEarnings);

router.post('/scrape-prices', auth, role('admin'), adminCtrl.scrapePrices);
router.post('/price', auth, role('admin'), adminCtrl.updatePrice);
router.get('/statistics', auth, role('admin'), adminCtrl.getStatistics);
router.get('/admin/users', auth, role('admin'), adminCtrl.getAllUsers);
router.get('/admin/orders', auth, role('admin'), adminCtrl.getAllOrders);
router.post('/admin/user/balance', auth, role('admin'), adminCtrl.updateUserBalance);

module.exports = router;
