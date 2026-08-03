import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';

import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class CollectorChatDetailPage extends StatefulWidget {
  final String name;
  final String preview;
  final String? orderId;

  const CollectorChatDetailPage({
    super.key,
    required this.name,
    required this.preview,
    this.orderId,
  });

  @override
  State<CollectorChatDetailPage> createState() =>
      _CollectorChatDetailPageState();
}

class _CollectorChatDetailPageState extends State<CollectorChatDetailPage> {
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollTimer;

  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;
  late String _targetOrderId;

  @override
  void initState() {
    super.initState();
    _targetOrderId = widget.orderId ?? 'order_1';
    _loadMessages(initial: true);

    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _loadMessages(initial: false),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageCtrl.dispose();
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
    if (initial) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final url = ApiConstants.orderMessages(_targetOrderId);
      final resp = await ApiService.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final List msgs = data['data'] ?? data['messages'] ?? [];

        final newMsgs = <Map<String, dynamic>>[];
        for (final m in msgs) {
          final isMe = m['isMe'] == true || (m['sender_role'] == 'collector');
          final timeStr = m['time'] ?? (m['created_at'] != null && m['created_at'].toString().length >= 16
              ? m['created_at'].toString().substring(11, 16)
              : '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}');

          newMsgs.add({
            'text': m['message'] ?? m['text'] ?? '',
            'fromMe': isMe,
            'time': timeStr,
          });
        }

        if (mounted) {
          final pendingMsgs = _messages.where((m) => m['pending'] == true).toList();
          setState(() {
            _messages.clear();
            _messages.addAll(newMsgs);
            for (final p in pendingMsgs) {
              if (!_messages.any((m) => m['text'] == p['text'])) {
                _messages.add(p);
              }
            }
          });
          if (initial || newMsgs.length > _messages.length) {
            _scrollToBottom();
          }
        }
      }
    } catch (e) {
      if (_messages.isEmpty && mounted) {
        setState(() {
          _messages.addAll([
            {
              'text': 'Halo, saya sedang dalam perjalanan ke lokasi.',
              'fromMe': true,
              'time': '09:40',
            },
            {'text': 'Baik, saya tunggu ya.', 'fromMe': false, 'time': '09:41'},
          ]);
        });
      }
    } finally {
      if (initial && mounted) {
        setState(() {
          _loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    final nowStr = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';

    setState(() {
      _messages.add({
        'text': text,
        'fromMe': true,
        'time': nowStr,
        'pending': true,
      });
      _messageCtrl.clear();
    });
    _scrollToBottom();

    try {
      final url = ApiConstants.orderMessages(_targetOrderId);
      final resp = await ApiService.post(url, {'message': text, 'text': text});
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        await _loadMessages();
      }
    } catch (e) {
      // Local message retained
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: Text(
              widget.preview,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(18),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['fromMe'] as bool;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF7CB342)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['text'] as String,
                                style: GoogleFonts.inter(
                                  color: isMe ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['time'] as String,
                                style: GoogleFonts.inter(
                                  color: isMe ? Colors.white70 : Colors.grey.shade600,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF7CB342),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
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
}
