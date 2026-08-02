import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewDetailPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const ReviewDetailPage({super.key, this.extra});

  @override
  State<ReviewDetailPage> createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    final item = widget.extra?['item'] as Map<String, dynamic>?;
    final mode = widget.extra?['mode']?.toString() ?? 'view';
    if (mode == 'view' && item != null) {
      _rating = (item['rating'] ?? 5) as int;
      _reviewController.text = item['text'] ?? '';
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() {
    // dummy: just pop back with result — in real app, call backend
    final result = {
      'rating': _rating,
      'text': _reviewController.text.trim(),
    };
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.extra?['item'] as Map<String, dynamic>?;
    final mode = widget.extra?['mode']?.toString() ?? 'view';
    final isCreate = mode == 'create';

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
          isCreate ? 'Beri Ulasan' : 'Ulasan',
          style: GoogleFonts.outfit(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE0E0E0))),
                  child: const Icon(Icons.psychology_alt_outlined, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item?['name'] ?? '-', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(item?['detail'] ?? '', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9E9E9E))),
                    ],
                  ),
                ),
                if (item != null && item['rating'] != null)
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < (item['rating'] as int);
                      return Icon(Icons.star, color: filled ? const Color(0xFFFFC107) : const Color(0xFFE0E0E0), size: 16);
                    }),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(isCreate ? 'Berikan rating' : 'Ulasan', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(i < _rating ? Icons.star : Icons.star_border, color: i < _rating ? const Color(0xFFFFC107) : const Color(0xFFE0E0E0)),
                        onPressed: isCreate
                            ? () {
                                setState(() => _rating = i + 1);
                              }
                            : null,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    maxLines: 6,
                    readOnly: !isCreate,
                    decoration: InputDecoration(
                      hintText: isCreate ? 'Tulis ulasan Anda di sini...' : '',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!isCreate && item != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('kode orderan : ${item['orderCode'] ?? '-'}', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF9E9E9E))),
                    )
                ],
              ),
            ),
          ),

          if (isCreate)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7CB342)),
                  onPressed: _submitReview,
                  child: Text('Kirim Ulasan', style: GoogleFonts.inter(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
