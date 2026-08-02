import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _selectedTab = 0; // 0 = belum diberi ulasan, 1 = cek ulasan anda

  final List<Map<String, dynamic>> _notReviewed = [
    {
      'id': 'r1',
      'name': 'Bapak Sutarjo Sangar',
      'detail': 'Kardus, 12kg',
      'time': '14.50',
      'date': '15 Juli 2026',
      'avatar': null,
    },
  ];

  final List<Map<String, dynamic>> _reviewed = [
    {
      'id': 'r2',
      'name': 'Hendra Pengepul gantenk',
      'detail': 'Kardus, 2kg',
      'rating': 5,
      'time': '12.20',
      'date': '21 Juli 2026',
      'avatar': null,
      'text': 'Pelayanan bagus, orangnya juga ramah top markotop pokonya buat Bang hendra',
      'orderCode': 'EP 0002'
    },
    {
      'id': 'r3',
      'name': 'Bapak Muftar',
      'detail': 'Botol Plastik, 2kg',
      'rating': 4,
      'time': '14.20',
      'date': '20 Juli 2026',
      'avatar': null,
      'text': 'Cepat dan rapi',
      'orderCode': 'EP 0001'
    }
  ];

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = _selectedTab == 0 ? _notReviewed : _reviewed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.maybeOf(context)?.pop(),
        ),
        title: Text(
          'Rating',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // tabs
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 0 ? const Color(0xFF7CB342) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text('Belum diberikan Ulasan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedTab == 1 ? const Color(0xFF7CB342) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text('Cek Ulasan anda', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),

          // list
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text('Tidak ada rating & ulasan lain', style: GoogleFonts.inter(color: const Color(0xFF9E9E9E))),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEDEDED)),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final it = items[index];
                      return _buildListItem(it, _selectedTab == 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item, bool isNotReviewed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Icon(Icons.psychology_alt_outlined, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item['name'] ?? '-', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item['time'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9E9E9E))),
                        Text(item['date'] ?? '', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFBDBDBD))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (!isNotReviewed) ...[_buildStars(item['rating'] ?? 0), const SizedBox(width: 8)],
                    Text(item['detail'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF757575))),
                    const SizedBox(width: 8),
                    if (isNotReviewed)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF7E6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF1E6B8)),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to review form — since backend dummy, pass item
                            context.push('/rating/detail', extra: {'mode': 'create', 'item': item});
                          },
                          child: Text('Lakukan ulasan', style: GoogleFonts.inter(color: const Color(0xFF7CB342))),
                        ),
                      ),
                    if (!isNotReviewed)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF7CB342)),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // view review
                            context.push('/rating/detail', extra: {'mode': 'view', 'item': item});
                          },
                          child: Text('Cek ulasan anda', style: GoogleFonts.inter(color: const Color(0xFF7CB342))),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < count;
        return Icon(Icons.star, color: filled ? const Color(0xFFFFC107) : const Color(0xFFE0E0E0), size: 16);
      }),
    );
  }
}
