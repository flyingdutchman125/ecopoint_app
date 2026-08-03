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
  LatLng? _selectedCollectorPoint;
  String? _selectedCollectorName;

  // Default User location (Lamongan / Surabaya area)
  final LatLng _userLocation = LatLng(-7.1185, 112.4166);

  final List<Map<String, dynamic>> _defaultCollectors = [
    {
      'id': 'c1',
      'name': 'Hendra Pengepul (Jelantah & Besi)',
      'rating': 4.8,
      'lat': -7.1150,
      'lng': 112.4200,
      'distance_km': 0.8,
      'status': 'online',
      'phone': '081234567890',
    },
    {
      'id': 'c2',
      'name': 'Bapak Sutarjo (Kardus & Plastik)',
      'rating': 4.6,
      'lat': -7.1220,
      'lng': 112.4100,
      'distance_km': 1.4,
      'status': 'online',
      'phone': '081987654321',
    },
    {
      'id': 'c3',
      'name': 'Mas Budi Kolektor Daur Ulang',
      'rating': 4.9,
      'lat': -7.1110,
      'lng': 112.4250,
      'distance_km': 2.1,
      'status': 'offline',
      'phone': '085711223344',
    },
    {
      'id': 'c4',
      'name': 'Pak Anto Pengepul Sukorejo',
      'rating': 4.7,
      'lat': -7.1250,
      'lng': 112.4220,
      'distance_km': 2.8,
      'status': 'online',
      'phone': '082199887766',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchNearbyCollectors();
  }

  Future<void> _fetchNearbyCollectors() async {
    setState(() => _loading = true);
    try {
      final resp = await ApiService.get(ApiConstants.nearbyCollectors);
      if (resp.statusCode == 200) {
        final body = resp.body;
        final decoded = body.isNotEmpty ? jsonDecode(body) : null;
        final data = decoded != null && decoded['data'] != null
            ? decoded['data'] as List
            : [];
        if (data.isNotEmpty) {
          setState(() {
            _collectors = List<Map<String, dynamic>>.from(
              data.map((e) => Map<String, dynamic>.from(e)),
            );
          });
        } else {
          setState(() => _collectors = List.from(_defaultCollectors));
        }
      } else {
        setState(() => _collectors = List.from(_defaultCollectors));
      }
    } catch (e) {
      setState(() => _collectors = List.from(_defaultCollectors));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectCollector(Map<String, dynamic> c) {
    final lat = (c['lat'] as num).toDouble();
    final lng = (c['lng'] as num).toDouble();
    final target = LatLng(lat, lng);

    setState(() {
      _selectedCollectorPoint = target;
      _selectedCollectorName = c['name'];
    });

    _mapController.move(target, 15.5);
    _showCollectorBottomSheet(c);
  }

  void _showCollectorBottomSheet(Map<String, dynamic> c) {
    final isOnline = c['status'] == 'online';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE8F5E9),
                    child: Icon(
                      Icons.person_pin_circle,
                      color: isOnline ? const Color(0xFF7CB342) : Colors.grey,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['name'] ?? 'Kolektor',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${c['rating'] ?? 4.8}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isOnline ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isOnline ? 'Online (Aktif)' : 'Offline',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isOnline ? const Color(0xFF2E7D32) : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Jarak dari lokasi Anda: ${c['distance_km'] ?? '1.2'} km',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push(
                          '/warga/chat-room',
                          extra: {
                            'orderId': 'order_map_${c['id']}',
                            'name': c['name'],
                          },
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF7CB342)),
                      label: Text(
                        'Chat Kolektor',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7CB342),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF7CB342)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                        Navigator.pop(ctx);
                        context.push(
                          '/create-order',
                          extra: {
                            'collector_id': c['id'],
                            'collector_name': c['name'],
                          },
                        );
                      },
                      icon: const Icon(Icons.local_shipping, color: Colors.white),
                      label: Text(
                        'Pesan Penjemputan',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CB342),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
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
        title: Text(
          'Rute Map Kolektor',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informational Banner explaining feature purpose
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Peta interaktif untuk memantau kolektor terdekat & membuat janji penjemputan sampah.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interactive Map Container
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _userLocation,
                    initialZoom: 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.ecopoint',
                    ),
                    if (_selectedCollectorPoint != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [_userLocation, _selectedCollectorPoint!],
                            color: const Color(0xFF7CB342),
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        // User Marker (Home)
                        Marker(
                          point: _userLocation,
                          width: 44,
                          height: 44,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF7CB342),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: const Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        // Collector Markers
                        ..._collectors.map((c) {
                          final lat = (c['lat'] as num).toDouble();
                          final lng = (c['lng'] as num).toDouble();
                          final status = c['status'] ?? 'offline';
                          final isSelected = _selectedCollectorName == c['name'];

                          return Marker(
                            point: LatLng(lat, lng),
                            width: 42,
                            height: 42,
                            child: GestureDetector(
                              onTap: () => _selectCollector(c),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: status == 'online'
                                      ? (isSelected ? const Color(0xFF2E7D32) : const Color(0xFF7CB342))
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.amber : Colors.white,
                                    width: isSelected ? 3.0 : 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 4),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.moped,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kolektor Terdekat',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _fetchNearbyCollectors,
                  icon: _loading
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 16, color: Color(0xFF7CB342)),
                  label: Text(
                    'Refresh',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7CB342),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _collectors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final c = _collectors[index];
                final isOnline = c['status'] == 'online';
                final isSelected = _selectedCollectorName == c['name'];

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF7CB342) : const Color(0xFFEEEEEE),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: isOnline ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                      child: Icon(
                        Icons.moped,
                        color: isOnline ? const Color(0xFF7CB342) : Colors.grey,
                      ),
                    ),
                    title: Text(
                      c['name'] ?? '-',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${c['rating'] ?? 4.8}',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${c['distance_km'] ?? '1.0'} km',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isOnline ? 'Online' : 'Offline',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isOnline ? const Color(0xFF2E7D32) : Colors.grey,
                        ),
                      ),
                    ),
                    onTap: () => _selectCollector(c),
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
