import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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
        title: Text('EcoTree', style: _jakarta(fontSize: 16, fontWeight: FontWeight.w700)),
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
              final progress = (xp - prev) / (next - prev);

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 360,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCEE9C9)),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Text('Level $level', style: _jakarta(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2F7A2F))),
                                const SizedBox(height: 8),
                                Text('Reduksi Karbon sebesar ${(xp * 0.41).toStringAsFixed(1)}kg', style: _jakarta(fontSize: 12, color: Colors.green)),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Center(
                                    child: Image.asset(
                                      'assets/images/eco_tree.png',
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFEFEFEF)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tingkatan Level', style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    ...List.generate(state.xpThresholds.length - 1, (i) {
                                      final lvl = i + 1;
                                      final thresh = state.xpThresholds[lvl];
                                      final isCurrent = level == lvl;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: Text('Level$lvl', style: _jakarta(fontSize: 12, color: isCurrent ? Colors.green : Colors.black54))),
                                                                                        Text('$thresh XP', style: _jakarta(fontSize: 12, color: Colors.black45)),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF0E8C6))),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Reward Level', style: _jakarta(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text('Rendah : Chance Good Chest 25%\nSedang : Chance Good Chest 40%\nTinggi : Chance Good Chest 60%', style: _jakarta(fontSize: 11, color: Colors.black54)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ValueListenableBuilder<String>(
                                valueListenable: state.nameNotifier,
                                builder: (context, name, _) {
                                  final display = name.isEmpty ? 'Nama Anda' : name;
                                  return Text(display, style: _jakarta(fontSize: 16, fontWeight: FontWeight.w700));
                                },
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  final controller = TextEditingController(text: state.nameNotifier.value);
                                  final result = await showDialog<String>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text('Ubah Nama EcoTree', style: _jakarta(fontWeight: FontWeight.w700)),
                                      content: TextField(
                                        controller: controller,
                                        decoration: InputDecoration(hintText: 'Masukkan nama...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: _jakarta(color: Colors.black54))),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                                          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                                          child: Text('Simpan', style: _jakarta(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (result != null) {
                                    state.setName(result);
                                  }
                                },
                                child: Icon(Icons.edit, size: 16, color: Colors.black45),
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
                                    Text('Level Tunas Saat ini $level (Kecil)', style: _jakarta(fontSize: 12, color: Colors.black54)),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: LinearProgressIndicator(
                                        value: progress.clamp(0.0, 1.0),
                                        minHeight: 12,
                                        color: const Color(0xFF4CAF50),
                                        backgroundColor: const Color(0xFFE9F6EA),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  Text('$xp/$next XP', style: _jakarta(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text('Siram Menggunakan', style: _jakarta(fontSize: 13, fontWeight: FontWeight.w600)),
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
                          Center(child: Text('Konvers Point 2 : 1XP', style: _jakarta(fontSize: 12, color: Colors.black45))),
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
        // Convert points to XP: 2 points -> 1 XP as note; so points/2 XP
        final xpGain = (points / 2).round();
        state.addXp(xpGain);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('+$xpGain XP', style: _jakarta(color: Colors.white)), backgroundColor: const Color(0xFF2E7D32)));
      },
      child: Container(
        width: 84,
        height: 44,
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4C8C2B)), borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text('$points Points', style: _jakarta(fontSize: 13, color: const Color(0xFF4C8C2B), fontWeight: FontWeight.w600))),
      ),
    );
  }
}
