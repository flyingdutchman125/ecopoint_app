import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

// Menyelaraskan fungsi font dengan yang ada di User Dashboard & Store
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

class PointsPage extends StatefulWidget {
  const PointsPage({Key? key}) : super(key: key);

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  // --- Dummy State untuk Progress Data ---
  bool _isCheckedInToday = false;
  
  final int _currentDailyScan = 1; 
  final int _targetDailyScan = 1;

  final double _currentWeight = 2.5; 
  final double _targetWeight = 5.0;  

  final int _currentCategories = 1;  
  final int _targetCategories = 3;   

  final int _currentTransactions = 0; 
  final int _targetTransactions = 2;  

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna dasar hijau gelap khas dashboard utama
    const Color primaryGreen = Color(0xFF358C16); 

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Misi & Points',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER MISI HARIAN ---
            Text(
              'Misi Harian',
              style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),

            // PANEL GREEN MISI HARIAN (Mengikuti tema warna utama dashboard)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryGreen, 
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selesaikan Berbagai misi untuk mendapatkan Points dan tukarkan dengan berbagai hadiah di store',
                    style: _jakarta(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 16),

                  // CARD 1: DAILY CHECK IN
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Misi: Langkah Awal Hijau (Daily Check-in)',
                              style: _jakarta(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _isCheckedInToday ? '3/6 Hari' : '2/6 Hari',
                              style: _jakarta(fontSize: 11, fontWeight: FontWeight.bold, color: primaryGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCheckInBox("Hari 1", "70", isDone: true),
                              _buildCheckInBox("Hari 2", "80", isDone: true),
                              _buildCheckInBox("Hari 3", "90", isActive: !_isCheckedInToday, isDone: _isCheckedInToday),
                              _buildCheckInBox("Hari 4", "Random", isRandom: true),
                              _buildCheckInBox("Hari 5", "70"),
                              _buildCheckInBox("Hari 6", "80"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isCheckedInToday ? null : () async {
                              setState(() {
                                _isCheckedInToday = true;
                              });
                              await context.read<UserProvider>().redeemPoints(1000);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Check-in Berhasil! Poin harian telah ditambahkan dan dikonversi.'),
                                    backgroundColor: primaryGreen,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: Text(
                              _isCheckedInToday ? 'Sudah Check-in Hari Ini' : 'Check in Hari ini !',
                              style: _jakarta(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // CARD 2: DETEKTIF SAMPAH
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Misi: Detektif Sampah (Gunakan AI Pilah)',
                                    style: _jakarta(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gunakan fitur AI Pilah minimal 1 kali untuk memindai jenis sampah di sekitarmu.',
                                    style: _jakarta(fontSize: 10, color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Icon(
                                  (_currentDailyScan >= _targetDailyScan) ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: primaryGreen,
                                ),
                                Text(
                                  '300 Pts',
                                  style: _jakarta(fontSize: 9.5, color: primaryGreen, fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildProgressBar(current: _currentDailyScan.toDouble(), target: _targetDailyScan.toDouble(), unit: 'Scan', activeColor: primaryGreen),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // --- HEADER MISI MINGGUAN ---
            Text(
              'Misi Mingguan',
              style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),

            // PANEL GREEN MISI MINGGUAN (Menggunakan spesifikasi visual persis seperti di Dashboard)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _buildWeeklyMissionCard(
                    title: 'Misi: Pahlawan Timbangan',
                    desc: 'Mencapai akumulasi total berat setoran minimal 5 Kilogram dalam seminggu.',
                    points: '1.800 Pts',
                    icon: Icons.scale_outlined,
                    currentProgress: _currentWeight,
                    targetProgress: _targetWeight,
                    unit: 'Kg',
                    activeColor: primaryGreen,
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklyMissionCard(
                    title: 'Misi: Master Pemilah',
                    // Kategori disesuaikan dengan yang ada di AI Live Price Feed dashboard utama
                    desc: 'Berhasil menyetor 3 jenis kategori sampah yang berbeda (Botol Plastik, Kardus, dan Minyak Jelantah).',
                    points: '2.500 Pts',
                    icon: Icons.category_outlined,
                    currentProgress: _currentCategories.toDouble(),
                    targetProgress: _targetCategories.toDouble(),
                    unit: 'Kategori',
                    activeColor: primaryGreen,
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklyMissionCard(
                    title: 'Misi: Setoran Konsisten',
                    desc: 'Menyelesaikan minimal 2 kali transaksi penjemputan sampah (Status: Completed) dalam seminggu.',
                    points: '1.350 Pts',
                    icon: Icons.receipt_long,
                    currentProgress: _currentTransactions.toDouble(),
                    targetProgress: _targetTransactions.toDouble(),
                    unit: 'Order',
                    activeColor: primaryGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInBox(String day, String points, {bool isDone = false, bool isRandom = false, bool isActive = false}) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;
    Color textColor = Colors.black45;

    if (isDone) {
      borderColor = const Color(0xFFEAD247); // Warna kuning aksen Eco Warga Card
      bgColor = const Color(0xFFFFFDE7);
    } else if (isActive) {
      borderColor = const Color(0xFF358C16);
      textColor = const Color(0xFF358C16);
    } else if (isRandom) {
      borderColor = Colors.amber;
      textColor = Colors.amber;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: 65,
      height: 75,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRandom) ...[
                  const Icon(Icons.card_giftcard, color: Colors.amber, size: 18),
                  Text(points, style: _jakarta(fontSize: 9, color: Colors.amber, fontWeight: FontWeight.bold)),
                ] else ...[
                  Text(
                    '$points 🪙',
                    textAlign: TextAlign.center,
                    style: _jakarta(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text('Points', style: _jakarta(fontSize: 9, color: Colors.black38)),
                ],
                const SizedBox(height: 4),
                Text(day, style: _jakarta(fontSize: 8.5, color: Colors.black38)),
              ],
            ),
          ),
          if (isDone)
            const Positioned(
              top: 3,
              right: 3,
              child: Icon(Icons.check_circle, color: Color(0xFFEAD247), size: 12),
            )
        ],
      ),
    );
  }

  Widget _buildProgressBar({required double current, required double target, required String unit, required Color activeColor}) {
    double percentage = current / target;
    if (percentage > 1.0) percentage = 1.0; 

    String currentStr = current % 1 == 0 ? current.toInt().toString() : current.toStringAsFixed(1);
    String targetStr = target % 1 == 0 ? target.toInt().toString() : target.toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 7,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$currentStr / $targetStr $unit',
          style: _jakarta(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildWeeklyMissionCard({
    required String title,
    required String desc,
    required String points,
    required IconData icon,
    required double currentProgress,
    required double targetProgress,
    required String unit,
    required Color activeColor,
  }) {
    bool isMissionCompleted = currentProgress >= targetProgress;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: activeColor, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _jakarta(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(desc, style: _jakarta(fontSize: 10.5, color: Colors.black45)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMissionCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                    color: activeColor,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    points,
                    style: _jakarta(fontSize: 9.5, color: activeColor, fontWeight: FontWeight.bold),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar(current: currentProgress, target: targetProgress, unit: unit, activeColor: activeColor),
        ],
      ),
    );
  }
}