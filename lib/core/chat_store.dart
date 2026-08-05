import 'package:flutter/foundation.dart';

class ChatStore {
  ChatStore._internal();
  static final ChatStore instance = ChatStore._internal();

  final Map<String, List<Map<String, dynamic>>> _store = {};

  List<Map<String, dynamic>> getMessages(String orderId) {
    return List<Map<String, dynamic>>.from(_store[orderId] ?? []);
  }

  void addMessage(String orderId, Map<String, dynamic> msg) {
    if (!_store.containsKey(orderId)) {
      _store[orderId] = [];
    }
    final list = _store[orderId]!;
    if (!list.any((m) => m['text'] == msg['text'] && m['time'] == msg['time'])) {
      list.add(msg);
    }
  }

  void seedInitialIfEmpty(String orderId, List<Map<String, dynamic>> initialMsgs) {
    if (!_store.containsKey(orderId) || _store[orderId]!.isEmpty) {
      _store[orderId] = List<Map<String, dynamic>>.from(initialMsgs);
    }
  }
}
