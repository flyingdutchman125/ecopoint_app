import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../models/order_model.dart';
import '../../core/utils/currency_formatter.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProv = context.watch<UserProvider>();
    
    final orderList = userProv.orders.where((o) => o.id == orderId).toList();
    final OrderModel? order = orderList.isNotEmpty ? orderList.first : null;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(child: Text('Pesanan tidak ditemukan')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Detail Pesanan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    'Status Pesanan',
                    style: GoogleFonts.inter(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.statusLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ],
              ),
            ).animate().fade().scale(),

            const SizedBox(height: 24),

            // Order Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Sampah',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(context, Icons.category_rounded, 'Jenis', order.itemType ?? '-'),
                    const SizedBox(height: 16),
                    _buildInfoRow(context, Icons.scale_rounded, 'Estimasi Berat', CurrencyFormatter.formatWeight(order.estWeight)),
                    if (order.actualWeight != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(context, Icons.monitor_weight_rounded, 'Berat Aktual', CurrencyFormatter.formatWeight(order.actualWeight)),
                    ],
                    if (order.totalAmount != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(context, Icons.payments_rounded, 'Total Didapat', CurrencyFormatter.formatRupiah(order.totalAmount!), isHighlight: true),
                    ],
                  ],
                ),
              ),
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

            const SizedBox(height: 16),

            // Location Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Penjemputan',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 32),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            order.pickupAddress.isNotEmpty ? order.pickupAddress : '-',
                            style: GoogleFonts.inter(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    if (order.notes != null && order.notes!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Catatan:',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(order.notes!, style: GoogleFonts.inter()),
                    ],
                  ],
                ),
              ),
            ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Actions
            if (order.canCancel)
              ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Batalkan Pesanan'),
                      content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Tidak'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Ya, Batalkan'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    final success = await context.read<UserProvider>().cancelOrder(order.id);
                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
                        );
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(context.read<UserProvider>().error ?? 'Gagal membatalkan pesanan')),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Batalkan Pesanan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {bool isHighlight = false}) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: isHighlight ? 16 : 14,
            color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'en_route':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
