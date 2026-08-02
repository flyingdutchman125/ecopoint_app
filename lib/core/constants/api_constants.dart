class ApiConstants {
  // Use live backend server to avoid local networking/credential issues
  static const String baseUrl = 'https://ecopoint-api.fly.dev';
  static const String apiBase = '$baseUrl/api';
  
  // Auth
  static const String login = '$apiBase/login';
  static const String register = '$apiBase/register';
  static const String forgotPassword = '$apiBase/forgot-password';
  
  // User
  static const String order = '$apiBase/order';
  static const String orders = '$apiBase/orders';
  static const String prices = '$apiBase/prices';
  static const String wallet = '$apiBase/wallet';
  static const String walletTopup = '$apiBase/wallet/topup';
  static const String walletWithdraw = '$apiBase/wallet/withdraw';
  static const String transactions = '$apiBase/transactions';
  static const String redeem = '$apiBase/redeem';
  static const String upload = '$apiBase/upload';
  static const String analyzeImage = '$apiBase/analyze-image';
  
  // Collector
  static const String location = '$apiBase/location';
  static const String nearbyOrders = '$apiBase/nearby-orders';
  static const String collectorOrders = '$apiBase/collector/orders';
  static const String earnings = '$apiBase/collector/earnings';
  static const String nearbyCollectors = '$apiBase/map/nearby-collectors';
   
  // Admin
  static const String statistics = '$apiBase/statistics';
  static const String adminUsers = '$apiBase/admin/users';
  static const String adminOrders = '$apiBase/admin/orders';
  static const String scrapePrices = '$apiBase/scrape-prices';
  static const String adminPrice = '$apiBase/price';
  // Profile
  static const String profile = '$apiBase/profile';

  // Auth & Profile Security
  static const String changePassword = '$apiBase/change-password';
  static const String deleteAccount = '$apiBase/account';
  static String deleteMessage(String id) => '$apiBase/message/$id';
  
  // Collector Wallet
  static const String collectorWallet = '$apiBase/collector/wallet';
  
  // Admin
  static const String adminUserBalance = '$apiBase/admin/user/balance';
  static const String adminResetPassword = '$apiBase/admin/reset-password';
  static String adminDeleteUser(String userId) => '$apiBase/admin/user/$userId';
}
