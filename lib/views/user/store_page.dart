import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/eco_tree_state.dart';
import '../../core/wallet_state.dart';
import '../../core/notification_state.dart';
import '../../core/history_state.dart';
import '../../providers/user_provider.dart';

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

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final Set<String> _redeemedTitles = {};
  bool _showAllLevels = false;

  final Map<int, List<_StoreItemData>> _storeLevelsData = const {
    1: [
      _StoreItemData(icon: Icons.grain, title: 'Garam Dapur 250g', description: 'Garam beryodium konsumsi keluarga untuk bumbu dapur sehari-hari.', price: 2500, locked: false),
      _StoreItemData(icon: Icons.clean_hands, title: 'Sabun Cuci Tangan 100ml', description: 'Sabun cuci tangan cair wangi pembasmi kuman dan bakteri.', price: 3500, locked: false),
    ],
    2: [
      _StoreItemData(icon: Icons.sanitizer, title: 'Spons Cuci Piring 2in1', description: 'Spons cuci piring busa tebal dan sabut penggosok kerak.', price: 5000, locked: true),
      _StoreItemData(icon: Icons.local_fire_department, title: 'Korek Api Kayu (1 Pack)', description: 'Korek api kayu praktis untuk kebutuhan dapur.', price: 4000, locked: true),
    ],
    3: [
      _StoreItemData(icon: Icons.dry_cleaning, title: 'Kain Lap Microfiber', description: 'Kain lap microfiber menyerap air tinggi untuk membersihkan meja & piring.', price: 7500, locked: true),
      _StoreItemData(icon: Icons.soap, title: 'Sabun Cuci Piring 210ml', description: 'Cairan pencuci piring ekstrak jeruk nipis ampuh hilangkan lemak.', price: 9000, locked: true),
    ],
    4: [
      _StoreItemData(icon: Icons.cleaning_services, title: 'Sikat Botol Gagang Panjang', description: 'Sikat fleksibel pembersih dalam botol minum dan gelas.', price: 12000, locked: true),
      _StoreItemData(icon: Icons.takeout_dining, title: 'Gula Pasir 250g', description: 'Gula pasir putih murni kemasan praktis 250 gram.', price: 15000, locked: true),
    ],
    5: [
      _StoreItemData(icon: Icons.delete_outline, title: 'Kantong Sampah Ramah Lingkungan', description: '1 roll plastik sampah biodegradable mudah terurai.', price: 20000, locked: true),
      _StoreItemData(icon: Icons.wash, title: 'Deterjen Bubuk 450g', description: 'Deterjen pembersih pakaian harum anti bau apek.', price: 25000, locked: true),
    ],
    6: [
      _StoreItemData(icon: Icons.opacity, title: 'Minyak Goreng Pouch 500ml', description: 'Minyak goreng kelapa sawit jernih kemasan pouch 500ml.', price: 35000, locked: true),
      _StoreItemData(icon: Icons.local_drink, title: 'Botol Minum Plastik BPA Free', description: 'Botol minum portable ramah lingkungan bebas bahan kimia BPA.', price: 40000, locked: true),
    ],
    7: [
      _StoreItemData(icon: Icons.rice_bowl, title: 'Beras Premium 1 Kg', description: 'Beras putih pulen berkualitas super kemasan 1 kg.', price: 50000, locked: true),
      _StoreItemData(icon: Icons.egg, title: 'Telur Ayam Segar 1/2 Kg', description: 'Telur ayam negeri fresh kaya protein untuk konsumsi keluarga.', price: 45000, locked: true),
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadRedeemedItems();
  }

  Future<void> _loadRedeemedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('ecopoint_redeemed_store_items');
      if (list != null) {
        setState(() {
          _redeemedTitles.addAll(list);
        });
      }
    } catch (_) {}
  }

  Future<void> _saveRedeemedItem(String title) async {
    setState(() {
      _redeemedTitles.add(title);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('ecopoint_redeemed_store_items', _redeemedTitles.toList());
    } catch (_) {}
  }

  void _onTukarPoint(_StoreItemData item) {
    if (item.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item ini masih terkunci! Tingkatkan EcoTree Level kamu terlebih dahulu.', style: _jakarta(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (WalletState.instance.currentPoints < item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Poin tidak mencukupi untuk menukar "${item.title}"! Poin kamu: ${WalletState.instance.currentPoints} Pts, Butuh: ${item.formattedPrice}', style: _jakarta(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Tukar Point', style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Tukar ${item.formattedPrice} untuk mendapatkan "${item.title}"?', style: _jakarta(fontSize: 14, color: Colors.black87)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: _jakarta(fontWeight: FontWeight.w600, color: Colors.black54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C8C2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<UserProvider>().redeemPoints(item.price);
              if (success) {
                await _saveRedeemedItem(item.title);
                NotificationState.instance.addNotification(
                  category: 'Convert',
                  title: 'Permintaan Penukaran Terkirim',
                  subtitle: 'Penukaran "${item.title}" (${item.formattedPrice}) berhasil diajukan. Status: Menunggu Admin. Kamu akan dikabari via Chat ketika diterima.',
                );
                HistoryState.instance.addHistory(
                  title: 'Tukar Barang: ${item.title}',
                  description: 'Menunggu konfirmasi admin (Akan dikabari via Chat)',
                  category: 'EcoStore',
                  valueChange: '-${item.formattedPrice}',
                );

                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF4C8C2B), size: 28),
                          const SizedBox(width: 8),
                          Text('Permintaan Terkirim!', style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Permintaan penukaran poin untuk "${item.title}" (${item.formattedPrice}) berhasil diajukan.', style: _jakarta(fontSize: 13.5)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFB74D)),
                            ),
                            child: Row(
                              children: [
                                const _RotatingSyncIcon(),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Status: Menunggu Admin\nKamu akan dikabari melalui Fitur Chat dan Notifikasi ketika permintaan penukaran sudah diterima oleh Admin.',
                                    style: _jakarta(fontSize: 11, color: const Color(0xFFE65100), fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C8C2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: () => Navigator.pop(c),
                          child: Text('Mengerti', style: _jakarta(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Poin tidak mencukupi atau gagal melakukan penukaran.', style: _jakarta(color: Colors.white)),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text('Ya, Tukar', style: _jakarta(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: EcoTreeState.instance.notifier,
      builder: (context, xpValue, child) {
        final currentLevel = EcoTreeState.instance.level;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStoreLevelSection(1, _storeLevelsData[1]!, currentLevel),
                  const SizedBox(height: 24),
                  _buildStoreLevelSection(2, _storeLevelsData[2]!, currentLevel),
                  const SizedBox(height: 16),

                  // Expand Button below Level 2
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showAllLevels = !_showAllLevels;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4C8C2B),
                          side: const BorderSide(color: Color(0xFF4C8C2B), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(
                          _showAllLevels ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 20,
                        ),
                        label: Text(
                          _showAllLevels
                              ? 'Tutup Level Store Tambahan'
                              : 'Lihat Selengkapnya Level Store (Level 1 - 7)',
                          style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF4C8C2B)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Level 3 to 7
                  if (_showAllLevels) ...[
                    for (int lvl = 3; lvl <= 7; lvl++) ...[
                      _buildStoreLevelSection(lvl, _storeLevelsData[lvl]!, currentLevel),
                      const SizedBox(height: 24),
                    ],
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final wallet = WalletState.instance;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'ECO ', style: _jakarta(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFE0A800), letterSpacing: 1)),
                TextSpan(text: 'STORE', style: _jakarta(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFF0C230), letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Saldo Aktif – live data, tap to go to Withdraw
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/withdraw'),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saldo Aktif', style: _jakarta(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 4),
                      ListenableBuilder(
                        listenable: wallet.activeBalance,
                        builder: (context, _) {
                          final val = wallet.activeBalance.value.toInt();
                          final str = val.toString().replaceAllMapped(
                            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
                          return Text('Rp $str', style: _jakarta(fontSize: 17, fontWeight: FontWeight.bold));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36, child: VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE0E0E0))),
              const SizedBox(width: 16),
              // Point Aktif – live data, tap to go to Convert
              InkWell(
                onTap: () => context.push('/convert'),
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Point Aktif', style: _jakarta(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    ListenableBuilder(
                      listenable: wallet.points,
                      builder: (context, _) {
                        final val = wallet.points.value;
                        final str = val.toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
                        return Text(str, style: _jakarta(fontSize: 17, fontWeight: FontWeight.bold));
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _convertButton(),
            ],
          ),
          const SizedBox(height: 20),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _convertButton() {
    return Container(
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE0A800), Color(0xFFF0C230)]), borderRadius: BorderRadius.circular(20)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/convert'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text('Convert', style: _jakarta(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECECEC)),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: _quickActionItem(Icons.front_hand_outlined, 'Withdraw', onTap: () => context.push('/withdraw'))),
          const SizedBox(height: 34, child: VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEDEDED))),
          // INTEGRASI: Tombol Points diarahkan ke route /points
          Expanded(child: _quickActionItem(Icons.monetization_on_outlined, 'Points', onTap: () => context.push('/points'))),
          const SizedBox(height: 34, child: VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEDEDED))),
          Expanded(child: _quickActionItem(Icons.eco_outlined, 'EcoTree', onTap: () => context.push('/eco-tree'))),
        ],
      ),
    );
  }

  Widget _quickActionItem(IconData icon, String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black45, size: 22),
          const SizedBox(height: 6),
          Text(label, style: _jakarta(fontSize: 11.5, color: Colors.black45, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStoreLevelSection(int levelNum, List<_StoreItemData> items, int userTreeLevel) {
    final bool isLevelUnlocked = levelNum == 1 ? true : userTreeLevel >= levelNum;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Store Level $levelNum', style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isLevelUnlocked ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isLevelUnlocked ? const Color(0xFF81C784) : const Color(0xFFE57373),
                      ),
                    ),
                    child: Text(
                      isLevelUnlocked ? 'Terbuka 🔓' : 'Terkunci 🔒 (Butuh Level $levelNum)',
                      style: _jakarta(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isLevelUnlocked ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final itemToShow = _StoreItemData(
              icon: item.icon,
              title: item.title,
              description: item.description,
              price: item.price,
              locked: !isLevelUnlocked,
            );
            final isRedeemed = _redeemedTitles.contains(itemToShow.title);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StoreItemCard(
                data: itemToShow,
                isRedeemed: isRedeemed,
                onTukarPoint: () => _onTukarPoint(itemToShow),
                onLockedTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Capai EcoTree Level $levelNum untuk membuka Store Level $levelNum!',
                        style: _jakarta(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StoreItemData {
  final IconData icon;
  final String title;
  final String description;
  final int price;
  final bool locked;
  const _StoreItemData({required this.icon, required this.title, required this.description, required this.price, required this.locked});

  String get formattedPrice {
    final priceStr = price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return '$priceStr Pts';
  }
}

class _RotatingSyncIcon extends StatefulWidget {
  const _RotatingSyncIcon({Key? key}) : super(key: key);

  @override
  State<_RotatingSyncIcon> createState() => _RotatingSyncIconState();
}

class _RotatingSyncIconState extends State<_RotatingSyncIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.sync, size: 14, color: Color(0xFFE65100)),
    );
  }
}

class _StoreItemCard extends StatelessWidget {
  final _StoreItemData data;
  final bool isRedeemed;
  final VoidCallback onTukarPoint;
  final VoidCallback onLockedTap;
  const _StoreItemCard({
    required this.data,
    required this.isRedeemed,
    required this.onTukarPoint,
    required this.onLockedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0,0,0,0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Icon(data.icon, size: 28, color: const Color(0xFF4C8C2B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: _jakarta(fontSize: 13.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(data.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: _jakarta(fontSize: 10.5, color: Colors.black45)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(data.formattedPrice, style: _jakarta(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _actionButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton() {
    if (isRedeemed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0),
          border: Border.all(color: const Color(0xFFFFB74D)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _RotatingSyncIcon(),
                const SizedBox(width: 4),
                Text(
                  'Proses Pengiriman',
                  style: _jakarta(fontSize: 9.5, color: const Color(0xFFE65100), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Menunggu Admin',
              style: _jakarta(fontSize: 8, color: Colors.black54),
            ),
          ],
        ),
      );
    }
    if (data.locked) {
      return GestureDetector(
        onTap: onLockedTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Text('Locked', style: _jakarta(fontSize: 10.5, color: Colors.black45)),
              const SizedBox(width: 4),
              const Icon(Icons.lock, size: 11, color: Colors.black38),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTukarPoint,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF4C8C2B)), borderRadius: BorderRadius.circular(8)),
        child: Text('Tukar', style: _jakarta(fontSize: 10.5, color: const Color(0xFF4C8C2B), fontWeight: FontWeight.w600)),
      ),
    );
  }
}