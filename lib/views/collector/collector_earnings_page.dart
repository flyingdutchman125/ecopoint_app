import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collector_provider.dart';
import '../../core/utils/currency_formatter.dart';

class CollectorEarningsPage extends StatefulWidget {
  const CollectorEarningsPage({super.key});

  @override
  State<CollectorEarningsPage> createState() => _CollectorEarningsPageState();
}

class _CollectorEarningsPageState extends State<CollectorEarningsPage> {
  String selectedCategory = 'Logam/Besi';
  int _selectedWeek = 1;

  final List<String> categories = [
    'Logam/Besi',
    'Botol Plastik',
    'Kardus',
    'Minyak Jelantah',
  ];

  DateTime _selectedDate = DateTime(2026, 8, 1);

  String get _formattedWeekRange {
    final int day = _selectedDate.day;
    int week = ((day - 1) ~/ 7) + 1;
    if (week > 4) week = 4;
    
    int startDay = (week - 1) * 7 + 1;
    int endDay = week * 7;
    
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
    return '$startDay - $endDay ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7CB342),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedWeek = ((picked.day - 1) ~/ 7) + 1;
        if (_selectedWeek > 4) _selectedWeek = 4;
      });
    }
  }



  final Map<int, List<Map<String, dynamic>>> _weeklyData = {
    1: [
      {'day': 'Sen', 'income': 130000},
      {'day': 'Sel', 'income': 120000},
      {'day': 'Rab', 'income': 123000},
      {'day': 'Kam', 'income': 141000},
      {'day': 'Jum', 'income': 130000},
      {'day': 'Sab', 'income': 115000},
      {'day': 'Min', 'income': 110000},
    ],
    2: [
      {'day': 'Sen', 'income': 140000},
      {'day': 'Sel', 'income': 110000},
      {'day': 'Rab', 'income': 103000},
      {'day': 'Kam', 'income': 121000},
      {'day': 'Jum', 'income': 140000},
      {'day': 'Sab', 'income': 105000},
      {'day': 'Min', 'income': 120000},
    ],
    3: [
      {'day': 'Sen', 'income': 110000},
      {'day': 'Sel', 'income': 130000},
      {'day': 'Rab', 'income': 143000},
      {'day': 'Kam', 'income': 111000},
      {'day': 'Jum', 'income': 120000},
      {'day': 'Sab', 'income': 135000},
      {'day': 'Min', 'income': 100000},
    ],
    4: [
      {'day': 'Sen', 'income': 120000},
      {'day': 'Sel', 'income': 140000},
      {'day': 'Rab', 'income': 113000},
      {'day': 'Kam', 'income': 101000},
      {'day': 'Jum', 'income': 110000},
      {'day': 'Sab', 'income': 145000},
      {'day': 'Min', 'income': 130000},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final collectorProv = context.watch<CollectorProvider>();
    final authProv = context.watch<AuthProvider>();
    final user = authProv.user;
    
    final String rawName = user?.name ?? '';
    final String name = rawName.trim().isNotEmpty ? rawName : 'Bang Ridwan';
    final city = (user?.city != null && user!.city.toString().isNotEmpty) ? user.city : 'Lamongan';
    final String ratingStr = (user?.rating != null) ? (user!.rating as num).toStringAsFixed(1) : '4.9';

    // Calculate monthly values from collector provider
    final double monthlyEarnings = collectorProv.earnings * 4.0;
    final String earningsText = CurrencyFormatter.formatRupiah(monthlyEarnings.toInt());

    final completedOrders = collectorProv.myOrders.where((o) => o.status == 'completed').toList();
    final completedCount = completedOrders.length;
    
    final double realWeightSum = completedOrders.fold(0.0, (sum, order) => sum + (order.weightKg ?? 0.0));
    final String displayWeightText = '${realWeightSum.toStringAsFixed(1)} Kg';

    final double realHoursSum = (completedOrders.length * 0.6);
    final String displayHoursText = '${realHoursSum.toStringAsFixed(2)} Jam';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF57C00), Color(0xFFE65100)],
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
                      name,
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
                      ratingStr,
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
                  'Mitra Pengepul - Wilayah $city',
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
                        'Estimasi Saldo yang didapatkan Bulan Ini',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        earningsText,
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
                          _buildStatBadge('Selesai', '$completedCount Order'),
                          const SizedBox(width: 8),
                          _buildStatBadge('Total Berat', displayWeightText),
                          const SizedBox(width: 8),
                          _buildStatBadge('Jam Kerja', displayHoursText),
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
                      // WEEK SELECTOR
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [1, 2, 3, 4].map((week) {
                            final isSelected = _selectedWeek == week;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedWeek = week;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF7CB342) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF7CB342) : Colors.grey[300]!,
                                  ),
                                ),
                                child: Text(
                                  'Minggu $week',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // DATE INDICATOR
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF7CB342).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_month, size: 16, color: Color(0xFF7CB342)),
                              const SizedBox(width: 8),
                              Text(
                                _formattedWeekRange,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF7CB342),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF7CB342)),
                            ],
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final collectorProv = context.watch<CollectorProvider>();
                          final baseList = _weeklyData[_selectedWeek] ?? _weeklyData[1]!;
                          final chartData = baseList.map((item) => Map<String, dynamic>.from(item)).toList();
                          for (final order in collectorProv.myOrders) {
                            if (order.status == 'completed' && order.totalPrice != null) {
                              final dayIdx = (order.createdAt.weekday - 1).clamp(0, 6);
                              chartData[dayIdx]['income'] = (double.tryParse(chartData[dayIdx]['income'].toString()) ?? 0) + order.totalPrice!;
                            }
                          }
                          return _buildCustomBarChart(chartData);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_left,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[350],
                            ),
                          ),
                          Icon(
                            Icons.arrow_right,
                            size: 14,
                            color: Colors.grey[400],
                          ),
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

  Widget _buildCustomBarChart(List<Map<String, dynamic>> dataForWeek) {
    double maxIncome = 150000;
    for (final d in dataForWeek) {
      final inc = double.tryParse(d['income'].toString()) ?? 0;
      if (inc > maxIncome) maxIncome = inc;
    }

    final labels = [
      '${(maxIncome / 1000).toInt()}rb',
      '${(maxIncome * 0.75 / 1000).toInt()}rb',
      '${(maxIncome * 0.50 / 1000).toInt()}rb',
      '${(maxIncome * 0.25 / 1000).toInt()}rb',
      '0rb',
    ];

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((label) {
              return Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return Container(height: 0.8, color: Colors.grey[200]);
                  }),
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: dataForWeek.map<Widget>((data) {
                      final double currentIncome = double.tryParse(data['income'].toString()) ?? 0.0;
                      double heightFactor = maxIncome > 0 ? (currentIncome / maxIncome) : 0.0;
                      heightFactor = heightFactor.clamp(0.08, 1.0);

                      final isHighest = currentIncome == maxIncome;

                      return Tooltip(
                        message: '${data['day']}: ${CurrencyFormatter.formatRupiah(currentIncome.toInt())}',
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${(currentIncome / 1000).toStringAsFixed(0)}k',
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isHighest ? const Color(0xFFF57C00) : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: heightFactor,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    width: 16,
                                    decoration: BoxDecoration(
                                      color: isHighest ? const Color(0xFFF57C00) : const Color(0xFF7CB342),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isHighest ? const Color(0xFFF57C00) : const Color(0xFF7CB342)).withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
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
                                color: isHighest ? Colors.black : Colors.grey[700],
                                fontWeight: isHighest ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
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
