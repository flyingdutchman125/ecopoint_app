import '../../core/utils/alert_helper.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(ApiConstants.forgotPassword, {
        'email': _emailController.text.trim(),
      });

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (data['success'] == true) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Berhasil'),
            content: Text(
              data['message'] ??
                  'Tautan reset password telah dikirim ke email Anda.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/login');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        AppAlerts.showError(context, data['message'] ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      if (mounted) {
        AppAlerts.showError(context, 'Gagal terhubung ke server');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lupa Password',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: const Color(0xFF1B5E20),
                ).animate().scale(),
                const SizedBox(height: 24),
                Text(
                  'Reset Password',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B5E20),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 8),
                Text(
                  'Masukkan email yang terdaftar, kami akan mengirimkan tautan untuk mereset password Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF4CAF50),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1B5E20),
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return 'Email tidak boleh kosong';
                      if (!val.contains('@')) return 'Email tidak valid';
                      return null;
                    },
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Kirim Link Reset',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Kembali ke Login',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1B5E20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
