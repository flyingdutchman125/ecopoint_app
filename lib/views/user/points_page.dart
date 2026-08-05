import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../core/mission_state.dart';
import '../../core/eco_tree_state.dart';

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
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  final MissionState _missionState = MissionState.instance;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _missionState.init();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _getFormattedResetTimer() {
    final remaining = _missionState.getRemainingTimeToReset();
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '${hours}j ${minutes}m ${seconds}s';
  }

  /// Displays the Information Dialog (?) explaining Page Features & Peti Emas Gacha Luck Rates
  void _showInfoGuideDialog() {
    final level = EcoTreeState.instance.level;
    final luckMap = {1: 25, 2: 45, 3: 65, 4: 80};
    final currentLuck = luckMap[level] ?? 95;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF358C16).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline,
                color: Color(0xFF358C16),
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Panduan Misi & Points',
                style: _jakarta(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection(
                title: '1. Apa itu EcoPoints?',
                desc:
                    'EcoPoints adalah poin hadiah yang kamu dapatkan setiap kali menyelesaikan misi harian, memindai sampah dengan AI Pilah, atau menyetor sampah. Poin ini dapat ditukarkan di EcoStore dengan saldo e-wallet, voucher, atau bibit tanaman!',
              ),
              const SizedBox(height: 14),
              _buildInfoSection(
                title: '2. Peti Emas & Tingkat Kehokian (Luck Rate)',
                desc:
                    'Peti Emas terbuka pada Daily Check-in Hari ke-4! Jumlah hadiah koin ditentukan oleh Tingkat Kehokian berdasarkan Level akunmu:\n'
                    '• Level 1: 25% Kehokian (50 Koin Base)\n'
                    '• Level 2: 45% Kehokian (100 Koin Base)\n'
                    '• Level 3: 65% Kehokian (180 Koin Base)\n'
                    '• Level 4: 80% Kehokian (300 Koin Base)\n'
                    '• Level 5+: 95% Kehokian (500 Koin Base)\n\n'
                    'Saat ini kamu di Level $level (Tingkat Kehokian: $currentLuck%)! Semakin tinggi levelmu, semakin besar koin yang kamu peroleh.',
              ),
              const SizedBox(height: 14),
              _buildInfoSection(
                title: '3. Misi Harian & Mingguan Real',
                desc:
                    'Semua progres misi tercatat secara nyata:\n'
                    '• Misi AI Pilah: Gunakan scanner AI untuk mendeteksi sampah.\n'
                    '• Misi Pahlawan Timbangan: Kumpulkan setoran sampah minimal 5Kg.\n'
                    '• Daily Check-in: Ambil hadiah koin setiap hari secara berurutan.',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF358C16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Saya Paham',
              style: _jakarta(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({required String title, required String desc}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: _jakarta(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF358C16),
          ),
        ),
        const SizedBox(height: 4),
        Text(desc, style: _jakarta(fontSize: 11.5, color: Colors.black87)),
      ],
    );
  }

  /// Golden Chest Gacha Modal Dialog
  void _showGoldenChestDialog(Map<String, dynamic> chestData) {
    final int totalReward = chestData['total_reward'];
    final int level = chestData['level'];
    final int luckPercent = chestData['luck_percent'];
    final bool isLucky = chestData['is_lucky'];
    final int bonus = chestData['bonus'];
    final int baseReward = chestData['base_reward'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8E1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard,
                size: 54,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'PETI EMAS TERBUKA! 🎉',
              style: _jakarta(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFB78103),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Level $level • Kehokian $luckPercent%',
                style: _jakarta(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '+$totalReward EcoPoints',
              style: _jakarta(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF358C16),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isLucky
                  ? 'HOKI BANGET! (Base: $baseReward + Bonus Kehokian: +$bonus Pts)'
                  : 'Peti Emas Level $level (Mendapatkan $baseReward Pts)',
              style: _jakarta(
                fontSize: 11,
                color: isLucky ? Colors.amber.shade900 : Colors.black54,
                fontWeight: isLucky ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF358C16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Klaim Koin Hadiah!',
                  style: _jakarta(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Claim Check-In Handler
  Future<void> _handleCheckIn(int dayIndex) async {
    final userProv = context.read<UserProvider>();
    final chestResult = await _missionState.claimCheckInDay(dayIndex, userProv);

    if (!mounted) return;

    if (chestResult != null) {
      _showGoldenChestDialog(chestResult);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily Check-in Berhasil! Poin telah ditambahkan.'),
          backgroundColor: Color(0xFF358C16),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF358C16);
    final userProv = context.watch<UserProvider>();

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
          style: _jakarta(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          // Tombol Informasi (?) yang memuat penjelasan lengkap fitur
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black),
            tooltip: 'Informasi Misi & Points',
            onPressed: _showInfoGuideDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER MISI HARIAN ---
            Text(
              'Misi Harian',
              style: _jakarta(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // PANEL GREEN MISI HARIAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selesaikan berbagai misi untuk mendapatkan Points dan tukarkan dengan berbagai hadiah di store',
                    style: _jakarta(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CARD 1: DAILY CHECK IN
                  ValueListenableBuilder<List<int>>(
                    valueListenable: _missionState.claimedCheckinDays,
                    builder: (context, claimedDays, _) {
                      final canCheckIn = _missionState.canCheckInToday();
                      final nextDayToClaim = [1, 2, 3, 4, 5, 6].firstWhere(
                        (d) => !claimedDays.contains(d),
                        orElse: () => 1,
                      );
                      final isCompletedAll =
                          claimedDays.length >= 6 && !canCheckIn;

                      return Container(
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
                                Expanded(
                                  child: Text(
                                    'Misi: Langkah Awal Hijau (Daily Check-in)',
                                    style: _jakarta(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${claimedDays.length}/6 Hari',
                                  style: _jakarta(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 06:00 AM Reset Timer Banner
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: canCheckIn
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: canCheckIn
                                      ? const Color(0xFF81C784)
                                      : const Color(0xFFFFB74D),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    canCheckIn
                                        ? Icons.check_circle_outline
                                        : Icons.timer_outlined,
                                    size: 14,
                                    color: canCheckIn
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFE65100),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      canCheckIn
                                          ? 'Siap Check-in! Reset berikutnya 06.00 WIB (${_getFormattedResetTimer()})'
                                          : 'Reset Jam 06.00 WIB dalam: ${_getFormattedResetTimer()}',
                                      style: _jakarta(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: canCheckIn
                                            ? const Color(0xFF2E7D32)
                                            : const Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildCheckInBox(
                                    1,
                                    "Hari 1",
                                    "70",
                                    claimedDays,
                                    nextDayToClaim,
                                    canCheckIn,
                                  ),
                                  _buildCheckInBox(
                                    2,
                                    "Hari 2",
                                    "80",
                                    claimedDays,
                                    nextDayToClaim,
                                    canCheckIn,
                                  ),
                                  _buildCheckInBox(
                                    3,
                                    "Hari 3",
                                    "90",
                                    claimedDays,
                                    nextDayToClaim,
                                    canCheckIn,
                                  ),
                                  _buildCheckInBox(
                                    4,
                                    "Hari 4",
                                    "Peti Emas",
                                    claimedDays,
                                    nextDayToClaim,
                                    canCheckIn,
                                    isRandom: true,
                                  ),
                                  _buildCheckInBox(
                                    5,
                                    "Hari 5",
                                    "70",
                                    claimedDays,
                                    nextDayToClaim,
                                    canCheckIn,
                                  ),
                                  _buildCheckInBox(
                                    6,
                                    "Hari 6",
                                    "80",
                                    claimedDays,
                                    nextDayToClaim,
                                    canCheckIn,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (isCompletedAll || !canCheckIn)
                                    ? null
                                    : () => _handleCheckIn(nextDayToClaim),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGreen,
                                  disabledBackgroundColor: Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  isCompletedAll
                                      ? 'Semua Check-in Diklaim 🎉 (Reset 06.00)'
                                      : (!canCheckIn
                                            ? 'Sudah Check-in Hari ini (Reset Jam 06.00)'
                                            : 'Check in Hari ini ! (Hari ke-$nextDayToClaim)'),
                                  style: _jakarta(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // CARD 2: DETEKTIF SAMPAH
                  ValueListenableBuilder<int>(
                    valueListenable: _missionState.aiScanCount,
                    builder: (context, scanCount, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _missionState.isAiScanClaimed,
                        builder: (context, isClaimed, _) {
                          final isCompleted = scanCount >= 1;

                          return Container(
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
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Misi: Detektif Sampah (Gunakan AI Pilah)',
                                            style: _jakarta(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Gunakan fitur AI Pilah minimal 1 kali untuk memindai jenis sampah di sekitarmu.',
                                            style: _jakarta(
                                              fontSize: 10,
                                              color: Colors.black45,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      children: [
                                        Icon(
                                          isCompleted
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          color: primaryGreen,
                                        ),
                                        Text(
                                          '300 Pts',
                                          style: _jakarta(
                                            fontSize: 9.5,
                                            color: primaryGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildProgressBar(
                                  current: scanCount.toDouble(),
                                  target: 1.0,
                                  unit: 'Scan',
                                  activeColor: primaryGreen,
                                ),
                                if (isCompleted && !isClaimed) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryGreen,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () async {
                                        await _missionState.claimAiScanMission(
                                          userProv,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Berhasil mengklaim +300 EcoPoints Misi Detektif Sampah!',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Text(
                                        'Klaim +300 EcoPoints',
                                        style: _jakarta(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- HEADER MISI MINGGUAN ---
            Text(
              'Misi Mingguan',
              style: _jakarta(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),

            // PANEL GREEN MISI MINGGUAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ValueListenableBuilder<double>(
                    valueListenable: _missionState.weeklyWeightKg,
                    builder: (context, weightKg, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: _missionState.isWeightClaimed,
                        builder: (context, isClaimed, _) {
                          return _buildWeeklyMissionCard(
                            title: 'Misi: Pahlawan Timbangan',
                            desc:
                                'Mencapai akumulasi total berat setoran minimal 5 Kilogram dalam seminggu.',
                            points: '1.800 Pts',
                            icon: Icons.scale_outlined,
                            currentProgress: weightKg,
                            targetProgress: 5.0,
                            unit: 'Kg',
                            activeColor: primaryGreen,
                            isClaimed: isClaimed,
                            onClaim: () async {
                              await _missionState.claimWeightMission(userProv);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Berhasil mengklaim +1.800 EcoPoints Misi Pahlawan Timbangan!',
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: _missionState.scannedCategoriesCount,
                    builder: (context, catCount, _) {
                      return _buildWeeklyMissionCard(
                        title: 'Misi: Master Pemilah',
                        desc:
                            'Berhasil menyetor 3 jenis kategori sampah yang berbeda (Botol Plastik, Kardus, dan Minyak Jelantah).',
                        points: '2.500 Pts',
                        icon: Icons.category_outlined,
                        currentProgress: catCount.toDouble(),
                        targetProgress: 3.0,
                        unit: 'Kategori',
                        activeColor: primaryGreen,
                        isClaimed: false,
                        onClaim: null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<int>(
                    valueListenable: _missionState.completedOrdersCount,
                    builder: (context, orderCount, _) {
                      return _buildWeeklyMissionCard(
                        title: 'Misi: Setoran Konsisten',
                        desc:
                            'Menyelesaikan minimal 2 kali transaksi penjemputan sampah (Status: Completed) dalam seminggu.',
                        points: '1.350 Pts',
                        icon: Icons.receipt_long,
                        currentProgress: orderCount.toDouble(),
                        targetProgress: 2.0,
                        unit: 'Order',
                        activeColor: primaryGreen,
                        isClaimed: false,
                        onClaim: null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInBox(
    int dayNum,
    String dayLabel,
    String points,
    List<int> claimedDays,
    int nextDayToClaim,
    bool canCheckIn, {
    bool isRandom = false,
  }) {
    final bool isDone = claimedDays.contains(dayNum);
    final bool isActive = canCheckIn && dayNum == nextDayToClaim;

    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;
    Color textColor = Colors.black45;

    if (isDone) {
      borderColor = const Color(0xFFEAD247);
      bgColor = const Color(0xFFFFFDE7);
    } else if (isActive) {
      borderColor = const Color(0xFF358C16);
      textColor = const Color(0xFF358C16);
    } else if (isRandom) {
      borderColor = Colors.amber;
      textColor = Colors.amber;
    }

    return GestureDetector(
      onTap: isActive ? () => _handleCheckIn(dayNum) : null,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 68,
        height: 78,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: isActive ? 2.0 : 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isRandom) ...[
                    const Icon(
                      Icons.card_giftcard,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      points,
                      style: _jakarta(
                        fontSize: 8.5,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '$points 🪙',
                      textAlign: TextAlign.center,
                      style: _jakarta(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Points',
                      style: _jakarta(fontSize: 9, color: Colors.black38),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    dayLabel,
                    style: _jakarta(fontSize: 8.5, color: Colors.black38),
                  ),
                ],
              ),
            ),
            if (isDone)
              const Positioned(
                top: 3,
                right: 3,
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFFEAD247),
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required double current,
    required double target,
    required String unit,
    required Color activeColor,
  }) {
    double percentage = current / target;
    if (percentage > 1.0) percentage = 1.0;

    String currentStr = current % 1 == 0
        ? current.toInt().toString()
        : current.toStringAsFixed(1);
    String targetStr = target % 1 == 0
        ? target.toInt().toString()
        : target.toStringAsFixed(1);

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
          style: _jakarta(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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
    required bool isClaimed,
    required VoidCallback? onClaim,
  }) {
    bool isMissionCompleted = currentProgress >= targetProgress;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
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
                    Text(
                      title,
                      style: _jakarta(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: _jakarta(fontSize: 10.5, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isMissionCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: activeColor,
                    size: 22,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    points,
                    style: _jakarta(
                      fontSize: 9.5,
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            current: currentProgress,
            target: targetProgress,
            unit: unit,
            activeColor: activeColor,
          ),
          if (isMissionCompleted && !isClaimed && onClaim != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onClaim,
                child: Text(
                  'Klaim $points',
                  style: _jakarta(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
