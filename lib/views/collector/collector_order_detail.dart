import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../core/utils/currency_formatter.dart';

class CollectorOrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const CollectorOrderDetailPage({super.key, required this.order});

  String get _statusLabel {
    switch (order.status) {
      case 'accepted':
        return 'Diterima';
      case 'en_route':
        return 'Dalam Perjalanan';
      case 'completed':
        return 'Selesai';
      case 'pending':
        return 'Menunggu';
      default:
        return order.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Detail Order',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status Order',
                        style: GoogleFonts.inter(color: Colors.grey.shade600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFF7DD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusLabel,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Alamat Penjemputan',
                    style: GoogleFonts.inter(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.address,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoBlock(
                        'Berat',
                        order.weightKg != null
                            ? '${order.weightKg!.toStringAsFixed(1)} Kg'
                            : '-',
                      ),
                      _buildInfoBlock(
                        'Estimasi',
                        order.totalPrice != null
                            ? CurrencyFormatter.formatRupiah(
                                order.totalPrice!.toInt(),
                              )
                            : '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile('ID Order', order.id),
                  const SizedBox(height: 8),
                  _buildInfoTile(
                    'Tanggal',
                    order.createdAt.toLocal().toString(),
                  ),
                  const SizedBox(height: 24),
                  if (order.status == 'accepted' || order.status == 'en_route')
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push(
                            '/collector/order-weigh',
                            extra: order.toJson(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7CB342),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Penimbangan & Validasi',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
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
      ),
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FBF5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: GoogleFonts.inter(color: Colors.grey.shade600)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
