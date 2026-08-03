import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/eco_tree_state.dart';
import '../../core/wallet_state.dart';
import '../../core/history_state.dart';
import '../../widgets/eco_tree_vector_widget.dart';

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

class EcoTreePage extends StatefulWidget {
  const EcoTreePage({super.key});

  @override
  State<EcoTreePage> createState() => _EcoTreePageState();
}

class _EcoTreePageState extends State<EcoTreePage> {
  final state = EcoTreeState.instance;

  @override
  void initState() {
    super.initState();
  }

  int _nextThreshold() {
    final lv = state.level;
    if (lv + 1 < state.xpThresholds.length) return state.xpThresholds[lv + 1];
    return state.xpThresholds.last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EcoTree (Level 1 - 9)',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder<int>(
            valueListenable: state.notifier,
            builder: (context, xp, _) {
              final level = state.level;
              final next = _nextThreshold();
              final prev = state.xpThresholds[level];
              final progress = next == prev ? 1.0 : (xp - prev) / (next - prev);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left: 1 Tall Container (EcoTree graphic)
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFCEE9C9),
                                  width: 1.5,
                                ),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        'Level $level',
                                        style: _jakarta(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2F7A2F),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        state.levelTitle,
                                        style: _jakarta(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF4CAF50),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F5E9),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Reduksi Karbon: ${(xp * 0.41).toStringAsFixed(1)} kg CO2',
                                          style: _jakarta(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2E7D32),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        child: EcoTreeVectorWidget(
                                          key: ValueKey(level),
                                          level: level,
                                          width: 220,
                                          height: 220,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right: 2 Stacked Containers aligned to match left height
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFEFEFEF),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tingkatan Level (1-9)',
                                        style: _jakarta(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...List.generate(9, (i) {
                                        final lvl = i + 1;
                                        final thresh = state.xpThresholds[lvl];
                                        final isCurrent = level == lvl;
                                        final isUnlocked = level >= lvl;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 3.5,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isUnlocked
                                                    ? Icons.check_circle
                                                    : Icons.lock,
                                                size: 13,
                                                color: isCurrent
                                                    ? const Color(0xFF2E7D32)
                                                    : (isUnlocked
                                                          ? Colors.green
                                                          : Colors
                                                                .grey
                                                                .shade400),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  'Lvl $lvl',
                                                  style: _jakarta(
                                                    fontSize: 11,
                                                    fontWeight: isCurrent
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isCurrent
                                                        ? const Color(
                                                            0xFF2E7D32,
                                                          )
                                                        : (isUnlocked
                                                              ? Colors.black87
                                                              : Colors.black45),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '$thresh XP',
                                                style: _jakarta(
                                                  fontSize: 10.5,
                                                  fontWeight: isCurrent
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isCurrent
                                                      ? const Color(0xFF2E7D32)
                                                      : Colors.black45,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFDE7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFFEE58),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.card_giftcard,
                                              size: 15,
                                              color: Colors.orange.shade800,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Bonus Chest',
                                              style: _jakarta(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Lvl 1-3: Chance 25%\nLvl 4-6: Chance 45%\nLvl 7-9: Chance 75%',
                                          style: _jakarta(
                                            fontSize: 10.5,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: state.nameNotifier,
                                builder: (context, name, _) {
                                  final display = name.isEmpty
                                      ? 'Nama Anda'
                                      : name;
                                  return Text(
                                    display,
                                    style: _jakarta(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  final controller = TextEditingController(
                                    text: state.nameNotifier.value,
                                  );
                                  final result = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(
                                        'Ubah Nama EcoTree',
                                        style: _jakarta(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      content: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          hintText: 'Masukkan nama...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text(
                                            'Batal',
                                            style: _jakarta(
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF4CAF50,
                                            ),
                                          ),
                                          onPressed: () => Navigator.pop(
                                            ctx,
                                            controller.text.trim(),
                                          ),
                                          child: Text(
                                            'Simpan',
                                            style: _jakarta(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (result != null) {
                                    state.setName(result);
                                  }
                                },
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Level $level: ${state.levelTitle}',
                                      style: _jakarta(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: LinearProgressIndicator(
                                        value: progress.clamp(0.0, 1.0),
                                        minHeight: 12,
                                        color: const Color(0xFF4CAF50),
                                        backgroundColor: const Color(
                                          0xFFE9F6EA,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  Text(
                                    '$xp/$next XP',
                                    style: _jakarta(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Siram Menggunakan',
                                style: _jakarta(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              ValueListenableBuilder<int>(
                                valueListenable: WalletState.instance.points,
                                builder: (context, userPts, _) {
                                  return Text(
                                    'Sisa Point: $userPts',
                                    style: _jakarta(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2F7A2F),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _waterOption(50),
                              _waterOption(100),
                              _waterOption(150),
                              _waterOption(200),
                              _waterOption(250),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Konversi Point 1 : 1 XP',
                              style: _jakarta(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _waterOption(int points) {
    return GestureDetector(
      onTap: () {
        final wallet = WalletState.instance;
        if (wallet.points.value < points) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Point tidak cukup! (Sisa: ${wallet.points.value} Points)',
                style: _jakarta(color: Colors.white),
              ),
              backgroundColor: Colors.red.shade700,
            ),
          );
          return;
        }

        // 1 Point = 1 XP gained
        wallet.points.value -= points;
        state.addXp(points);
        HistoryState.instance.addHistory(
          title: 'Penyiraman EcoTree',
          description:
              'Menggunakan $points Points untuk menyiram tunas EcoTree (+$points XP)',
          category: 'EcoTree',
          valueChange: '-$points Pts',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '+$points XP (Tunas Tersiram!)',
              style: _jakarta(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 84,
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF4C8C2B)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '$points Points',
            style: _jakarta(
              fontSize: 13,
              color: const Color(0xFF4C8C2B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
