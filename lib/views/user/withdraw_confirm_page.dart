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
  double? height,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
  );
}

class WithdrawConfirmPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const WithdrawConfirmPage({super.key, this.extra});

  @override
  State<WithdrawConfirmPage> createState() => _WithdrawConfirmPageState();
}

class _WithdrawConfirmPageState extends State<WithdrawConfirmPage> {
  final wallet = WalletState.instance;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final double amount =
        (widget.extra?['amount'] as num?)?.toDouble() ?? 200000.0;

    // Formatting helper
    final amountStr = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    const Color bgYellow = Color(0xFFEADB3F);
    const Color btnGreen = Color(0xFF82C13E);

    return Scaffold(
      backgroundColor: bgYellow,
      body: Stack(
        children: [
          // 1. Mock background: Represents the Withdraw page (dimmed)
          SafeArea(
            child: Column(
              children: [
                // Mock App Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 24,
                      ),
                      Text(
                        'Withdraw',
                        style: _jakarta(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),

                // Mock Card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo Aktif',
                                style: _jakarta(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Rp 200.000',
                                style: _jakarta(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Lakukan Penarikan',
                                style: _jakarta(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tarik semua',
                                    style: _jakarta(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Switch(
                                    value: false,
                                    onChanged: (_) {},
                                    activeThumbColor: btnGreen,
                                    activeTrackColor: btnGreen.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 24,
                                color: Color(0xFFEEEEEE),
                              ),
                              Text(
                                'Transfer Ke',
                                style: _jakarta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Mock Destination Box
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Dim Overlay
          Container(color: Colors.black.withValues(alpha: 0.35)),

          // 2. Custom Bottom Sheet Content (Withdraw Confirmation)
          Align(
            alignment: Alignment.bottomCenter,
            child:
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Drag Handle
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Nominal Penarikan',
                        style: _jakarta(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Large nominal amount text (green)
                      Text(
                        'Rp $amountStr',
                        style: _jakarta(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: btnGreen,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transfer Ke Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Transfer Ke',
                          style: _jakarta(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Transfer destination row
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1E88E5), // Dana Blue
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${wallet.bankAccount['bank']} - ${wallet.bankAccount['name']}',
                                  style: _jakarta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  wallet.bankAccount['phone'] as String? ??
                                      '0895341381130',
                                  style: _jakarta(
                                    fontSize: 11,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Detail Penarikan Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Detail Penarikan',
                          style: _jakarta(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Bordered Details Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nominal Penarikan',
                                  style: _jakarta(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Rp $amountStr',
                                  style: _jakarta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Biaya Transfer',
                                  style: _jakarta(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Gratis',
                                  style: _jakarta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: btnGreen,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                height: 1,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Diterima',
                                  style: _jakarta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rp $amountStr',
                                  style: _jakarta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                height: 1,
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ID Withdraw',
                                  style: _jakarta(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '5505090 - 001 - 001',
                                  style: _jakarta(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Information banner (blue theme)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBDEFB)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info,
                              color: Color(0xFF1976D2),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Dana paling lambat akan masuk 1 hari setelah penarikan dilakukan. Hubungi bantuan jika ada kendala.',
                                style: _jakarta(
                                  fontSize: 10,
                                  color: const Color(0xFF1976D2),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Withdraw Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  final scaffoldMessenger =
                                      ScaffoldMessenger.of(context);

                                  // Enforce Cooldown Check
                                  if (!wallet.canWithdraw) {
                                    final err =
                                        wallet.getWithdrawalCooldownMessage() ??
                                        'Penarikan gagal: batas cooldown mingguan.';
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          err,
                                          style: _jakarta(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => _isProcessing = true);
                                  final success = await wallet.withdrawBalance(
                                    amount,
                                  );
                                  setState(() => _isProcessing = false);

                                  if (!context.mounted) return;
                                  if (success) {
                                    // Navigate to success verify page
                                    context.push(
                                      '/withdraw/verify',
                                      extra: {'amount': amount},
                                    );
                                  } else {
                                    scaffoldMessenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Penarikan gagal. Saldo aktif tidak mencukupi.',
                                          style: _jakarta(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: btnGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Withdraw',
                                  style: _jakarta(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(
                  begin: 1.0,
                  end: 0.0,
                  duration: 250.ms,
                  curve: Curves.easeOutQuad,
                ),
          ),
        ],
      ),
    );
  }
}
