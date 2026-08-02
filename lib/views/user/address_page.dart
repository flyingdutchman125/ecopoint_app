import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/address_state.dart';

TextStyle _jakarta({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = Colors.black,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final AddressState _addressState = AddressState.instance;

  String? _detectedLat;
  String? _detectedLng;
  bool _isDetectingLocation = false;

  @override
  void initState() {
    super.initState();
    _addressState.init();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Real GPS location detection handler
  Future<void> _detectLocation() async {
    setState(() {
      _isDetectingLocation = true;
    });

    try {
      final loc = await _addressState.detectCurrentLocation();
      setState(() {
        _labelController.text = loc['label'] ?? 'Lokasi GPS Saya';
        _addressController.text = loc['detail'] ?? '';
        _detectedLat = loc['lat'];
        _detectedLng = loc['lng'];
      });
      _showSnack('Lokasi saat ini berhasil terdeteksi!');
    } catch (e) {
      _showSnack('Gagal mendeteksi lokasi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDetectingLocation = false;
        });
      }
    }
  }

  // Fungsi Tambah Alamat Baru dengan simpan nyata ke SharedPreferences
  Future<void> _addAddress() async {
    final label = _labelController.text.trim();
    final detail = _addressController.text.trim();

    if (label.isEmpty || detail.isEmpty) {
      _showSnack('Label dan Alamat Lengkap tidak boleh kosong!');
      return;
    }

    await _addressState.addAddress(
      label: label,
      detail: detail,
      lat: _detectedLat,
      lng: _detectedLng,
    );

    setState(() {
      _labelController.clear();
      _addressController.clear();
      _detectedLat = null;
      _detectedLng = null;
    });

    _showSnack('Alamat baru berhasil disimpan secara nyata!');
    FocusScope.of(context).unfocus();
  }

  // Fungsi Hapus Alamat dengan simpan nyata ke SharedPreferences
  Future<void> _deleteAddress(int index) async {
    await _addressState.deleteAddress(index);
    _showSnack('Alamat berhasil dihapus!');
  }

  // Fungsi Pilih Alamat Utama
  Future<void> _selectAddress(int index) async {
    await _addressState.selectAddress(index);
    _showSnack('Alamat utama berhasil dipilih!');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: _jakarta(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF1B3A1B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Alamat Warga',
          style: _jakarta(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEKSI TAMBAH ALAMAT BARU ---
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  Text(
                    'Tambah Alamat Baru',
                    style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tombol Deteksi Lokasi Real (GPS)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isDetectingLocation ? null : _detectLocation,
                      icon: _isDetectingLocation
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.my_location, size: 20, color: Colors.white),
                      label: Text(
                        _isDetectingLocation ? 'Mendeteksi Lokasi Real (GPS)...' : 'Deteksi Lokasi Saya Saat Ini (GPS)',
                        style: _jakarta(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Label Alamat',
                    hint: 'Kantor, Rumah, dan lain-lain',
                    controller: _labelController,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    label: 'Alamat Lengkap',
                    hint: 'Nama jalan, Blok, No. Rumah, RT/RW, Ciri Gerbang/Pagar ...',
                    controller: _addressController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _addAddress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF82C139),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Simpan Alamat Baru',
                        style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // --- SEKSI DAFTAR ALAMAT TERSIMPAN (PERSISTENT & SELECTABLE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ValueListenableBuilder<List<Map<String, String>>>(
                valueListenable: _addressState.addresses,
                builder: (context, addresses, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: _addressState.selectedIndex,
                    builder: (context, selectedIndex, _) {
                      if (addresses.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final isSelected = selectedIndex == index;
                          final address = addresses[index];

                          return GestureDetector(
                            onTap: () => _selectAddress(index),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF82C139) : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              address['label'] ?? 'Alamat',
                                              style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F5E9),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Utama',
                                                  style: _jakarta(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          address['detail'] ?? '',
                                          style: _jakarta(fontSize: 11, color: Colors.black54),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSelected) ...[
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF82C139),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  // Tombol Hapus Alamat
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                    onPressed: () => _deleteAddress(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: _jakarta(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: _jakarta(fontSize: 14, color: Colors.black38),
            fillColor: const Color(0xFFF4F5F6),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(Icons.location_off_outlined, size: 40, color: Colors.black26),
            const SizedBox(height: 8),
            Text(
              'Belum ada alamat tersimpan',
              style: _jakarta(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}