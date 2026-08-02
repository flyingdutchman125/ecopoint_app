import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/notification_state.dart';

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

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final NotificationState _state = NotificationState.instance;

  @override
  void initState() {
    super.initState();
    _state.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifikasi',
          style: _jakarta(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'read_all') {
                _state.markAllAsRead();
              } else if (value == 'clear_all') {
                _state.clearAll();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    const Icon(Icons.done_all, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text('Tandai Dibaca', style: _jakarta(fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text('Hapus Semua', style: _jakarta(fontSize: 13, color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: _state.notifications,
        builder: (context, notifications, _) {
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final weekAgo = today.subtract(const Duration(days: 7));

          final todayItems = notifications.where((n) {
            final d = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
            return d.isAtSameMomentAs(today);
          }).toList();

          final thisWeekItems = notifications.where((n) {
            final d = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
            return d.isBefore(today) && d.isAfter(weekAgo);
          }).toList();

          final olderItems = notifications.where((n) {
            final d = DateTime(n.timestamp.year, n.timestamp.month, n.timestamp.day);
            return d.isBefore(weekAgo) || d.isAtSameMomentAs(weekAgo);
          }).toList();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (todayItems.isNotEmpty) ...[
                        _buildSectionHeader('Hari Ini'),
                        ...todayItems.map((item) => _buildItemTile(item)),
                      ],
                      if (thisWeekItems.isNotEmpty) ...[
                        _buildSectionHeader('Minggu Ini'),
                        ...thisWeekItems.map((item) => _buildItemTile(item)),
                      ],
                      if (olderItems.isNotEmpty) ...[
                        _buildSectionHeader('Sebelumnya'),
                        ...olderItems.map((item) => _buildItemTile(item)),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 12),
                child: Center(
                  child: Text(
                    'Tidak ada notifikasi lain',
                    style: _jakarta(fontSize: 13, color: Colors.black38, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF4F6F8),
      child: Text(
        title,
        style: _jakarta(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildItemTile(NotificationItem item) {
    return Container(
      color: item.isRead ? Colors.white : const Color(0xFFF1F8E9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          SizedBox(
            width: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: item.iconColor, size: 26),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  textAlign: TextAlign.center,
                  style: _jakarta(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: _jakarta(
                          fontSize: 13.5,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!item.isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF82C139),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: _jakarta(fontSize: 11, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Timestamp & Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.timeFormatted,
                style: _jakarta(fontSize: 11, color: Colors.black45),
              ),
              const SizedBox(height: 2),
              Text(
                item.dateFormatted,
                style: _jakarta(fontSize: 9.5, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off_outlined, size: 54, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Notifikasi',
            style: _jakarta(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            'Aktivitas penjemputan, penarikan, dan level akan tampil di sini.',
            style: _jakarta(fontSize: 12, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}