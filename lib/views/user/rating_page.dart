import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../core/rating_state.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _selectedTab = 0; // 0 = belum diberi ulasan, 1 = cek ulasan anda

  @override
  void initState() {
    super.initState();
    RatingState.instance.init();
  }

  @override
  Widget build(BuildContext context) {
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
          'Rating & Ulasan',
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
                            color: _selectedTab == 0
                                ? const Color(0xFF7CB342)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Belum diberikan Ulasan',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 0 ? const Color(0xFF7CB342) : Colors.black87,
                          ),
                        ),
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
                            color: _selectedTab == 1
                                ? const Color(0xFF7CB342)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Cek Ulasan anda',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTab == 1 ? const Color(0xFF7CB342) : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),

          // list with ValueListenableBuilder
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _selectedTab == 0
                  ? RatingState.instance.unreviewedOrders
                  : RatingState.instance.reviewedOrders,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _selectedTab == 0
                              ? 'Semua orderan telah diberikan ulasan!'
                              : 'Belum ada ulasan yang dikirim.',
                          style: GoogleFonts.inter(color: const Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: Color(0xFFEDEDED)),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final it = items[index];
                    return _buildListItem(it, _selectedTab == 0);
                  },
                );
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
            child: const Icon(
              Icons.psychology_alt_outlined,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['name'] ?? '-',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['time'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                        Text(
                          item['date'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFFBDBDBD),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (!isNotReviewed) ...[
                      _buildStars((item['rating'] as num?)?.toInt() ?? 5),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        item['detail'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF757575),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isNotReviewed)
                      InkWell(
                        onTap: () async {
                          final res = await context.push(
                            '/rating/detail',
                            extra: {'mode': 'create', 'item': item},
                          );
                          if (res == true && mounted) {
                            setState(() => _selectedTab = 1);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF7E6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFF1E6B8)),
                          ),
                          child: Text(
                            'Lakukan ulasan',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF7CB342),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    if (!isNotReviewed)
                      InkWell(
                        onTap: () {
                          context.push(
                            '/rating/detail',
                            extra: {'mode': 'view', 'item': item},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF7CB342)),
                          ),
                          child: Text(
                            'Cek ulasan anda',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF7CB342),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
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
        return Icon(
          Icons.star,
          color: filled ? const Color(0xFFFFC107) : const Color(0xFFE0E0E0),
          size: 16,
        );
      }),
    );
  }
}
