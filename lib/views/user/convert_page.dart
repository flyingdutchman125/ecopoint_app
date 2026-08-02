import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  final wallet = WalletState.instance;
  int? _selectedPoints;
  int? _selectedBalance;

  final conversionOptions = [
    {'points': 10000, 'balance': 5000, 'label': 'Rp 5.000'},
    {'points': 20000, 'balance': 10000, 'label': 'Rp 10.000'},
    {'points': 40000, 'balance': 20000, 'label': 'Rp 20.000'},
  ];

  @override
  Widget build(BuildContext context) {
    // Exact yellow background Color from design
    const Color bgYellow = Color(0xFFEADB3F);

    return Scaffold(
      backgroundColor: bgYellow,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Convert',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
                  children: [
                    // Main White Container Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubah Points anda menjadi saldo rekening..',
                            style: _jakarta(fontSize: 12, color: Colors.black54),
                          ),
                          const SizedBox(height: 16),
                          
                          // Conversion Ratio Display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '2 : 1',
                                style: _jakarta(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              ListenableBuilder(
                                listenable: Listenable.merge([wallet.points]),
                                builder: (context, _) {
                                  final pts = wallet.points.value;
                                  final converted = (pts / 2).toInt();
                                  final ptsStr = pts.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
                                  final convStr = converted.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
                                  return Text(
                                    '$ptsStr Pts = Rp$convStr',
                                    style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold),
                                  );
                                },
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'Pilih tingkatan penarikan',
                            style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          
                          // Tiers List
                          ListenableBuilder(
                            listenable: Listenable.merge([wallet.points, wallet.loginDaysCount, wallet.limit5k, wallet.limit10k, wallet.limit20k]),
                            builder: (context, _) {
                              return Column(
                                children: conversionOptions.map((opt) {
                                  final pointsNeeded = opt['points'] as int;
                                  final balanceVal = opt['balance'] as int;
                                  final isSelected = _selectedPoints == pointsNeeded;
                                  
                                  // Determine status message and if locked
                                  String statusText = '';
                                  bool isLocked = false;
                                  
                                  if (balanceVal == 5000) {
                                    final limit = wallet.limit5k.value;
                                    statusText = 'Sisa Penarikan $limit/1';
                                    isLocked = limit <= 0;
                                  } else if (balanceVal == 10000) {
                                    final logDays = wallet.loginDaysCount.value;
                                    if (logDays < 7) {
                                      statusText = 'Login Selama 1 Minggu $logDays/7';
                                      isLocked = true;
                                    } else {
                                      final limit = wallet.limit10k.value;
                                      statusText = 'Sisa Penarikan $limit/1';
                                      isLocked = limit <= 0;
                                    }
                                  } else if (balanceVal == 20000) {
                                    final logDays = wallet.loginDaysCount.value;
                                    if (logDays < 7) {
                                      statusText = 'Login Selama 1 Minggu $logDays/7';
                                      isLocked = true;
                                    } else {
                                      final limit = wallet.limit20k.value;
                                      statusText = 'Sisa Penarikan $limit/1';
                                      isLocked = limit <= 0;
                                    }
                                  }

                                  // Also lock if points are insufficient
                                  final hasEnoughPoints = wallet.points.value >= pointsNeeded;
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      onTap: () {
                                        if (isLocked) {
                                          String reason = '';
                                          final logDays = wallet.loginDaysCount.value;
                                          if (balanceVal == 5000) {
                                            reason = 'Batas penarikan mingguan untuk nominal ini sudah habis (0/1).';
                                          } else {
                                            if (logDays < 7) {
                                              reason = 'Nominal ini terkunci. Anda harus login selama 7 hari (saat ini $logDays/7) untuk membukanya.';
                                            } else {
                                              reason = 'Batas penarikan mingguan untuk nominal ini sudah habis (0/1).';
                                            }
                                          }
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(reason, style: _jakarta(color: Colors.white)), backgroundColor: Colors.red),
                                          );
                                          return;
                                        }
                                        if (!hasEnoughPoints) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Poin Anda tidak cukup (butuh $pointsNeeded Pts).', style: _jakarta(color: Colors.white)), backgroundColor: Colors.red),
                                          );
                                          return;
                                        }
                                        setState(() {
                                          _selectedPoints = pointsNeeded;
                                          _selectedBalance = balanceVal;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                        decoration: BoxDecoration(
                                          color: isLocked ? const Color(0xFFF3F3F3) : Colors.white,
                                          border: Border.all(
                                            color: isSelected 
                                                ? bgYellow 
                                                : isLocked 
                                                    ? Colors.transparent 
                                                    : const Color(0xFFE5E5E5),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              opt['label'] as String,
                                              style: _jakarta(
                                                fontSize: 14, 
                                                fontWeight: FontWeight.bold,
                                                color: isLocked ? Colors.black38 : Colors.black87,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  statusText,
                                                  style: _jakarta(
                                                    fontSize: 10,
                                                    color: isLocked ? Colors.black38 : Colors.black45,
                                                  ),
                                                ),
                                                if (isLocked) ...[
                                                  const SizedBox(width: 6),
                                                  const Icon(Icons.lock, size: 12, color: Colors.black38),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Withdraw Button (inside the card)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _selectedPoints == null
                                  ? null
                                  : () {
                                      context.push('/convert/confirm', extra: {
                                        'points': _selectedPoints,
                                        'balance': _selectedBalance,
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: bgYellow,
                                disabledBackgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Lanjut',
                                style: _jakarta(
                                  fontWeight: FontWeight.bold,
                                  color: _selectedPoints == null ? Colors.black26 : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
      ),
    );
  }
}
