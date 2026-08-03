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

  /// Primary Key ID Format Rule:
  /// - User Warga: Identik dengan awalan '550' (contoh: 5505090)
  /// - User Kolektor: Identik dengan awalan '000' (contoh: 0005090)
  String get formattedId {
    if (id.isEmpty) {
      return role.toLowerCase() == 'collector' ? '0005090' : '5505090';
    }
    String numPart = id.replaceAll(RegExp(r'[^0-9]'), '');
    if (numPart.length < 4) {
      int hash = 0;
      for (int i = 0; i < id.length; i++) {
        hash = (hash * 31 + id.codeUnitAt(i)) % 10000;
      }
      numPart = hash.toString().padLeft(4, '0');
    } else {
      numPart = numPart.substring(numPart.length - 4);
    }

    final prefix = role.toLowerCase() == 'collector' ? '000' : '550';
    return '$prefix$numPart';
  }

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
      rating:
          (json['rating'] as num?)?.toDouble() ??
          (json['user_metadata']?['rating'] as num?)?.toDouble(),
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
      'wallet_balance': walletBalance,
      'eco_points': ecoPoints,
      'rating': rating,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? phone,
    String? city,
    String? address,
    String? subdistrict,
    String? avatarUrl,
    double? walletBalance,
    int? ecoPoints,
    double? rating,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      address: address ?? this.address,
      subdistrict: subdistrict ?? this.subdistrict,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      ecoPoints: ecoPoints ?? this.ecoPoints,
      rating: rating ?? this.rating,
    );
  }
}
