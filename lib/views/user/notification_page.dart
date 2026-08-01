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

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifikasi',
          style: _jakarta(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- KATEGORI HARI INI ---
                  _buildSectionHeader('Hari Ini'),
                  _buildNotificationItem(
                    icon: Icons.local_shipping,
                    iconColor: const Color(0xFFE53935),
                    categoryLabel: 'Jemput',
                    title: 'Pesanan Berhasil di isi !',
                    subtitle: 'Kardus, 2kg',
                    time: '12.19',
                    date: '21 Juli 2026',
                  ),
                  _buildDivider(),
                  _buildNotificationItem(
                    icon: Icons.receipt_long,
                    iconColor: const Color(0xFFFFC107),
                    categoryLabel: 'Order',
                    title: 'Collector Ditemukan !',
                    subtitle: 'Pak Subarsono berminat',
                    time: '12.2',
                    date: '21 Juli 2026',
                  ),
                  _buildDivider(),
                  _buildNotificationItem(
                    icon: Icons.chat_bubble_outline,
                    iconColor: const Color(0xFFFFC107),
                    categoryLabel: 'Chat',
                    title: 'Pak Subarsono Mengirim Pesan',
                    subtitle: 'Mas ini perkiraan sampai 15 menit lagi',
                    time: '12.22',
                    date: '21 Juli 2026',
                  ),

                  // --- KATEGORI MINGGU INI ---
                  _buildSectionHeader('Minggu Ini'),
                  _buildNotificationItem(
                    icon: Icons.eco,
                    iconColor: const Color(0xFF4CAF50),
                    categoryLabel: 'EcoTree',
                    title: 'Berhasil Meningkatkan Level',
                    subtitle: 'Mencapai level 2 dalam penumbuhan tunas EcoTree',
                    time: '12.22',
                    date: '21 Juli 2026',
                  ),
                ],
              ),
            ),
          ),
          
          // --- FOOTER TEKS BAWAH ---
          Padding(
            padding: const EdgeInsets.only(bottom: 40, top: 20),
            child: Center(
              child: Text(
                'Tidak ada notifikasi lain',
                style: _jakarta(fontSize: 14, color: Colors.black38, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF4F6F8),
      child: Text(
        title,
        style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String categoryLabel,
    required String title,
    required String subtitle,
    required String time,
    required String date,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blok Ikon Kiri + Label
          SizedBox(
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(height: 6),
                Text(
                  categoryLabel,
                  textAlign: TextAlign.center,
                  style: _jakarta(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Konten Tengah (Judul & Deskripsi)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: _jakarta(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: _jakarta(fontSize: 11, color: Colors.black45),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Info Waktu & Tanggal Kanan
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: _jakarta(fontSize: 11, color: Colors.black45),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: _jakarta(fontSize: 10, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F3F4),
      indent: 16,
      endIndent: 16,
    );
  }
}