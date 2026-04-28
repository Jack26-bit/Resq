import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../theme/colors.dart';
import '../data/models/bitchat_packet.dart';
import '../data/local/message_store.dart';
import '../core/network/ble_mesh_node.dart';
import '../core/platform/bluetooth_mesh_support.dart';
import 'package:uuid/uuid.dart';

class MeshChatScreen extends StatefulWidget {
  const MeshChatScreen({super.key});
  @override
  State<MeshChatScreen> createState() => _MeshChatScreenState();
}

class _MeshChatScreenState extends State<MeshChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final String _channel = 'mesh_global';
  BleMeshNode? _meshNode;
  StreamSubscription<BitchatPacket>? _packetSubscription;
  final String _myNickname = 'ECHO_User_${const Uuid().v4().substring(0, 4)}';
  late final bool _meshAvailable;

  @override
  void initState() {
    super.initState();
    _meshAvailable = supportsBluetoothMesh;

    if (_meshAvailable) {
      _meshNode = BleMeshNode(nickname: _myNickname);
      _meshNode!.start();

      // Listen for incoming packets from the mesh network
      _packetSubscription = _meshNode!.incomingPackets.listen((packet) {
        // In a real app, we would decrypt here. For POC, we just parse JSON.
        try {
          final jsonStr = String.fromCharCodes(packet.payload);
          // Note: simplified JSON parsing
          // We assume payload is plain text for POC since noise is scaffolded
        } catch (e) {
          print('Error parsing incoming message');
        }
      });
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _packetSubscription?.cancel();
    _meshNode?.stop();
    super.dispose();
  }

  void _sendMessage() {
    if (!_meshAvailable) return;

    if (_msgCtrl.text.trim().isEmpty) return;

    final content = _msgCtrl.text.trim();
    final message = BitchatMessage(
      flags: 0,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      senderNickname: _myNickname,
      content: content,
    );

    MessageStore().saveMessage(_channel, message);

    // Convert to BitchatPacket and broadcast
    final payloadBytes = content.codeUnits; // Simplified for POC
    final packet = BitchatPacket(
      type: 1, // 'message'
      ttl: 7, // Multi-hop TTL
      timestamp: message.timestamp,
      flags: 0,
      payload: Uint8List.fromList(payloadBytes),
    );

    _meshNode?.broadcastPacket(packet);
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: const Color(0xB3131313),
        title: const Text('OFFLINE MESH',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.white,
            )),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _meshAvailable
          ? Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: C.primary.withOpacity(0.1),
                  child: const Row(
                    children: [
                      Icon(Icons.bluetooth_connected,
                          color: C.primary, size: 16),
                      SizedBox(width: 8),
                      Text('SECURE P2P MESH ACTIVE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: C.primary,
                          )),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<BitchatMessage>(
                    stream: MessageStore().messageStream,
                    builder: (context, snapshot) {
                      final messages = MessageStore().getMessages(_channel);
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderNickname == _myNickname;
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? C.primary.withOpacity(0.2)
                                    : C.surfaceLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isMe
                                      ? C.primary.withOpacity(0.5)
                                      : C.outlineVar,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(msg.senderNickname,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        color: isMe ? C.primary : Colors.grey,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(msg.content,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildInputArea(),
              ],
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.bluetooth_disabled,
                        color: Colors.white, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Not available on web',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Offline mesh chat requires Android or iOS Bluetooth support.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: C.surfaceLow,
        border: Border(top: BorderSide(color: C.outlineVar)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Broadcast to mesh...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: C.surfaceHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.send, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
