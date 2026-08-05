import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/order_model.dart';
import '../../providers/collector_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/alert_helper.dart';

class CollectorOrderWeighPage extends StatefulWidget {
  final OrderModel order;

  const CollectorOrderWeighPage({super.key, required this.order});

  @override
  State<CollectorOrderWeighPage> createState() =>
      _CollectorOrderWeighPageState();
}

class _CollectorOrderWeighPageState extends State<CollectorOrderWeighPage> {
  /// null = Belum divalidasi
  /// true = Centang (Sesuai/Benar)
  /// false = Silang (Salah/Tidak Sesuai -> Diisi via pop-up)
  bool? _isWeightCorrect;
  late double _validatedWeight;
  late double _unitPricePerKg;
  late double _finalTotalPrice;
  bool _isSubmitting = false;

  final TextEditingController _popupWeightCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initialWeight = widget.order.weightKg ?? 1.0;
    _validatedWeight = initialWeight;

    if (widget.order.totalPrice != null &&
        widget.order.totalPrice! > 0 &&
        initialWeight > 0) {
      _unitPricePerKg = widget.order.totalPrice! / initialWeight;
    } else {
      _unitPricePerKg = 4500.0;
    }

    _finalTotalPrice = _validatedWeight * _unitPricePerKg;
  }

  @override
  void dispose() {
    _popupWeightCtrl.dispose();
    super.dispose();
  }

  void _onSelectCorrectWeight() {
    setState(() {
      _isWeightCorrect = true;
      _validatedWeight = widget.order.weightKg ?? 1.0;
      _finalTotalPrice = _validatedWeight * _unitPricePerKg;
    });
    AppAlerts.showSuccess(context, 'Timbangan dikonfirmasi sesuai!');
  }

  void _onSelectIncorrectWeight() {
    _showWeightInputPopup();
  }

  void _showWeightInputPopup() {
    _popupWeightCtrl.text = _validatedWeight.toStringAsFixed(1);
    double modalWeight = _validatedWeight;
    double modalPrice = modalWeight * _unitPricePerKg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

          return Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: bottomPadding + 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_rounded,
                        color: Colors.red,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Koreksi Berat Timbangan',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Input berat fisik hasil penimbangan aktual',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Info Perbandingan
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Input Awal Warga: ${widget.order.weightKg?.toStringAsFixed(1) ?? "0"} Kg (${CurrencyFormatter.formatRupiah(widget.order.totalPrice?.toInt() ?? 0)})',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.amber.shade200
                                : Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Input Berat Timbangan
                TextField(
                  controller: _popupWeightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Berat Hasil Timbangan Aktual (Kg)',
                    labelStyle: GoogleFonts.outfit(fontSize: 14),
                    prefixIcon: const Icon(
                      Icons.scale_rounded,
                      color: Colors.teal,
                    ),
                    suffixText: 'Kg',
                    suffixStyle: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey.shade900
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    final parsed = double.tryParse(val);
                    setModalState(() {
                      if (parsed != null && parsed > 0) {
                        modalWeight = parsed;
                        modalPrice = modalWeight * _unitPricePerKg;
                      } else {
                        modalWeight = 0;
                        modalPrice = 0;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Preview Recalculated Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kalkulasi Harga Baru',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.teal.shade700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${CurrencyFormatter.formatRupiah(_unitPricePerKg.toInt())} / kg',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.formatRupiah(modalPrice.toInt()),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final parsed = double.tryParse(_popupWeightCtrl.text);
                      if (parsed == null || parsed <= 0) {
                        AppAlerts.showError(
                          context,
                          'Masukkan berat yang valid',
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      setState(() {
                        _isWeightCorrect = false;
                        _validatedWeight = parsed;
                        _finalTotalPrice = _validatedWeight * _unitPricePerKg;
                      });
                      AppAlerts.showInfo(
                        context,
                        'Berat diperbarui ke ${parsed.toStringAsFixed(1)} Kg. Harga disesuaikan.',
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      'Simpan & Update Harga',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitFinalOrder() async {
    if (_isWeightCorrect == null) {
      AppAlerts.showError(
        context,
        'Silakan lakukan validasi timbangan dulu (Sesuai [✓] atau Salah [✗])',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await context.read<CollectorProvider>().completeOrder(
          widget.order.id,
          _validatedWeight,
        );
    setState(() => _isSubmitting = false);

    if (success && mounted) {
      AppAlerts.showSuccess(
        context,
        'Order penimbangan berhasil diselesaikan!',
      );
      context.go('/collector');
    } else if (mounted) {
      AppAlerts.showError(
        context,
        'Gagal menyelesaikan order. Silakan coba lagi.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Validasi Timbangan',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order Detail Card Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 14,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          widget.order.category ?? 'Sampah Daur Ulang',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        'ID: ${widget.order.id}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pemilik Limbah: ${widget.order.userName ?? "Warga EcoPoint"}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.order.address,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.05, end: 0),
            const SizedBox(height: 20),

            // Original Weight Input by Owner Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.input_rounded,
                        size: 20,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Inputan Pemilik Limbah (Warga)',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
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
                            'Estimasi Berat Awal',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            widget.order.weightKg != null
                                ? '${widget.order.weightKg!.toStringAsFixed(1)} Kg'
                                : '1.0 Kg',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Estimasi Harga Awal',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            widget.order.totalPrice != null
                                ? CurrencyFormatter.formatRupiah(
                                    widget.order.totalPrice!.toInt(),
                                  )
                                : CurrencyFormatter.formatRupiah(
                                    _finalTotalPrice.toInt(),
                                  ),
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Heading for Validation Actions
            Text(
              'Validasi Hasil Penimbangan Kolektor',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Timbang ulang limbah fisik lalu pilih validasi di bawah ini:',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 14),

            // Two Quick Validation Action Buttons: Centang (✓) vs Silang (✗)
            Row(
              children: [
                // Tombol CENTANG (✓ - Sesuai)
                Expanded(
                  child: InkWell(
                    onTap: _onSelectCorrectWeight,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _isWeightCorrect == true
                            ? Colors.green.withValues(alpha: 0.15)
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isWeightCorrect == true
                              ? Colors.green
                              : Colors.grey.withValues(alpha: 0.3),
                          width: _isWeightCorrect == true ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isWeightCorrect == true
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sesuai (✓)',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Berat Benar',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Tombol SILANG (✗ - Salah / Input Ulang)
                Expanded(
                  child: InkWell(
                    onTap: _onSelectIncorrectWeight,
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _isWeightCorrect == false
                            ? Colors.red.withValues(alpha: 0.15)
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isWeightCorrect == false
                              ? Colors.red
                              : Colors.grey.withValues(alpha: 0.3),
                          width: _isWeightCorrect == false ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isWeightCorrect == false
                                ? Colors.red.withValues(alpha: 0.2)
                                : Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cancel_rounded,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Salah (✗)',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Input Berat Pop-up',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Validation Summary & Recalculated Price Output Card
            if (_isWeightCorrect != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _isWeightCorrect!
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isWeightCorrect!
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isWeightCorrect!
                              ? Icons.verified_rounded
                              : Icons.edit_note_rounded,
                          color: _isWeightCorrect!
                              ? Colors.green
                              : Colors.orange.shade800,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isWeightCorrect!
                              ? 'Status: Timbangan Dikonfirmasi Sesuai'
                              : 'Status: Berat Diperbarui Oleh Kolektor',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _isWeightCorrect!
                                ? Colors.green.shade900
                                : Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Berat Akhir Penimbangan',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_validatedWeight.toStringAsFixed(1)} Kg',
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Bayar Terbaru',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.formatRupiah(
                                _finalTotalPrice.toInt(),
                              ),
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (_isWeightCorrect == false) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _showWeightInputPopup,
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: Text(
                            'Ubah Berat Lagi',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ).animate().fadeIn().scale(begin: const Offset(0.98, 0.98)),
              const SizedBox(height: 24),
            ],

            // Submit Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFinalOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isWeightCorrect != null
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _isWeightCorrect != null ? 3 : 0,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isWeightCorrect == null
                            ? 'Pilih Validasi Timbangan Dulu'
                            : 'Selesaikan Order & Bayar (${CurrencyFormatter.formatRupiah(_finalTotalPrice.toInt())})',
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
