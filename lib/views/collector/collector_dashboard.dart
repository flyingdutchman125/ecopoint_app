import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/collector_provider.dart';

class CollectorDashboard extends StatefulWidget {
  const CollectorDashboard({super.key});

  @override
  State<CollectorDashboard> createState() => _CollectorDashboardState();
}

class _CollectorDashboardState extends State<CollectorDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectorProvider>().updateLocationAndFetchNearby();
    });
  }

  bool _showMap = false;
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    final collectorProv = context.watch<CollectorProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF8FD14A),
              const Color(0xFF3E8E1E),
            ],
          ),
        ),
        child: SafeArea(
          child: collectorProv.isLoading
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: () => collectorProv.updateLocationAndFetchNearby(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    children: [
                      // Header: name + rating + offline toggle
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bang Ridwan', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, size: 14, color: Colors.yellow),
                                          const SizedBox(width: 6),
                                          Text('4.9', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text('Mitra Pengepul - Wilayah Lamongan', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Offline toggle
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  children: [
                                    const Text('Offline', style: TextStyle(color: Colors.white)),
                                    const SizedBox(width: 6),
                                    Switch(value: _isOnline, onChanged: (v) { setState(() { _isOnline = v; }); if (v) { collectorProv.updateLocationAndFetchNearby(); } }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Earnings card + small stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Estimasi Saldo yang didapatkan hari ini', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            Text('Rp ${collectorProv.earnings}', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _smallStatCard('Selesai', '${collectorProv.myOrders.where((o) => o.status == "completed").length} Order'),
                                                                _smallStatCard('Total Berat', '${collectorProv.myOrders.fold<double>(0, (p, c) => p + (c.weightKg ?? 0)).toStringAsFixed(1)} Kg'),
                                                                _smallStatCard('Jam Kerja', '0 Jam'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Toggle buttons
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _showMap = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_showMap ? const Color(0xFFEBD74A) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [Icon(Icons.radar, color: Colors.black54), SizedBox(width: 8), Text('Radar Order')],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _showMap = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _showMap ? const Color(0xFFEBD74A) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [Icon(Icons.map, color: Colors.black54), SizedBox(width: 8), Text('Peta Rute GPS')],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Conditional content: Radar or Map
                      if (_showMap) ...[
                        Text('Lokasi Orderan Sekitar', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          height: 300,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              options: MapOptions(
                                                              initialCenter: collectorProv.nearbyOrders.isNotEmpty
                                    ? LatLng(collectorProv.nearbyOrders.first.lat, collectorProv.nearbyOrders.first.lng)
                                    : const LatLng(-6.2088, 106.8456),
                                                              initialZoom: 14.0,
                              ),
                              children: [
                                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                                MarkerLayer(markers: collectorProv.nearbyOrders.map((order) => Marker(point: LatLng(order.lat, order.lng), width: 60, height: 60, child: const Icon(Icons.location_on, color: Colors.green, size: 32))).toList()),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _legendDot(Colors.green, 'Titik Warga'),
                            const SizedBox(width: 12),
                            _legendDot(Colors.yellow, 'Titik Collector'),
                          ],
                        ),
                      ] else ...[
                        Text('Permintaan Penjemputan Masuk', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (collectorProv.nearbyOrders.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: Text('Tidak ada permintaan penjemputan saat ini', style: TextStyle(color: Colors.grey.shade700)),
                          )
                        else
                          ...collectorProv.nearbyOrders.take(3).map((order) => Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(radius: 22, child: Text(order.userId.isNotEmpty ? order.userId[0].toUpperCase() : 'U')), 
                                                                    title: Text(order.userId.isNotEmpty ? order.userId : 'Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                    subtitle: Text('${order.distanceMeters != null ? (order.distanceMeters!/1000).toStringAsFixed(1) + ' km' : ''} • ${order.address}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                  trailing: ElevatedButton(
                                    onPressed: () => _acceptOrder(context, order.id),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF59B41C)),
                                    child: const Text('Terima Penjemputan'),
                                  ),
                                ),
                              )),
                      ],

                      const SizedBox(height: 18),

                      // Active order preview
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            if (collectorProv.myOrders.isNotEmpty) ...[
                              ListTile(
                                leading: CircleAvatar(radius: 26, child: Text(collectorProv.myOrders.first.userId.isNotEmpty ? collectorProv.myOrders.first.userId[0].toUpperCase() : 'U')),
                                                                title: Text(collectorProv.myOrders.first.userId.isNotEmpty ? collectorProv.myOrders.first.userId : 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                subtitle: Text('${collectorProv.myOrders.first.distanceMeters != null ? (collectorProv.myOrders.first.distanceMeters!/1000).toStringAsFixed(1) + ' km' : ''} • ${collectorProv.myOrders.first.address}'),
                                trailing: const Icon(Icons.chevron_right),
                              ),
                              const SizedBox(height: 8),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Lihat Selengkapnya', style: TextStyle(color: Colors.white)),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _smallStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: const Color(0xFFF0F8E6), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildEarningsCard(ThemeData theme, CollectorProvider prov) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFff9a44), Color(0xFFfc6076)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFff9a44).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Earnings',
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rp ${prov.earnings}',
            style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: -1),
          ),
        ],
      ),
    );
  }

  void _acceptOrder(BuildContext context, String id) async {
    final success = await context.read<CollectorProvider>().acceptOrder(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order Accepted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
    }
  }

  void _showOrderDetails(BuildContext context, dynamic order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Text('Pickup Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.category_rounded, color: Colors.orange)),
              title: Text('${order.category} • ${order.weightKg}kg', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Rp ${order.totalPrice}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.location_on_rounded, color: Colors.red)),
              title: const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(order.address),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _acceptOrder(context, order.id);
                },
                child: const Text('Accept Pickup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _completeOrder(BuildContext context, String id) async {
    final weightCtrl = TextEditingController();
    
    final actualWeight = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete Order'),
          content: TextField(
            controller: weightCtrl,
            decoration: const InputDecoration(
              labelText: 'Actual Weight (kg)',
              hintText: 'Enter the final weighed amount',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final w = double.tryParse(weightCtrl.text);
                Navigator.pop(context, w);
              },
              child: const Text('Submit'),
            )
          ],
        );
      }
    );

    if (actualWeight == null || actualWeight <= 0) return;

    if (!mounted) return;
    
    final success = await context.read<CollectorProvider>().completeOrder(id, actualWeight);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Order Completed! Earnings updated.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
    }
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildShimmerBox(height: 180),
        const SizedBox(height: 32),
        _buildShimmerBox(height: 30, width: 150),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 140),
        const SizedBox(height: 16),
        _buildShimmerBox(height: 140),
      ],
    );
  }

  Widget _buildShimmerBox({required double height, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
