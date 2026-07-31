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

  final double? distanceMeters;

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
    this.distanceMeters,
  });

  String? get itemType => category;
  double get estWeight => weightKg ?? 0.0;
  String get pickupAddress => address;
  double get pickupLat => lat;
  double get pickupLng => lng;
  String? get notes => null;
  String get statusLabel => status;
  double? get displayWeight => weightKg;
  double? get actualWeight => weightKg;
  double? get totalAmount => totalPrice;
  bool get canCancel => status == 'pending';

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      collectorId: json['collector_id'],
      status: json['status'] ?? 'pending',
      photoUrl: json['photo_url'],
      category: json['category'] ?? json['item_type'],
      weightKg: (json['weight_kg'] ?? json['est_weight']) != null ? double.parse((json['weight_kg'] ?? json['est_weight']).toString()) : null,
      totalPrice: (json['total_price'] ?? json['total_amount']) != null ? double.parse((json['total_price'] ?? json['total_amount']).toString()) : null,
      lat: (json['lat'] ?? json['pickup_lat']) != null ? double.parse((json['lat'] ?? json['pickup_lat']).toString()) : 0.0,
      lng: (json['lng'] ?? json['pickup_lng']) != null ? double.parse((json['lng'] ?? json['pickup_lng']).toString()) : 0.0,
      address: json['address'] ?? json['pickup_address'] ?? '',
      statusHistory: json['status_history'] ?? [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
