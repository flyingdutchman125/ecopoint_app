import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final List<String> _categories = [
    'Semua',
    'Jemput',
    'Rating',
    'Points',
    'Tukar Point',
    'Withdraw'
  ];

  final List<_HistoryItemData> _allHistory = const [
    _HistoryItemData(
      title: 'Pilah Sampah Lemari tua',
      description: 'Melakukan transaksi pemilahan sampah lemari tua dengan colector Pak subarsono',
      category: 'Jemput',
      date: '21 Juli 2027',
    ),
    _HistoryItemData(
      title: 'Pilah Sampah Lemari tua',
      description: 'Sangat membantu untuk penjemputan dan dilakukan secara satset joss pokoe !!',
      category: 'Rating',
      date: '21 Juli 2027',
    ),
    _HistoryItemData(
      title: 'Menyelesaikan Misi 10kg Carbon',
      description: 'Berhasil Menyelesaikan misi 10kg dan mendapat hadiah total 1000 Pts',
      category: 'Points',
      date: '20 Juli 2027',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _selectedCategory == 'Semua'
        ? _allHistory
        : _allHistory.where((item) => item.category == _selectedCategory).toList();

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: filteredHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: filteredHistory.length + 1,
              itemBuilder: (context, index) {
                if (index == filteredHistory.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    child: Text(
                      'Tidak ada obrolan lain',
                      textAlign: TextAlign.center,
                      style: _jakarta(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.w500),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _HistoryCard(data: filteredHistory[index]),
                );
              },
            ),
    );
  }

  Widget _buildFilterBar() {
    List<Widget> rowChildren = [];

    for (int index = 0; index < _categories.length; index++) {
      final cat = _categories[index];
      final isSelected = _selectedCategory == cat;

      rowChildren.add(
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown, // Memaksa teks mengecil otomatis jika ruang menyempit
                child: Text(
                  cat,
                  textAlign: TextAlign.center,
                  style: _jakarta(
                    fontSize: 12, // Ukuran dasar yang ideal untuk layar normal
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: _getCategoryColor(cat, isSelected),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Berikan garis batas pembatas '|' antar menu kecuali di item paling akhir
      if (index < _categories.length - 1) {
        rowChildren.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 1),
            child: Text(
              '|',
              style: TextStyle(color: Colors.black12, fontSize: 11),
            ),
          ),
        );
      }
    }

    return Container(
      height: 46,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: rowChildren,
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
            'Belum ada riwayat di kategori ini',
            style: _jakarta(fontSize: 14, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category, bool isSelected) {
    if (category == 'Semua') return Colors.black87;
    if (category == 'Rating' || category == 'Points') {
      return const Color(0xFFB8860B);
    }
    return const Color(0xFF4CAF50);
  }
}

class _HistoryItemData {
  final String title;
  final String description;
  final String category;
  final String date;

  const _HistoryItemData({
    required this.title,
    required this.description,
    required this.category,
    required this.date,
  });
}

class _HistoryCard extends StatelessWidget {
  final _HistoryItemData data;
  const _HistoryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.title,
                  style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 8),
              _buildTag(data.category),
              const SizedBox(width: 6),
              Text(
                data.date,
                style: _jakarta(fontSize: 10.5, color: Colors.black38, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.description,
            style: _jakarta(fontSize: 11, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String category) {
    final isYellowTag = category == 'Rating' || category == 'Points';
    final baseColor = isYellowTag ? const Color(0xFFB8860B) : const Color(0xFF4CAF50);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: baseColor.withOpacity(0.5), width: 0.8),
        color: baseColor.withOpacity(0.05),
      ),
      child: Text(
        category,
        style: _jakarta(fontSize: 9, fontWeight: FontWeight.bold, color: baseColor),
      ),
    );
  }
}