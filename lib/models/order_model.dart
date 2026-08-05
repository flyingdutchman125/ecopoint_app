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
  final String? userName;

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
    this.userName,
  });

  String? get itemType => category;
  double get estWeight => weightKg ?? 0.0;
  String get pickupAddress => address;
  double get pickupLat => lat;
  double get pickupLng => lng;
  double get latitude => lat;
  double get longitude => lng;
  String? get notes => null;
  String get statusLabel => status;
  double? get displayWeight => weightKg;
  double? get actualWeight => weightKg;
  double? get totalAmount => totalPrice;
  bool get canCancel => status == 'pending';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'collector_id': collectorId,
      'status': status,
      'photo_url': photoUrl,
      'category': category,
      'weight_kg': weightKg,
      'total_price': totalPrice,
      'lat': lat,
      'lng': lng,
      'address': address,
      'status_history': statusHistory,
      'created_at': createdAt.toIso8601String(),
      'distance_meters': distanceMeters,
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    String? parseUserName() {
      if (json['user_name'] != null) return json['user_name'].toString();
      final u = json['user'];
      if (u is Map) return u['name']?.toString();
      if (u is List && u.isNotEmpty && u.first is Map) return u.first['name']?.toString();
      return null;
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      collectorId: json['collector_id']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      photoUrl: json['photo_url']?.toString(),
      category: _translateToIndonesian(json['category'] ?? json['item_type']),
      weightKg: (json['weight_kg'] ?? json['est_weight']) != null
          ? double.tryParse((json['weight_kg'] ?? json['est_weight']).toString())
          : null,
      totalPrice: (json['total_price'] ?? json['total_amount']) != null
          ? double.tryParse(
              (json['total_price'] ?? json['total_amount']).toString(),
            )
          : null,
      lat: (json['lat'] ?? json['pickup_lat']) != null
          ? double.tryParse((json['lat'] ?? json['pickup_lat']).toString()) ?? 0.0
          : 0.0,
      lng: (json['lng'] ?? json['pickup_lng']) != null
          ? double.tryParse((json['lng'] ?? json['pickup_lng']).toString()) ?? 0.0
          : 0.0,
      address: json['address']?.toString() ?? json['pickup_address']?.toString() ?? '',
      statusHistory: json['status_history'] is List ? json['status_history'] : [],
      createdAt: DateTime.tryParse(
            json['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
      userName: parseUserName(),
    );
  }

  static String? _translateToIndonesian(dynamic val) {
    if (val == null) return null;
    final s = val.toString().toLowerCase().trim();
    if (s == 'metal') return 'Logam/Besi';
    if (s == 'pet plastic') return 'Botol Plastik';
    if (s == 'cardboard') return 'Kardus';
    if (s == 'cooking oil') return 'Minyak Jelantah';
    return val.toString();
  }
}
