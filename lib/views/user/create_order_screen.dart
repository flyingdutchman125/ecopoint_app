import 'dart:convert';
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
  final _addressCtrl = TextEditingController(text: 'Rumah Admin (-7.115324691276371, 112.42788624055461)');
  final _weightCtrl = TextEditingController(text: '5'); 
  
  final List<String> _validCategories = ['Logam/Besi', 'Botol Plastik', 'Kardus', 'Minyak Jelantah'];

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
    if (widget.extra != null) {
      final initialCat = widget.extra!['category']?.toString();
      final initialPhoto = widget.extra!['photo_url']?.toString();
      if (initialCat != null && _validCategories.contains(initialCat)) {
        _category = initialCat;
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

  Future<void> _doPickAndUpload(ImageSource source) async {
    final pickedFile = await ImagePickerHelper.pickImage(source);
    if (pickedFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin kamera/galeri ditolak atau foto tidak dipilih.')),
        );
      }
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final uploadRes = await ApiService.upload(ApiConstants.upload, pickedFile.path);
      final uploadData = jsonDecode(uploadRes.body);

      if (uploadRes.statusCode == 200 && uploadData['success'] == true) {
        String imageUrl = (uploadData['data']['url'] as String)
            .replaceFirst('localhost', '10.0.2.2');
        setState(() => _photoUrl = imageUrl);

        final analyzeRes = await ApiService.post(ApiConstants.analyzeImage, {
          'photo_url': imageUrl,
        });

        final analyzeData = jsonDecode(analyzeRes.body);
        if (analyzeRes.statusCode == 200 && analyzeData['success'] == true) {
          String aiCategory = analyzeData['data']['category'] ?? '';
          if (_validCategories.contains(aiCategory)) {
            setState(() => _category = aiCategory);
          } else {
            setState(() => _category = _validCategories.first);
          }
        } else {
          setState(() => _category = _validCategories.first);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI tidak tersedia. Pilih kategori manual.')),
            );
          }
        }
      } else {
        if (mounted) {
          final msg = uploadData['message'] ?? 'Upload gagal. Coba lagi.';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      if (mounted) {
        final message = e is ApiConnectionException
            ? e.message
            : 'Upload error: ${e.toString()}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
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
              title: Text('Ambil foto dari kamera', style: _jakarta(fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.of(ctx).pop();
                _doPickAndUpload(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF7BC143)),
              title: Text('Pilih dari galeri', style: _jakarta(fontWeight: FontWeight.w500)),
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
    if (_photoUrl == null || _category == null || _addressCtrl.text.trim().isEmpty || _weightCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data dan upload foto sampah.')),
      );
      return;
    }

    final double? weight = double.tryParse(_weightCtrl.text.trim());
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan estimasi jumlah/bobot yang valid.')),
      );
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aktifkan GPS Anda untuk mencari koordinat.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin akses lokasi diperlukan.')));
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak permanen di pengaturan HP.')));
      return;
    } 

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menentukan lokasi & memproses jemputan...')));
    
    try {
      Position position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));

      if (!mounted) return;
      final success = await context.read<UserProvider>().createOrder(
        photoUrl: _photoUrl!,
        category: _category!,
        weightKg: weight,
        lat: position.latitude,
        lng: position.longitude,
        address: _addressCtrl.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Jemputan berhasil dibuat! Menunggu kolektor.'),
            backgroundColor: const Color(0xFF7BC143),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          )
        );
        context.pop();
      }
    } catch(e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendapatkan titik GPS: $e')));
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
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
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
              Text('AI Vision Image Analyzer', style: _jakarta(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isAnalyzing ? null : _pickAndUploadImage,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB)), 
                    image: _photoUrl != null
                        ? DecorationImage(image: NetworkImage(_photoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _isAnalyzing
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(color: Color(0xFF7BC143)),
                            const SizedBox(height: 16),
                            Text('AI sedang menganalisis foto...', style: _jakarta(color: const Color(0xFF7BC143), fontWeight: FontWeight.bold))
                          ],
                        )
                      : _photoUrl == null
                          ? Column(
                              children: [
                                const Icon(Icons.camera_alt_outlined, size: 40, color: Color(0xFF7BC143)),
                                const SizedBox(height: 12),
                                Text(
                                  'Ambil foto/upload gambar sampah',
                                  style: _jakarta(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 32,
                                  child: OutlinedButton(
                                    onPressed: _pickAndUploadImage,
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF7BC143)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    child: Text(
                                      'Upload Sampah Anda',
                                      style: _jakarta(fontSize: 11, color: const Color(0xFF7BC143), fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              height: 100,
                            ),
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: 0.05),
              
              const SizedBox(height: 20),

              // ================= SECTION 2: Kategori Sampah Dropdown =================
              Text('Kategori Sampah', style: _jakarta(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _validCategories.contains(_category) ? _category : _validCategories.first,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                    items: _validCategories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: _jakarta(fontSize: 14, color: Colors.black87)),
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
              Text('Estimasi Berat/Volume (Kg/Liter)', style: _jakarta(fontWeight: FontWeight.bold, color: Colors.black87)),
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold),
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
                          style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
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

              // ================= SECTION 4: Pilih Alamat Text Field (Styled Dropdown) =================
              Text('Pilih Alamat (GPS PinPoint)', style: _jakarta(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        style: _jakarta(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Masukkan alamat lengkap penjemputan...',
                          hintStyle: _jakarta(fontSize: 13, color: Colors.black38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                  ],
                ),
              ).animate().fade(delay: 200.ms),

              const SizedBox(height: 32),

              // ================= SECTION 5: Submit Button =================
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: (_isAnalyzing || userProv.isLoading) ? null : _submitOrder,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7BC143),
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: userProv.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Konfirmasi Jemput & Cari Kolektor',
                          style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
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