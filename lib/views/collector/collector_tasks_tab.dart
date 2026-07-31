import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/collector_provider.dart';
import '../../models/order_model.dart';
import '../../core/utils/currency_formatter.dart';

class CollectorTasksTab extends StatelessWidget {
  const CollectorTasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectorProvider>();
    final myOrders = provider.myOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Saya'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.fetchCollectorOrders();
          await provider.fetchEarnings();
        },
        child: Column(
          children: [
            _buildEarningsCard(context, provider).animate().fadeIn().slideY(begin: -0.2, end: 0),
            Expanded(
              child: myOrders.isEmpty
                  ? const Center(child: Text('Belum ada tugas'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: myOrders.length,
                      itemBuilder: (context, index) {
                        final order = myOrders[index];
                        return _buildTaskCard(context, order, provider)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 100 * index))
                            .slideX(begin: 0.2, end: 0);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context, CollectorProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A65), Color(0xFFE64A19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Pendapatan',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.formatRupiah(provider.totalEarnings),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Pesanan Selesai',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '${provider.totalOrders}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, OrderModel order, CollectorProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.itemType ?? 'Barang',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
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
            const SizedBox(height: 16),
            _buildActionButtons(context, order, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'accepted':
        color = Colors.blue;
        label = 'Diterima';
        break;
      case 'en_route':
        color = Colors.orange;
        label = 'Dalam Perjalanan';
        break;
      case 'completed':
        color = Colors.green;
        label = 'Selesai';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderModel order, CollectorProvider provider) {
    if (order.status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => provider.enRouteOrder(order.id),
          child: const Text('Mulai Perjalanan'),
        ),
      );
    } else if (order.status == 'en_route') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _showWeightDialog(context, order, provider),
          child: const Text('Selesaikan Pesanan'),
        ),
      );
    } else if (order.status == 'completed') {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Tugas Selesai', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _showWeightDialog(BuildContext context, OrderModel order, CollectorProvider provider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Masukkan Berat Aktual (kg)'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Misal: 5.5',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text);
              if (weight != null && weight > 0) {
                Navigator.pop(context);
                try {
                  await provider.completeOrder(order.id, weight);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
