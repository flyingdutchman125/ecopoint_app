class OrderModel {
  final String id;
  final String userId;
  final String? collectorId;
  final String status; // pending, accepted, en_route, completed, cancelled
  final String? photoUrl;
  final String? category;
  final double? weightKg;
  final double? totalPrice;
  final double lat;
  final double lng;
  final String address;
  final List<dynamic> statusHistory;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.collectorId,
    required this.status,
    this.photoUrl,
    this.category,
    this.weightKg,
    this.totalPrice,
    required this.lat,
    required this.lng,
    required this.address,
    required this.statusHistory,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      collectorId: json['collector_id'],
      status: json['status'] ?? 'pending',
      photoUrl: json['photo_url'],
      category: json['category'],
      weightKg: json['weight_kg'] != null ? double.parse(json['weight_kg'].toString()) : null,
      totalPrice: json['total_price'] != null ? double.parse(json['total_price'].toString()) : null,
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : 0.0,
      lng: json['lng'] != null ? double.parse(json['lng'].toString()) : 0.0,
      address: json['address'] ?? '',
      statusHistory: json['status_history'] ?? [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
