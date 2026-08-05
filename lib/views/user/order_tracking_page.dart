import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

  Widget _statusStep({
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isCurrent,
    required bool isLast,
  }) {
    Color circleColor;
    IconData iconData;

    if (isDone) {
      circleColor = const Color(0xFF358C16);
      iconData = Icons.check;
    } else if (isCurrent) {
      circleColor = const Color(0xFFFACC15);
      iconData = Icons.two_wheeler;
    } else {
      circleColor = Colors.grey.shade300;
      iconData = Icons.circle;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFACC15).withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                iconData,
                size: 16,
                color: isCurrent ? Colors.black : Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.5,
                height: 36,
                color: isDone ? const Color(0xFF358C16) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: _jakarta(
                  fontSize: 13,
                  fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent
                      ? const Color(0xFF1E293B)
                      : (isDone ? Colors.black87 : Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: _jakarta(
                  fontSize: 11,
                  color: isCurrent ? const Color(0xFF358C16) : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = extra != null && extra!['order'] != null
        ? Map<String, dynamic>.from(extra!['order'])
        : null;
    final id = order?['id']?.toString() ?? 'EP-982103';
    final name = order?['name']?.toString() ?? 'Budi Kolektor (Mitra Resmi)';
    final code = order?['code']?.toString() ?? id;
    final summary = order?['summary']?.toString() ?? 'Plastik PET Bening (10.0 Kg)';
    final completed = order?['completed'] == true;

    final LatLng collectorPos = LatLng(-7.1186, 112.4162);
    final LatLng wargaPos = LatLng(-7.1198, 112.4180);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Lacak Penjemputan GPS',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SECTION 1: LIVE MAP TRACKING =================
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            (collectorPos.latitude + wargaPos.latitude) / 2,
                            (collectorPos.longitude + wargaPos.longitude) / 2,
                          ),
                          initialZoom: 15.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.ecopoint',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [collectorPos, wargaPos],
                                color: const Color(0xFF358C16),
                                strokeWidth: 4.5,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              // Collector Marker
                              Marker(
                                point: collectorPos,
                                width: 50,
                                height: 50,
                                child: Container(
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
                              ),
                              // Warga Marker
                              Marker(
                                point: wargaPos,
                                width: 44,
                                height: 44,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Color(0xFF358C16),
                                  size: 38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
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
                                completed
                                    ? 'PENJEMPUTAN SELESAI'
                                    : 'KOLEKTOR DALAM PERJALANAN (~5 MENIT)',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ================= SECTION 2: MITRA KOLEKTOR PROFILE CARD =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF358C16),
                          child: const Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: _jakarta(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Honda Vario 125 • S 4891 XX (4.9 ★)',
                                style: _jakarta(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF358C16).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'MITRA RESMI',
                            style: _jakarta(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF358C16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.push(
                                '/warga/chat-room',
                                extra: {
                                  'name': name,
                                  'orderId': id,
                                },
                              );
                            },
                            icon: const Icon(Icons.chat, size: 16, color: Color(0xFF358C16)),
                            label: Text('Chat Mitra', style: _jakarta(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF358C16))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF358C16)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Menghubungi nomor telepon Mitra Kolektor...')),
                              );
                            },
                            icon: const Icon(Icons.phone, size: 16, color: Colors.white),
                            label: Text('Telepon', style: _jakarta(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF358C16),
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
              const SizedBox(height: 16),

              // ================= SECTION 3: ORDER SUMMARY CARD =================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KODE ORDER',
                          style: _jakarta(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          code,
                          style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ESTIMASI SAMPAH',
                          style: _jakarta(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF358C16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ================= SECTION 4: LIVE STATUS TIMELINE =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Perkembangan Order',
                      style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),
                    _statusStep(
                      title: 'Pesanan Berhasil Dibuat',
                      subtitle: 'Pesanan Anda telah tercatat di sistem EcoPoint.',
                      isDone: true,
                      isCurrent: false,
                      isLast: false,
                    ),
                    _statusStep(
                      title: 'Kolektor Menerima Pesanan',
                      subtitle: 'Mitra $name menyanggupi penjemputan.',
                      isDone: true,
                      isCurrent: false,
                      isLast: false,
                    ),
                    _statusStep(
                      title: 'Kolektor Dalam Perjalanan (Live GPS)',
                      subtitle: completed ? 'Selesai ditempuh' : 'Sedang meluncur ke lokasi rumah Anda (~5 min).',
                      isDone: completed,
                      isCurrent: !completed,
                      isLast: false,
                    ),
                    _statusStep(
                      title: 'Tiba & Penimbangan Sampah',
                      subtitle: 'Penimbangan & penyesuaian bobot di lokasi.',
                      isDone: completed,
                      isCurrent: false,
                      isLast: false,
                    ),
                    _statusStep(
                      title: 'Selesai & Saldo Masuk',
                      subtitle: 'Saldo & EcoPoint otomatis cair ke dompet Anda.',
                      isDone: completed,
                      isCurrent: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ================= SECTION 5: ACTION BUTTON =================
              if (!completed)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(
                            'Selesaikan Order',
                            style: _jakarta(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'Konfirmasi bahwa penjemputan telah selesai dan barang telah ditimbang?',
                            style: _jakarta(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Batal', style: _jakarta(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF358C16),
                              ),
                              child: Text('Ya, Selesai', style: _jakarta(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        context.push(
                          '/rating/detail',
                          extra: {
                            'mode': 'create',
                            'item': {
                              'id': id,
                              'orderId': id,
                              'name': name,
                              'detail': summary,
                              'orderCode': code,
                            },
                          },
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF358C16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Konfirmasi Penjemputan Selesai',
                      style: _jakarta(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '/rating/detail',
                        extra: {
                          'mode': 'create',
                          'item': {
                            'id': id,
                            'orderId': id,
                            'name': name,
                            'detail': summary,
                            'orderCode': code,
                          },
                        },
                      );
                    },
                    icon: const Icon(Icons.star, color: Colors.white),
                    label: Text(
                      'Berikan Rating & Ulasan',
                      style: _jakarta(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF358C16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

