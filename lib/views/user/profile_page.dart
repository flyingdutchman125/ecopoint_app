import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// TODO: Jika menggunakan Opsi 2 (Widget Routing), import file halaman login kamu di sini:
// import 'package:ecopoint/views/auth/login_page.dart';

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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  bool _isPendingApproval = false; // Status menunggu ACC Admin
  bool _isLoading = false; // Status simulasi kirim data ke backend

  // Controller untuk menampung data inputan
  late TextEditingController _nameController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data awal akun
    _nameController = TextEditingController(text: 'Ahmad Syifa’ul Falakhul K.');
    _whatsappController = TextEditingController(text: '895333222130'); 
    _emailController = TextEditingController(text: 'syifaul@email.com');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Fungsi simulasi pengiriman data ke backend
  Future<void> _submitProfileUpdate() async {
    setState(() {
      _isLoading = true;
    });

    // Simulasi delay request jaringan backend selama 1.5 detik
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isLoading = false;
      _isEditing = false;
      _isPendingApproval = true; // Set menjadi true untuk memicu banner & lock field
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Permintaan perubahan berhasil dikirim. Menunggu persetujuan admin!',
            style: _jakarta(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF1B3A1B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Fungsi untuk memunculkan dialog konfirmasi keluar akun
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib memilih salah satu tombol
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Keluar Akun', 
            style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun EcoPoint?', 
            style: _jakarta(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal', 
                style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                // Tampilkan snackbar pemberitahuan keluar sebelum pindah screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil keluar dari akun', style: _jakarta(color: Colors.white)),
                    backgroundColor: const Color(0xFFBA2525),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                // --- PROSES NAVIGASI KELUAR (Pilih salah satu sesuai arsitektur projectmu) ---
                
                // OPSI 1: Jika menggunakan Nama Route / Named Routes (Misal route login di main.dart dinamai '/login')
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                
                // OPSI 2: Jika menggunakan Widget Routing langsung tanpa nama (Aktifkan baris di bawah dan sesuaikan nama classnya)
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(builder: (context) => const LoginPage()), // Ganti LoginPage dengan nama class login kamu
                //   (route) => false, // Menghapus seluruh history halaman sebelumnya
                // );
              },
              child: Text(
                'Keluar', 
                style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFBA2525)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              
              // Banner pemberitahuan jika data sedang ditinjau admin
              if (_isPendingApproval) _buildPendingBanner(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditableInfoField('NAMA LENGKAP (SESUAI KTP)', _nameController),
                    const SizedBox(height: 20),
                    _buildEditableWhatsAppField(),
                    const SizedBox(height: 20),
                    _buildEditableInfoField('ALAMAT EMAIL', _emailController),
                    const SizedBox(height: 20),
                    _buildStaticInfoField('SANDI AKUN', '********'),
                    const SizedBox(height: 48),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 24, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.black12, width: 0.5),
                ),
                child: const ClipOval(
                  child: Icon(Icons.person, size: 40, color: Colors.black38),
                ),
              ),
              Positioned(
                top: 0,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 11, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text,
                  style: _jakarta(fontSize: 17.5, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: _jakarta(fontSize: 12.5, color: Colors.black45, fontWeight: FontWeight.w500),
                    children: const [
                      TextSpan(text: 'ID : '),
                      TextSpan(text: '5505090', style: TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.watch_later_outlined, color: Color(0xFFFF9800), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Perubahan data pribadi Anda sedang menunggu persetujuan dari Admin EcoPoint.',
              style: _jakarta(fontSize: 12.5, color: const Color(0xFF856404), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _jakarta(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black45)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing && !_isLoading,
          style: _jakarta(fontSize: 14.5, color: Colors.black87, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: _isEditing ? Colors.white : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5CB82B), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableWhatsAppField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NOMOR WHATSAPP AKTIF', style: _jakarta(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black45)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text('+62', style: _jakarta(fontSize: 14.5, color: Colors.black87, fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: TextFormField(
                controller: _whatsappController,
                enabled: _isEditing && !_isLoading,
                keyboardType: TextInputType.phone,
                style: _jakarta(fontSize: 14.5, color: Colors.black87, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _isEditing ? Colors.white : const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                    borderSide: const BorderSide(color: Color(0xFF5CB82B), width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaticInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _jakarta(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black45)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(value, style: _jakarta(fontSize: 14.5, color: Colors.black87, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF5CB82B)));
    }

    if (_isEditing) {
      return Column(
        children: [
          GestureDetector(
            onTap: _submitProfileUpdate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF5CB82B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Ajukan Perubahan data', style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              setState(() {
                _isEditing = false;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black38, width: 1.2),
              ),
              child: Text('Batal', style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black54)),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: _isPendingApproval
              ? null
              : () {
                  setState(() {
                    _isEditing = true;
                  });
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _isPendingApproval ? Colors.grey[300] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isPendingApproval ? Colors.transparent : const Color(0xFF5CB82B),
                width: 1.2,
              ),
            ),
            child: Text(
              _isPendingApproval ? 'Menunggu Persetujuan Admin...' : 'Ubah Data Pribadi?',
              style: _jakarta(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _isPendingApproval ? Colors.black38 : const Color(0xFF5CB82B),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _showLogoutDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFBA2525),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Keluar dari akun', style: _jakarta(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}