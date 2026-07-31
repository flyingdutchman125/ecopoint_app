#!/bin/bash
cat << 'INNER_EOF' > /home/user/myapp/lib/views/admin/admin_orders_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';
import '../../core/utils/currency_formatter.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAdminOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final orders = provider.adminOrders.where((o) => _selectedStatus == 'all' || o.status == _selectedStatus).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pesanan'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Menunggu', 'pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Diterima', 'accepted'),
                const SizedBox(width: 8),
                _buildFilterChip('Dalam Perjalanan', 'en_route'),
                const SizedBox(width: 8),
                _buildFilterChip('Selesai', 'completed'),
                const SizedBox(width: 8),
                _buildFilterChip('Dibatalkan', 'cancelled'),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading && provider.adminOrders.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.fetchAdminOrders(),
                    child: orders.isEmpty
                        ? const Center(child: Text('Tidak ada pesanan'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(order.itemType ?? 'Barang', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text('Alamat: ${order.pickupAddress}'),
                                      const SizedBox(height: 4),
                                      Text('Status: ${order.statusLabel}', style: TextStyle(color: Theme.of(context).primaryColor)),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${order.displayWeight ?? 0} kg'),
                                      if (order.totalAmount != null)
                                        Text(CurrencyFormatter.formatRp(order.totalAmount!), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1, end: 0);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }
}
INNER_EOF

cat << 'INNER_EOF' > /home/user/myapp/lib/views/admin/admin_users_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        title: const Text('Pengguna'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('User', 'user'),
                const SizedBox(width: 8),
                _buildFilterChip('Kolektor', 'collector'),
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
                        ? const Center(child: Text('Tidak ada pengguna'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                                  ),
                                  title: Text(user.name ?? 'Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email),
                                      Text('Role: ${user.role.toUpperCase()}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.account_balance_wallet, color: Colors.green),
                                    onPressed: () => _showTopupDialog(context, user, provider),
                                  ),
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.1, end: 0);
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
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRole = value;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
    );
  }

  void _showTopupDialog(BuildContext context, UserModel user, AdminProvider provider) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Topup Saldo ${user.name ?? 'Pengguna'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saldo Saat Ini: ${CurrencyFormatter.formatRp(user.walletBalance)}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Jumlah Topup',
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
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                try {
                  await provider.updateUserBalance(user.id, amount, 'add');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Topup berhasil')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Topup'),
          ),
        ],
      ),
    );
  }
}
INNER_EOF
