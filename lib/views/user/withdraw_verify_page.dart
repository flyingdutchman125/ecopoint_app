import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/wallet_state.dart';

TextStyle _jakarta({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = Colors.black,
  FontStyle? fontStyle,
  double? letterSpacing,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
  );
}

class WithdrawVerifyPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const WithdrawVerifyPage({super.key, this.extra});

  @override
  State<WithdrawVerifyPage> createState() => _WithdrawVerifyPageState();
}

class _WithdrawVerifyPageState extends State<WithdrawVerifyPage> {
  final wallet = WalletState.instance;

  @override
  Widget build(BuildContext context) {
    final double amount =
        (widget.extra?['amount'] as num?)?.toDouble() ?? 200000.0;

    // Formatting helper
    final amountStr = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    // Create a mock/real transaction ID and timestamp
    final transactionId =
        'WD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final timestamp = DateTime.now();
    final formattedTime =
        '${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    const Color bgYellow = Color(0xFFEADB3F);
    const Color successGreen = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: bgYellow,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Main Success Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Animated Green Success Tick Icon
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: successGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: successGreen,
                            size: 48,
                          ),
                        ),
                      ).animate().scale(
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Penarikan Diproses',
                        style: _jakarta(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ).animate().fade(delay: 200.ms),

                      const SizedBox(height: 6),

                      Text(
                        'Dana akan ditransfer dalam waktu 1 hari kerja',
                        textAlign: TextAlign.center,
                        style: _jakarta(fontSize: 11, color: Colors.black45),
                      ).animate().fade(delay: 300.ms),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),

                      // nominal text
                      Text(
                        'Total Penarikan',
                        style: _jakarta(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp $amountStr',
                        style: _jakarta(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: successGreen,
                        ),
                      ).animate().fade(delay: 450.ms).scale(),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),

                      // Transaction Detail rows
                      _detailRow('ID Transaksi', transactionId),
                      const SizedBox(height: 12),
                      _detailRow('Waktu', formattedTime),
                      const SizedBox(height: 12),
                      _detailRow(
                        'Metode Transfer',
                        'DANA (${wallet.bankAccount['phone']})',
                      ),
                      const SizedBox(height: 12),
                      _detailRow(
                        'Penerima',
                        wallet.bankAccount['name'] as String? ??
                            'Ahmad Syifa\'ul',
                      ),
                    ],
                  ),
                ).animate().fade(duration: 350.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                // 2. Done / Back to Home Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to the home dashboard
                      context.go('/user');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Text(
                      'Kembali ke Beranda',
                      style: _jakarta(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ).animate().fade(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _jakarta(fontSize: 12, color: Colors.black54)),
        Text(
          value,
          style: _jakarta(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
