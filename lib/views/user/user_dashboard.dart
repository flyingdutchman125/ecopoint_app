import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/wallet_state.dart';
import '../../core/eco_tree_state.dart';
import '../../providers/auth_provider.dart';

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

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Timer? _priceTicker;
  final _random = Random();

  final List<_MenuItemData> _menuItems = const [
    _MenuItemData(Icons.local_shipping, 'Jemput', Color(0xFFE53935)),
    _MenuItemData(Icons.attach_money, 'Points', Color(0xFFFFC107)),
    _MenuItemData(Icons.chat_bubble_outline, 'Chat', Color(0xFFFFC107)),
    _MenuItemData(Icons.star, 'Rating', Color(0xFFFFC107)),
    _MenuItemData(Icons.alt_route, 'Rute Map', Color(0xFF4CAF50)),
    _MenuItemData(Icons.eco, 'EcoTree', Color(0xFF4CAF50)),
    _MenuItemData(Icons.receipt_long, 'Order', Color(0xFFFF9800)),
    _MenuItemData(Icons.menu_book, 'EcoBook', Color(0xFF3F51B5)),
  ];

  List<_PriceData> _prices = [
    _PriceData(name: 'Logam/Besi', pricePerKg: 8900, change: 1.2),
    _PriceData(name: 'Minyak Jelantah', pricePerKg: 9600, change: 0.9),
    _PriceData(name: 'Kardus', pricePerKg: 4900, change: -1.1),
    _PriceData(name: 'Botol Plastik', pricePerKg: 3900, change: 1.4),
  ];

  @override
  void initState() {
    super.initState();
    _priceTicker = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() {
        _prices = _prices.map((p) {
          if (p.locked) return p;
          final deltaPercent = (_random.nextDouble() * 4) - 2;
          final newPrice = (p.pricePerKg * (1 + deltaPercent / 100)).roundToDouble();
          return p.copyWith(pricePerKg: newPrice, change: deltaPercent);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _priceTicker?.cancel();
    super.dispose();
  }

  Future<void> _onLockTap(int index) async {
    final item = _prices[index];

    if (item.locked) {
      final remaining = item.lockedUntil!.difference(DateTime.now());
      _showSnack('Price lock aktif. Menunggu ${_formatDuration(remaining)} lagi.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Kunci Harga', style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Konfirmasi penguncian harga selama 24 jam?', style: _jakarta(fontSize: 14, color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: _jakarta(fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF358C16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Ya, Kunci', style: _jakarta(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _prices[index] = item.copyWith(lockedUntil: DateTime.now().add(const Duration(hours: 24)));
      });
      _showSnack('Harga "${item.name}" berhasil dikunci selama 24 jam.');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: _jakarta(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF1B3A1B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inHours >= 1) return '${d.inHours} jam';
    if (d.inMinutes >= 1) return '${d.inMinutes} menit';
    return '${d.inSeconds} detik';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF358C16), 
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F9FA),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuUtama(),
                    const SizedBox(height: 24),
                    _buildLivePriceFeed(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8EE33F), Color(0xFF358C16)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: _jakarta(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  children: [
                    TextSpan(text: 'ECO ', style: _jakarta(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    TextSpan(text: 'POINT', style: _jakarta(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFFFFEB3B))),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.location_on, color: Colors.white, size: 24),
                    onPressed: () {
                      context.push('/address');
                    },
                  ),
                  const SizedBox(width: 18),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.notifications, color: Colors.white, size: 24),
                    onPressed: () {
                      context.push('/notification'); 
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: _jakarta(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
              children: [
                const TextSpan(text: 'Hai, '),
                TextSpan(text: Provider.of<AuthProvider>(context).user?.name ?? 'Warga', style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildEcoWargaCard(),
        ],
      ),
    );
  }

  Widget _buildEcoWargaCard() {
    final wallet = WalletState.instance;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEAD247),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Text(
              'Eco Warga Card',
              textAlign: TextAlign.center,
              style: _jakarta(color: Colors.white, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                // Saldo Aktif -> Click to Withdraw
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => context.push('/withdraw'),
                    child: ListenableBuilder(
                      listenable: wallet.activeBalance,
                      builder: (context, _) {
                        final val = wallet.activeBalance.value.toInt();
                        final valStr = val.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
                        return _saldoPointItem('Saldo Aktif', 'Rp $valStr');
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 36, child: VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE5E5E5))),
                // Point Aktif -> Click to Convert
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => context.push('/convert'),
                    child: ListenableBuilder(
                      listenable: wallet.points,
                      builder: (context, _) {
                        final val = wallet.points.value;
                        final valStr = val.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
                        return _saldoPointItem('Point Aktif', '$valStr Pts');
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          InkWell(
            onTap: () => context.push('/eco-tree'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListenableBuilder(
                      listenable: EcoTreeState.instance.notifier,
                      builder: (context, _) {
                        final currentLvl = EcoTreeState.instance.level;
                        return RichText(
                          text: TextSpan(
                            style: _jakarta(fontSize: 12.5, color: Colors.black87, fontStyle: FontStyle.italic),
                            children: [
                              const TextSpan(text: 'Level Pertumbuhan Tunas : '),
                              TextSpan(text: 'Level $currentLvl', style: _jakarta(fontSize: 12.5, color: const Color(0xFF5CB82B), fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFCCCCCC)), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Lihat Perkembangan ', style: _jakarta(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.black54)),
                        const Icon(Icons.arrow_forward_ios, size: 8, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saldoPointItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _jakarta(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          Text(value, style: _jakarta(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildMenuUtama() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu Utama', style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _menuItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 71,
            ),
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              return _MenuItemCard(
                data: item,
                onTap: () {
                  // MENGHUBUNGKAN NAVIGASI TOMBOL JEMPUT, POINTS, CHAT, RATING
                  if (item.label == 'Jemput') {
                    context.push('/create-order');
                  } else if (item.label == 'Points') {
                    context.push('/points'); // INTEGRASI: Arahkan langsung ke halaman Points
                  } else if (item.label == 'Chat') {
                    context.push('/warga/chats');
                  } else if (item.label == 'Rute Map') {
                    context.push('/route-map');
                                    } else if (item.label == 'EcoTree') {
                                      context.push('/eco-tree');
                                    } else if (item.label == 'Rating') {
                                      context.push('/rating');
                                    } else if (item.label == 'EcoBook') {
                                      context.push('/eco-book');
                                    } else if (item.label == 'Order') {
                                      context.push('/orders');
                                    } else {
                                      _showSnack('Fitur ${item.label} sedang dalam pengembangan');
                                    }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLivePriceFeed() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('AI Live Dynamic Price Feed', style: _jakarta(fontSize: 14.5, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                  const SizedBox(width: 4),
                  Text('Live Market', style: _jakarta(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _prices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (context, index) => _PriceCard(data: _prices[index], onLockTap: () => _onLockTap(index)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              context.push('/ai-price'); 
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEDEDED))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lihat Selengkapnya', style: _jakarta(fontSize: 12.5, color: Colors.black45)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 14, color: Colors.black38),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  const _MenuItemData(this.icon, this.label, this.color);
}

class _MenuItemCard extends StatelessWidget {
  final _MenuItemData data;
  final VoidCallback? onTap;
  const _MenuItemCard({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon, color: data.color, size: 26),
                const SizedBox(height: 8),
                Text(data.label, textAlign: TextAlign.center, style: _jakarta(fontSize: 11.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceData {
  final String name;
  final double pricePerKg;
  final double change; 
  final DateTime? lockedUntil;

  const _PriceData({required this.name, required this.pricePerKg, required this.change, this.lockedUntil});

  bool get locked => lockedUntil != null && DateTime.now().isBefore(lockedUntil!);
  bool get isUp => change >= 0;

  String get formattedPrice {
    final priceStr = pricePerKg.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $priceStr/kg';
  }

  String get formattedChange {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  String? get lockedUntilLabel {
    if (!locked) return null;
    final t = lockedUntil!;
    return 'Terkunci s.d. ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  _PriceData copyWith({String? name, double? pricePerKg, double? change, DateTime? lockedUntil}) {
    return _PriceData(
      name: name ?? this.name,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      change: change ?? this.change,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }
}

class _PriceCard extends StatelessWidget {
  final _PriceData data;
  final VoidCallback onLockTap;
  const _PriceCard({required this.data, required this.onLockTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: data.locked ? Border.all(color: const Color(0xFF358C16), width: 1.2) : null,
        boxShadow: [BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(data.name, style: _jakarta(fontSize: 12.5, fontWeight: FontWeight.w600))),
              GestureDetector(
                onTap: onLockTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(data.locked ? Icons.lock : Icons.lock_open, size: 14, color: data.locked ? const Color(0xFF358C16) : Colors.black38),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data.formattedPrice, style: _jakarta(fontSize: 12.5, fontWeight: FontWeight.w400)),
              Text(data.formattedChange, style: _jakarta(fontSize: 12, fontWeight: FontWeight.bold, color: data.isUp ? Colors.green : Colors.red)),
            ],
          ),
          if (data.locked) ...[
            const SizedBox(height: 4),
            Text(data.lockedUntilLabel!, style: _jakarta(fontSize: 9.5, color: const Color(0xFF358C16), fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}