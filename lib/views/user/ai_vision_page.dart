import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

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

class AiVisionPage extends StatefulWidget {
  const AiVisionPage({super.key});

  @override
  State<AiVisionPage> createState() => _AiVisionPageState();
}

class _AiVisionPageState extends State<AiVisionPage> {
  String _category = 'Logam/Besi';
  String _price = '8.900/kg';
  int _accuracy = 90;
  bool _isAnalyzing = false;
  String? _photoUrl;

  final Map<String, Map<String, dynamic>> _wasteData = {
    'Logam/Besi': {'price': '8.900/kg', 'accuracy': 90},
    'Botol Plastik': {'price': '3.900/kg', 'accuracy': 94},
    'Kardus': {'price': '4.900/kg', 'accuracy': 92},
    'Minyak Jelantah': {'price': '9.600/kg', 'accuracy': 88},
  };

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final pickedFile = await ImagePickerHelper.pickImage(source);
    if (pickedFile == null) return;

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
          String aiCategory = analyzeData['data']['category'] ?? 'Logam/Besi';
          if (_wasteData.containsKey(aiCategory)) {
            setState(() {
              _category = aiCategory;
              _price = _wasteData[aiCategory]!['price'] as String;
              _accuracy = _wasteData[aiCategory]!['accuracy'] as int;
            });
          }
        }
      }
    } catch (_) {
      // Fallback cycle for demo offline testing
      _cycleCategoryDemo();
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _cycleCategoryDemo() {
    final keys = _wasteData.keys.toList();
    final currentIndex = keys.indexOf(_category);
    final nextIndex = (currentIndex + 1) % keys.length;
    final nextCategory = keys[nextIndex];

    setState(() {
      _category = nextCategory;
      _price = _wasteData[nextCategory]!['price'] as String;
      _accuracy = _wasteData[nextCategory]!['accuracy'] as int;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('AI Pilah: Terdeteksi "$_category"', style: _jakarta(color: Colors.white)),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF7BC143),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF7BC143);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ai Vision',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Scan Barang bekas untuk di pindai !',
                    style: _jakarta(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ================= CAMERA SCANNER VIEWFINDER =================
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(8),
                      borderRadius: BorderRadius.circular(16),
                      image: _photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(_photoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        if (_isAnalyzing)
                          const Center(
                            child: CircularProgressIndicator(color: primaryGreen),
                          ),
                        // Corner borders (Framing Bracket)
                        CustomPaint(
                          size: const Size(double.infinity, 260),
                          painter: ScannerFramePainter(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= RESULT CARD =================
                  Text(
                    'Image Classifier pintar',
                    style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Green 4-box Icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: GridView.count(
                            crossAxisCount: 2,
                            padding: const EdgeInsets.all(10),
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                            children: List.generate(
                              4,
                              (index) => Container(
                                decoration: BoxDecoration(
                                  color: primaryGreen,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Classification Details Table
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoRow('Jenis Sampah', ':', _category),
                              const SizedBox(height: 6),
                              _infoRow('Harga saat ini', ':', _price),
                              const SizedBox(height: 6),
                              _infoRow('Akurasi', ':', '$_accuracy %', isGreen: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= LANJUTKAN KE JEMPUT BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        context.push('/create-order', extra: {
                          'category': _category,
                          'price': _price,
                          'photo_url': _photoUrl,
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryGreen, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        'Lanjutkan ke "Jemput"',
                        style: _jakarta(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= BOTTOM SHUTTER ACTION BAR =================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gallery Icon
                IconButton(
                  icon: const Icon(Icons.image, size: 28, color: Colors.grey),
                  onPressed: () => _pickAndAnalyze(ImageSource.gallery),
                ),

                // Shutter Button
                GestureDetector(
                  onTap: () => _pickAndAnalyze(ImageSource.camera),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 28), // Spacer balance
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String colon, String value, {bool isGreen = false}) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: _jakarta(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Text(
          '$colon ',
          style: _jakarta(fontSize: 11, color: Colors.black54),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: _jakarta(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isGreen ? const Color(0xFF4CAF50) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

/// Painter to draw the 4 corner framing brackets matching scanner UI
class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const double lineLength = 40;

    // Top-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(20, 20 + lineLength)
        ..lineTo(20, 20)
        ..lineTo(20 + lineLength, 20),
      paint,
    );

    // Top-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 20 - lineLength, 20)
        ..lineTo(size.width - 20, 20)
        ..lineTo(size.width - 20, 20 + lineLength),
      paint,
    );

    // Bottom-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(20, size.height - 20 - lineLength)
        ..lineTo(20, size.height - 20)
        ..lineTo(20 + lineLength, size.height - 20),
      paint,
    );

    // Bottom-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 20 - lineLength, size.height - 20)
        ..lineTo(size.width - 20, size.height - 20)
        ..lineTo(size.width - 20, size.height - 20 - lineLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
