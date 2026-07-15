class ApiConstants {
  static const String baseUrl = 'https://ecopoint-api.fly.dev/api';
  
  // Auth
  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  
  // User
  static const String order = '$baseUrl/order';
  static const String orders = '$baseUrl/orders';
  static const String prices = '$baseUrl/prices';
  static const String wallet = '$baseUrl/wallet';
  static const String transactions = '$baseUrl/transactions';
  static const String redeem = '$baseUrl/redeem';
  static const String upload = '$baseUrl/upload';
  static const String analyzeImage = '$baseUrl/analyze-image';
  
  // Collector
  static const String location = '$baseUrl/location';
  static const String nearbyOrders = '$baseUrl/nearby-orders';
  static const String collectorOrders = '$baseUrl/collector/orders';
  static const String earnings = '$baseUrl/collector/earnings';
  
  // Admin
  static const String statistics = '$baseUrl/statistics';
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminOrders = '$baseUrl/admin/orders';
  static const String scrapePrices = '$baseUrl/scrape-prices';
  static const String adminPrice = '$baseUrl/price';
  static const String adminUserBalance = '$baseUrl/admin/user/balance';
}
