import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class CollectorBusinessScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const CollectorBusinessScreen({Key? key, this.extra}) : super(key: key);

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
        const SnackBar(content: Text('Silakan lengkapi nama usaha, jenis kendaraan, dan nomor plat.')),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black54),
                  ),
                  const Spacer(),
                  Text('Daftar', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LANGKAH 1 DARI 2 : NAMA USAHA & KENDARAAN', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _buildLabel('NAMA USAHA'),
                    _buildTextField(controller: _businessCtrl, hintText: 'Pak tejo Pengepul Hits'),
                    const SizedBox(height: 18),
                    _buildLabel('JENIS KENDARAAN'),
                    _buildTextField(controller: _vehicleCtrl, hintText: 'Contoh : Mobil Pick up, Becak dan Lain-lain'),
                    const SizedBox(height: 18),
                    _buildLabel('NO PLAT KENDARAAN'),
                    _buildTextField(controller: _plateCtrl, hintText: 'S 1234 JZ'),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBD74A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Lanjutkan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
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
  const CollectorKtpScreen({Key? key, this.extra}) : super(key: key);

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
          const SnackBar(content: Text('Izin kamera/galeri ditolak atau foto tidak dipilih.')),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto KTP berhasil diunggah.')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengunggah KTP. Silakan coba lagi.')));
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiConnectionException
            ? e.message
            : 'Error unggah KTP: ${e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil foto dari kamera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickKtpPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.of(context).pop();
                _pickKtpPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCollector() async {
    final auth = context.read<AuthProvider>();

    // collect required fields from previous steps
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

    // validate required fields
    if (address.trim().isEmpty || subdistrict.trim().isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi alamat, kecamatan, dan kata sandi sebelum melanjutkan.')));
      return;
    }

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan setujui pernyataan sebelum melanjutkan.')));
      return;
    }

    if (_uploadedKtpUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan unggah foto KTP.')));
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
      // Optionally, here one could call an endpoint to store collector-specific details (businessName, vehicle, plate, ktpPath)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendaftaran kolektor dikirim. Tunggu verifikasi admin.')));
      context.go('/login');
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black54),
                  ),
                  const Spacer(),
                  Text('Daftar', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LANGKAH 2 DARI 2 : KTP', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _buildLabel('FOTO KTP'),
                    InkWell(
                      onTap: _isUploading ? null : _showImageSourceOptions,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400, width: 1, style: BorderStyle.solid),
                          color: Colors.white,
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
                            ? const Center(child: CircularProgressIndicator())
                            : (_pickedKtpFile != null || _uploadedKtpUrl != null)
                                ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.black.withOpacity(0.4),
                                      padding: const EdgeInsets.all(12),
                                      child: const Text('KTP siap digunakan', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.camera_alt_outlined, size: 36, color: Colors.grey),
                                        const SizedBox(height: 8),
                                        Text('Ambil Foto KTP anda dengan jelas', style: theme.textTheme.bodySmall),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade400),
                                          ),
                                          child: const Text('Upload Foto KTP', style: TextStyle(color: Colors.black54)),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
                        const Expanded(child: Text('Saya menyetujui pernyataan dan berjanji melaksanakan tugas dengan sebaik mungkin dan sejujur - jujurnya')),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitCollector,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEBD74A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Selesaikan Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}
