import 'package:flutter/material.dart';
import 'notification_state.dart';
import 'history_state.dart';

/// Simple in-memory state for wallet/balance management
/// Tracks: active balance (saldo aktif), points, conversion & withdrawal history
class WalletState {
  WalletState._internal();
  static final WalletState instance = WalletState._internal();

  // Balance & Points
  final ValueNotifier<double> activeBalance = ValueNotifier<double>(
    200000,
  ); // Saldo Aktif
  final ValueNotifier<int> points = ValueNotifier<int>(
    50000,
  ); // Points (increased default to allow testing Rp20.000 tier)

  // Login progress for weekly tiers
  final ValueNotifier<int> loginDaysCount = ValueNotifier<int>(
    1,
  ); // e.g. 1/7 days

  // Weekly convert limits left
  final ValueNotifier<int> limit5k = ValueNotifier<int>(
    1,
  ); // Sisa penarikan Rp 5.000 (1/1)
  final ValueNotifier<int> limit10k = ValueNotifier<int>(
    1,
  ); // Sisa penarikan Rp 10.000 (1/1)
  final ValueNotifier<int> limit20k = ValueNotifier<int>(
    1,
  ); // Sisa penarikan Rp 20.000 (1/1)

  // Last withdrawal date (for weekly cooldown)
  DateTime? lastWithdrawalDate;

  // Conversion & withdrawal history
  final List<Map<String, dynamic>> conversionHistory = [];
  final List<Map<String, dynamic>> withdrawalHistory = [];

  final Map<String, dynamic> bankAccount = {
    'bank': 'Dana',
    'phone': '0895341381130',
    'name': 'Ahmad Syifa\'ul Falakhul Khayyi',
  };

  void setBankAccount({required String bank, required String phone, required String name}) {
    bankAccount['bank'] = bank;
    bankAccount['phone'] = phone;
    bankAccount['name'] = name;
  }

  double get currentBalance => activeBalance.value;
  int get currentPoints => points.value;

  void addPoints(int amount) {
    points.value = (points.value + amount).clamp(0, 99999999);
  }

  bool get canWithdraw {
    if (lastWithdrawalDate == null) return true;
    final now = DateTime.now();
    final diff = now.difference(lastWithdrawalDate!);
    return diff.inDays >= 7;
  }

  /// Reset simulation data to test successful convert & withdraw flows
  void simulateReset() {
    points.value = 50000;
    activeBalance.value = 200000;
    loginDaysCount.value = 7;
    limit5k.value = 1;
    limit10k.value = 1;
    limit20k.value = 1;
    lastWithdrawalDate = null;
  }

  /// Reset to initial demo states
  void resetToDemoState() {
    points.value = 20000;
    activeBalance.value = 200000;
    loginDaysCount.value = 1;
    limit5k.value = 1;
    limit10k.value = 1;
    limit20k.value = 1;
    lastWithdrawalDate = null;
  }

  /// Convert points to balance (2:1 ratio, so points/2 = balance)
  Future<bool> convertPointsToBalance(int pointsToConvert) async {
    if (pointsToConvert <= 0 || pointsToConvert > points.value) return false;

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final balanceGain = (pointsToConvert / 2).toInt();
    points.value = points.value - pointsToConvert;
    activeBalance.value = activeBalance.value + balanceGain;

    // Deduct limit based on nominal
    if (balanceGain == 5000) {
      if (limit5k.value > 0) limit5k.value--;
    } else if (balanceGain == 10000) {
      if (limit10k.value > 0) limit10k.value--;
    } else if (balanceGain == 20000) {
      if (limit20k.value > 0) limit20k.value--;
    }

    conversionHistory.add({
      'timestamp': DateTime.now(),
      'pointsUsed': pointsToConvert,
      'balanceGained': balanceGain,
      'ratioUsed': '2:1',
    });

    NotificationState.instance.addNotification(
      category: 'Convert',
      title: 'Konversi Point Berhasil!',
      subtitle:
          'Kamu berhasil menukar $pointsToConvert Point menjadi Saldo Rp ${balanceGain.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}.',
    );

    HistoryState.instance.addHistory(
      title: 'Tukar Point ke Saldo',
      description:
          'Menukar $pointsToConvert Point menjadi Saldo Rp ${balanceGain.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
      category: 'Tukar Point',
      valueChange:
          '+Rp ${balanceGain.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
    );

    return true;
  }

  /// Withdraw from active balance to bank account
  Future<bool> withdrawBalance(double amount) async {
    if (amount <= 0 || amount > activeBalance.value || amount < 10000)
      return false;
    if (!canWithdraw) return false;

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    activeBalance.value = activeBalance.value - amount;
    lastWithdrawalDate = DateTime.now();

    withdrawalHistory.add({
      'timestamp': DateTime.now(),
      'amount': amount,
      'bank': bankAccount['bank'],
      'status': 'pending',
      'id': 'WD${DateTime.now().millisecondsSinceEpoch}',
    });

    NotificationState.instance.addNotification(
      category: 'Withdraw',
      title: 'Penarikan Saldo Berhasil!',
      subtitle:
          'Penarikan Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ke akun ${bankAccount['bank']} berhasil diproses.',
    );

    HistoryState.instance.addHistory(
      title: 'Penarikan Saldo',
      description:
          'Penarikan Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ke rekening ${bankAccount['bank']} (${bankAccount['phone']})',
      category: 'Withdraw',
      valueChange:
          '-Rp ${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
    );

    return true;
  }

  String? getWithdrawalCooldownMessage() {
    if (canWithdraw) return null;
    if (lastWithdrawalDate == null) return null;
    final now = DateTime.now();
    final diff = now.difference(lastWithdrawalDate!);
    final daysLeft = 7 - diff.inDays;
    return 'Withdrawal tersedia dalam $daysLeft hari lagi';
  }
}
