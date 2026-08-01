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

class AiPricePage extends StatefulWidget {
  const AiPricePage({super.key});

  @override
  State<AiPricePage> createState() => _AiPricePageState();
}

class _AiPricePageState extends State<AiPricePage> {
  String _selectedCategory = 'Logam/Besi';

  final List<String> _categories = [
    'Logam/Besi',
    'Botol Plastik',
    'Kardus',
    'Minyak Jelantah'
  ];

  // Data Mock untuk List Komoditas Sampah
  final List<Map<String, dynamic>> _commodities = [
    {
      'name': 'Logam/Besi',
      'trend': '+ 1.2%',
      'today_price': 'Rp 8.900/kg',
      'tomorrow_price': 'Rp 8.900/kg',
      'is_up': true,
    },
    {
      'name': 'Minyak Jelantah',
      'trend': '+ 1.2%',
      'today_price': 'Rp 9.600/kg',
      'tomorrow_price': 'Rp 9.900/kg',
      'is_up': true,
    },
    {
      'name': 'Kardus',
      'trend': '+0%',
      'today_price': 'Rp 4.900/kg',
      'tomorrow_price': 'Rp 4.900/kg',
      'is_up': false,
    },
    {
      'name': 'Botol Plastik',
      'trend': '+ 1.2%',
      'today_price': 'Rp 3.900/kg',
      'tomorrow_price': 'Rp 4.000/kg',
      'is_up': true,
    },
  ];

  void _handleLockHarga(String commodityName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Harga $commodityName berhasil dikunci untuk 24 jam ke depan!',
          style: _jakarta(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF5CB82B),
        behavior: SnackBarBehavior.floating,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI Live Dynamic Price',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Green Card untuk Grafik Proyeksi
            _buildProjectionCard(),

            // 2. Section Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Katalog Komoditas Sampah',
                style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            // 3. List Item Komoditas dengan Desain Baru
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _commodities.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = _commodities[index];
                return _buildCommodityCard(item);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7BC143), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Proyeksi Harga 48 Jam',
                style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                'AI Predictive',
                style: _jakarta(fontSize: 11, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Horizontal Chips Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      category,
                      style: _jakarta(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF7BC143) : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Area Grafik Custom Paint
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.only(right: 10),
            child: CustomPaint(
              painter: PriceChartPainter(),
            ),
          ),
          const SizedBox(height: 12),

          // Legend Informasi di Bawah Grafik
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildLegendItem(Colors.white, 'Real History'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFFFFD54F), 'Proyeksi AI'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: _jakarta(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // RE-DESIGN: Modifikasi penuh tampilan kartu katalog komoditas sampah
  Widget _buildCommodityCard(Map<String, dynamic> item) {
    final String name = item['name'] as String;
    final String trend = item['trend'] as String;
    final String todayPrice = item['today_price'] as String;
    final String tomorrowPrice = item['tomorrow_price'] as String;
    final bool isUp = item['is_up'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB).withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Bagian Atas: Nama Komoditas & Badge Trend
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUp ? const Color(0xFFE8F5E9) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: _jakarta(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUp ? const Color(0xFF2E7D32) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Bagian Tengah: Komparasi Harga Hari Ini vs Besok (AI)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kolom Hari Ini
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hari ini', style: _jakarta(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(todayPrice, style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
                
                // Icon Panah Transisi / Indikator Arah
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: isUp ? const Color(0xFF7BC143).withOpacity(0.6) : Colors.black12,
                    size: 18,
                  ),
                ),

                // Kolom Besok
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Besok (AI)', style: _jakarta(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        tomorrowPrice, 
                        style: _jakarta(
                          fontSize: 14, 
                          fontWeight: FontWeight.bold, 
                          color: isUp ? const Color(0xFF2E7D32) : Colors.black87
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Garis Pembatas Tipis Sebelum Tombol Aksi
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          
          // 3. Bagian Bawah: Tombol Kunci Harga Premium (Full Width)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton.icon(
                onPressed: () => _handleLockHarga(name),
                icon: const Icon(Icons.lock_outline, size: 16, color: Colors.white),
                label: Text(
                  'Kunci Harga Sekarang',
                  style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF7BC143), // Hijau khas EcoPoint
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PriceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: Colors.white.withOpacity(0.9),
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    List<String> yLabels = ['9.000', '8.900', '8.800', '8.700', '8.600', '8.500', '8.400', '8.300', '8.200', '8.100'];
    double rowHeight = (size.height - 20) / (yLabels.length - 1);
    
    for (int i = 0; i < yLabels.length; i++) {
      double y = i * rowHeight;
      canvas.drawLine(Offset(40, y), Offset(size.width, y), gridPaint);
      
      final textPainter = TextPainter(
        text: TextSpan(text: yLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(5, y - 6));
    }

    List<String> xLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min', 'Sen'];
    double startX = 50;
    double spacingX = (size.width - startX) / (xLabels.length - 1);

    double getY(double price) {
      double minPrice = 8100;
      double maxPrice = 9000;
      double chartHeight = size.height - 20;
      return chartHeight - ((price - minPrice) / (maxPrice - minPrice) * chartHeight);
    }

    List<Offset> points = [
      Offset(startX + 0 * spacingX, getY(8100)),
      Offset(startX + 1 * spacingX, getY(8200)),
      Offset(startX + 2 * spacingX, getY(8300)),
      Offset(startX + 3 * spacingX, getY(8300)),
      Offset(startX + 4 * spacingX, getY(8400)),
      Offset(startX + 5 * spacingX, getY(8600)), 
      Offset(startX + 6 * spacingX, getY(8700)), 
      Offset(startX + 7 * spacingX, getY(8900)),
    ];

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    
    Path fillPath = Path()
      ..moveTo(points[0].dx, getY(8100))
      ..lineTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= 5; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points[5].dx, getY(8100));
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    final historyLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path historyPath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= 5; i++) {
      historyPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(historyPath, historyLinePaint);

    final aiLinePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, points[5], points[6], aiLinePaint);
    _drawDashedLine(canvas, points[6], points[7], aiLinePaint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < points.length; i++) {
      dotPaint.color = (i <= 5) ? Colors.white : const Color(0xFFFFD54F);
      canvas.drawCircle(points[i], 4, dotPaint);
    }

    for (int i = 0; i < xLabels.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(text: xLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(points[i].dx - 8, size.height - 12));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 4;
    const double dashSpace = 4;
    double distance = (end - start).distance;
    double currentDistance = 0.0;
    
    Offset direction = (end - start) / distance;
    
    while (currentDistance < distance) {
      canvas.drawLine(
        start + direction * currentDistance,
        start + direction * (currentDistance + dashWidth <= distance ? currentDistance + dashWidth : distance),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}