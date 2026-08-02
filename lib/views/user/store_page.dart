import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/eco_tree_state.dart';
import '../../core/wallet_state.dart';
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
  final List<_StoreItemData> _level1Items = const [
    _StoreItemData(icon: Icons.local_drink, title: 'Kecap Bango', description: 'Kecap Manis Bango Botol terbuat dari kedelai hitam pilihan.', price: 15000, locked: false),
    _StoreItemData(icon: Icons.oil_barrel, title: 'Minyak Goreng Bimoli', description: 'Minyak goreng berkualitas terbuat dari kelapa sawit pilihan.', price: 33000, locked: false),
  ];

  final List<_StoreItemData> _level2Items = const [
    _StoreItemData(icon: Icons.soup_kitchen, title: 'Wajan Stainless Steel', description: 'Alat masak modern kuat, tahan karat, menghantarkan panas merata.', price: 50000, locked: true),
    _StoreItemData(icon: Icons.shopping_basket, title: 'Keranjang Anyaman Rotan', description: 'Wadah penyimpanan estetik berbahan alami kokoh.', price: 35000, locked: true),
  ];

  void _onTukarPoint(_StoreItemData item) {
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
              final success = await context.read<UserProvider>().redeemPoints(1000);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Berhasil menukarkan poin untuk ${item.title}! Saldo dompet telah bertambah.'
                          : 'Poin tidak mencukupi atau gagal melakukan penukaran.',
                    ),
                    backgroundColor: success ? const Color(0xFF5CB82B) : Colors.red,
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
              _buildStoreLevelSection('Store Level 1', _level1Items),
              const SizedBox(height: 24),
              _buildStoreLevelSection('Store Level 2', _level2Items),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
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

  Widget _buildStoreLevelSection(String title, List<_StoreItemData> items) {
      final isLevel2 = title.toLowerCase().contains('level 2');
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold)),
                InkWell(onTap: () {}, child: Text('Lihat Semua', style: _jakarta(fontSize: 12.5, color: const Color(0xFF4C8C2B), fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 12),
            // Jika ini adalah Level 2, cek EcoTreeState untuk menentukan apakah item terkunci
            ...items.map((item) {
              final itemToShow = isLevel2
                  ? _StoreItemData(icon: item.icon, title: item.title, description: item.description, price: item.price, locked: EcoTreeState.instance.level < 2)
                  : item;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _StoreItemCard(
                  data: itemToShow,
                  onTukarPoint: () => _onTukarPoint(itemToShow),
                  onLockedTap: () {
                    if (EcoTreeState.instance.level < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reach EcoTree Level 2 to unlock Store Level 2', style: _jakarta(color: Colors.white)), backgroundColor: const Color(0xFF2E7D32)));
                    }
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

class _StoreItemCard extends StatelessWidget {
  final _StoreItemData data;
  final VoidCallback onTukarPoint;
  final VoidCallback onLockedTap;
  const _StoreItemCard({required this.data, required this.onTukarPoint, required this.onLockedTap});

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