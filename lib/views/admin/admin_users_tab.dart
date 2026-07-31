import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../core/utils/currency_formatter.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final users = provider.users.where((u) => _selectedRole == 'all' || u.role == _selectedRole).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Pengguna', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Warga', 'user'),
                const SizedBox(width: 8),
                _buildFilterChip('Pengepul', 'collector'),
                const SizedBox(width: 8),
                _buildFilterChip('Admin', 'admin'),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.fetchDashboardData(),
                    child: users.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada pengguna ditemukan',
                              style: GoogleFonts.outfit(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                      child: Icon(
                                        user.role == 'collector'
                                            ? Icons.directions_bike
                                            : user.role == 'admin'
                                                ? Icons.admin_panel_settings
                                                : Icons.person,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    title: Text(
                                      user.name ?? 'Pengguna',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.email, style: GoogleFonts.outfit(fontSize: 13)),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: user.role == 'collector'
                                                    ? Colors.orange.withValues(alpha: 0.15)
                                                    : user.role == 'admin'
                                                        ? Colors.purple.withValues(alpha: 0.15)
                                                        : Colors.blue.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                user.role.toUpperCase(),
                                                style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: user.role == 'collector'
                                                      ? Colors.orange.shade800
                                                      : user.role == 'admin'
                                                          ? Colors.purple
                                                          : Colors.blue.shade800,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              CurrencyFormatter.formatRupiah(user.walletBalance),
                                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'topup') {
                                          _showTopupDialog(context, user, provider);
                                        } else if (value == 'reset_password') {
                                          _showResetPasswordDialog(context, user, provider);
                                        } else if (value == 'delete') {
                                          _showDeleteUserDialog(context, user, provider);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'topup',
                                          child: Row(
                                            children: [
                                              Icon(Icons.add_card, color: Colors.green, size: 20),
                                              SizedBox(width: 8),
                                              Text('Top Up Saldo'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'reset_password',
                                          child: Row(
                                            children: [
                                              Icon(Icons.lock_reset, color: Colors.orange, size: 20),
                                              SizedBox(width: 8),
                                              Text('Reset Password'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_forever, color: Colors.red, size: 20),
                                              SizedBox(width: 8),
                                              Text('Hapus Akun', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: 40 * index)).slideX(begin: 0.05, end: 0);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedRole == value;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRole = value;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
    );
  }

  void _showTopupDialog(BuildContext context, UserModel user, AdminProvider provider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Top Up Saldo (${user.name ?? user.email})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo Saat Ini: ${CurrencyFormatter.formatRupiah(user.walletBalance)}', style: GoogleFonts.outfit()),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Tambah Saldo (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                final success = await provider.updateUserBalance(user.id, amount);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Saldo berhasil ditambahkan' : 'Gagal menambahkan saldo')),
                  );
                }
              }
            },
            child: const Text('Tambah Saldo'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context, UserModel user, AdminProvider provider) {
    final TextEditingController passwordCtrl = TextEditingController();
    final TextEditingController confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password (${user.name ?? user.email})', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            onPressed: () async {
              if (passwordCtrl.text.isEmpty) return;
              if (passwordCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password baru dan konfirmasi tidak cocok')),
                );
                return;
              }
              Navigator.pop(context);
              final success = await provider.resetUserPassword(user.id, passwordCtrl.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Password pengguna berhasil di-reset' : (provider.error ?? 'Gagal reset password'))),
                );
              }
            },
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, UserModel user, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Akun Pengguna', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text('Apakah Anda yakin ingin menghapus pengguna "${user.name ?? user.email}" secara permanen? Data pengguna tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteUser(user.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Pengguna berhasil dihapus' : (provider.error ?? 'Gagal menghapus pengguna'))),
                );
              }
            },
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }
}
