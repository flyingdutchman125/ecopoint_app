import '../../core/utils/alert_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/collector_provider.dart';

class CollectorOrderWeighPage extends StatefulWidget {
  final OrderModel order;

  const CollectorOrderWeighPage({super.key, required this.order});

  @override
  State<CollectorOrderWeighPage> createState() =>
      _CollectorOrderWeighPageState();
}

class _CollectorOrderWeighPageState extends State<CollectorOrderWeighPage> {
  final _weightCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitWeight() async {
    final weight = double.tryParse(_weightCtrl.text);
    if (weight == null || weight <= 0) {
      AppAlerts.showError(context, 'Masukkan berat aktual yang valid');
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await context.read<CollectorProvider>().completeOrder(
      widget.order.id,
      weight,
    );
    setState(() => _isSubmitting = false);

    if (success && mounted) {
      AppAlerts.showSuccess(context, 'Order berhasil diselesaikan');
      context.go('/collector');
    } else if (mounted) {
      AppAlerts.showError(context, 'Gagal menyelesaikan order. Silakan coba lagi.');
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
          'Penimbangan Order',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Order ID',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              widget.order.id,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Berat Estimasi',
              style: GoogleFonts.inter(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              widget.order.weightKg != null
                  ? '${widget.order.weightKg!.toStringAsFixed(1)} Kg'
                  : 'Tidak tersedia',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Masukkan berat aktual sampah setelah ditimbang',
                    style: GoogleFonts.inter(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Berat Aktual (Kg)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7CB342),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Selesaikan Order',
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
    );
  }
}
