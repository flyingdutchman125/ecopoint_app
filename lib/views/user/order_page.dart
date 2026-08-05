import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

TextStyle _jakarta({
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.w400,
  Color color = Colors.black,
  FontStyle? fontStyle,
  double? letterSpacing,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
  );
}

class OrderPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const OrderPage({super.key, this.extra});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderItem {
  final String id;
  final String name;
  final String summary;
  final String code;
  final bool completed;
  _OrderItem({
    required this.id,
    required this.name,
    required this.summary,
    required this.code,
    this.completed = false,
  });
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<_OrderItem> ongoing = [];
  List<_OrderItem> completed = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // seed demo data
    ongoing = [
      _OrderItem(
        id: 'EP0001',
        name: 'Pak Sutarjo (Mitra Resmi)',
        summary: 'Kardus 12kg',
        code: 'EP 0001',
        completed: false,
      ),
    ];
    completed = [
      _OrderItem(
        id: 'EP0000',
        name: 'Pak Sutarjo (Mitra Resmi)',
        summary: 'Kardus 12kg',
        code: 'EP 0000',
        completed: true,
      ),
    ];

    // if route passed an order from map, add to ongoing
    final extra = widget.extra;
    if (extra != null) {
      if (extra['order'] != null) {
        final o = extra['order'] as Map<String, dynamic>;
        final item = _OrderItem(
          id: o['id']?.toString() ?? 'EP_MAP',
          name: o['name']?.toString() ?? 'Mitra dari Map',
          summary: o['summary']?.toString() ?? 'Item',
          code: o['code']?.toString() ?? 'EP_MAP',
          completed: false,
        );
        ongoing.insert(0, item);
        // switch to ongoing tab
        _tabController.index = 0;
      }

      // handle updateOrder: move order from ongoing -> completed
      if (extra['updateOrder'] != null) {
        final u = extra['updateOrder'] as Map<String, dynamic>;
        final id = u['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          // find in ongoing
          final idx = ongoing.indexWhere((el) => el.id == id);
          if (idx != -1) {
            final moved = ongoing.removeAt(idx);
            final completedItem = _OrderItem(
              id: moved.id,
              name: moved.name,
              summary: moved.summary,
              code: moved.code,
              completed: true,
            );
            completed.insert(0, completedItem);
            // switch to completed tab
            _tabController.index = 1;
          } else {
            // if not found, add to completed directly
            final completedItem = _OrderItem(
              id: u['id']?.toString() ?? 'EP_UNKNOWN',
              name: u['name']?.toString() ?? 'Unknown',
              summary: u['summary']?.toString() ?? 'Item',
              code: u['code']?.toString() ?? 'EP_UNKNOWN',
              completed: true,
            );
            completed.insert(0, completedItem);
            _tabController.index = 1;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildOrderTile(_OrderItem item) {
    return InkWell(
      onTap: () {
        // navigate to tracking/detail page
        context.push(
          '/orders/tracking',
          extra: {
            'order': {
              'id': item.id,
              'name': item.name,
              'code': item.code,
              'completed': item.completed,
            },
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: const Icon(Icons.person, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: _jakarta(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.summary,
                    style: _jakarta(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'kode orderan : ${item.code}',
                  style: _jakarta(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Icon(
                  item.completed
                      ? Icons.check_circle_outline
                      : Icons.chevron_right,
                  color: item.completed ? Colors.green : Colors.black38,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order',
          style: _jakarta(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4C8C2B),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          tabs: [
            Tab(
              child: Text(
                'Orderan Yang Berlangsung',
                style: _jakarta(fontSize: 12),
              ),
            ),
            Tab(
              child: Text(
                'Orderan Yang Terselesaikan',
                style: _jakarta(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ongoing
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: ongoing.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = ongoing[index];
                return _buildOrderTile(item);
              },
            ),
          ),

          // completed
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              itemCount: completed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = completed[index];
                return _buildOrderTile(item);
              },
            ),
          ),
        ],
      ),
    );
  }
}
