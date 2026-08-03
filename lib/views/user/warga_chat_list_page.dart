import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class WargaChatListPage extends StatefulWidget {
  const WargaChatListPage({super.key});

  @override
  State<WargaChatListPage> createState() => _WargaChatListPageState();
}

class _WargaChatListPageState extends State<WargaChatListPage> {
  String selectedFilter = 'All'; // Pilihan: 'All', 'Warga', 'Collector'
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.get(ApiConstants.chats);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        _chats = list.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      // Fallback default threads if network issue occurs
      _chats = [
        {
          'order_id': 'order_1',
          'peer_name': "Ahmad Syifa’ul Falakhul K.",
          'peer_role': 'collector',
          'last_message': "Permisi kak saya sedang di perjalanan, Perkiraan 10 Me..",
          'last_message_time': '12.19',
          'unread_count': 2,
        },
        {
          'order_id': 'order_2',
          'peer_name': "Pak Sutarjo",
          'peer_role': 'collector',
          'last_message': "Baik kak",
          'last_message_time': '12.18',
          'unread_count': 0,
        },
      ];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredChats {
    final query = _searchController.text.toLowerCase().trim();
    return _chats.where((chat) {
      final name = (chat['peer_name'] ?? '').toString().toLowerCase();
      final role = (chat['peer_role'] ?? '').toString().toLowerCase();

      final matchesQuery = query.isEmpty || name.contains(query);
      if (!matchesQuery) return false;

      if (selectedFilter == 'Warga') {
        return role == 'user' || role == 'warga';
      } else if (selectedFilter == 'Collector') {
        return role == 'collector' || role == 'mitra';
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredChats;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.maybeOf(context)?.pop(),
        ),
        title: Text(
          'Obrolan Penjemputan',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchChats,
        color: const Color(0xFF7CB342),
        child: Column(
          children: [
            // 1. SEARCH BAR CONTAINER
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari Nama Kolektor / Warga...',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF9E9E9E),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF757575),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // 2. FILTER TABS (All, Warga, Collector)
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 16.0,
              ),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Warga'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Collector'),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // 3. CHAT LIST ITEMS
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : list.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 60),
                            Center(
                              child: Text(
                                'Tidak ada obrolan ditemukan',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFBDBDBD),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: list.length + 1,
                          itemBuilder: (context, index) {
                            if (index == list.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32.0),
                                child: Center(
                                  child: Text(
                                    'Tidak ada obrolan lain',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFFBDBDBD),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final chat = list[index];
                            final orderId = chat['order_id'] ?? 'order_1';
                            final peerName = chat['peer_name'] ?? 'Mitra Pengepul';
                            final lastMsg = chat['last_message'] ?? '';
                            final rawTime = chat['last_message_time']?.toString() ?? '';
                            final timeDisplay = rawTime.length >= 16
                                ? rawTime.substring(11, 16)
                                : (rawTime.isNotEmpty ? rawTime : 'Baru saja');
                            final unread = chat['unread_count'] ?? 0;

                            return _buildChatItem(
                              name: peerName,
                              lastMessage: lastMsg,
                              time: timeDisplay,
                              unreadCount: unread is int ? unread : 0,
                              avatarWidget: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7CB342).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF7CB342),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.person_pin,
                                  color: Color(0xFF558B2F),
                                  size: 26,
                                ),
                              ),
                              onTap: () {
                                context.push(
                                  '/warga/chat-room',
                                  extra: {
                                    'orderId': orderId,
                                    'name': peerName,
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7CB342) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7CB342)
                : const Color(0xFF7CB342).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isSelected ? Colors.white : const Color(0xFF7CB342),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required String name,
    required String lastMessage,
    required String time,
    required int unreadCount,
    required Widget avatarWidget,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
          ),
        ),
        child: Row(
          children: [
            avatarWidget,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF212121),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF616161),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF29B6F6),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
