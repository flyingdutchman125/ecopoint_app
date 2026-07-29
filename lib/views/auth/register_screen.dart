import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

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
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi nama, nomor WhatsApp, dan email.')),
      );
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
    if (_addressCtrl.text.trim().isEmpty || _subdistrictCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi alamat, kecamatan/kelurahan, dan kata sandi.')),
      );
      return;
    }

    if (!_agreeSorting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan setujui pernyataan penyortiran sampah anorganik.')),
      );
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
      role: 'user',
      consentSorting: _agreeSorting,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran berhasil. Silakan login.')),
      );
      context.go('/login');
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
    }
  }

  Widget _buildStepIndicator(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF4D9F09),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: _step >= 1 ? const Color(0xFF59B41C) : const Color(0xFFE7F9D9),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: _step >= 2 ? const Color(0xFF59B41C) : const Color(0xFFE7F9D9),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
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
                    child: const Icon(Icons.arrow_back_ios_new, size: 22, color: Colors.black54),
                  ),
                  const Spacer(),
                  Text(
                                      'Daftar',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 82),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _step == 1 ? 'LANGKAH 1 DARI 2 : IDENTITAS' : 'LANGKAH 2 DARI 2 : ALAMAT & SANDI',
                    style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[700], fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  _buildStepIndicator(_step == 1 ? 'Identitas' : 'Alamat & Sandi'),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _step == 1 ? _buildIdentityStep(theme) : _buildAddressStep(theme),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _step == 2
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Daftarkan Sebagai', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: auth.isLoading ? null : _submitRegistration,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF59B41C),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Akun Warga', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                          if (_addressCtrl.text.trim().isEmpty ||
                                              _subdistrictCtrl.text.trim().isEmpty ||
                                              _passwordCtrl.text.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Silakan lengkapi alamat, kecamatan/kelurahan, dan kata sandi.'),
                                              ),
                                            );
                                            return;
                                          }

                                          if (!_agreeSorting) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Silakan setujui pernyataan penyortiran sampah anorganik.'),
                                              ),
                                            );
                                            return;
                                          }

                                          context.push('/register/collector', extra: {
                                            'name': _nameCtrl.text.trim(),
                                            'phone': _phoneCtrl.text.trim(),
                                            'email': _emailCtrl.text.trim(),
                                            'city': _selectedCity,
                                            'address': _addressCtrl.text.trim(),
                                            'subdistrict': _subdistrictCtrl.text.trim(),
                                            'password': _passwordCtrl.text,
                                            'consentSorting': _agreeSorting,
                                          });
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEBD74A),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: const Text('Akun Kolektor', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _goToNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF59B41C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: auth.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Lanjut Ke alamat',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityStep(ThemeData theme) {
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
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF225A0F)),
              ),
              const SizedBox(height: 8),
              Text(
                'Satu akun untuk menikmati tabungan penjemputan sampah digital, klaim e-wallet, & tracker emisi karbon.',
                style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF3E5933), height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('NAMA LENGKAP (SESUAI KTP)'),
        _buildTextField(controller: _nameCtrl, hintText: 'Contoh : Mochammad Zacki'),
        const SizedBox(height: 18),
        _buildLabel('NOMOR WHATSAPP AKTIF'),
        Row(
          children: [
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('+62', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(controller: _phoneCtrl, hintText: '895341381130', keyboardType: TextInputType.phone),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('Digunakan kurir untuk konfirmasi kedatangan', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 18),
        _buildLabel('ALAMAT EMAIL'),
        _buildTextField(controller: _emailCtrl, hintText: 'nama@email.com', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 18),
        _buildLabel('KOTA OPERASIONAL'),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(border: InputBorder.none),
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

  Widget _buildAddressStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel('ALAMAT LENGKAP RUMAH'),
        _buildTextField(controller: _addressCtrl, hintText: 'Nama jalan, Blok, No. Rumah, RT/RW, Ciri Gerbang/Pagar ...', maxLines: 4),
        const SizedBox(height: 18),
        _buildLabel('KECAMATAN/KELURAHAN'),
        _buildTextField(controller: _subdistrictCtrl, hintText: 'Contoh : Lamongan, Sukorejo'),
        const SizedBox(height: 18),
        _buildLabel('BUAT KATA SANDI AKUN'),
        _buildTextField(controller: _passwordCtrl, hintText: '********', obscureText: true),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreeSorting,
              onChanged: (value) => setState(() => _agreeSorting = value ?? false),
            ),
            const Expanded(
              child: Text('Saya bersedia menyortir sampah anorganik secara bersih sebelum kurir tiba'),
            ),
          ],
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
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
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    );
  }
}
