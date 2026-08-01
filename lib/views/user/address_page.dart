import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  int _selectedAddressIndex = 0; 
  
  // Daftar alamat dibuat non-konstan agar bisa ditambah dan dihapus secara dinamis
  final List<Map<String, String>> _savedAddresses = [
    {
      'label': 'Rumah Admin',
      'detail': 'Jln. Andansari Mojo GG duku No. 3, RT 001/ RW 003, Kelurahan Sukorejo (Rumah Cat Hijau)',
    },
    {
      'label': 'Rumah Si mbah',
      'detail': 'Jl. Kali utik di walik dadi batagor enak nyam nyam no 3 Gerobak abu abu dan blue',
    },
  ];

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Fungsi Fitur Tambah Alamat
  void _addAddress() {
    final label = _labelController.text.trim();
    final detail = _addressController.text.trim();

    if (label.isEmpty || detail.isEmpty) {
      _showSnack('Label dan Alamat Lengkap tidak boleh kosong!');
      return;
    }

    setState(() {
      _savedAddresses.add({
        'label': label,
        'detail': detail,
      });
      _labelController.clear();
      _addressController.clear();
    });

    _showSnack('Alamat baru berhasil ditambahkan!');
    FocusScope.of(context).unfocus(); // Menutup keyboard setelah submit
  }

  // Fungsi Fitur Hapus Alamat
  void _deleteAddress(int index) {
    setState(() {
      _savedAddresses.removeAt(index);
      
      // Amankan indeks pilihan agar tidak crash jika item yang aktif dihapus
      if (_savedAddresses.isEmpty) {
        _selectedAddressIndex = -1;
      } else if (_selectedAddressIndex >= _savedAddresses.length) {
        _selectedAddressIndex = max(0, _savedAddresses.length - 1);
      }
    });

    _showSnack('Alamat berhasil dihapus!');
  }

  void _showSnack(String message) {
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
                  const SizedBox(height: 20),
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
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
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
            
            // --- SEKSI DAFTAR ALAMAT TERSIMPAN ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: _savedAddresses.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _savedAddresses.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedAddressIndex == index;
                        final address = _savedAddresses[index];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAddressIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF82C139) : Colors.transparent,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
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
                                      Text(
                                        address['label']!,
                                        style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        address['detail']!,
                                        style: _jakarta(fontSize: 11, color: Colors.black45),
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
                                // Tombol Aksi Hapus Alamat
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