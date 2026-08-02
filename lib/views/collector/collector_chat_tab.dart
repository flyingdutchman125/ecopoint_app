import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectorChatTab extends StatefulWidget {
  const CollectorChatTab({super.key});

  @override
  State<CollectorChatTab> createState() => _CollectorChatTabState();
}

class _CollectorChatTabState extends State<CollectorChatTab> {
  String?
  _activeChatWindow; // null = Daftar Chat, 'pak_sutarjo' / 'ahmad' = Ruang Chat
  String _selectedFilter = 'All'; // Filter waktu: All, Today, Yesterday

  @override
  Widget build(BuildContext context) {
    if (_activeChatWindow != null) {
      return _buildChatDetailScreen();
    }
    return _buildChatListScreen();
  }

  // === SCREEN 1.1: TAMPILAN DAFTAR CHAT WARGA ===
  Widget _buildChatListScreen() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // SEARCH BAR ID WARGA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search ID Warga',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // FILTER WAKTU (ALL, TODAY, YESTERDAY)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterPill('All'),
                const SizedBox(width: 8),
                _buildFilterPill('Today'),
                const SizedBox(width: 8),
                _buildFilterPill('Yesterday'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),

          // LIST DAFTAR CHAT
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildChatTile(
                  name: "Ahmad Syifa’ul Falakhul K.",
                  message:
                      "Permisi kak saya sedang di perjalanan, Perkiraan 10 Me..",
                  time: "12.19",
                  unreadCount: 2,
                  isDinoAvatar: false,
                  onTap: () {
                    setState(() {
                      _activeChatWindow = 'ahmad';
                    });
                  },
                ),
                _buildChatTile(
                  name: "Pak Sutarjo",
                  message: "Baik kak",
                  time: "12.18",
                  unreadCount: 0,
                  isDinoAvatar: true,
                  onTap: () {
                    setState(() {
                      _activeChatWindow = 'pak_sutarjo';
                    });
                  },
                ),

                // FOOTER KETERANGAN
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Tidak ada obrolan lain',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade400,
                        fontSize: 14,
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

  // === SCREEN 1.2: TAMPILAN RUANG DETAIL CHAT ===
  Widget _buildChatDetailScreen() {
    final String currentChatName = _activeChatWindow == 'pak_sutarjo'
        ? 'Pak Sutarjo'
        : 'Ahmad Syifa’ul Falakhul K.';
    final String currentChatSub = _activeChatWindow == 'pak_sutarjo'
        ? 'Mitra pengepul area made'
        : 'Warga';

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // CUSTOM CHAT APP BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _activeChatWindow = null;
                    });
                  },
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade100,
                  child: _activeChatWindow == 'pak_sutarjo'
                      ? const Icon(Icons.adb_rounded, color: Colors.grey)
                      : const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentChatName,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        currentChatSub,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // AREA PESAN / OBROLAN
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Today',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Bubble 1: Masuk (Kiri)
                _buildChatBubble(
                  message:
                      "Halo kak saya dari tim penjemputan sampah bapak sutarjo ya, perkiraan 10 menit, siap siap ya kak",
                  time: "12.10",
                  isMe: false,
                ),
                const SizedBox(height: 16),

                // Bubble 2: Keluar (Kanan)
                _buildChatBubble(
                  message:
                      "Baik pak, ini saya juga sedang memilah, sampah - sampahnya",
                  time: "12.15",
                  isMe: true,
                ),
                const SizedBox(height: 16),

                // Bubble 3: Masuk (Kiri)
                _buildChatBubble(
                  message: "Baik kak",
                  time: "12.18",
                  isMe: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === HELPER UTILITAS WIDGETS ===
  Widget _buildFilterPill(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8BC34A) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF8BC34A) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile({
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    required bool isDinoAvatar,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey.shade100,
          child: isDinoAvatar
              ? const Icon(Icons.adb_rounded, color: Colors.grey)
              : const Icon(Icons.person, color: Colors.grey),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF2196F3),
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
      ),
    );
  }

  Widget _buildChatBubble({
    required String message,
    required String time,
    required bool isMe,
  }) {
    final bubbleColor = const Color(0xFFECECEC);
    final alignment = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;

    Widget mainBubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );

    Widget actionButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.grey.shade100,
        child: Icon(
          isMe ? Icons.reply : Icons.reply_all_outlined,
          size: 12,
          color: Colors.grey.shade600,
        ),
      ),
    );

    return Row(
      mainAxisAlignment: alignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: isMe ? [actionButton, mainBubble] : [mainBubble, actionButton],
    );
  }
}
