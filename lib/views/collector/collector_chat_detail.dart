import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectorChatDetailPage extends StatefulWidget {
  final String name;
  final String preview;

  const CollectorChatDetailPage({
    super.key,
    required this.name,
    required this.preview,
  });

  @override
  State<CollectorChatDetailPage> createState() =>
      _CollectorChatDetailPageState();
}

class _CollectorChatDetailPageState extends State<CollectorChatDetailPage> {
  final _messageCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Halo, saya sedang dalam perjalanan ke lokasi.',
      'fromMe': true,
      'time': '09:40',
    },
    {'text': 'Baik, saya tunggu ya.', 'fromMe': false, 'time': '09:41'},
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'text': text,
        'fromMe': true,
        'time': '09:5${_messages.length}',
      });
      _messageCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _messages.add({
          'text': 'Terima kasih, saya akan segera cek.',
          'fromMe': false,
          'time': '09:5${_messages.length}',
        });
      });
    });
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
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            child: Text(
              widget.preview,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'] as String,
                          style: GoogleFonts.inter(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message['time'] as String,
                          style: GoogleFonts.inter(
                            color: isMe ? Colors.white70 : Colors.grey.shade600,
                            fontSize: 11,
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
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
        ],
      ),
    );
  }
}
