import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = 'admin@ecopoint.id';
    _passwordCtrl.text = 'admin123456';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi email dan kata sandi')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (success && mounted) {
      final role = auth.user?.role;
      if (role == 'admin') {
        context.go('/admin');
      } else if (role == 'collector') {
        context.go('/collector');
      } else {
        context.go('/user');
      }
    } else if (!success && mounted && auth.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  Future<void> _quickRegisterAdmin() async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // Auto register admin if not exists
    const email = 'admin@ecopoint.id';
    const password = 'admin123456';

    _emailCtrl.text = email;
    _passwordCtrl.text = password;

    final regSuccess = await auth.register(
      email: email,
      password: password,
      name: 'Admin Master EcoPoint',
      role: 'admin',
      phone: '081299998888',
      address: 'Jl. Admin No. 1',
      city: 'Jakarta',
      subdistrict: 'Gambir',
      consentSorting: true,
    );

    if (regSuccess) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Akun Admin berhasil dibuat! Mencoba login...'),
        ),
      );
    }
    // Attempt login regardless (if created or already exists)
    await _login();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE7F9D9), Color(0xFFFFFFFF)],
              ),
            ),
          ),
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFDEFFB8),
                borderRadius: BorderRadius.circular(120),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'ECO ',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF59B41C),
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        TextSpan(
                          text: 'POINT',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF9CC63A),
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ubah Sampah Jadi Berkah Finansial',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: const Color(0xFF22311F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelola sampah bernilai jual Anda dengan dukungan kecerdasan buatan dinamis.',
                    style: GoogleFonts.outfit(
                      color: Colors.green[900],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 24,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Masuk Ke Akun',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'ALAMAT EMAIL',
                            hintText: 'user@ecopoint.com / admin@ecopoint.id',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordCtrl,
                          decoration: const InputDecoration(
                            labelText: 'KATA SANDI',
                            hintText: '********',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF59B41C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: auth.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'Masuk',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: auth.isLoading
                              ? null
                              : _quickRegisterAdmin,
                          icon: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.purple,
                          ),
                          label: Text(
                            'Masuk / Buat Akun Admin',
                            style: GoogleFonts.outfit(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.purple),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Daftar Warga',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF59B41C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '|',
                          style: GoogleFonts.outfit(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register/collector'),
                          child: Text(
                            'Daftar Kolektor',
                            style: GoogleFonts.outfit(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
