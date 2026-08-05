import '../../core/utils/alert_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collector_provider.dart';
import '../../models/order_model.dart';
import '../../core/utils/currency_formatter.dart';
import 'collector_earnings_page.dart'; //  Ubah import ke halaman pendapatan baru
import 'collector_profile_tab.dart';
import 'collector_chat_tab.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  int _bottomNavIndex = 0;
  int _selectedTopTab = 0; // 0 = Radar Order, 1 = Peta Rute GPS
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectorProvider>().updateLocationAndFetchNearby();
    });
  }

  @override
  Widget build(BuildContext context) {
    final collectorProv = context.watch<CollectorProvider>();
    final activeOrder = collectorProv.myOrders.firstWhere(
      (o) => o.status == 'accepted' || o.status == 'en_route',
      orElse: () => OrderModel(
        id: 'EP-982103',
        userId: 'u1',
        userName: 'Budi Santoso (Warga)',
        category: 'Plastik PET Bening (10 Kg)',
        status: 'accepted',
        lat: -7.1185,
        lng: 112.4166,
        address: 'Jl. Andansari Mojo (1.2 Km)',
        statusHistory: [],
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF57C00), // Cohesive Collector Amber Orange Theme
      body: SafeArea(
        child: IndexedStack(
          index: _bottomNavIndex,
          children: [
            _buildBerandaTab(),
            CollectorChatTab(activeOrder: activeOrder),
            const CollectorEarningsPage(), //  Sudah diganti dari CollectorWalletTab() ke halaman baru
            const CollectorProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- TAB 0: BERANDA (MAIN DASHBOARD FROM PIC) ---
  Widget _buildBerandaTab() {
    final collectorProv = context.watch<CollectorProvider>();
    final authProv = context.watch<AuthProvider>();
    final user = authProv.user;

    return RefreshIndicator(
      onRefresh: () => collectorProv.updateLocationAndFetchNearby(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // 1. TOP HEADER (PROFILE & STATUS SWITCH)
          _buildTopHeader(user),
          const SizedBox(height: 12),

          // 1.5 ONLINE / OFFLINE TOGGLE BANNER
          _buildOnlineToggleCard(collectorProv),
          const SizedBox(height: 16),

          // 2. SALDO ESTIMATION CARD
          _buildEstimasiSaldoCard(collectorProv),
          const SizedBox(height: 20),

          // 3. TAB SWITCHER (RADAR ORDER vs PETA RUTE GPS)
          _buildTabSwitcher(),
          const SizedBox(height: 20),

          // 4. TAB CONTENT (RADAR ORDER vs PETA RUTE GPS)
          if (_selectedTopTab == 0)
            _buildRadarOrderContent(collectorProv)
          else
            _buildPetaRuteGpsContent(collectorProv),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- 1.5 ONLINE / OFFLINE TOGGLE BANNER ---
  Widget _buildOnlineToggleCard(CollectorProvider collectorProv) {
    final isOnline = collectorProv.isOnline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFF2E7D32) : const Color(0xFF374151),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.sensors_rounded : Icons.sensors_off_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'STATUS: ONLINE (Siap Jemput)' : 'STATUS: OFFLINE (Istirahat)',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? 'Terhubung dengan Rute Map Warga'
                      : 'Aktifkan untuk dapat menerima order sampah',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isOnline,
            activeColor: Colors.amber,
            activeTrackColor: Colors.lightGreenAccent.shade700,
            inactiveThumbColor: Colors.grey.shade300,
            inactiveTrackColor: Colors.grey.shade600,
            onChanged: (val) async {
              await collectorProv.setOnlineStatus(val);
              if (mounted) {
                AppAlerts.showSuccess(context, val ? '🟢 Status Anda ONLINE - Siap menerima pesanan' : '⚪ Status Anda OFFLINE - Mode Istirahat');
              }
            },
          ),
        ],
      ),
    );
  }

  // --- 1. TOP HEADER ---
  Widget _buildTopHeader(dynamic user) {
    final String rawName = user?.name ?? '';
    final String emailPrefix =
        (user?.email != null && user!.email.contains('@'))
        ? user.email.split('@')[0]
        : 'Anto';
    final String formattedEmailPrefix = emailPrefix.isNotEmpty
        ? (emailPrefix[0].toUpperCase() + emailPrefix.substring(1))
        : 'Anto';
    final String name = rawName.trim().isNotEmpty
        ? rawName
        : formattedEmailPrefix;

    final city = (user?.city != null && user!.city.toString().isNotEmpty)
        ? user.city
        : 'Lamongan';

    final String ratingStr = (user?.rating != null)
        ? (user.rating as num).toStringAsFixed(1)
        : '4.9';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.recycling,
          color: Colors.white,
          size: 30,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          ratingStr,
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Mitra Pengepul - Wilayah $city',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                'Mitra Resmi',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // --- 2. SALDO CARD ---
  Widget _buildEstimasiSaldoCard(CollectorProvider collectorProv) {
    final earningsText = CurrencyFormatter.formatRupiah(collectorProv.earnings);

    final completedOrders = collectorProv.myOrders
        .where((o) => o.status == 'completed')
        .toList();
    final completedCount = completedOrders.length;
    final displayCompletedCount = completedCount;

    final double realWeightSum = completedOrders.fold(
      0.0,
      (sum, order) => sum + (order.weightKg ?? 0.0),
    );
    final String displayWeightText = '${realWeightSum.toStringAsFixed(1)} Kg';

    final double realHoursSum = (completedCount * 0.6);
    final String displayHoursText = '${realHoursSum.toStringAsFixed(2)} Jam';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimasi Saldo yang didapatkan Minggu Ini',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            earningsText,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatPill(
                  'Selesai',
                  '$displayCompletedCount Order',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildStatPill('Total Berat', displayWeightText)),
              const SizedBox(width: 8),
              Expanded(child: _buildStatPill('Jam Kerja', displayHoursText)),
            ],
          ),
        ],
      ),
    ).animate().fade(delay: 100.ms).slideY(begin: -0.05);
  }

  Widget _buildStatPill(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF7CB342),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // --- 3. TAB SWITCHER (RADAR ORDER vs PETA RUTE GPS) ---
  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _selectedTopTab = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTopTab == 0
                      ? const Color(0xFFFACC15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.radar,
                        size: 18,
                        color: _selectedTopTab == 0
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Radar Order',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _selectedTopTab == 0
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _selectedTopTab = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTopTab == 1
                      ? const Color(0xFFFACC15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 18,
                        color: _selectedTopTab == 1
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEAB308),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Peta Rute GPS',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _selectedTopTab == 1
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFEAB308),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. RADAR ORDER CONTENT ---
  Widget _buildRadarOrderContent(CollectorProvider collectorProv) {
    final activeOrders = collectorProv.myOrders.where((o) {
      final st = (o.status).toLowerCase();
      return st == 'accepted' || st == 'in_progress' || st == 'en_route' || st == 'pending';
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeOrders.isNotEmpty) ...[
          Text(
            'Orderan Aktif Penjemputan (${activeOrders.length})',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          ...activeOrders.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildActiveOrderCard(o),
              )),
          const SizedBox(height: 16),
        ],
        Text(
          'Permintaan Penjemputan Masuk',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        if (!collectorProv.isOnline)
          _buildOfflineNotice()
        else if (collectorProv.isLoading)
          _buildShimmerBox(height: 220)
        else if (collectorProv.nearbyOrders.isNotEmpty)
          ...collectorProv.nearbyOrders.map((order) => _buildPickupCard(order))
        else if (activeOrders.isNotEmpty)
          _buildNoPendingOrdersNotice()
        else
          _buildSamplePickupCard(collectorProv),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildOfflineNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade400, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.do_not_disturb_on_rounded,
            size: 44,
            color: Colors.amber,
          ),
          const SizedBox(height: 10),
          Text(
            'Status Anda Sedang OFFLINE',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aktifkan sakelar STATUS ONLINE di bagian atas untuk dapat menerima dan melihat permintaan penjemputan dari warga.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPendingOrdersNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF7CB342), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 44,
            color: Color(0xFF7CB342),
          ),
          const SizedBox(height: 10),
          Text(
            'Semua Pesanan Sudah Ditangani! 🎉',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada permintaan baru saat ini.\nFokus selesaikan orderan aktif Anda.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPickupCard(OrderModel order) {
    final String displayName =
        (order.userName != null && order.userName!.isNotEmpty)
        ? order.userName!
        : "Warga EcoPoint";
    final String displayAddress = order.address.isNotEmpty
        ? order.address
        : "Jl. Andansari Mojo";
    final String displayCategory =
        (order.category != null && order.category!.isNotEmpty)
        ? order.category!
        : "Plastik PET Bening";
    final double weight = order.weightKg ?? 10.0;
    final int price = (order.totalPrice ?? 39000).toInt();
    final double dist = (order.distanceMeters ?? 1200) / 1000;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        '${dist.toStringAsFixed(1)} Km - $displayAddress',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Komoditas Utama',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$displayCategory (~${weight.toInt()}Kg)',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Estimasi Harga Barang',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatRupiah(price),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7CB342),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 22,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deteksi AI : 96% Botol PET Clean',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kondisi : Terpisah Kering',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CB342),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _acceptOrder(context, order.id),
                    child: Text(
                      'Terima Penjemputan',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSamplePickupCard(CollectorProvider collectorProv) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (collectorProv.nearbyOrders.isNotEmpty &&
                                collectorProv.nearbyOrders.first.userName !=
                                    null)
                            ? collectorProv.nearbyOrders.first.userName!
                            : "Budi Santoso",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '1.2 Km - Jl. Andansari Mojo',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Komoditas Utama',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Plastik PET Bening (~10Kg)',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Estimasi Harga Barang',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp 39.000',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF7CB342),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deteksi AI : 96% Botol PET Clean',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kondisi : Terpisah Kering',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7CB342),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (!collectorProv.isOnline) {
                        AppAlerts.showError(
                          context,
                          'Status Anda sedang OFFLINE. Aktifkan status ONLINE terlebih dahulu untuk menerima pesanan!',
                        );
                        return;
                      }
                      final sampleOrder = OrderModel(
                        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
                        userId: 'usr-budi',
                        userName: 'Budi Santoso',
                        category: 'Plastik PET Bening',
                        weightKg: 10.0,
                        totalPrice: 39000,
                        status: 'accepted',
                        lat: -7.1185,
                        lng: 112.4166,
                        address: 'Jl. Andansari Mojo (1.2 Km)',
                        statusHistory: const [],
                        createdAt: DateTime.now(),
                      );
                      collectorProv.addOrderToActive(sampleOrder);
                      AppAlerts.showSuccess(
                        context,
                        'Penjemputan Budi Santoso berhasil diterima! Pesanan telah masuk ke Orderan Aktif.',
                      );
                    },
                    child: Text(
                      'Terima Penjemputan',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(OrderModel order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF7CB342),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.userName ?? 'Pelanggan Aktif',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.address,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7CB342).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF388E3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Berat Estimasi',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.weightKg?.toStringAsFixed(1) ?? '-'} Kg',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Estimasi Harga',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.totalPrice != null
                        ? CurrencyFormatter.formatRupiah(
                            order.totalPrice!.toInt(),
                          )
                        : '-',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoActiveOrderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF7CB342)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada order aktif. Silakan terima penjemputan di halaman Radar Order.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. PETA RUTE GPS CONTENT ---
  Widget _buildPetaRuteGpsContent(CollectorProvider collectorProv) {
    final double myLat = collectorProv.currentPosition?.latitude ?? -7.1186;
    final double myLng = collectorProv.currentPosition?.longitude ?? 112.4162;
    final myCenter = LatLng(myLat, myLng);

    final activeOrders = collectorProv.myOrders.where((o) {
      final st = (o.status).toLowerCase();
      return st == 'accepted' || st == 'in_progress' || st == 'en_route';
    }).toList();

    final activeOrder = activeOrders.isNotEmpty ? activeOrders.first : null;
    final LatLng? activeTarget = activeOrder != null
        ? LatLng(
            activeOrder.latitude != 0 ? activeOrder.latitude : (myLat - 0.0020),
            activeOrder.longitude != 0 ? activeOrder.longitude : (myLng + 0.0025),
          )
        : null;

    final List<Marker> markers = [
      // Collector marker (Yellow pin with car icon at actual GPS location)
      Marker(
        point: myCenter,
        width: 60,
        height: 60,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFFACC15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car,
                color: Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    ];

    if (activeTarget != null && activeOrder != null) {
      markers.add(
        Marker(
          point: activeTarget,
          width: 150,
          height: 75,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7CB342),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  'Tujuan: ${activeOrder.userName ?? "Warga"}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.location_on,
                color: Color(0xFF388E3C),
                size: 36,
              ),
            ],
          ),
        ),
      );
    } else if (collectorProv.nearbyOrders.isNotEmpty) {
      for (var o in collectorProv.nearbyOrders) {
        if (o.latitude != 0 && o.longitude != 0) {
          markers.add(
            Marker(
              point: LatLng(o.latitude, o.longitude),
              width: 140,
              height: 70,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${o.userName ?? "Warga"} - ${o.category ?? "Plastik"}',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Siap Dijemput',
                          style: GoogleFonts.inter(
                            fontSize: 7,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFF7CB342),
                    size: 32,
                  ),
                ],
              ),
            ),
          );
        }
      }
    } else {
      markers.addAll([
        Marker(
          point: LatLng(myLat - 0.0012, myLng + 0.0013),
          width: 140,
          height: 70,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Warung Bu Kris - Plastik Bening',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Siap Dijemput',
                      style: GoogleFonts.inter(
                        fontSize: 7,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.location_on, color: Color(0xFF7CB342), size: 32),
            ],
          ),
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activeOrder != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RUTE NAVIGASI AKTIF GPS',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22C55E),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFACC15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '1.2 Km • ~5 min',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  activeOrder.userName ?? 'Pelanggan Warga',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activeOrder.address,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _bottomNavIndex = 1;
                          });
                        },
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('Chat Warga'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7CB342),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            '/collector/order-detail',
                            extra: activeOrder.toJson(),
                          );
                        },
                        icon: const Icon(Icons.navigation, size: 16),
                        label: const Text('Detail Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFACC15),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        Text(
          'Lokasi Orderan Sekitar',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        // Map Container Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: SizedBox(
                  height: 260,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: activeTarget ?? myCenter,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.ecopoint',
                          ),
                          if (activeTarget != null)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: [myCenter, activeTarget],
                                  color: const Color(0xFF388E3C),
                                  strokeWidth: 4.5,
                                ),
                              ],
                            ),
                          MarkerLayer(markers: markers),
                        ],
                      ),
                      // Recenter button
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: FloatingActionButton.small(
                          heroTag: 'recenter_map',
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF7CB342),
                          onPressed: () {
                            _mapController.move(myCenter, 15.5);
                          },
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Map Legend Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7CB342),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Titik Warga',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF7CB342),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFACC15),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Titik Collector',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFACC15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'User Kolektor',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF7CB342),
                          size: 16,
                        ),
                        Text(
                          'User Warga',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section 2: Orderan Aktif
        Text(
          'Orderan Aktif',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        if (collectorProv.myOrders.any(
          (o) => o.status == 'accepted' || o.status == 'en_route',
        ))
          _buildActiveOrderCard(
            collectorProv.myOrders.firstWhere(
              (o) => o.status == 'accepted' || o.status == 'en_route',
            ),
          )
        else
          _buildNoActiveOrderCard(),
        const SizedBox(height: 14),
        // Lihat Selengkapnya Button
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final activeOrder = collectorProv.myOrders.firstWhere(
                (o) => o.status == 'accepted' || o.status == 'en_route',
                orElse: () => OrderModel(
                  id: '',
                  userId: '',
                  status: 'pending',
                  lat: 0.0,
                  lng: 0.0,
                  address: '',
                  statusHistory: [],
                  createdAt: DateTime.now(),
                ),
              );
              if (activeOrder.id.isNotEmpty) {
                context.push(
                  '/collector/order-detail',
                  extra: activeOrder.toJson(),
                );
              } else {
                AppAlerts.showError(context, 'Tidak ada order aktif untuk ditampilkan');
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lihat Selengkapnya',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  // --- BOTTOM NAVIGATION BAR ---
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFBF360C), // Cohesive Collector Deep Amber Rust Orange
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, 'Beranda'),
          _buildNavItem(1, Icons.chat_bubble, 'Chat'),
          _buildNavItem(2, Icons.account_balance_wallet, 'Pendapatan'),
          _buildNavItem(3, Icons.person, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _bottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _bottomNavIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFFFACC15) : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? const Color(0xFFFACC15) : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // Helper actions
  void _acceptOrder(BuildContext context, String id) async {
    final collectorProv = context.read<CollectorProvider>();
    if (!collectorProv.isOnline) {
      AppAlerts.showError(
        context,
        'Status Anda sedang OFFLINE. Aktifkan status ONLINE terlebih dahulu untuk menerima pesanan!',
      );
      return;
    }
    final success = await collectorProv.acceptOrder(id);
    if (success && mounted) {
      AppAlerts.showSuccess(
        context,
        'Penjemputan berhasil diterima! Pesanan telah masuk ke Orderan Aktif.',
      );
    } else if (mounted) {
      AppAlerts.showError(context, collectorProv.error ?? 'Gagal menerima pesanan');
    }
  }

  Widget _buildShimmerBox({required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
