import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/collector_provider.dart';
import '../../models/order_model.dart';

class CollectorNearbyTab extends StatefulWidget {
  const CollectorNearbyTab({super.key});

  @override
  State<CollectorNearbyTab> createState() => _CollectorNearbyTabState();
}

class _CollectorNearbyTabState extends State<CollectorNearbyTab> {
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
    final provider = context.watch<CollectorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Sekitar'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.updateLocationAndFetchNearby();
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: _buildMap(provider.nearbyOrders),
              ),
            ),
            if (provider.isLoading)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildShimmer(),
                  childCount: 3,
                ),
              )
            else if (provider.nearbyOrders.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text('Tidak ada pesanan di sekitar Anda saat ini'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final order = provider.nearbyOrders[index];
                    return _buildOrderCard(order, provider)
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 100 * index))
                        .slideY(begin: 0.2, end: 0);
                  }, childCount: provider.nearbyOrders.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(List<OrderModel> orders) {
    final defaultCenter = const LatLng(-6.200000, 106.816666);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: defaultCenter, initialZoom: 13.0),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.ecopoint',
        ),
        MarkerLayer(
          markers: orders.asMap().entries.map((entry) {
            final idx = entry.key;
            // Fake offset to spread markers around
            final lat = defaultCenter.latitude + (idx * 0.005);
            final lng = defaultCenter.longitude + (idx * 0.005);
            return Marker(
              point: LatLng(lat, lng),
              width: 40,
              height: 40,
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, CollectorProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.itemType ?? 'Barang Campuran',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(order.distanceMeters ?? 0) / 1000} km',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.pickupAddress,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.scale_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${order.estWeight} kg',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _acceptOrder(context, order.id, provider),
                child: const Text('Terima Pesanan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptOrder(
    BuildContext context,
    String orderId,
    CollectorProvider provider,
  ) async {
    try {
      await provider.acceptOrder(orderId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pesanan berhasil diterima')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
