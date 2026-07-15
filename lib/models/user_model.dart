class UserModel {
  final String id;
  final String email;
  final String? name;
  final String role; // 'user', 'collector', 'admin'
  final String? phone;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    this.phone,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['user_metadata']?['name'] ?? json['name'],
      role: json['user_metadata']?['role'] ?? json['role'] ?? 'user',
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'avatar_url': avatarUrl,
    };
  }
}
