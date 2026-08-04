import '../../core/utils/alert_helper.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/history_state.dart';

class CollectorProfileTab extends StatefulWidget {
  const CollectorProfileTab({super.key});

  @override
  State<CollectorProfileTab> createState() => _CollectorProfileTabState();
}

class _CollectorProfileTabState extends State<CollectorProfileTab> {
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _plateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _plateController = TextEditingController(text: 'S 1928 JZ');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name ?? 'Ahmad Syifa’ul Falakhul K.';
      _emailController.text = user.email.isNotEmpty
          ? user.email
          : 'syifaul@ecopoint.com';

      String rawPhone = user.phone ?? '895123456130';
      if (rawPhone.startsWith('+62')) {
        rawPhone = rawPhone.substring(3);
      } else if (rawPhone.startsWith('62')) {
        rawPhone = rawPhone.substring(2);
      } else if (rawPhone.startsWith('0')) {
        rawPhone = rawPhone.substring(1);
      }
      _phoneController.text = rawPhone;
    } else {
      _nameController.text = 'Ahmad Syifa’ul Falakhul K.';
      _phoneController.text = '895123456130';
      _emailController.text = 'syifaul@ecopoint.com';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfileUpdate() async {
    setState(() {
      _isLoading = true;
    });

    final authProv = context.read<AuthProvider>();
    String phoneText = _phoneController.text.trim();
    if (!phoneText.startsWith('+62')) {
      if (phoneText.startsWith('0')) {
        phoneText = '+62${phoneText.substring(1)}';
      } else {
        phoneText = '+62$phoneText';
      }
    }

    await authProv.updateUserProfile(
      name: _nameController.text.trim(),
      phone: phoneText,
      email: _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (mounted) {
      AppAlerts.showSuccess(context, 'Data profil kolektor berhasil diperbarui!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final user = authProv.user;
    final displayName = user?.name ?? _nameController.text;
    final collectorId = user?.formattedId ?? '0005090';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP PROFILE HEADER CARD (Dengan Awalan ID 000)
            _buildProfileHeader(displayName, collectorId, user?.avatarUrl),

            // 2. FORM FIELDS CONTAINER
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAMA LENGKAP
                  _buildFieldLabel('NAMA LENGKAP (SESUAI KTP)'),
                  const SizedBox(height: 8),
                  _buildEditableTextField(_nameController, enabled: _isEditing),
                  const SizedBox(height: 20),

                  // NOMOR WHATSAPP
                  _buildFieldLabel('NOMOR WHATSAPP AKTIF'),
                  const SizedBox(height: 8),
                  _buildWhatsAppField(_phoneController, enabled: _isEditing),
                  const SizedBox(height: 20),

                  // ALAMAT EMAIL
                  _buildFieldLabel('ALAMAT EMAIL'),
                  const SizedBox(height: 8),
                  _buildEditableTextField(
                    _emailController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),

                  // SANDI AKUN
                  _buildFieldLabel('SANDI AKUN'),
                  const SizedBox(height: 8),
                  _buildDefaultTextField('*********', isPassword: true),
                  const SizedBox(height: 20),

                  // PLAT KENDARAAN
                  _buildFieldLabel('PLAT KENDARAAN'),
                  const SizedBox(height: 8),
                  _buildEditableTextField(
                    _plateController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 32),

                  // 3. ACTION BUTTONS
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF7CB342),
                      ),
                    )
                  else if (_isEditing) ...[
                    _buildSolidGreenButton(
                      label: 'Simpan Perubahan',
                      onPressed: _saveProfileUpdate,
                    ),
                    const SizedBox(height: 12),
                    _buildOutlinedButton(
                      label: 'Batal',
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                      },
                    ),
                  ] else ...[
                    _buildOutlinedButton(
                      label: 'Ubah Data Pribadi?',
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
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
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubah Foto Profil Kolektor',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF7CB342),
              ),
              title: Text(
                'Ambil Foto (Kamera)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePickerHelper.pickImage(
                  ImageSource.camera,
                );
                if (picked != null) {
                  await _updateAvatar(picked.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFF7CB342),
              ),
              title: Text(
                'Pilih dari Galeri HP',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await ImagePickerHelper.pickImage(
                  ImageSource.gallery,
                );
                if (picked != null) {
                  await _updateAvatar(picked.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateAvatar(String path) async {
    await context.read<AuthProvider>().updateUserProfile(avatarUrl: path);
    HistoryState.instance.addHistory(
      title: 'Ubah Foto Profil Kolektor',
      description: 'Berhasil memperbarui foto profil akun kolektor.',
      category: 'Akun',
      valueChange: 'Foto Diperbarui',
    );
    if (mounted) {
      AppAlerts.showSuccess(context, 'Foto profil kolektor berhasil diperbarui!');
    }
  }

  Widget _buildProfileHeader(String name, String idText, String? avatarUrl) {
    ImageProvider? avatarImage;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        avatarImage = NetworkImage(avatarUrl);
      } else {
        avatarImage = FileImage(File(avatarUrl));
      }
    }

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
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    color: Colors.grey[200],
                    image: avatarImage != null
                        ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                        : null,
                  ),
                  child: avatarImage == null
                      ? const ClipOval(
                          child: Icon(
                            Icons.person,
                            size: 44,
                            color: Colors.black38,
                          ),
                        )
                      : null,
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
          ),
          const SizedBox(width: 16),
          // Nama & ID Kolektor (Awalan 000)
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
                  'ID : $idText',
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

  Widget _buildEditableTextField(
    TextEditingController controller, {
    bool enabled = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF424242)),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7CB342), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDefaultTextField(String value, {bool isPassword = false}) {
    final String displayedText = isPassword ? '•' * value.length : value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
      ),
      child: Text(
        displayedText,
        style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF424242)),
      ),
    );
  }

  Widget _buildWhatsAppField(
    TextEditingController controller, {
    bool enabled = false,
  }) {
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
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: const Color(0xFF424242),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                borderSide: const BorderSide(
                  color: Color(0xFF7CB342),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutlinedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
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

  Widget _buildSolidGreenButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7CB342),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSolidRedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
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
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
