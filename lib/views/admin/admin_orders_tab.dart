import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';
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
    final orders = provider.adminOrders
        .where((o) => _selectedStatus == 'all' || o.status == _selectedStatus)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Pesanan',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        ? Center(
                            child: Text(
                              'Tidak ada pesanan',
                              style: GoogleFonts.outfit(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      title: Text(
                                        order.itemType ?? 'Barang',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 6),
                                          Text(
                                            'Warga: ${order.userName ?? '-'}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            'Alamat: ${order.pickupAddress}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  order.statusLabel
                                                      .toUpperCase(),
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton.icon(
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                ),
                                                icon: const Icon(
                                                  Icons.chat_bubble_outline,
                                                  size: 16,
                                                ),
                                                label: Text(
                                                  'Kelola Pesan',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                onPressed: () =>
                                                    _showMessagesDialog(
                                                      context,
                                                      order,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${order.displayWeight ?? 0} kg',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (order.totalAmount != null)
                                            Text(
                                              CurrencyFormatter.formatRupiah(
                                                order.totalAmount!,
                                              ),
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(
                                    delay: Duration(milliseconds: 40 * index),
                                  )
                                  .slideX(begin: 0.05, end: 0);
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
      label: Text(
        label,
        style: GoogleFonts.outfit(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
    );
  }

  void _showMessagesDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => _AdminOrderMessagesDialog(orderId: order.id),
    );
  }
}

class _AdminOrderMessagesDialog extends StatefulWidget {
  final String orderId;
  const _AdminOrderMessagesDialog({required this.orderId});

  @override
  State<_AdminOrderMessagesDialog> createState() =>
      _AdminOrderMessagesDialogState();
}

class _AdminOrderMessagesDialogState extends State<_AdminOrderMessagesDialog> {
  List<dynamic> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get(
        '${ApiConstants.order}/${widget.orderId}/messages',
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          setState(() {
            _messages = data['data'] ?? [];
          });
        }
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _deleteMessage(String messageId) async {
    final success = await context.read<AdminProvider>().deleteOrderMessage(
      messageId,
    );
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pesan berhasil dihapus')));
      }
      _fetchMessages();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menghapus pesan')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Kelola Pesan Order',
        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _messages.isEmpty
            ? Center(
                child: Text(
                  'Belum ada pesan pada order ini',
                  style: GoogleFonts.outfit(color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (ctx, idx) {
                  final msg = _messages[idx];
                  return ListTile(
                    dense: true,
                    title: Text(
                      msg['message'] ?? '',
                      style: GoogleFonts.outfit(),
                    ),
                    subtitle: Text(
                      msg['created_at']?.toString().substring(0, 16) ?? '',
                      style: GoogleFonts.outfit(fontSize: 10),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      tooltip: 'Hapus Pesan',
                      onPressed: () => _deleteMessage(msg['id'].toString()),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}
