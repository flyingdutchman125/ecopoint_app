import '../../core/utils/alert_helper.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/history_state.dart';

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
  bool _isLoading = false;
  bool _isInitialized = false;

  // Controller untuk menampung data inputan
  late TextEditingController _nameController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _whatsappController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _nameController.text = user.name ?? 'Pengguna EcoPoint';
        String rawPhone = user.phone ?? '08123456789';
        if (rawPhone.startsWith('+62')) {
          rawPhone = rawPhone.substring(3);
        } else if (rawPhone.startsWith('62')) {
          rawPhone = rawPhone.substring(2);
        } else if (rawPhone.startsWith('0')) {
          rawPhone = rawPhone.substring(1);
        }
        _whatsappController.text = rawPhone;
        _emailController.text = user.email;
      } else {
        _nameController.text = 'Pengguna EcoPoint';
        _whatsappController.text = '8123456789';
        _emailController.text = 'budi@ecopoint.com';
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Pengiriman dan penyimpanan data ke state & SharedPreferences
  Future<void> _submitProfileUpdate() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    String phoneText = _whatsappController.text.trim();
    if (!phoneText.startsWith('+62')) {
      if (phoneText.startsWith('0')) {
        phoneText = '+62${phoneText.substring(1)}';
      } else {
        phoneText = '+62$phoneText';
      }
    }

    await authProvider.updateUserProfile(
      name: _nameController.text.trim(),
      phone: phoneText,
      email: _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _isEditing = false;
      _isPendingApproval = false; // Directly applied without admin approval!
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profil berhasil diperbarui!',
            style: _jakarta(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Keluar Akun',
            style: _jakarta(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun EcoPoint?',
            style: _jakarta(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Batal',
                style: _jakarta(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                if (mounted) {
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Berhasil keluar dari akun',
                        style: _jakarta(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFBA2525),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(
                'Keluar',
                style: _jakarta(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFBA2525),
                ),
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

              if (_isPendingApproval) _buildPendingBanner(),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEditableInfoField(
                      'NAMA LENGKAP (SESUAI KTP)',
                      _nameController,
                    ),
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
              'Ubah Foto Profil',
              style: _jakarta(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF5CB82B),
              ),
              title: Text(
                'Ambil Foto (Kamera)',
                style: _jakarta(fontSize: 14, fontWeight: FontWeight.w600),
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
                color: Color(0xFF5CB82B),
              ),
              title: Text(
                'Pilih dari Galeri HP',
                style: _jakarta(fontSize: 14, fontWeight: FontWeight.w600),
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
      title: 'Ubah Foto Profil',
      description: 'Berhasil memperbarui foto profil akun EcoPoint.',
      category: 'Akun',
      valueChange: 'Foto Diperbarui',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Foto profil berhasil diperbarui!',
            style: _jakarta(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1B3A1B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildHeader(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final displayName = user?.name ?? _nameController.text;
    final displayId = user?.formattedId ?? '5505090';
    final avatarUrl = user?.avatarUrl;

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
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 24,
        24,
        28,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black12, width: 0.5),
                    image: avatarImage != null
                        ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                        : null,
                  ),
                  child: avatarImage == null
                      ? const ClipOval(
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.black38,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 0,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 11,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: _jakarta(
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: _jakarta(
                      fontSize: 12.5,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: 'ID : '),
                      TextSpan(
                        text: displayId,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
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
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.watch_later_outlined,
            color: Color(0xFFFF9800),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Perubahan data pribadi Anda sedang menunggu persetujuan dari Admin EcoPoint.',
              style: _jakarta(
                fontSize: 12.5,
                color: const Color(0xFF856404),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoField(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: _jakarta(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing && !_isLoading,
          style: _jakarta(
            fontSize: 14.5,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _isEditing ? Colors.white : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
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
              borderSide: const BorderSide(
                color: Color(0xFF5CB82B),
                width: 1.5,
              ),
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
        Text(
          'NOMOR WHATSAPP AKTIF',
          style: _jakarta(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
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
              child: Text(
                '+62',
                style: _jakarta(
                  fontSize: 14.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _whatsappController,
                enabled: _isEditing && !_isLoading,
                keyboardType: TextInputType.phone,
                style: _jakarta(
                  fontSize: 14.5,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: _isEditing
                      ? Colors.white
                      : const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    borderSide: const BorderSide(
                      color: Color(0xFF5CB82B),
                      width: 1.5,
                    ),
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
        Text(
          label,
          style: _jakarta(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            value,
            style: _jakarta(
              fontSize: 14.5,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF5CB82B)),
      );
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
              child: Text(
                'Ajukan Perubahan data',
                style: _jakarta(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
              child: Text(
                'Batal',
                style: _jakarta(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
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
                color: _isPendingApproval
                    ? Colors.transparent
                    : const Color(0xFF5CB82B),
                width: 1.2,
              ),
            ),
            child: Text(
              _isPendingApproval
                  ? 'Menunggu Persetujuan Admin...'
                  : 'Ubah Data Pribadi?',
              style: _jakarta(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _isPendingApproval
                    ? Colors.black38
                    : const Color(0xFF5CB82B),
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
            child: Text(
              'Keluar dari akun',
              style: _jakarta(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
