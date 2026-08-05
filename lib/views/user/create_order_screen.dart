import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../providers/user_provider.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/address_state.dart';
import '../../core/notification_state.dart';
import '../../core/history_state.dart';

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

class CreateOrderScreen extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const CreateOrderScreen({super.key, this.extra});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  String? _photoUrl;
  String? _category = 'Logam/Besi';
  bool _isAnalyzing = false;
  String _selectedUnit = 'Kg';
  final _addressCtrl = TextEditingController(
    text: 'Rumah Admin (-7.115324691276371, 112.42788624055461)',
  );
  final _weightCtrl = TextEditingController(text: '5');

  final List<String> _validCategories = [
    'Logam/Besi',
    'Botol Plastik',
    'Kardus',
    'Minyak Jelantah',
  ];

  String _mapAiCategoryToIndonesian(String rawCategory) {
    final cat = rawCategory.toLowerCase().trim();
    if (cat.contains('plastic') || cat.contains('pet') || cat.contains('hdpe') || cat.contains('pp') || cat.contains('botol')) {
      return 'Botol Plastik';
    }
    if (cat.contains('cardboard') || cat.contains('paper') || cat.contains('kardus') || cat.contains('karton') || cat.contains('kertas')) {
      return 'Kardus';
    }
    if (cat.contains('oil') || cat.contains('minyak') || cat.contains('jelantah')) {
      return 'Minyak Jelantah';
    }
    if (cat.contains('metal') || cat.contains('iron') || cat.contains('steel') || cat.contains('copper') || cat.contains('aluminum') || cat.contains('logam') || cat.contains('besi') || cat.contains('kaleng')) {
      return 'Logam/Besi';
    }
    return 'Botol Plastik';
  }

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
    if (widget.extra != null) {
      final initialCat = widget.extra!['category']?.toString();
      final initialPhoto = widget.extra!['photo_url']?.toString();
      if (initialCat != null && initialCat.isNotEmpty) {
        String mapped = _mapAiCategoryToIndonesian(initialCat);
        if (_validCategories.contains(mapped)) {
          _category = mapped;
        } else if (_validCategories.contains(initialCat)) {
          _category = initialCat;
        }
      }
      if (initialPhoto != null && initialPhoto.isNotEmpty) {
        _photoUrl = initialPhoto;
      }
    }
  }

  Future<void> _loadUserAddress() async {
    await AddressState.instance.init();
    final active = AddressState.instance.activeAddress;
    if (active != null && mounted) {
      setState(() {
        _addressCtrl.text = '${active['label']}: ${active['detail']}';
      });
    }
  }

  void _showAddressPickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final addresses = AddressState.instance.addresses.value;
        final selectedIdx = AddressState.instance.selectedIndex.value;

        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Alamat Saya',
                    style: _jakarta(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (addresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Belum ada alamat tersimpan',
                      style: _jakarta(color: Colors.black45),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: addresses.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final item = addresses[idx];
                      final fullStr = '${item['label']}: ${item['detail']}';
                      final isSelected = _addressCtrl.text == fullStr;
                      final isPrimary = selectedIdx == idx;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        leading: Icon(
                          isPrimary
                              ? Icons.home_work
                              : Icons.location_on_outlined,
                          color: const Color(0xFF7BC143),
                        ),
                        title: Row(
                          children: [
                            Text(
                              item['label'] ?? 'Alamat',
                              style: _jakarta(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Utama',
                                  style: _jakarta(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          item['detail'] ?? '',
                          style: _jakarta(fontSize: 12, color: Colors.black54),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF7BC143),
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _addressCtrl.text = fullStr;
                          });
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  File? _localPhotoFile;

  Future<void> _doPickAndUpload(ImageSource source) async {
    final pickedFile = await ImagePickerHelper.pickImage(source);
    if (pickedFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin kamera/galeri ditolak atau foto tidak dipilih.',
            ),
          ),
        );
      }
      return;
    }

    final file = File(pickedFile.path);
    setState(() {
      _localPhotoFile = file;
      _photoUrl ??= pickedFile.path;
      _isAnalyzing = true;
    });

    try {
      final uploadRes = await ApiService.upload(
        ApiConstants.upload,
        pickedFile.path,
      );
      final uploadData = jsonDecode(uploadRes.body);

      if (uploadRes.statusCode == 200 && uploadData['success'] == true) {
        String imageUrl = (uploadData['data']['url'] as String).replaceFirst(
          'localhost',
          '10.0.2.2',
        );
        setState(() => _photoUrl = imageUrl);

        final analyzeRes = await ApiService.post(ApiConstants.analyzeImage, {
          'photo_url': imageUrl,
        });

        final analyzeData = jsonDecode(analyzeRes.body);
        if (analyzeRes.statusCode == 200 && analyzeData['success'] == true) {
          String aiCategory = analyzeData['data']['category'] ?? analyzeData['data']['detectedType'] ?? '';
          String mapped = _mapAiCategoryToIndonesian(aiCategory);
          setState(() => _category = mapped);
        } else {
          setState(() => _category = _validCategories.first);
        }
      } else {
        setState(() => _category = _validCategories.first);
      }
    } catch (e) {
      setState(() => _category = _validCategories.first);
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        final sourceText = source == ImageSource.gallery ? 'Galeri' : 'Kamera';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto sampah dari $sourceText berhasil dipilih!'),
            backgroundColor: const Color(0xFF7BC143),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (_isAnalyzing) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF7BC143)),
              title: Text(
                'Ambil foto dari kamera',
                style: _jakarta(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _doPickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF7BC143),
              ),
              title: Text(
                'Pilih dari galeri',
                style: _jakarta(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _doPickAndUpload(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    final targetPhotoUrl = _photoUrl ?? _localPhotoFile?.path;
    if (targetPhotoUrl == null ||
        _category == null ||
        _addressCtrl.text.trim().isEmpty ||
        _weightCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data dan upload foto sampah.'),
        ),
      );
      return;
    }

    final double? weight = double.tryParse(_weightCtrl.text.trim());
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan estimasi jumlah/bobot yang valid.'),
        ),
      );
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktifkan GPS Anda untuk mencari koordinat.'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin akses lokasi diperlukan.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi ditolak permanen di pengaturan HP.'),
        ),
      );
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menentukan lokasi & memproses jemputan...'),
      ),
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      
      String categoryDbName = _category!;
      if (_category == 'Logam/Besi') categoryDbName = 'Metal';
      if (_category == 'Botol Plastik') categoryDbName = 'PET Plastic';
      if (_category == 'Kardus') categoryDbName = 'Cardboard';
      if (_category == 'Minyak Jelantah') categoryDbName = 'Cooking Oil';

      final success = await context.read<UserProvider>().createOrder(
        photoUrl: targetPhotoUrl,
        category: categoryDbName,
        weightKg: weight,
        lat: position.latitude,
        lng: position.longitude,
        address: _addressCtrl.text.trim(),
      );

      if (success && mounted) {
        NotificationState.instance.addNotification(
          category: 'Jemput',
          title: 'Pesanan Berhasil Dibuat!',
          subtitle:
              'Penjemputan sampah ($_category, ${_weightCtrl.text.trim()} $_selectedUnit) berhasil diproses.',
        );
        HistoryState.instance.addHistory(
          title: 'Buat Pesanan Jemput',
          description:
              'Penjemputan sampah ($_category, ${_weightCtrl.text.trim()} $_selectedUnit) ke ${_addressCtrl.text.trim()}',
          category: 'Jemput',
          valueChange: '${_weightCtrl.text.trim()} $_selectedUnit',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Jemputan berhasil dibuat! Membuka Halaman Tracking...'),
            backgroundColor: const Color(0xFF7BC143),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        final newOrder = {
          'id': 'EP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'name': 'Budi Kolektor (Mitra Resmi)',
          'summary': '$_category (${_weightCtrl.text.trim()} $_selectedUnit)',
          'code': 'EP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'completed': false,
          'category': _category,
          'weight': weight,
          'address': _addressCtrl.text.trim(),
        };
        context.pop();
        context.push('/orders/tracking', extra: {'order': newOrder});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan titik GPS: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Jemput',
          style: _jakarta(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= SECTION 1: AI Vision Image Analyzer =================
              Text(
                'AI Vision Image Analyzer',
                style: _jakarta(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isAnalyzing ? null : _pickAndUploadImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    image: _localPhotoFile != null
                        ? DecorationImage(
                            image: FileImage(_localPhotoFile!),
                            fit: BoxFit.cover,
                          )
                        : (_photoUrl != null && _photoUrl!.startsWith('http')
                              ? DecorationImage(
                                  image: NetworkImage(_photoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : (_photoUrl != null && _photoUrl!.isNotEmpty
                                    ? DecorationImage(
                                        image: FileImage(File(_photoUrl!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null)),
                  ),
                  child: _isAnalyzing
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF7BC143),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'AI sedang menganalisis foto...',
                              style: _jakarta(
                                color: const Color(0xFF7BC143),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : (_photoUrl == null && _localPhotoFile == null)
                      ? Column(
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                              color: Color(0xFF7BC143),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ambil foto/upload gambar sampah',
                              style: _jakarta(
                                fontSize: 11,
                                color: Colors.black45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 32,
                              child: OutlinedButton(
                                onPressed: _pickAndUploadImage,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF7BC143),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                child: Text(
                                  'Upload Sampah Anda',
                                  style: _jakarta(
                                    fontSize: 11,
                                    color: const Color(0xFF7BC143),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          height: 110,
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF7BC143),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Foto Terpilih (Klik untuk Ganti)',
                                  style: _jakarta(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.05),

              const SizedBox(height: 20),

              // ================= SECTION 2: Kategori Sampah Dropdown =================
              Text(
                'Kategori Sampah',
                style: _jakarta(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _validCategories.contains(_category)
                        ? _category
                        : _validCategories.first,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black87,
                    ),
                    items: _validCategories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: _jakarta(fontSize: 14, color: Colors.black87),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _category = newValue;
                      });
                    },
                  ),
                ),
              ).animate().fade(delay: 100.ms),

              const SizedBox(height: 20),

              // ================= SECTION 3: Estimasi Berat/Volume (Dual Unit) =================
              Text(
                'Estimasi Berat/Volume (Kg/Liter)',
                style: _jakarta(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: _jakarta(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          style: _jakarta(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          items: <String>['Kg', 'Liter'].map((String unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (newUnit) {
                            setState(() {
                              _selectedUnit = newUnit!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 150.ms),

              const SizedBox(height: 20),

              // ================= SECTION 4: Pilih Alamat (Dropdown dari Alamat Saya) =================
              Text(
                'Pilih Alamat (GPS PinPoint)',
                style: _jakarta(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showAddressPickerModal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF7BC143),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _addressCtrl.text.isNotEmpty
                              ? _addressCtrl.text
                              : 'Pilih dari alamat tersimpan saya...',
                          style: _jakarta(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _addressCtrl.text.isNotEmpty
                                ? Colors.black87
                                : Colors.black38,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ).animate().fade(delay: 200.ms),

              const SizedBox(height: 32),

              // ================= SECTION 5: Submit Button =================
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: (_isAnalyzing || userProv.isLoading)
                      ? null
                      : _submitOrder,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7BC143),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: userProv.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Konfirmasi Jemput & Cari Kolektor',
                          style: _jakarta(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ).animate().fade(delay: 250.ms).scale(curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    );
  }
}
