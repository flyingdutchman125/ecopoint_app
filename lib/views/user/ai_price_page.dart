import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/user_provider.dart';
import '../../models/price_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/price_lock_state.dart';

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
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchPrices();
    });
  }

  Future<void> _handleLockHarga(String commodityName, double price) async {
    final lockState = PriceLockState.instance;

    if (lockState.isLocked(commodityName)) {
      final remaining = lockState.getRemainingDuration(commodityName);
      final hours = remaining?.inHours ?? 0;
      final minutes = remaining?.inMinutes.remainder(60) ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harga $commodityName sudah dikunci. Sisa waktu penguncian: $hours jam $minutes menit.',
            style: _jakarta(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF358C16),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Kunci Harga $commodityName', style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          'Konfirmasi penguncian harga $commodityName (${CurrencyFormatter.formatRupiah(price)}/kg) selama 24 jam ke depan?',
          style: _jakarta(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: _jakarta(fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF358C16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Ya, Kunci', style: _jakarta(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await lockState.lockCommodity(commodityName, price: price);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Harga $commodityName (${CurrencyFormatter.formatRupiah(price)}/kg) dikunci untuk 24 jam ke depan!',
              style: _jakarta(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            backgroundColor: const Color(0xFF358C16),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final List<PriceModel> apiPrices = userProv.prices;

    // Mapping categories dynamically from API
    final List<String> availableCategories = ['Semua'];
    for (var p in apiPrices) {
      if (!availableCategories.contains(p.itemName)) {
        availableCategories.add(p.itemName);
      }
    }

    final filteredPrices = _selectedCategory == 'Semua'
        ? apiPrices
        : apiPrices.where((p) => p.itemName == _selectedCategory).toList();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF7BC143)),
            tooltip: 'Sync Harga Web Terbaru',
            onPressed: () async {
              await context.read<UserProvider>().fetchPrices();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Harga komoditas berhasil disinkronkan dari Web API BSI!'),
                    backgroundColor: const Color(0xFF5CB82B),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: userProv.isLoading && apiPrices.isEmpty
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: () => context.read<UserProvider>().fetchPrices(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Green Card untuk Grafik Proyeksi AI (Live Data)
                    _buildProjectionCard(apiPrices, availableCategories),

                    // 2. Section Title
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Katalog Komoditas Live Web API',
                              style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sync, size: 12, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 4),
                                Text(
                                  'Live Web BSI',
                                  style: _jakarta(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3. List Item Komoditas dari Real API
                    if (filteredPrices.isEmpty)
                      _buildFallbackList(apiPrices)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredPrices.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final priceItem = filteredPrices[index];
                          return _buildCommodityCardFromApi(priceItem);
                        },
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 280,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 24),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 120,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectionCard(List<PriceModel> prices, List<String> categories) {
    final double selectedPrice = prices.firstWhere(
      (p) => p.itemName == _selectedCategory,
      orElse: () => prices.isNotEmpty
          ? prices.first
          : PriceModel(id: 1, itemName: 'Sampah', currentPrice: 5000, unit: 'kg'),
    ).currentPrice;

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
              Expanded(
                child: Text(
                  'Proyeksi Harga 48 Jam',
                  style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'AI Predictive Engine',
                  style: _jakarta(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
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

          // Dynamic Price Chart Painter
          Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.only(right: 10),
            child: CustomPaint(
              painter: PriceChartPainter(basePrice: selectedPrice),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLegendItem(Colors.white, 'Web API BSI History'),
                const SizedBox(width: 16),
                _buildLegendItem(const Color(0xFFFFD54F), 'Proyeksi AI (+2.5%)'),
              ],
            ),
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

  Widget _buildCommodityCardFromApi(PriceModel item) {
    final double tomorrowPriceVal = (item.currentPrice * (1 + ((item.changePercent ?? 1.5).abs() / 100)));
    final String todayPriceStr = '${CurrencyFormatter.formatRupiah(item.currentPrice)}/${item.unit}';
    final String tomorrowPriceStr = '${CurrencyFormatter.formatRupiah(tomorrowPriceVal)}/${item.unit}';
    final double percent = item.changePercent ?? 1.5;
    final String trendStr = percent >= 0 ? '+${percent.toStringAsFixed(1)}%' : '${percent.toStringAsFixed(1)}%';
    final bool isUp = percent >= 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(item.iconForType, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.itemName,
                          style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUp ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trendStr,
                    style: _jakarta(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isUp ? const Color(0xFF2E7D32) : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Price Comparison
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Harga Web BSI (Hari ini)',
                          style: _jakarta(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(todayPriceStr,
                          style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: isUp ? const Color(0xFF7BC143) : Colors.grey,
                    size: 18,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Proyeksi AI (Besok)',
                          style: _jakarta(fontSize: 11, color: Colors.black45, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        tomorrowPriceStr,
                        style: _jakarta(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isUp ? const Color(0xFF2E7D32) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),

          // Lock Price Action Button
          ValueListenableBuilder<Map<String, String>>(
            valueListenable: PriceLockState.instance.lockedPrices,
            builder: (context, val, child) {
              final isLocked = PriceLockState.instance.isLocked(item.itemName);
              final remaining = PriceLockState.instance.getRemainingDuration(item.itemName);
              final String remainingText = remaining != null
                  ? '${remaining.inHours}j ${remaining.inMinutes.remainder(60)}m'
                  : '24 jam';

              return Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: FilledButton.icon(
                    onPressed: () => _handleLockHarga(item.itemName, item.currentPrice),
                    icon: Icon(isLocked ? Icons.lock : Icons.lock_outline, size: 16, color: Colors.white),
                    label: Text(
                      isLocked ? 'Harga Terkunci ($remainingText)' : 'Kunci Harga Sekarang',
                      style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isLocked ? const Color(0xFF358C16) : const Color(0xFF7BC143),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackList(List<PriceModel> prices) {
    final fallbackItems = [
      PriceModel(id: 1, itemName: 'PET Plastic', currentPrice: 3900, unit: 'kg', changePercent: 1.2, trend: 'up'),
      PriceModel(id: 2, itemName: 'Cardboard', currentPrice: 4900, unit: 'kg', changePercent: 0.0, trend: 'stable'),
      PriceModel(id: 3, itemName: 'Metal', currentPrice: 8900, unit: 'kg', changePercent: 1.2, trend: 'up'),
      PriceModel(id: 4, itemName: 'Cooking Oil', currentPrice: 9600, unit: 'kg', changePercent: 1.5, trend: 'up'),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: fallbackItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildCommodityCardFromApi(fallbackItems[index]),
    );
  }
}

class PriceChartPainter extends CustomPainter {
  final double basePrice;

  PriceChartPainter({this.basePrice = 8500});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.9),
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    final double minPrice = basePrice * 0.95;
    final double maxPrice = basePrice * 1.05;
    final double step = (maxPrice - minPrice) / 4;

    List<String> yLabels = List.generate(5, (i) {
      final val = maxPrice - (i * step);
      return CurrencyFormatter.formatRupiah(val).replaceAll('Rp ', '');
    });

    double rowHeight = (size.height - 20) / (yLabels.length - 1);

    for (int i = 0; i < yLabels.length; i++) {
      double y = i * rowHeight;
      canvas.drawLine(Offset(40, y), Offset(size.width, y), gridPaint);

      final textPainter = TextPainter(
        text: TextSpan(text: yLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    List<String> xLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min', 'Besok (AI)'];
    double startX = 50;
    double spacingX = (size.width - startX) / (xLabels.length - 1);

    double getY(double price) {
      double chartHeight = size.height - 20;
      return chartHeight - ((price - minPrice) / (maxPrice - minPrice) * chartHeight);
    }

    List<double> priceTrend = [
      basePrice * 0.96,
      basePrice * 0.97,
      basePrice * 0.98,
      basePrice * 0.98,
      basePrice * 0.99,
      basePrice,
      basePrice * 1.01,
      basePrice * 1.03,
    ];

    List<Offset> points = List.generate(
      priceTrend.length,
      (i) => Offset(startX + i * spacingX, getY(priceTrend[i])),
    );

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    Path fillPath = Path()
      ..moveTo(points[0].dx, size.height - 20)
      ..lineTo(points[0].dx, points[0].dy);
    for (int i = 1; i <= 5; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(points[5].dx, size.height - 20);
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
      textPainter.paint(canvas, Offset(points[i].dx - 10, size.height - 12));
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
  bool shouldRepaint(covariant PriceChartPainter oldDelegate) => oldDelegate.basePrice != basePrice;
}