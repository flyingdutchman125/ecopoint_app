import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';

import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class WargaChatRoomPage extends StatefulWidget {
  final Map<String, dynamic>? extra;
  const WargaChatRoomPage({super.key, this.extra});

  @override
  State<WargaChatRoomPage> createState() => _WargaChatRoomPageState();
}

class _WargaChatRoomPageState extends State<WargaChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  Timer? _pollTimer;

  // messages will hold either remote messages or local dummy messages as fallback
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  String? _orderId;
  String _peerName = 'Chat';

  @override
  void initState() {
    super.initState();
    _orderId = widget.extra?['orderId']?.toString();
    _peerName = widget.extra?['name']?.toString() ?? 'Chat';

    if (_orderId != null) {
      _loadMessages();
      // poll every 3 seconds for new messages
      _pollTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _loadMessages(),
      );
    } else {
      // fallback: prefill with dummy messages
      _messages.addAll([
        {
          'text':
              'Halo kak saya dari tim penjemputan sampah bapak sutarjo ya, perkiraan estimasi 10 menit, siap siap ya kak',
          'time': '12.10',
          'isMe': false,
        },
        {
          'text': 'Baik pak, ini saya juga sedang memilah, sampah - sampahnya',
          'time': '12.16',
          'isMe': true,
        },
        {'text': 'Baik kak', 'time': '12.18', 'isMe': false},
      ]);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_orderId == null) return;
    setState(() {
      _loading = true;
    });
    try {
      final url = '${ApiConstants.apiBase}/order/$_orderId/messages';
      final resp = await ApiService.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        // expecting data.messages as array of {id, text, sender, createdAt}
        final List msgs = data['messages'] ?? data;
        _messages.clear();
        for (final m in msgs) {
          _messages.add({
            'text': m['text'] ?? m['message'] ?? '',
            'time': (m['createdAt'] ?? m['time'] ?? '').toString().substring(
              11,
              16,
            ),
            'isMe': (m['sender'] ?? '').toString() == 'user',
            'raw': m,
          });
        }
      } else {
        // API error — keep previous messages
      }
    } catch (e) {
      // ignore network errors — keep UI usable
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final text = _messageController.text.trim();

    // optimistic add
    setState(() {
      _messages.add({
        'text': text,
        'time':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'isMe': true,
      });
      _messageController.clear();
    });

    if (_orderId == null) return; // fallback only local

    try {
      final url = '${ApiConstants.apiBase}/order/$_orderId/messages';
      final resp = await ApiService.post(url, {'text': text});
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // reload to get authoritative data
        await _loadMessages();
      } else {
        // on failure, show toast and leave optimistic message
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Gagal mengirim pesan')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan (koneksi)')),
        );
      }
    }
  }

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
          _peerName,
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
          // 1. DETAIL MITRA SUMMARY PROFILE CARD
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_outlined,
                    color: Colors.black54,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _peerName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mitra pengepul area made',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // TIMESTAMP LABEL "Today"
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Today',
                style: GoogleFonts.inter(
                  color: const Color(0xFF757575),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // 2. CHAT BUBBLES AREA
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final chat = _messages[index];
                      return _buildChatBubble(
                        message: chat['text'],
                        time: chat['time'],
                        isMe: chat['isMe'] ?? false,
                      );
                    },
                  ),
          ),

          // 3. PERSISTENT INPUT FIELD CHAT (Dua Arah Komunikasi)
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF7CB342),
                      radius: 22,
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({
    required String message,
    required String time,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMe) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF212121),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.reply, color: Colors.grey, size: 18),
          ],
          if (isMe) ...[
            const Icon(Icons.reply, color: Colors.grey, size: 18),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEAEAEA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF212121),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
