class PriceModel {
  final int id;
  final String itemName;
  final double currentPrice;
  final String unit;
  final DateTime? lastUpdated;
  final double? change;
  final double? changePercent;
  final String? trend;

  PriceModel({
    required this.id,
    required this.itemName,
    required this.currentPrice,
    required this.unit,
    this.lastUpdated,
    this.change,
    this.changePercent,
    this.trend,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      itemName: json['item_name']?.toString() ?? '',
      currentPrice: _parseDouble(json['current_price']),
      unit: json['unit']?.toString() ?? 'kg',
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString())
          : null,
      change: _parseDoubleNullable(json['change']),
      changePercent: _parseDoubleNullable(json['change_percent']),
      trend: json['trend']?.toString(),
    );
  }

  bool get isTrendUp => trend == 'up';
  bool get isTrendDown => trend == 'down';

  String get iconForType {
    switch (itemName.toLowerCase()) {
      case 'pet plastic':
        return '♻️';
      case 'cardboard':
        return '📦';
      case 'metal':
        return '🔩';
      case 'cooking oil':
        return '🛢️';
      default:
        return '🗑️';
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
