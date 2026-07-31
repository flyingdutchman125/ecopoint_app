import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final TextEditingController _topUpAmountController = TextEditingController();
  final TextEditingController _withdrawAmountController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchDashboardData();
    });
  }

  @override
  void dispose() {
    _topUpAmountController.dispose();
    _withdrawAmountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userProv = context.watch<UserProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE7F9D9), Color(0xFFF8FFF5)],
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFDAF4B5),
                borderRadius: BorderRadius.circular(160),
              ),
            ),
          ),
          Positioned(
            top: 120,
            right: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFB7E69C),
                borderRadius: BorderRadius.circular(140),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => userProv.fetchDashboardData(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${auth.user?.name ?? 'Warga'}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF225A0F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kelola sampahmu, kumpulkan eco point, dan tukarkan hadiah.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded, color: Color(0xFF225A0F)),
                        onPressed: () => context.read<AuthProvider>().logout(),
                        tooltip: 'Keluar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryCard(theme, userProv),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/create-order'),
                          icon: const Icon(Icons.document_scanner_rounded, size: 20),
                          label: const Text('Buat Pesanan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF59B41C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.local_shipping_rounded, size: 20),
                          label: const Text('Riwayat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF225A0F),
                            side: const BorderSide(color: Color(0xFF225A0F)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showTopUpSheet,
                          icon: const Icon(Icons.account_balance_wallet_rounded, size: 20),
                          label: const Text('Top Up'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E8E3E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showWithdrawSheet,
                          icon: const Icon(Icons.south_east_rounded, size: 20),
                          label: const Text('Tarik Dana'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF225A0F),
                            side: const BorderSide(color: Color(0xFF225A0F)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pesanan Terbaru',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  if (userProv.isLoading) ...[
                    _buildShimmerBox(height: 120),
                    const SizedBox(height: 16),
                    _buildShimmerBox(height: 120),
                  ] else if (userProv.orders.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.eco_rounded, size: 72, color: Color.fromRGBO(76, 175, 80, 0.25)),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada pesanan',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Silakan buat pesanan sampah untuk mendapatkan eco point dan hadiah.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ] else ...userProv.orders.asMap().entries.map((entry) {
                    final order = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildOrderCard(theme, order),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTopUpSheet() {
    _topUpAmountController.clear();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Top Up Saldo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _topUpAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(_topUpAmountController.text.replaceAll(',', '').trim()) ?? 0;
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan jumlah top up yang valid')));
                    return;
                  }
                  final provider = context.read<UserProvider>();
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await provider.topUp(amount, 'bank_transfer');
                  if (success && mounted) {
                    navigator.pop();
                    messenger.showSnackBar(const SnackBar(content: Text('Top up berhasil')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF225A0F),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Lanjutkan Top Up'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showWithdrawSheet() {
    _withdrawAmountController.clear();
    _bankNameController.clear();
    _accountNumberController.clear();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tarik Dana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _withdrawAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nomor Rekening',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(_withdrawAmountController.text.replaceAll(',', '').trim()) ?? 0;
                  final bankName = _bankNameController.text.trim();
                  final accountNumber = _accountNumberController.text.trim();
                  if (amount <= 0 || bankName.isEmpty || accountNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data penarikan')));
                    return;
                  }
                  final provider = context.read<UserProvider>();
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final success = await provider.withdraw(
                        amount,
                        bankName,
                        accountNumber,
                      );
                  if (success && mounted) {
                    navigator.pop();
                    messenger.showSnackBar(const SnackBar(content: Text('Permintaan tarik dana terkirim')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF225A0F),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Kirim Permintaan'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(ThemeData theme, UserProvider userProv) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dompet Anda', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${userProv.wallet?.balance ?? 0}',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF225A0F)),
              ),
              const SizedBox(width: 8),
              Text('saldo', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryChip(theme, 'Eco Points', '${userProv.wallet?.ecoPoints ?? 0} pts', Icons.emoji_events_rounded),
              const SizedBox(width: 12),
              _buildSummaryChip(theme, 'Pesanan', '${userProv.orders.length}', Icons.history_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(ThemeData theme, String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F9ED),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF225A0F), size: 20),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[800])),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF225A0F))),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(ThemeData theme, order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 12)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF59B41C), Color(0xFF8CD663)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.recycling_rounded, color: Colors.white),
        ),
        title: Text(order.category ?? 'Sampah', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('${order.weightKg ?? 0} kg � ${order.status.toUpperCase()}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(order.address, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('+ Rp ${order.totalPrice ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF225A0F))),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F7DF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(order.status, style: const TextStyle(fontSize: 12, color: Color(0xFF225A0F), fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({required double height, double width = double.infinity}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
