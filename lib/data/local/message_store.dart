import 'dart:async';
import '../models/bitchat_packet.dart';

/// A simple store-and-forward message queue for offline messaging.
/// In a production environment, this should be backed by Isar or SQLite.
class MessageStore {
  // Store messages by channel/geohash or 'mesh'
  final Map<String, List<BitchatMessage>> _messages = {};
  
  // Track recently seen packet IDs for the Bloom Filter equivalent
  final Set<String> _seenPacketIds = {};

  final StreamController<BitchatMessage> _messageStreamController = StreamController.broadcast();
  Stream<BitchatMessage> get messageStream => _messageStreamController.stream;

  static final MessageStore _instance = MessageStore._internal();
  factory MessageStore() => _instance;
  MessageStore._internal();

  /// Adds a message to the store and broadcasts it to the UI
  void saveMessage(String channel, BitchatMessage message) {
    if (!_messages.containsKey(channel)) {
      _messages[channel] = [];
    }
    
    // Prevent duplicate messages
    if (_messages[channel]!.any((m) => m.id == message.id)) {
      return;
    }

    _messages[channel]!.add(message);
    _messageStreamController.add(message);
  }

  /// Retrieves all messages for a specific channel
  List<BitchatMessage> getMessages(String channel) {
    return _messages[channel] ?? [];
  }

  /// Checks if a packet has been seen recently (Routing loop prevention)
  bool hasSeenPacket(String id) {
    return _seenPacketIds.contains(id);
  }

  /// Marks a packet as seen
  void markPacketSeen(String id) {
    _seenPacketIds.add(id);
    // In a real implementation, this set should be pruned periodically or use a real Bloom Filter.
  }

  /// Wipes all locally stored messages (Emergency Wipe feature)
  void wipeAllData() {
    _messages.clear();
    _seenPacketIds.clear();
  }
}
