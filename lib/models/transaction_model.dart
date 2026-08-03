class TransactionModel {
  final String id;
  final String? orderId;
  final String? senderId;
  final String? receiverId;
  final double amount;
  final String type;
  final String? description;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    this.orderId,
    this.senderId,
    this.receiverId,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString(),
      senderId: json['sender_id']?.toString(),
      receiverId: json['receiver_id']?.toString(),
      amount: _parseDouble(json['amount']),
      type: json['type']?.toString() ?? 'payment',
      description: json['description']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  bool get isIncome => type == 'payment' || type == 'topup' || type == 'redeem';

  String get typeLabel {
    switch (type) {
      case 'payment':
        return 'Pembayaran';
      case 'topup':
        return 'Top Up';
      case 'redeem':
        return 'Tukar Poin';
      case 'withdraw':
        return 'Penarikan';
      default:
        return type;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
