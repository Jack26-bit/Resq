import 'dart:typed_data';

/// Represents the Application Layer message format
class BitchatMessage {
  final int flags;
  final int timestamp;
  final String id;
  final String senderNickname;
  final String content;

  BitchatMessage({
    required this.flags,
    required this.timestamp,
    required this.id,
    required this.senderNickname,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'flags': flags,
      'timestamp': timestamp,
      'id': id,
      'senderNickname': senderNickname,
      'content': content,
    };
  }

  factory BitchatMessage.fromJson(Map<String, dynamic> json) {
    return BitchatMessage(
      flags: json['flags'],
      timestamp: json['timestamp'],
      id: json['id'],
      senderNickname: json['senderNickname'],
      content: json['content'],
    );
  }
}

/// Represents the Session Layer binary packet format
class BitchatPacket {
  final int version;
  final int type;
  int ttl;
  final int timestamp;
  final int flags;
  final Uint8List payload;

  BitchatPacket({
    this.version = 1,
    required this.type,
    required this.ttl,
    required this.timestamp,
    required this.flags,
    required this.payload,
  });

  /// Serializes the packet into a compact binary format.
  Uint8List toBinary() {
    // Simplified serialization for demonstration
    // Header format:
    // version(1) + type(1) + ttl(1) + timestamp(8) + flags(1) + payload_len(2) = 14 bytes
    final headerBytes = BytesBuilder();
    headerBytes.addByte(version);
    headerBytes.addByte(type);
    headerBytes.addByte(ttl);

    // Convert 64-bit timestamp
    final tsData = ByteData(8);
    tsData.setInt64(0, timestamp, Endian.big);
    headerBytes.add(tsData.buffer.asUint8List());

    headerBytes.addByte(flags);

    final lenData = ByteData(2);
    lenData.setUint16(0, payload.length, Endian.big);
    headerBytes.add(lenData.buffer.asUint8List());

    final builder = BytesBuilder();
    builder.add(headerBytes.toBytes());
    builder.add(payload);

    return builder.toBytes();
  }

  /// Deserializes the packet from raw binary data.
  factory BitchatPacket.fromBinary(Uint8List data) {
    if (data.length < 14) throw const FormatException('Packet too small');

    final version = data[0];
    final type = data[1];
    final ttl = data[2];

    final tsData = ByteData.sublistView(data, 3, 11);
    final timestamp = tsData.getInt64(0, Endian.big);

    final flags = data[11];

    final lenData = ByteData.sublistView(data, 12, 14);
    final payloadLen = lenData.getUint16(0, Endian.big);

    if (data.length < 14 + payloadLen) {
      throw const FormatException('Payload incomplete');
    }

    final payload = data.sublist(14, 14 + payloadLen);

    return BitchatPacket(
      version: version,
      type: type,
      ttl: ttl,
      timestamp: timestamp,
      flags: flags,
      payload: Uint8List.fromList(payload),
    );
  }
}
