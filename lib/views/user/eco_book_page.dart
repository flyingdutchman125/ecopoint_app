import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

TextStyle _jakarta({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = Colors.black,
  FontStyle? fontStyle,
  double? letterSpacing,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
  );
}

class EcoBookPage extends StatelessWidget {
  const EcoBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'id': '1',
        'title': 'Kamus Kode Plastik',
        'subtitle': 'Mengenal Angka di Bawah Botol',
        'icon': Icons.category,
        'color': const Color(0xFF4CAF50),
      },
      {
        'id': '2',
        'title': 'D.I.Y Eco-Hacks',
        'subtitle': 'Mengolah Sampah Mandiri',
        'icon': Icons.build,
        'color': const Color(0xFF2E7D32),
      },
      {
        'id': '3',
        'title': 'Kalkulator Dampak Lingkungan',
        'subtitle': 'The "Real Impact"',
        'icon': Icons.calculate,
        'color': const Color(0xFF558B2F),
      },
      {
        'id': '4',
        'title': 'Etika & Keamanan Pemilihan',
        'subtitle': 'Safety First',
        'icon': Icons.security,
        'color': const Color(0xFF33691E),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'EcoBook',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: modules.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final m = modules[index];
            return InkWell(
              onTap: () => context.push(
                '/eco-book/modul',
                extra: {'id': m['id'], 'title': m['title']},
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (m['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        m['icon'] as IconData,
                        color: m['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modul ${m['id']}',
                            style: _jakarta(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m['title'] as String,
                            style: _jakarta(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            m['subtitle'] as String,
                            style: _jakarta(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.black26),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
