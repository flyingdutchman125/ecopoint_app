import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

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

class OrderTrackingPage extends StatelessWidget {
  final Map<String, dynamic>? extra;
  const OrderTrackingPage({super.key, this.extra});

  Widget _statusRow(String label, bool done) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: done ? const Color(0xFF4C8C2B) : const Color(0xFFBDBDBD), shape: BoxShape.circle)),
            const SizedBox(height: 6),
            if (!done) Container(width: 2, height: 30, color: const Color(0xFFBDBDBD)) else Container(width: 2, height: 30, color: const Color(0xFF4C8C2B)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: _jakarta(fontSize: 13, color: Colors.black87))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = extra != null && extra!['order'] != null ? Map<String, dynamic>.from(extra!['order']) : null;
    final id = order?['id']?.toString() ?? 'EP0001';
    final name = order?['name']?.toString() ?? 'Bapak Sutarjo Sangar';
    final code = order?['code']?.toString() ?? 'EP 0001';
    final completed = order?['completed'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop()),
        title: Text('Order', style: _jakarta(fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE0E0E0)), borderRadius: BorderRadius.circular(8), color: Colors.white),
                child: Row(
                  children: [
                    Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFF5F5F5), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE0E0E0))), child: const Icon(Icons.person, color: Colors.black54)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: _jakarta(fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Kardus 12kg', style: _jakarta(fontSize: 12, color: Colors.black54)),
                      ]),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('kode orderan : $code', style: _jakarta(fontSize: 12, color: Colors.black54)),
                      const SizedBox(height: 8),
                      Icon(completed ? Icons.check_circle_outline : Icons.expand_more, color: completed ? Colors.green : Colors.black38)
                    ])
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // map placeholder (use small FlutterMap or static container)
                    Container(
                      height: 160,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: const Color(0xFFF5F5F5)),
                      child: Center(child: Icon(Icons.map, size: 48, color: Colors.black26)),
                    ),
                    const SizedBox(height: 12),
                    Text('Status Tracking', style: _jakarta(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _statusRow('Menemukan Mitra kolektor', true),
                    const SizedBox(height: 8),
                    _statusRow('Kolektor & warga menerima kode orderan', true),
                    const SizedBox(height: 8),
                    _statusRow('Driver dalam perjalanan', completed ? true : true),
                    const SizedBox(height: 8),
                    _statusRow('Penimbangan & validasi', completed ? true : false),
                    const SizedBox(height: 12),
                    Text('Orderan Telah selesai jangan lupa memberi rating & Ulasan', style: _jakarta(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (!completed)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Selesaikan Order', style: _jakarta(fontWeight: FontWeight.w700)),
                            content: Text('Konfirmasi order ini telah selesai ?', style: _jakarta()),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal', style: _jakarta(color: Colors.black54))),
                              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Selesai', style: _jakarta(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C8C2B))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // simulate marking order complete and return to orders list
                          final updatedOrder = {'id': id, 'name': name, 'code': code, 'completed': true};
                          // Navigate to orders with update instruction
                          context.push('/orders', extra: {'updateOrder': updatedOrder});
                          // Optionally navigate directly to rating after a short delay
                          await Future.delayed(const Duration(milliseconds: 300));
                          if (!context.mounted) return;
                          context.push('/rating/detail', extra: {'orderId': id});
                        }
                      },
                      child: Text('Selesaikan Order', style: _jakarta(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C8C2B), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    ),
                  ],
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    // navigate to rating detail/create
                    context.push('/rating/detail', extra: {'orderId': id});
                  },
                  icon: const Icon(Icons.star, color: Colors.white),
                  label: Text('Berikan Rating & Ulasan anda', style: _jakarta(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C8C2B), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
