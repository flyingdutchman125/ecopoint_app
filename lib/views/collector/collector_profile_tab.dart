import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class CollectorProfileTab extends StatelessWidget {
  const CollectorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final user = authProv.user;

    // Menggunakan variabel lokal agar Dart type promotion bekerja dengan baik (bebas error null-safety)
    final String? userName = user?.name;
    final String? userEmail = user?.email;

    // Fallback data sesuai gambar mockup jika data user kosong
    final String displayName = (userName != null && userName.trim().isNotEmpty)
        ? userName
        : "Ahmad Syifa’ul Falakhul K.";
    
    final String displayEmail = (userEmail != null && userEmail.trim().isNotEmpty)
        ? userEmail
        : "syi*****@email.com";

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP PROFILE HEADER CARD
            _buildProfileHeader(displayName),
            
            // 2. FORM FIELDS CONTAINER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAMA LENGKAP
                  _buildFieldLabel('NAMA LENGKAP (SESUAI KTP)'),
                  const SizedBox(height: 8),
                  _buildDefaultTextField(displayName),
                  const SizedBox(height: 20),

                  // NOMOR WHATSAPP
                  _buildFieldLabel('NOMOR WHATSAPP AKTIF'),
                  const SizedBox(height: 8),
                  _buildWhatsAppField("895******130"),
                  const SizedBox(height: 20),

                  // ALAMAT EMAIL
                  _buildFieldLabel('ALAMAT EMAIL'),
                  const SizedBox(height: 8),
                  _buildFilledTextField(displayEmail),
                  const SizedBox(height: 20),

                  // SANDI AKUN
                  _buildFieldLabel('SANDI AKUN'),
                  const SizedBox(height: 8),
                  _buildDefaultTextField('*********', isPassword: true),
                  const SizedBox(height: 20),

                  // PLAT KENDARAAN
                  _buildFieldLabel('PLAT KENDARAAN'),
                  const SizedBox(height: 8),
                  _buildDefaultTextField('S 1928 JZ'),
                  const SizedBox(height: 32),

                  // 3. ACTION BUTTONS
                  _buildOutlinedButton(
                    label: 'Ubah Data Pribadi?',
                    onPressed: () {
                      // Aksi navigasi ke halaman ubah profil
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildSolidRedButton(
                    label: 'Keluar dari akun',
                    onPressed: () async {
                      await authProv.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildProfileHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar dengan Icon Kamera kecil
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/profile_placeholder.png'),
                    fit: BoxFit.cover,
                    onError: _handleImageError,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Nama & ID Kolektor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'ID : 0005090',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF757575),
        letterSpacing: 0.5,
      ),
    );
  }

  // Textfield Standar (Putih dengan Border Halus)
  Widget _buildDefaultTextField(String value, {bool isPassword = false}) {
    // Menyensor karakter dengan bullet jika field ini merupakan password
    final String displayedText = isPassword ? '•' * value.length : value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Text(
        displayedText,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: const Color(0xFF424242),
        ),
      ),
    );
  }

  // Textfield Khusus WhatsApp (Ada Kotak Prefix +62 Terpisah)
  Widget _buildWhatsAppField(String numberBody) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          child: Text(
            '+62',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF424242),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Text(
              numberBody,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF424242),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Textfield Berwarna Abu-Abu Penuh
  Widget _buildFilledTextField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Text(
        value,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: const Color(0xFF616161),
        ),
      ),
    );
  }

  // Tombol Putih Border Hijau ("Ubah Data Pribadi?")
  Widget _buildOutlinedButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF7CB342), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: const Color(0xFF7CB342),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Tombol Merah Solid ("Keluar dari akun")
  Widget _buildSolidRedButton({required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C1C),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static void _handleImageError(Object exception, StackTrace? stackTrace) {
    // Handler eror gambar jika diperlukan
  }
}