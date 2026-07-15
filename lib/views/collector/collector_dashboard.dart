import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/auth_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final collectorProv = context.watch<CollectorProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Collector Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: collectorProv.isLoading
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: () => collectorProv.updateLocationAndFetchNearby(),
                  child: ListView(
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      _buildEarningsCard(theme, collectorProv).animate().fade(duration: 500.ms).slideY(begin: -0.1),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nearby Pickups', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.radar, color: Colors.orange, size: 16),
                                const SizedBox(width: 4),
                                Text('${collectorProv.nearbyOrders.length}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ).animate().fade(delay: 200.ms),
                      const SizedBox(height: 16),
                      if (collectorProv.nearbyOrders.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.location_off_rounded, size: 64, color: Colors.grey.withOpacity(0.4)),
                                const SizedBox(height: 16),
                                Text('No orders nearby', style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ).animate().fade(delay: 300.ms)
                      else
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: collectorProv.nearbyOrders.isNotEmpty 
                                  ? LatLng(collectorProv.nearbyOrders.first.lat, collectorProv.nearbyOrders.first.lng)
                                  : const LatLng(-6.2088, 106.8456), // Jakarta fallback
                                initialZoom: 13.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.ecopoint',
                                ),
                                MarkerLayer(
                                  markers: collectorProv.nearbyOrders.map((order) {
                                    return Marker(
                                      point: LatLng(order.lat, order.lng),
                                      width: 80,
                                      height: 80,
                                      child: GestureDetector(
                                        onTap: () {
                                          _showOrderDetails(context, order);
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: theme.colorScheme.primary, width: 2),
                                              ),
                                              child: Text('Rp ${order.totalPrice}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: theme.colorScheme.primary)),
                                            ),
                                            const Icon(Icons.location_on, color: Colors.red, size: 40),
                                          ],
                                        ).animate().scale(delay: 200.ms),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
                      const SizedBox(height: 32),
                      Text('My Active Tasks', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))
                          .animate().fade(delay: 500.ms),
                      const SizedBox(height: 16),
                      if (collectorProv.myOrders.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text('No active tasks', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                          ),
                        ).animate().fade(delay: 600.ms)
                      else
                        ...collectorProv.myOrders.asMap().entries.map((entry) {
                          final index = entry.key;
                          final order = entry.value;
                          final isActive = order.status == 'accepted' || order.status == 'en_route';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Icon(isActive ? Icons.local_shipping_rounded : Icons.check_circle_rounded, color: isActive ? Colors.blue : Colors.green, size: 32),
                              title: Text(order.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Status: ${order.status.toUpperCase()}'),
                              trailing: isActive
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _completeOrder(context, order.id),
                                      child: const Text('Complete'),
                                    )
                                  : const Text('Done', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          ).animate().fade(delay: (600 + (index * 100)).ms).slideY(begin: 0.1);
                        })
                    ],
                  ),
                ),
        ),
      ),
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
