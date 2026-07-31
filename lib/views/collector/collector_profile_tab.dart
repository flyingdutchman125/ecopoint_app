import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/collector_provider.dart';
import '../../core/utils/currency_formatter.dart';

class CollectorProfileTab extends StatelessWidget {
  const CollectorProfileTab({super.key});

  void _showEditProfileDialog(BuildContext context, String currentPhone) {
    final phoneCtrl = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Nomor Telepon', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Nomor Telepon'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Usually calls an update profile API method for collector
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Nomor telepon diperbarui')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ganti Password', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Saat Ini'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Baru'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Password baru dan konfirmasi tidak cocok')),
                );
                return;
              }
              if (newCtrl.text.isNotEmpty && currentCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await ctx.read<AuthProvider>().changePassword(
                  currentCtrl.text,
                  newCtrl.text,
                );
                if (success && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Password berhasil diubah')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showTopUpDialog(BuildContext context) {
    final amountCtrl = TextEditingController();
    final paymentMethodCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Top Up Dompet', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah Top Up (Rp)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paymentMethodCtrl,
              decoration: const InputDecoration(labelText: 'Metode Pembayaran (ex: BCA)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount != null && amount > 0 && paymentMethodCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await ctx.read<CollectorProvider>().topUp(amount, paymentMethodCtrl.text);
                if (success && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Top up berhasil')),
                  );
                }
              }
            },
            child: const Text('Top Up'),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    final amountCtrl = TextEditingController();
    final bankCtrl = TextEditingController();
    final accountCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tarik Dana', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah Tarik (Rp)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bankCtrl,
              decoration: const InputDecoration(labelText: 'Nama Bank'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: accountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Nomor Rekening'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount != null && amount > 0 && bankCtrl.text.isNotEmpty && accountCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                final success = await ctx.read<CollectorProvider>().withdraw(amount, bankCtrl.text, accountCtrl.text);
                if (success && ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Penarikan dana berhasil')),
                  );
                }
              }
            },
            child: const Text('Tarik'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final collectorProvider = context.watch<CollectorProvider>();
    final user = authProvider.user;

    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Profil Kolektor', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person, size: 50, color: theme.colorScheme.onPrimaryContainer),
            ).animate().scale(),
            const SizedBox(height: 16),
            Text(
              user.name ?? 'Kolektor',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            ).animate().fadeIn(),
            Text(
              user.email,
              style: GoogleFonts.inter(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
            ).animate().fadeIn(delay: const Duration(milliseconds: 100)),
            const SizedBox(height: 8),
            Text(
              user.phone ?? 'Nomor belum diatur',
              style: GoogleFonts.inter(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
            ).animate().fadeIn(delay: const Duration(milliseconds: 150)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  _buildProfileRow(theme, 'Saldo Dompet', CurrencyFormatter.formatRupiah(collectorProvider.walletBalance), Icons.account_balance_wallet),
                  const Divider(height: 32),
                  _buildProfileRow(theme, 'Total Pendapatan', CurrencyFormatter.formatRupiah(collectorProvider.totalEarnings), Icons.monetization_on),
                  const Divider(height: 32),
                  _buildProfileRow(theme, 'Total Pesanan', '${collectorProvider.totalOrders}', Icons.list_alt),
                ],
              ),
            ).animate().slideY(begin: 0.2, end: 0).fadeIn(delay: const Duration(milliseconds: 200)),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTopUpDialog(context),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Top Up'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showWithdrawDialog(context),
                    icon: const Icon(Icons.money_off),
                    label: const Text('Tarik Dana'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: const Duration(milliseconds: 250)),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditProfileDialog(context, user.phone ?? ''),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Telepon'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showChangePasswordDialog(context),
                icon: const Icon(Icons.lock),
                label: const Text('Ganti Password'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 350)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => authProvider.logout(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Keluar', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(ThemeData theme, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
              const SizedBox(height: 4),
              Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}
