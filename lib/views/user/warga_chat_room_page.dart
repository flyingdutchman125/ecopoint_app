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
  final ScrollController _scrollController = ScrollController();
  Timer? _pollTimer;

  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  String? _orderId;
  String _peerName = 'Chat';

  @override
  void initState() {
    super.initState();
    _orderId = widget.extra?['orderId']?.toString() ?? 'order_1';
    _peerName = widget.extra?['name']?.toString() ?? 'Pak Sutarjo';

    _loadMessages(initial: true);
    // Poll backend every 2 seconds for instant 2-way sync
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _loadMessages(initial: false),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadMessages({bool initial = false}) async {
    if (_orderId == null) return;
    if (initial) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final url = ApiConstants.orderMessages(_orderId!);
      final resp = await ApiService.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final List msgs = data['data'] ?? data['messages'] ?? (data is List ? data : []);

        final newMessages = <Map<String, dynamic>>[];
        for (final m in msgs) {
          final textStr = m['message'] ?? m['text'] ?? '';
          final timeStr = m['time'] ?? (m['created_at'] != null && m['created_at'].toString().length >= 16
              ? m['created_at'].toString().substring(11, 16)
              : '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}');
          final isMe = m['isMe'] == true || (m['sender_role'] == 'user');

          newMessages.add({
            'id': m['id'],
            'text': textStr,
            'time': timeStr,
            'isMe': isMe,
            'raw': m,
          });
        }

        if (mounted) {
          final pendingMsgs = _messages.where((m) => m['pending'] == true).toList();
          setState(() {
            _messages.clear();
            _messages.addAll(newMessages);
            for (final p in pendingMsgs) {
              if (!_messages.any((m) => m['text'] == p['text'])) {
                _messages.add(p);
              }
            }
          });
          if (initial || newMessages.length > _messages.length) {
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      if (_messages.isEmpty && mounted) {
        setState(() {
          _messages.addAll([
            {
              'text':
                  'Halo kak saya dari tim penjemputan sampah Pak Sutarjo ya, perkiraan estimasi 10 menit, siap siap ya kak',
              'time': '12.10',
              'isMe': false,
            },
            {
              'text': 'Baik pak, ini saya juga sedang memilah, sampah - sampahnya',
              'time': '12.16',
              'isMe': true,
            },
            {'text': 'Baik kak, kami luncur ke lokasi.', 'time': '12.18', 'isMe': false},
          ]);
        });
      }
    } finally {
      if (mounted && initial) {
        setState(() {
          _loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final nowStr = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    // Optimistic UI update
    setState(() {
      _messages.add({
        'text': text,
        'time': nowStr,
        'isMe': true,
        'pending': true,
      });
      _messageController.clear();
    });
    _scrollToBottom();

    if (_orderId == null) return;

    try {
      final url = ApiConstants.orderMessages(_orderId!);
      final resp = await ApiService.post(url, {'message': text, 'text': text});

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await _loadMessages();
      } else {
        _triggerDemoResponse(text);
      }
    } catch (e) {
      _triggerDemoResponse(text);
    }
  }

  void _triggerDemoResponse(String userMsg) {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      String reply = 'Siap kak, pesan Anda telah diterima oleh mitra pengepul.';
      if (userMsg.toLowerCase().contains('lokasi') || userMsg.toLowerCase().contains('posisi')) {
        reply = 'Saya sudah dekat di sekitar area lokasi penjemputan kak.';
      } else if (userMsg.toLowerCase().contains('terima kasih') || userMsg.toLowerCase().contains('makasih')) {
        reply = 'Sama-sama kak! Sampai jumpa di lokasi.';
      }

      setState(() {
        _messages.add({
          'text': reply,
          'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
          'isMe': false,
        });
      });
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Navigator.maybeOf(context)?.pop(),
        ),
        title: Column(
          children: [
            Text(
              _peerName,
              style: GoogleFonts.outfit(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Online • Penjemputan Aktif',
                  style: GoogleFonts.inter(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. DETAIL MITRA SUMMARY PROFILE CARD
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7CB342).withValues(alpha: 0.12),
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _peerName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF212121),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mitra Pengepul Resmi EcoPoint • Active Order',
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

          // TIMESTAMP LABEL
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Hari Ini',
                style: GoogleFonts.inter(
                  color: const Color(0xFF616161),
                  fontSize: 11,
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
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final chat = _messages[index];
                      return _buildChatBubble(
                        message: chat['text'] ?? '',
                        time: chat['time'] ?? '',
                        isMe: chat['isMe'] ?? false,
                      );
                    },
                  ),
          ),

          // 3. PERSISTENT INPUT FIELD CHAT (2-Way Live Chat)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade500,
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
                  CircleAvatar(
                    backgroundColor: const Color(0xFF7CB342),
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
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
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF7CB342).withValues(alpha: 0.2),
              child: const Icon(Icons.person, size: 16, color: Color(0xFF558B2F)),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF7CB342) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isMe ? Colors.white : const Color(0xFF212121),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
