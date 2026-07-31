class CurrencyFormatter {
  static String formatRupiah(dynamic amount) {
    double value = 0;
    if (amount is double) {
      value = amount;
    } else if (amount is int) {
      value = amount.toDouble();
    } else if (amount != null) {
      value = double.tryParse(amount.toString()) ?? 0;
    }

    // Format with dot separator for thousands
    final parts = value.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    int count = 0;
    for (int i = parts.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(parts[i]);
      count++;
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  static String formatWeight(dynamic weight) {
    if (weight == null) return '-';
    double value = 0;
    if (weight is double) {
      value = weight;
    } else if (weight is int) {
      value = weight.toDouble();
    } else {
      value = double.tryParse(weight.toString()) ?? 0;
    }
    if (value == value.truncateToDouble()) {
      return '${value.toInt()} kg';
    }
    return '${value.toStringAsFixed(1)} kg';
  }

  static String formatDistance(double? meters) {
    if (meters == null) return '-';
    if (meters < 1000) {
      return '${meters.toInt()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}
