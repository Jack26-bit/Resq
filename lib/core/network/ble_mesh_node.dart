import 'dart:async';
import 'dart:typed_data';
import 'package:nearby_connections/nearby_connections.dart';
import '../crypto/noise_protocol.dart';
import '../../data/models/bitchat_packet.dart';

class BleMeshNode {
  final String nickname;
  final Strategy strategy = Strategy.P2P_CLUSTER; // Supports mesh topology
  final Map<String, ConnectionInfo> _connectedEndpoints = {};

  // A stream controller to broadcast incoming messages to the UI/App layer
  final StreamController<BitchatPacket> _incomingPacketsController =
      StreamController.broadcast();
  Stream<BitchatPacket> get incomingPackets =>
      _incomingPacketsController.stream;

  BleMeshNode({required this.nickname});

  Future<void> start() async {
    try {
      // Start Advertising
      await Nearby().startAdvertising(
        nickname,
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            print('Connected to $id');
          }
        },
        onDisconnected: (id) {
          _connectedEndpoints.remove(id);
          print('Disconnected from $id');
        },
      );

      // Start Discovering
      await Nearby().startDiscovery(
        nickname, // In a real app, use a service ID specific to the app
        strategy,
        onEndpointFound: (id, name, serviceId) {
          // Auto-request connection to form the mesh
          Nearby().requestConnection(
            nickname,
            id,
            onConnectionInitiated: _onConnectionInitiated,
            onConnectionResult: (id, status) {
              if (status == Status.CONNECTED) {
                print('Connected to discovered node $id');
              }
            },
            onDisconnected: (id) {
              _connectedEndpoints.remove(id);
            },
          );
        },
        onEndpointLost: (id) {
          print('Lost endpoint $id');
        },
      );
    } catch (e) {
      print('Failed to start mesh node: $e');
    }
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) async {
    // Automatically accept the connection for the mesh network
    await Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: (endpointId, payload) {
        if (payload.type == PayloadType.BYTES && payload.bytes != null) {
          _handleIncomingPayload(endpointId, payload.bytes!);
        }
      },
      onPayloadTransferUpdate: (endpointId, payloadTransferUpdate) {},
    );
    _connectedEndpoints[endpointId] = info;
  }

  void _handleIncomingPayload(String endpointId, Uint8List data) {
    try {
      // Parse the raw bytes into a packet
      final packet = BitchatPacket.fromBinary(data);

      // In a full implementation, we would check the Bloom filter here
      // and decrement TTL. If TTL > 0, we'd rebroadcast.

      _incomingPacketsController.add(packet);
    } catch (e) {
      print('Failed to parse incoming payload: $e');
    }
  }

  Future<void> broadcastPacket(BitchatPacket packet) async {
    final payloadBytes = Uint8List.fromList(packet.toBinary());

    // Send to all connected peers
    for (String endpointId in _connectedEndpoints.keys) {
      try {
        await Nearby().sendBytesPayload(endpointId, payloadBytes);
      } catch (e) {
        print('Failed to send to $endpointId: $e');
      }
    }
  }

  Future<void> stop() async {
    await Nearby().stopAdvertising();
    await Nearby().stopDiscovery();
    await Nearby().stopAllEndpoints();
    _connectedEndpoints.clear();
  }
}
