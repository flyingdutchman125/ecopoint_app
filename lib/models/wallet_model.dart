class WalletModel {
  final double balance;
  final int ecoPoints;

  WalletModel({
    required this.balance,
    required this.ecoPoints,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: json['balance'] != null ? double.parse(json['balance'].toString()) : 0.0,
      ecoPoints: json['eco_points'] ?? 0,
    );
  }
}
