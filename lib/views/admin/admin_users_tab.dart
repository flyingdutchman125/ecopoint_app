import '../../core/utils/alert_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../core/utils/currency_formatter.dart';

class AdminUsersTab extends StatefulWidget {
  final String selectedRole;

  const AdminUsersTab({super.key, this.selectedRole = 'all'});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  static const Color emeraldColor = Color(0xFF10B981);
  String _selectedRole = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchDashboardData();
    });
  }

  @override
  void didUpdateWidget(covariant AdminUsersTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRole != oldWidget.selectedRole) {
      _selectedRole = widget.selectedRole;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter by role and search query
    final filteredUsers = provider.users.where((u) {
      final matchesRole = _selectedRole == 'all' || u.role == _selectedRole;
      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch =
          query.isEmpty ||
          (u.name?.toLowerCase().contains(query) ?? false) ||
          u.email.toLowerCase().contains(query) ||
          (u.phone?.contains(query) ?? false) ||
          u.formattedId.contains(query);
      return matchesRole && matchesSearch;
    }).toList();

    // Count statistics per role
    final totalCount = provider.users.length;
    final wargaCount = provider.users.where((u) => u.role == 'user').length;
    final collectorCount = provider.users
        .where((u) => u.role == 'collector')
        .length;
    final adminCount = provider.users.where((u) => u.role == 'admin').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Pengguna',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Refresh User',
            onPressed: () => provider.fetchDashboardData(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama, email, nomor HP, atau ID...',
                hintStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Role Filter Chips with Counter Badges
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all', totalCount),
                const SizedBox(width: 8),
                _buildFilterChip('Warga', 'user', wargaCount),
                const SizedBox(width: 8),
                _buildFilterChip('Pengepul', 'collector', collectorCount),
                const SizedBox(width: 8),
                _buildFilterChip('Admin', 'admin', adminCount),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // User List
          Expanded(
            child: provider.isLoading && provider.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.fetchDashboardData(),
                    child: filteredUsers.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_search_rounded,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Pengguna Tidak Ditemukan',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _searchQuery.isNotEmpty
                                          ? 'Tidak ada hasil untuk "$_searchQuery"'
                                          : 'Belum ada pengguna pada kategori ini',
                                      style: GoogleFonts.outfit(
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return _buildUserCard(
                                context,
                                user,
                                provider,
                                isDark,
                                index,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedRole == value;
    final primaryColor = Theme.of(context).primaryColor;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? primaryColor : null,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRole = value;
          });
        }
      },
      selectedColor: primaryColor.withValues(alpha: 0.15),
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide(
        color: isSelected ? primaryColor : Colors.grey.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildUserCard(
    BuildContext context,
    UserModel user,
    AdminProvider provider,
    bool isDark,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Role Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: user.role == 'collector'
                          ? Colors.orange.withValues(alpha: 0.15)
                          : user.role == 'admin'
                          ? Colors.purple.withValues(alpha: 0.15)
                          : Colors.blue.withValues(alpha: 0.15),
                      child: Icon(
                        user.role == 'collector'
                            ? Icons.directions_bike_rounded
                            : user.role == 'admin'
                            ? Icons.admin_panel_settings_rounded
                            : Icons.person_rounded,
                        color: user.role == 'collector'
                            ? Colors.orange.shade800
                            : user.role == 'admin'
                            ? Colors.purple
                            : Colors.blue.shade800,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // User Basic Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              user.name ?? 'Tanpa Nama',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: user.role == 'collector'
                                  ? Colors.orange.withValues(alpha: 0.15)
                                  : user.role == 'admin'
                                  ? Colors.purple.withValues(alpha: 0.15)
                                  : Colors.blue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
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
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.wallet_rounded,
                            size: 14,
                            color: emeraldColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            CurrencyFormatter.formatRupiah(user.walletBalance),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: emeraldColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.eco_rounded,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${user.ecoPoints} Pts',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 0.8),

            // Action Buttons Bar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(
                        color: Colors.blue.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        _showUserDetailBottomSheet(context, user, provider),
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: Colors.blue,
                    ),
                    label: Text(
                      'Lihat Detail',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(
                        color: Colors.orange.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        _showResetPasswordDialog(context, user, provider),
                    icon: const Icon(
                      Icons.lock_reset_rounded,
                      size: 16,
                      color: Colors.orange,
                    ),
                    label: Text(
                      'Reset Pass',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showDeleteUserDialog(context, user, provider),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms).slideY(begin: 0.05, end: 0);
  }

  void _showUserDetailBottomSheet(
    BuildContext context,
    UserModel user,
    AdminProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.15),
                  child: Icon(
                    user.role == 'collector'
                        ? Icons.directions_bike_rounded
                        : user.role == 'admin'
                        ? Icons.admin_panel_settings_rounded
                        : Icons.person_rounded,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'Tanpa Nama',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: ${user.formattedId}',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildDetailRow('Role Status', user.role.toUpperCase()),
            _buildDetailRow('Nomor Telepon', user.phone ?? '-'),
            _buildDetailRow(
              'Saldo Dompet',
              CurrencyFormatter.formatRupiah(user.walletBalance),
            ),
            _buildDetailRow('Poin EcoPoint', '${user.ecoPoints} Pts'),
            _buildDetailRow('Kota', user.city ?? '-'),
            _buildDetailRow('Kecamatan', user.subdistrict ?? '-'),
            _buildDetailRow('Alamat Lengkap', user.address ?? '-'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showResetPasswordDialog(context, user, provider);
                    },
                    icon: const Icon(
                      Icons.lock_reset_rounded,
                      color: Colors.orange,
                    ),
                    label: Text(
                      'Reset Pass',
                      style: GoogleFonts.outfit(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showDeleteUserDialog(context, user, provider);
                    },
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: Text(
                      'Hapus User',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(
    BuildContext context,
    UserModel user,
    AdminProvider provider,
  ) {
    final TextEditingController passwordCtrl = TextEditingController();
    final TextEditingController confirmCtrl = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.lock_reset_rounded, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reset Password',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset password untuk akun: ${user.email}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordCtrl,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setDialogState(() {
                      obscurePassword = !obscurePassword;
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: obscurePassword,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (passwordCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password baru wajib diisi')),
                  );
                  return;
                }
                if (passwordCtrl.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password minimal 6 karakter'),
                    ),
                  );
                  return;
                }
                if (passwordCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password baru dan konfirmasi tidak cocok'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final success = await provider.resetUserPassword(
                  user.id,
                  passwordCtrl.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Password pengguna berhasil di-reset'
                            : (provider.error ?? 'Gagal reset password'),
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteUserDialog(
    BuildContext context,
    UserModel user,
    AdminProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Hapus Akun User',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menghapus pengguna berikut secara permanen?',
              style: GoogleFonts.outfit(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'No Name',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  Text(user.email, style: GoogleFonts.outfit(fontSize: 12)),
                  Text(
                    'Role: ${user.role.toUpperCase()}',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ Data pengguna yang dihapus tidak dapat dikembalikan!',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await provider.deleteUser(user.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Pengguna berhasil dihapus'
                          : (provider.error ?? 'Gagal menghapus pengguna'),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
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
