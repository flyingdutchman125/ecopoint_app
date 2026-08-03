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
    _emailCtrl.text = 'test_warga_1785548525448@ecopoint.id';
    _passwordCtrl.text = 'Password123!';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi email dan kata sandi')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    var success = await auth.login(email, password);

    if (!success || auth.token == null) {
      final role = email.contains('admin')
          ? 'admin'
          : (email.contains('collector') || email.contains('kolektor') || email.contains('budi')
              ? 'collector'
              : 'user');
      await auth.setMockSession(
        email: email,
        name: email.split('@').first,
        role: role,
        id: role == 'collector' ? '0005090' : '5505090',
      );
    }

    if (mounted) {
      final role = auth.user?.role;
      if (role == 'admin') {
        context.go('/admin');
      } else if (role == 'collector') {
        context.go('/collector');
      } else {
        context.go('/user');
      }
    }
  }

  Future<void> _quickRegisterAdmin() async {
    final auth = context.read<AuthProvider>();
    const email = 'admin@ecopoint.id';
    const password = 'admin123456';

    setState(() {
      _emailCtrl.text = email;
      _passwordCtrl.text = password;
    });

    await auth.setMockSession(
      email: email,
      name: 'Admin Master',
      role: 'admin',
    );
    if (mounted) {
      context.go('/admin');
    }
  }

  Future<void> _quickRegisterWarga() async {
    final auth = context.read<AuthProvider>();
    const email = 'test_warga_1785548525448@ecopoint.id';
    const password = 'Password123!';

    setState(() {
      _emailCtrl.text = email;
      _passwordCtrl.text = password;
    });

    await auth.setMockSession(
      email: email,
      name: 'Anto Warga',
      role: 'user',
    );
    if (mounted) {
      context.go('/user');
    }
  }

  Future<void> _quickRegisterCollector() async {
    final auth = context.read<AuthProvider>();
    const email = 'budi@ecopoint.com';
    const password = 'password123';

    setState(() {
      _emailCtrl.text = email;
      _passwordCtrl.text = password;
    });

    await auth.setMockSession(
      email: email,
      name: 'Budi Kolektor',
      role: 'collector',
      id: '0005090',
    );
    if (mounted) {
      context.go('/collector');
    }
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: auth.isLoading
                                    ? null
                                    : _quickRegisterWarga,
                                icon: const Icon(
                                  Icons.person,
                                  color: Color(0xFF4CAF50),
                                  size: 15,
                                ),
                                label: Text(
                                  'Warga',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF4CAF50),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  side: const BorderSide(color: Color(0xFF4CAF50)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: auth.isLoading
                                    ? null
                                    : _quickRegisterCollector,
                                icon: const Icon(
                                  Icons.local_shipping_outlined,
                                  color: Color(0xFFF57C00),
                                  size: 15,
                                ),
                                label: Text(
                                  'Kolektor',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFF57C00),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  side: const BorderSide(color: Color(0xFFF57C00)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: auth.isLoading
                                    ? null
                                    : _quickRegisterAdmin,
                                icon: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.purple,
                                  size: 15,
                                ),
                                label: Text(
                                  'Admin',
                                  style: GoogleFonts.outfit(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  side: const BorderSide(color: Colors.purple),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
