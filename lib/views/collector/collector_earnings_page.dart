import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectorEarningsPage extends StatefulWidget {
  const CollectorEarningsPage({Key? key}) : super(key: key);

  @override
  State<CollectorEarningsPage> createState() => _CollectorEarningsPageState();
}

class _CollectorEarningsPageState extends State<CollectorEarningsPage> {
  String selectedCategory = 'Logam/Besi';

  final List<String> categories = [
    'Logam/Besi',
    'Botol Plastik',
    'Kardus',
    'Minyak Jelantah',
  ];

  final List<Map<String, dynamic>> dailyData = [
    {'day': 'Sen', 'weight': 13.0},
    {'day': 'Sel', 'weight': 12.0},
    {'day': 'Rab', 'weight': 12.3},
    {'day': 'Kam', 'weight': 14.1},
    {'day': 'Jum', 'weight': 13.0},
    {'day': 'Sab', 'weight': 11.5},
    {'day': 'Min', 'weight': 11.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF82E23B),
              Color(0xFF52A41F),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Bang Ridwan',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '4.9',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Mitra Pengepul - Wilayah Lamongan',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimasi Saldo yang didapatkan Minggu Ini',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp 2,000,000',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[200], thickness: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatBadge('Selesai', '72 Order'),
                          const SizedBox(width: 8),
                          _buildStatBadge('Total Berat', '284.5 Kg'),
                          const SizedBox(width: 8),
                          _buildStatBadge('Jam Kerja', '90,20 Jam'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Grafik Pendapatan Harian',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: categories.map((category) {
                            final isSelected = selectedCategory == category;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF7CB342)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF7CB342),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF7CB342),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildCustomBarChart(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.arrow_left, size: 14, color: Colors.grey[400]),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[350],
                            ),
                          ),
                          Icon(Icons.arrow_right, size: 14, color: Colors.grey[400]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Semangat !',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF7CB342),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomBarChart() {
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(9, (index) {
              int labelValue = 15 - index;
              return Text(
                '${labelValue.toString().padLeft(2, '0')} Kg',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(9, (index) {
                    return Container(
                      height: 0.8,
                      color: Colors.grey[200],
                    );
                  }),
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dailyData.map<Widget>((data) {
                      double currentWeight = double.parse(data['weight'].toString());
                      double minGridScale = 6.5;
                      double maxGridScale = 15.0;
                      double heightFactor = (currentWeight - minGridScale) /
                          (maxGridScale - minGridScale);
                      heightFactor = heightFactor.clamp(0.0, 1.0);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: heightFactor,
                                child: Container(
                                  width: 14,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7CB342),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['day'].toString(),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}