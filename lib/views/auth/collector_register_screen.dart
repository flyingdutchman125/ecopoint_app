import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class CollectorBusinessScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const CollectorBusinessScreen({super.key, this.extra});

  @override
  State<CollectorBusinessScreen> createState() => _CollectorBusinessScreenState();
}

class _CollectorBusinessScreenState extends State<CollectorBusinessScreen> {
  final _businessCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();

  @override
  void dispose() {
    _businessCtrl.dispose();
    _vehicleCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_businessCtrl.text.trim().isEmpty || _vehicleCtrl.text.trim().isEmpty || _plateCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan lengkapi nama usaha, jenis kendaraan, dan nomor plat.', style: GoogleFonts.outfit())),
      );
      return;
    }

    final extra = {
      ...?widget.extra,
      'business_name': _businessCtrl.text.trim(),
      'vehicle': _vehicleCtrl.text.trim(),
      'plate': _plateCtrl.text.trim(),
    };
    context.push('/register/collector/ktp', extra: extra);
  }
  
  Widget _buildStepIndicator(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFF59B41C),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF59B41C),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F9D9),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7F9D9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Daftar Kolektor',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LANGKAH 1 DARI 2 : NAMA USAHA & KENDARAAN',
                            style: GoogleFonts.outfit(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStepIndicator('Usaha & Kendaraan'),
                          const SizedBox(height: 24),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('NAMA USAHA'),
                              _buildTextField(controller: _businessCtrl, hintText: 'Pak tejo Pengepul Hits'),
                              const SizedBox(height: 18),
                              _buildLabel('JENIS KENDARAAN'),
                              _buildTextField(controller: _vehicleCtrl, hintText: 'Contoh : Mobil Pick up, Becak'),
                              const SizedBox(height: 18),
                              _buildLabel('NO PLAT KENDARAAN'),
                              _buildTextField(controller: _plateCtrl, hintText: 'S 1234 JZ'),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _goNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF59B41C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Lanjutkan',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    );
  }
}

class CollectorKtpScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const CollectorKtpScreen({super.key, this.extra});

  @override
  State<CollectorKtpScreen> createState() => _CollectorKtpScreenState();
}

class _CollectorKtpScreenState extends State<CollectorKtpScreen> {
  bool _agree = false;
  XFile? _pickedKtpFile;
  String? _uploadedKtpUrl;
  bool _isUploading = false;

  Future<void> _pickKtpPhoto(ImageSource source) async {
    final picked = await ImagePickerHelper.pickImage(source);
    if (picked == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin kamera/galeri ditolak atau foto tidak dipilih.', style: GoogleFonts.outfit())),
        );
      }
      return;
    }

    setState(() {
      _pickedKtpFile = picked;
      _isUploading = true;
    });

    try {
      final uploadRes = await ApiService.upload(ApiConstants.upload, picked.path);
      final uploadData = jsonDecode(uploadRes.body);
      if (uploadRes.statusCode == 200 && uploadData['success'] == true) {
        setState(() {
          _uploadedKtpUrl = (uploadData['data']['url'] as String)
              .replaceFirst('localhost', '10.0.2.2');
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto KTP berhasil diunggah.', style: GoogleFonts.outfit())));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengunggah KTP. Silakan coba lagi.', style: GoogleFonts.outfit())));
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiConnectionException
            ? e.message
            : 'Error unggah KTP: ${e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: GoogleFonts.outfit())));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF59B41C)),
                title: Text('Ambil foto dari kamera', style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickKtpPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF59B41C)),
                title: Text('Pilih dari galeri', style: GoogleFonts.outfit(fontSize: 16)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickKtpPhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitCollector() async {
    final auth = context.read<AuthProvider>();

    final name = widget.extra?['name'] ?? '';
    final phone = widget.extra?['phone'] ?? '';
    final email = widget.extra?['email'] ?? '';
    final city = widget.extra?['city'] ?? '';
    final address = widget.extra?['address'] ?? '';
    final subdistrict = widget.extra?['subdistrict'] ?? '';
    final password = widget.extra?['password'] ?? '';
    final businessName = widget.extra?['business_name'] ?? '';
    final vehicle = widget.extra?['vehicle'] ?? '';
    final plate = widget.extra?['plate'] ?? '';

    if (address.trim().isEmpty || subdistrict.trim().isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lengkapi alamat, kecamatan, dan kata sandi sebelum melanjutkan.', style: GoogleFonts.outfit())));
      return;
    }

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Silakan setujui pernyataan sebelum melanjutkan.', style: GoogleFonts.outfit())));
      return;
    }

    if (_uploadedKtpUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Silakan unggah foto KTP.', style: GoogleFonts.outfit())));
      return;
    }

    final success = await auth.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      city: city,
      address: address,
      subdistrict: subdistrict,
      role: 'collector',
      consentSorting: _agree,
      businessName: businessName,
      vehicleType: vehicle,
      vehiclePlate: plate,
      ktpUrl: _uploadedKtpUrl,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pendaftaran kolektor dikirim. Tunggu verifikasi admin.', style: GoogleFonts.outfit())));
      context.go('/login');
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!, style: GoogleFonts.outfit())));
    }
  }

  Widget _buildStepIndicator(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFF59B41C),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF59B41C),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF59B41C),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7F9D9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Daftar Kolektor',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LANGKAH 2 DARI 2 : KTP',
                            style: GoogleFonts.outfit(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStepIndicator('KTP & Persetujuan'),
                          const SizedBox(height: 24),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabel('FOTO KTP'),
                              InkWell(
                                onTap: _isUploading ? null : _showImageSourceOptions,
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.transparent),
                                    color: Colors.grey[100],
                                    image: (_pickedKtpFile != null || _uploadedKtpUrl != null)
                                        ? DecorationImage(
                                            image: _pickedKtpFile != null
                                                ? FileImage(File(_pickedKtpFile!.path)) as ImageProvider
                                                : NetworkImage(_uploadedKtpUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _isUploading
                                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF59B41C)))
                                      : (_pickedKtpFile != null || _uploadedKtpUrl != null)
                                          ? Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withAlpha(128),
                                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                                                ),
                                                padding: const EdgeInsets.all(12),
                                                child: Text(
                                                  'KTP siap digunakan',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.camera_alt_outlined, size: 42, color: Colors.black38),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Ambil Foto KTP anda dengan jelas',
                                                    style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.grey.shade300),
                                                    ),
                                                    child: Text(
                                                      'Upload Foto KTP',
                                                      style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.w600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _agree,
                                      activeColor: const Color(0xFF59B41C),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      onChanged: (v) => setState(() => _agree = v ?? false),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Saya menyetujui pernyataan dan berjanji melaksanakan tugas dengan sebaik mungkin dan sejujur - jujurnya',
                                      style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _submitCollector,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF59B41C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Selesaikan Daftar',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
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
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
      ),
    );
  }
}
