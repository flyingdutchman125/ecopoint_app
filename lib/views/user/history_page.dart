import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/history_state.dart';

TextStyle _jakarta({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = Colors.black,
  FontStyle? fontStyle,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
  );
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedCategory = 'Semua';
  final HistoryState _historyState = HistoryState.instance;

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Semua', 'icon': Icons.tune, 'color': Color(0xFF1B3A1B)},
    {'name': 'Jemput', 'icon': Icons.local_shipping, 'color': Color(0xFFE53935)},
    {'name': 'Tukar Point', 'icon': Icons.sync_alt, 'color': Color(0xFFFB8C00)},
    {'name': 'Withdraw', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF8E24AA)},
    {'name': 'EcoTree', 'icon': Icons.eco, 'color': Color(0xFF4CAF50)},
    {'name': 'EcoBook', 'icon': Icons.menu_book, 'color': Color(0xFF3F51B5)},
    {'name': 'Kunci Harga', 'icon': Icons.lock_clock, 'color': Color(0xFF009688)},
    {'name': 'Alamat', 'icon': Icons.location_on, 'color': Color(0xFF0288D1)},
    {'name': 'Rating', 'icon': Icons.star, 'color': Color(0xFFFFB300)},
  ];

  @override
  void initState() {
    super.initState();
    _historyState.init();
  }

  void _showFilterInspectionBottomSheet(BuildContext context, List<HistoryItem> allHistory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctxState, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inspeksi Filter Riwayat Fitur',
                        style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pilih kategori fitur untuk mengecek riwayat aktivitas:',
                    style: _jakarta(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _categories.map((cat) {
                      final name = cat['name'] as String;
                      final isSelected = _selectedCategory == name;
                      final count = name == 'Semua'
                          ? allHistory.length
                          : allHistory.where((h) => h.category == name).length;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCategory = name;
                          });
                          Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF4F6F8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF82C139) : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(cat['icon'] as IconData, size: 16, color: cat['color'] as Color),
                              const SizedBox(width: 6),
                              Text(
                                name,
                                style: _jakarta(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF82C139) : Colors.black12,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$count',
                                  style: _jakarta(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showItemDetailDialog(BuildContext context, HistoryItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: item.categoryColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(item.category, style: _jakarta(fontSize: 11, color: item.categoryColor, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            _buildDetailRow('Waktu Transaksi', '${item.dateFormatted} • ${item.timeFormatted}'),
            const SizedBox(height: 6),
            _buildDetailRow('ID Aktivitas', item.id),
            const SizedBox(height: 6),
            _buildDetailRow('Status', item.status),
            if (item.valueChange != null) ...[
              const SizedBox(height: 6),
              _buildDetailRow('Perubahan Nilai', item.valueChange!, isHighlight: true),
            ],
            const SizedBox(height: 12),
            Text('Deskripsi Lengkap:', style: _jakarta(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(item.description, style: _jakarta(fontSize: 12, color: Colors.black.withValues(alpha: 0.65))),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF82C139),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: _jakarta(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _jakarta(fontSize: 11, color: Colors.black54)),
        Flexible(
          child: Text(
            val,
            style: _jakarta(
              fontSize: 11,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? const Color(0xFF2E7D32) : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        title: Text(
          'Riwayat Aktivitas',
          style: _jakarta(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87, size: 24),
            tooltip: 'Filter Pop-up Aktivitas',
            onPressed: () => _showFilterInspectionBottomSheet(context, _historyState.historyList.value),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<HistoryItem>>(
        valueListenable: _historyState.historyList,
        builder: (context, allHistory, _) {
          final filteredHistory = _selectedCategory == 'Semua'
              ? allHistory
              : allHistory.where((item) => item.category == _selectedCategory).toList();

          return Column(
            children: [
              // --- UPTOP SUMMARY CARD & QUICK FILTER TRIGGER ---
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Aktivitas Warga',
                              style: _jakarta(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kategori Aktif: $_selectedCategory (${filteredHistory.length} Transaksi)',
                              style: _jakarta(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32)),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showFilterInspectionBottomSheet(context, allHistory),
                          icon: const Icon(Icons.tune, size: 16, color: Colors.white),
                          label: Text('Inspeksi Pop-up', style: _jakarta(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF82C139),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- DAFTAR RIWAYAT NYATA ---
              Expanded(
                child: filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: filteredHistory.length + 1,
                        itemBuilder: (context, index) {
                          if (index == filteredHistory.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 24, bottom: 16),
                              child: Text(
                                'Seluruh riwayat terverifikasi secara nyata',
                                textAlign: TextAlign.center,
                                style: _jakarta(fontSize: 12, color: Colors.black38, fontWeight: FontWeight.w500),
                              ),
                            );
                          }

                          final item = filteredHistory[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _showItemDetailDialog(context, item),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: item.categoryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(item.icon, color: item.categoryColor, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.title,
                                                  style: _jakarta(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.black87),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                item.dateFormatted,
                                                style: _jakarta(fontSize: 10, color: Colors.black38),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.description,
                                            style: _jakarta(fontSize: 11, color: Colors.black54),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (item.valueChange != null) ...[
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.valueChange!,
                                                style: _jakarta(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_right, color: Colors.black26, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_toggle_off, size: 48, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat di kategori $_selectedCategory',
            style: _jakarta(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Lakukan transaksi penjemputan, tukar poin, atau penarikan.',
            style: _jakarta(fontSize: 12, color: Colors.black26),
          ),
        ],
      ),
    );
  }
}