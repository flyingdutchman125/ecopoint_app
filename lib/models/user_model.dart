class UserModel {
  final String id;
  final String email;
  final String? name;
  final String role; // 'user', 'collector', 'admin'
  final String? phone;
  final String? city;
  final String? address;
  final String? subdistrict;
  final String? avatarUrl;
  final double walletBalance;
  final int ecoPoints;
  final double? rating;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.phone,
    this.city,
    this.address,
    this.subdistrict,
    this.avatarUrl,
    this.walletBalance = 0.0,
    this.ecoPoints = 0,
    this.rating,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['user_metadata']?['name'] ?? json['name'],
      role: json['user_metadata']?['role'] ?? json['role'] ?? 'user',
      phone: json['phone'],
      city: json['city'],
      address: json['address'],
      subdistrict: json['subdistrict'],
      avatarUrl: json['avatar_url'],
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      ecoPoints: (json['eco_points'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? (json['user_metadata']?['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'city': city,
      'address': address,
      'subdistrict': subdistrict,
      'avatar_url': avatarUrl,
      'rating': rating,
    };
  }
}
