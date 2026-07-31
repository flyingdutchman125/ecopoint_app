import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/collector_provider.dart';
import '../../core/utils/currency_formatter.dart';

class CollectorWalletTab extends StatefulWidget {
  const CollectorWalletTab({super.key});

  @override
  State<CollectorWalletTab> createState() => _CollectorWalletTabState();
}

class _CollectorWalletTabState extends State<CollectorWalletTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectorProvider>().fetchCollectorWallet();
    });
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
                final success = await context.read<CollectorProvider>().topUp(amount, paymentMethodCtrl.text);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
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
                final success = await context.read<CollectorProvider>().withdraw(amount, bankCtrl.text, accountCtrl.text);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
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
    final collectorProvider = context.watch<CollectorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Dompet Kolektor', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Saldo',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.formatRupiah(collectorProvider.walletBalance),
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showTopUpDialog(context),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Top Up'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Riwayat Transaksi', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Center(
              child: Text('Belum ada transaksi.'),
            ),
          ],
        ),
      ),
    );
  }
}
