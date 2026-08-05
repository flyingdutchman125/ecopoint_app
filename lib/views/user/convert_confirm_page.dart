import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/wallet_state.dart';
import '../../core/utils/alert_helper.dart';

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

class ConvertConfirmPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const ConvertConfirmPage({super.key, this.extra});

  @override
  State<ConvertConfirmPage> createState() => _ConvertConfirmPageState();
}

class _ConvertConfirmPageState extends State<ConvertConfirmPage> {
  final wallet = WalletState.instance;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final points = widget.extra?['points'] as int? ?? 20000;
    final balance = widget.extra?['balance'] as int? ?? 10000;

    // Formatting helpers
    final pointsStr = points.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    final balanceStr = balance.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );

    // Theme Colors
    const Color bgYellow = Color(0xFFEADB3F);

    return Scaffold(
      backgroundColor: bgYellow,
      body: Stack(
        children: [
          // 1. Mock background: Represents the Convert page (dimmed)
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
                        'Convert',
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
                                'Ubah Points anda menjadi saldo rekening..',
                                style: _jakarta(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '2 : 1',
                                    style: _jakarta(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '20.000 Pts = Rp10,000',
                                    style: _jakarta(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Pilih tingkatan penarikan',
                                style: _jakarta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Three mock items
                              _mockTierRow('Rp 5.000', 'Sisa Penarikan 0/1'),
                              _mockTierRow(
                                'Rp 10.000',
                                'Login Selama 1 Minggu 1/7',
                              ),
                              _mockTierRow(
                                'Rp 20.000',
                                'Login Selama 1 Minggu 1/7',
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: double.infinity,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: bgYellow.withValues(alpha: 0.5),
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

          // 2. Custom Bottom Sheet Content
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
                        'Nominal Penukaran',
                        style: _jakarta(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Points -> Balance Visual Representation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$pointsStr Pts',
                            style: _jakarta(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE5C118),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.black38,
                              size: 24,
                            ),
                          ),
                          Text(
                            'Rp $balanceStr',
                            style: _jakarta(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Detail Penukaran Heading
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Detail Penukaran',
                          style: _jakarta(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Detailed Box (Bordered)
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
                                  'Nominal Penukaran',
                                  style: _jakarta(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Rp $balanceStr',
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
                                  'Biaya Penukaran',
                                  style: _jakarta(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  'Gratis 1/2',
                                  style: _jakarta(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF4CAF50),
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
                                  'Rp $balanceStr',
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
                                  '5505090 - 001 - 002',
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
                      const SizedBox(height: 24),

                      // Convert Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing
                              ? null
                              : () async {
                                  final goRouter = GoRouter.of(context);

                                  setState(() => _isProcessing = true);
                                  final success = await wallet
                                      .convertPointsToBalance(points);
                                  setState(() => _isProcessing = false);

                                  if (!context.mounted) return;
                                  if (success) {
                                    AppAlerts.showSuccess(context, 'Konversi poin berhasil! Rp $balanceStr ditambahkan ke saldo aktif Anda.');
                                    Future.delayed(const Duration(milliseconds: 1500), () {
                                      if (context.mounted) {
                                        goRouter.pop(); // Close confirm bottom sheet
                                        goRouter.pop(); // Back to Points/Dashboard page
                                      }
                                    });
                                  } else {
                                    AppAlerts.showError(context, 'Konversi gagal. Saldo Poin tidak mencukupi.');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bgYellow,
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
                                  'Convert',
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

  Widget _mockTierRow(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _jakarta(fontSize: 13, color: Colors.black38)),
          Text(subtitle, style: _jakarta(fontSize: 10, color: Colors.black38)),
        ],
      ),
    );
  }
}
