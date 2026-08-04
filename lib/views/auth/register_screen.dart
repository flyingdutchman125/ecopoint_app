import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/alert_helper.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  const RegisterScreen({super.key, this.role = 'user'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _subdistrictCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  int _step = 1;
  String _selectedCity = 'Lamongan';
  bool _agreeSorting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _subdistrictCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty) {
      AppAlerts.showError(context, 'Silakan lengkapi nama, nomor WhatsApp, dan email.');
      return;
    }

    setState(() {
      _step = 2;
    });
  }

  void _goBack() {
    setState(() {
      _step = 1;
    });
  }

  Future<void> _submitRegistration() async {
    if (_addressCtrl.text.trim().isEmpty ||
        _subdistrictCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      AppAlerts.showError(context, 'Silakan lengkapi alamat, kecamatan/kelurahan, dan kata sandi.');
      return;
    }

    if (!_agreeSorting) {
      AppAlerts.showError(context, 'Silakan setujui pernyataan penyortiran sampah anorganik.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      city: _selectedCity,
      address: _addressCtrl.text.trim(),
      subdistrict: _subdistrictCtrl.text.trim(),
      role: widget.role,
      consentSorting: _agreeSorting,
    );

    if (success && mounted) {
      AppAlerts.showSuccess(context, 'Pendaftaran berhasil. Silakan login.');
      context.go('/login');
    } else if (mounted && auth.error != null) {
      AppAlerts.showError(context, auth.error!);
    }
  }

  void _handleStep2Submit() {
    if (_addressCtrl.text.trim().isEmpty ||
        _subdistrictCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.isEmpty) {
      AppAlerts.showError(context, 'Silakan lengkapi alamat, kecamatan/kelurahan, dan kata sandi.');
      return;
    }

    if (!_agreeSorting) {
      AppAlerts.showError(context, 'Silakan setujui pernyataan penyortiran sampah anorganik.');
      return;
    }

    if (widget.role == 'collector') {
      context.push(
        '/register/collector',
        extra: {
          'name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'city': _selectedCity,
          'address': _addressCtrl.text.trim(),
          'subdistrict': _subdistrictCtrl.text.trim(),
          'password': _passwordCtrl.text,
          'consentSorting': _agreeSorting,
        },
      );
    } else {
      _submitRegistration();
    }
  }

  Widget _buildStepIndicator(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: const Color(0xFF59B41C),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (int i = 1; i <= (widget.role == 'collector' ? 4 : 2); i++) ...[
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _step >= i
                        ? const Color(0xFF59B41C)
                        : const Color(0xFFE7F9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (i < (widget.role == 'collector' ? 4 : 2))
                const SizedBox(width: 6),
            ]
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE7F9D9), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_step == 1) {
                          context.pop();
                        } else {
                          _goBack();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.role == 'collector'
                          ? 'Daftar Kolektor'
                          : 'Daftar Warga',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 36),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _step == 1
                                ? 'LANGKAH 1 DARI ${widget.role == 'collector' ? '4' : '2'} : IDENTITAS'
                                : 'LANGKAH 2 DARI ${widget.role == 'collector' ? '4' : '2'} : ALAMAT & SANDI',
                            style: GoogleFonts.outfit(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStepIndicator(
                            _step == 1 ? 'Identitas' : 'Alamat & Sandi',
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _step == 1
                              ? _buildIdentityStep()
                              : _buildAddressStep(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.isLoading
                              ? null
                              : (_step == 1
                                    ? _goToNextStep
                                    : _handleStep2Submit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF59B41C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _step == 1
                                      ? 'Lanjut Ke alamat'
                                      : (widget.role == 'collector'
                                            ? 'Lanjutkan'
                                            : 'Daftar Sekarang'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFE7F9D9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EKONOMI SIRKULAR',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF225A0F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Satu akun untuk menikmati tabungan penjemputan sampah digital, klaim e-wallet, & tracker emisi karbon.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: const Color(0xFF3E5933),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('NAMA LENGKAP (SESUAI KTP)'),
        _buildTextField(
          controller: _nameCtrl,
          hintText: 'Contoh : Mochammad Zacki',
        ),
        const SizedBox(height: 18),
        _buildLabel('NOMOR WHATSAPP AKTIF'),
        Row(
          children: [
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  '+62',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _phoneCtrl,
                hintText: '895341381130',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Digunakan kurir untuk konfirmasi kedatangan',
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 18),
        _buildLabel('ALAMAT EMAIL'),
        _buildTextField(
          controller: _emailCtrl,
          hintText: 'nama@email.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        _buildLabel('KOTA OPERASIONAL'),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(border: InputBorder.none),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            style: GoogleFonts.outfit(color: Colors.black87, fontSize: 16),
            items: const [
              DropdownMenuItem(value: 'Lamongan', child: Text('Lamongan')),
              DropdownMenuItem(value: 'Surabaya', child: Text('Surabaya')),
              DropdownMenuItem(value: 'Jakarta', child: Text('Jakarta')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedCity = value);
            },
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('ALAMAT LENGKAP RUMAH'),
        _buildTextField(
          controller: _addressCtrl,
          hintText: 'Nama jalan, Blok, No. Rumah, RT/RW...',
          maxLines: 4,
        ),
        const SizedBox(height: 18),
        _buildLabel('KECAMATAN/KELURAHAN'),
        _buildTextField(
          controller: _subdistrictCtrl,
          hintText: 'Contoh : Lamongan, Sukorejo',
        ),
        const SizedBox(height: 18),
        _buildLabel('BUAT KATA SANDI AKUN'),
        _buildTextField(
          controller: _passwordCtrl,
          hintText: '********',
          obscureText: true,
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _agreeSorting,
                activeColor: const Color(0xFF59B41C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                onChanged: (value) =>
                    setState(() => _agreeSorting = value ?? false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Saya bersedia menyortir sampah anorganik secara bersih sebelum kurir tiba',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      style: GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }
}
