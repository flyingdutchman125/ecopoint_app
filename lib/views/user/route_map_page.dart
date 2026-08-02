import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';

import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';
import 'package:go_router/go_router.dart';

class RouteMapPage extends StatefulWidget {
  const RouteMapPage({super.key});

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  final MapController _mapController = MapController();
  bool _loading = false;
  List<Map<String, dynamic>> _collectors = [];

  // For demo start center to Surabaya
  final LatLng _center = LatLng(-7.2575, 112.7521);

  @override
  void initState() {
    super.initState();
    // preload dummy collectors (so map shows markers immediately)
    _fetchNearbyCollectors();
  }

  Future<void> _fetchNearbyCollectors() async {
    setState(() => _loading = true);
    try {
      final resp = await ApiService.get(ApiConstants.nearbyCollectors);
      if (resp.statusCode == 200) {
        final body = resp.body;
        final decoded = body.isNotEmpty ? jsonDecode(body) : null;
        final data = decoded != null && decoded['data'] != null ? decoded['data'] as List : [];
        setState(() {
                _collectors = List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e)));
        });
      }
    } catch (e) {
      // ignore, keep UI usable
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.maybeOf(context)?.pop(),
        ),
        title: Text('Rute Map', style: GoogleFonts.outfit(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16,12,16,8),
            child: Text('Pilih kolektor atau klik search untuk mencari otomatis !', style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 240,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.ecopoint',
                    ),
                    MarkerLayer(
                      markers: [
                        // user marker
                        Marker(
                          point: _center,
                          width: 40,
                          height: 40,
                          child: const CircleAvatar(backgroundColor: Color(0xFF7CB342), child: Icon(Icons.person, color: Colors.white, size: 18)),
                        ),
                        // collector markers
                        ..._collectors.map((c) {
                          final lat = (c['lat'] as num).toDouble();
                          final lng = (c['lng'] as num).toDouble();
                          final status = c['status'] ?? 'offline';
                          return Marker(
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () {
                                // focus map to marker
                                _mapController.move(LatLng(lat, lng), 16);
                              },
                              child: CircleAvatar(
                                backgroundColor: status == 'online' ? const Color(0xFF7CB342) : const Color(0xFFBDBDBD),
                                child: const Icon(Icons.location_on, color: Colors.white, size: 18),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20,12,20,0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _fetchNearbyCollectors,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7CB342), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Cari otomatis kolektor !', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Kolektor terdekat dari rumah anda', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: _collectors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = _collectors[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListTile(
                    leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFFF5F5F5), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE0E0E0))), child: const Icon(Icons.psychology_alt_outlined, color: Colors.black54)),
                    title: Text(c['name'] ?? '-', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    subtitle: Text('Rating Pengepul : ${c['rating']?.toString() ?? '-'}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9E9E9E))),
                    trailing: Text('${c['distance_km']?.toString() ?? '-'} km Dari anda', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9E9E9E))),
                    onTap: () {
                      // focus map to marker
                      final lat = (c['lat'] as num).toDouble();
                      final lng = (c['lng'] as num).toDouble();
                      _mapController.move(LatLng(lat, lng), 16);
                      // Provide a quick choice dialog to either chat or continue to order
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.chat_bubble_outline),
                                title: Text('Chat dengan ${c['name']}', style: GoogleFonts.inter()),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  context.push('/warga/chat-room', extra: {'orderId': 'order_from_map_${c['id']}', 'name': c['name']});
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.check_circle_outline),
                                title: const Text('Lanjutkan ke Order'),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  // create a demo order object and navigate to orders page
                                  final order = {'id': 'EP_MAP_${c['id']}', 'name': c['name'], 'summary': '${c['distance_km'] ?? '-'} km', 'code': 'EP_MAP_${c['id']}', 'completed': false};
                                  context.push('/orders', extra: {'fromMap': true, 'order': order});
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
