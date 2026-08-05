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
    String? parseName() {
      if (json['name'] != null) return json['name'].toString();
      final meta = json['user_metadata'];
      if (meta is Map) return meta['name']?.toString();
      return null;
    }

    String parseRole() {
      final roleStr = json['role']?.toString();
      if (roleStr != null &&
          roleStr != 'authenticated' &&
          ['user', 'collector', 'admin'].contains(roleStr.toLowerCase())) {
        return roleStr.toLowerCase();
      }
      final meta = json['user_metadata'];
      if (meta is Map && meta['role'] != null) {
        final metaRole = meta['role'].toString().toLowerCase();
        if (['user', 'collector', 'admin'].contains(metaRole)) {
          return metaRole;
        }
      }
      return 'user';
    }

    double? parseRating() {
      if (json['rating'] != null) {
        return double.tryParse(json['rating'].toString());
      }
      final meta = json['user_metadata'];
      if (meta is Map && meta['rating'] != null) {
        return double.tryParse(meta['rating'].toString());
      }
      return null;
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: parseName(),
      role: parseRole(),
      phone: json['phone']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      subdistrict: json['subdistrict']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      walletBalance: (json['wallet_balance'] != null)
          ? (double.tryParse(json['wallet_balance'].toString()) ?? 0.0)
          : 0.0,
      ecoPoints: (json['eco_points'] != null)
          ? (int.tryParse(json['eco_points'].toString()) ?? 0)
          : 0,
      rating: parseRating(),
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
