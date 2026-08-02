import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class WargaChatListPage extends StatefulWidget {
  const WargaChatListPage({super.key});

  @override
  State<WargaChatListPage> createState() => _WargaChatListPageState();
}

class _WargaChatListPageState extends State<WargaChatListPage> {
  String selectedFilter = 'All'; // Pilihan: 'All', 'Warga', 'Collector'
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.maybeOf(context)?.pop(),
        ),
        title: Text(
          'Chats',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR CONTAINER
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search ID Kolektor',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF757575), size: 20),
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
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 16.0),
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
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Item Chat 1: Ahmad Syifa'ul Falakhul K.
                _buildChatItem(
                  name: "Ahmad Syifa’ul Falakhul K.",
                  lastMessage: "Permisi kak saya sedang di perjalanan, Perkiraan 10 Me..",
                  time: "12.19",
                  unreadCount: 2,
                  avatarWidget: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/profile_placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                    // pass an orderId when available; using demo ids for UI navigation
                    context.push('/warga/chat-room', extra: {'orderId': 'order_1', 'name': "Ahmad Syifa’ul Falakhul K."});
                  },
                ),
                 
                // Item Chat 2: Pak Sutarjo
                _buildChatItem(
                  name: "Pak sutarjo",
                  lastMessage: "Baik kak",
                  time: "12.18",
                  unreadCount: 0,
                  avatarWidget: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                    ),
                    child: const Icon(Icons.psychology_alt_outlined, color: Colors.black54, size: 26),
                  ),
                  onTap: () {
                    context.push('/warga/chat-room', extra: {'orderId': 'order_2', 'name': 'Pak sutarjo'});
                  },
                ),

                // 4. FOOTER LABEL: "Tidak ada obrolan lain"
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Tidak ada obrolan lain',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFBDBDBD),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            color: isSelected ? const Color(0xFF7CB342) : const Color(0xFF7CB342).withValues(alpha: 0.5),
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