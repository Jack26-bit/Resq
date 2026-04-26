import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class OfflineMeshService {
  static final OfflineMeshService _instance = OfflineMeshService._internal();
  factory OfflineMeshService() => _instance;
  OfflineMeshService._internal();

  Database? _db;

  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, 'resq_offline.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE sos_queue(id TEXT PRIMARY KEY, payload TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<bool> isOffline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.none);
  }

  Future<void> queueSosReport(String id, Map<String, dynamic> data) async {
    await init();
    // Save to SQLite
    await _db?.insert(
      'sos_queue',
      {'id': id, 'payload': jsonEncode(data)},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Try broadcasting via Bluetooth
    try {
      await Nearby().startAdvertising(
        'ResQ-Node',
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: (id, info) => Nearby().acceptConnection(id, onPayLoadRecieved: (id, payload) {}),
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            Nearby().sendBytesPayload(id, Uint8List.fromList(utf8.encode(jsonEncode(data))));
          }
        },
        onDisconnected: (id) {},
      );
    } catch (e) {
      debugPrint('Nearby advertising failed: $e');
    }
  }

  Future<void> syncOfflineData() async {
    if (await isOffline()) return;
    await init();
    
    final List<Map<String, dynamic>> queued = await _db?.query('sos_queue') ?? [];
    for (var row in queued) {
      try {
        final payload = jsonDecode(row['payload'] as String);
        payload['timestamp'] = FieldValue.serverTimestamp(); // Refresh timestamp
        await FirebaseFirestore.instance.collection('sos_reports').doc(row['id'] as String).set(payload);
        await _db?.delete('sos_queue', where: 'id = ?', whereArgs: [row['id']]);
      } catch (e) {
        debugPrint('Sync failed for ${row['id']}: $e');
      }
    }
  }
}
