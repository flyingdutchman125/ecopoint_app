class ApiConstants {
  // For Android emulator, use 10.0.2.2 to reach the host machine.
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String apiBase = '$baseUrl/api';
  
  // Auth
  static const String login = '$apiBase/login';
  static const String register = '$apiBase/register';
  
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
  
  // Admin
  static const String statistics = '$apiBase/statistics';
  static const String adminUsers = '$apiBase/admin/users';
  static const String adminOrders = '$apiBase/admin/orders';
  static const String scrapePrices = '$apiBase/scrape-prices';
  static const String adminPrice = '$apiBase/price';
  static const String adminUserBalance = '$apiBase/admin/user/balance';
}
