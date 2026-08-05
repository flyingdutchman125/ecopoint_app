import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:convert';

import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/chat_store.dart';

class CollectorChatTab extends StatefulWidget {
  final OrderModel? activeOrder;
  const CollectorChatTab({super.key, this.activeOrder});

  @override
  State<CollectorChatTab> createState() => _CollectorChatTabState();
}

class _CollectorChatTabState extends State<CollectorChatTab> {
  String? _activeOrderId; 
  String? _activeChatName;
  String? _activeChatSub;
  String _selectedFilter = 'All';

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _messageCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _threads = [
    {
      'order_id': 'EP-982103',
      'peer_name': "Budi Santoso (Warga)",
      'peer_role': 'user',
      'item_type': 'Plastik PET Bening (10 Kg)',
      'last_message': "Halo mas kolektor, posisi di mana?",
      'last_message_time': '12.19',
      'unread_count': 2,
    },
    {
      'order_id': 'EP-982104',
      'peer_name': "Warung Bu Kris",
      'peer_role': 'user',
      'item_type': 'Kardus & Minyak Jelantah',
      'last_message': "Baik pak, sampah sudah siap di depan warung",
      'last_message_time': '12.15',
      'unread_count': 0,
    },
  ];
  List<Map<String, dynamic>> _activeMessages = [];
  bool _loadingThreads = true;
  bool _loadingMessages = false;

  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _applyActiveOrder();
    _fetchThreads();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_activeOrderId != null) {
        _loadMessages(_activeOrderId!, initial: false);
      } else {
        _fetchThreads(silent: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CollectorChatTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeOrder != oldWidget.activeOrder) {
      _applyActiveOrder();
    }
  }

  void _applyActiveOrder() {
    final active = widget.activeOrder;
    if (active != null && active.id.isNotEmpty) {
      final name = (active.userName != null && active.userName!.isNotEmpty) ? active.userName! : "Budi Santoso (Warga)";
      final sub = (active.category != null && active.category!.isNotEmpty) ? active.category! : "Plastik PET Bening (10 Kg)";

      final existingIdx = _threads.indexWhere((t) => t['order_id'] == active.id || t['peer_name'] == name);
      if (existingIdx != -1) {
        _threads[existingIdx]['peer_name'] = name;
        _threads[existingIdx]['item_type'] = sub;
      } else {
        _threads.insert(0, {
          'order_id': active.id,
          'peer_name': name,
          'peer_role': 'user',
          'item_type': sub,
          'last_message': "Halo mas kolektor, posisi di mana?",
          'last_message_time': 'Baru saja',
          'unread_count': 1,
        });
      }
      setState(() {
        _activeOrderId = active.id;
        _activeChatName = name;
        _activeChatSub = sub;
      });
      _loadMessages(active.id, initial: true);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchCtrl.dispose();
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

  Future<void> _fetchThreads({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loadingThreads = true;
      });
    }

    try {
      final response = await ApiService.get(ApiConstants.chats);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['data'] ?? [];
        if (mounted) {
          setState(() {
            if (list.isNotEmpty) {
              _threads = list.map((e) => Map<String, dynamic>.from(e)).toList();
            } else {
              _threads = [
                {
                  'order_id': 'order_1',
                  'peer_name': "Budi Santoso (Warga)",
                  'peer_role': 'user',
                  'item_type': 'Plastik PET Bening (10 Kg)',
                  'last_message': "Halo mas kolektor, posisi di mana?",
                  'last_message_time': '12.19',
                  'unread_count': 2,
                },
                {
                  'order_id': 'order_2',
                  'peer_name': "Warung Bu Kris",
                  'peer_role': 'user',
                  'item_type': 'Kardus & Minyak Jelantah',
                  'last_message': "Baik pak, sampah sudah siap di depan warung",
                  'last_message_time': '12.15',
                  'unread_count': 0,
                },
              ];
            }
          });
        }
      }
    } catch (e) {
      if (_threads.isEmpty && mounted) {
        setState(() {
          _threads = [
            {
              'order_id': 'order_1',
              'peer_name': "Warga EcoPoint",
              'peer_role': 'user',
              'item_type': 'Kardus & Plastik',
              'last_message': "Permisi kak saya sedang di perjalanan, Perkiraan 10 Me..",
              'last_message_time': '12.19',
              'unread_count': 2,
            },
            {
              'order_id': 'order_2',
              'peer_name': "Pak Sutarjo (Warga)",
              'peer_role': 'user',
              'item_type': 'Minyak Jelantah',
              'last_message': "Baik pak, sampah sudah siap",
              'last_message_time': '12.18',
              'unread_count': 0,
            },
          ];
        });
      }
    } finally {
      if (!silent && mounted) {
        setState(() {
          _loadingThreads = false;
        });
      }
    }
  }

  Future<void> _loadMessages(String orderId, {bool initial = false}) async {
    if (initial) {
      setState(() {
        _loadingMessages = true;
      });
    }

    ChatStore.instance.seedInitialIfEmpty(orderId, [
      {
        'text': 'Halo mas kolektor, posisi di mana? Pesanan penjemputan sampah saya sudah siap ya.',
        'time': '12.15',
        'isMe': false,
      },
      {
        'text': 'Halo kak, saya sedang dalam perjalanan menuju lokasi Anda. Perkiraan 3-5 menit lagi sampai.',
        'time': '12.16',
        'isMe': true,
      },
    ]);

    try {
      final url = ApiConstants.orderMessages(orderId);
      final resp = await ApiService.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final List msgs = data['data'] ?? data['messages'] ?? [];
        for (final m in msgs) {
          final isMe = m['isMe'] == true || (m['sender_role'] == 'collector');
          final timeStr = m['time'] ?? (m['created_at'] != null && m['created_at'].toString().length >= 16
              ? m['created_at'].toString().substring(11, 16)
              : '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}');

          ChatStore.instance.addMessage(orderId, {
            'id': m['id'],
            'text': m['message'] ?? m['text'] ?? '',
            'time': timeStr,
            'isMe': isMe,
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _activeMessages = ChatStore.instance.getMessages(orderId);
          if (initial) {
            _loadingMessages = false;
          }
        });
        if (initial) {
          _scrollToBottom();
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;

    _activeOrderId ??= (_threads.isNotEmpty ? _threads.first['order_id'] : 'EP-982103');
    _messageCtrl.clear();

    final nowStr = '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    final newMsg = {
      'text': text,
      'time': nowStr,
      'isMe': true,
      'pending': true,
    };

    ChatStore.instance.addMessage(_activeOrderId!, newMsg);

    setState(() {
      _activeMessages = ChatStore.instance.getMessages(_activeOrderId!);
      final threadIdx = _threads.indexWhere((t) => t['order_id'] == _activeOrderId);
      if (threadIdx != -1) {
        _threads[threadIdx]['last_message'] = text;
        _threads[threadIdx]['last_message_time'] = nowStr;
      }
    });
    _scrollToBottom();

    try {
      final url = ApiConstants.orderMessages(_activeOrderId!);
      await ApiService.post(url, {'message': text, 'text': text});
    } catch (e) {
      // Local addition remains saved in ChatStore
    }
  }

  List<Map<String, dynamic>> get _filteredThreads {
    final query = _searchCtrl.text.toLowerCase().trim();
    return _threads.where((t) {
      final name = (t['peer_name'] ?? '').toString().toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_activeOrderId != null) {
      return _buildChatDetailScreen();
    }
    return _buildChatListScreen();
  }

  // === SCREEN 1: LIST CHAT WARGA ===
  Widget _buildChatListScreen() {
    final list = _filteredThreads;

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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari Nama / ID Warga...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
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
            child: _loadingThreads
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => _fetchThreads(),
                    child: ListView.builder(
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
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }

                        final item = list[index];
                        final orderId = item['order_id'] ?? 'order_1';
                        final name = item['peer_name'] ?? 'Warga EcoPoint';
                        final lastMsg = item['last_message'] ?? '';
                        final rawTime = item['last_message_time']?.toString() ?? '';
                        final timeStr = rawTime.length >= 16
                            ? rawTime.substring(11, 16)
                            : (rawTime.isNotEmpty ? rawTime : 'Baru saja');
                        final unread = item['unread_count'] ?? 0;

                        return _buildChatTile(
                          name: name,
                          message: lastMsg,
                          time: timeStr,
                          unreadCount: unread is int ? unread : 0,
                          onTap: () {
                            setState(() {
                              _activeOrderId = orderId;
                              _activeChatName = name;
                              _activeChatSub = item['item_type'] ?? 'Penjemputan Sampah Daur Ulang';
                            });
                            _loadMessages(orderId, initial: true);
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // === SCREEN 2: DETAIL CHAT ROOM ===
  Widget _buildChatDetailScreen() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          // CUSTOM CHAT APP BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _activeOrderId = null;
                      _activeMessages.clear();
                    });
                  },
                ),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF7CB342).withOpacity(0.2),
                  child: const Icon(Icons.person, color: Color(0xFF558B2F)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _activeChatName ?? 'Warga EcoPoint',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _activeChatSub ?? 'Warga • Penjemputan Daur Ulang',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey.shade600,
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
            child: _loadingMessages
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _activeMessages.length,
                    itemBuilder: (context, index) {
                      final msg = _activeMessages[index];
                      return _buildChatBubble(
                        message: msg['text'] ?? '',
                        time: msg['time'] ?? '',
                        isMe: msg['isMe'] ?? false,
                      );
                    },
                  ),
          ),

          // INPUT PESAN (2-Way Live Chat)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan balasan...',
                        hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        fillColor: const Color(0xFFF5F5F5),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFF57C00),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
          color: isSelected ? const Color(0xFFF57C00) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFFF57C00) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade600,
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
          backgroundColor: const Color(0xFFF57C00).withValues(alpha: 0.15),
          child: const Icon(Icons.person, color: Color(0xFFE65100)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              child: const Icon(Icons.person, size: 16, color: Colors.black54),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFF57C00) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
