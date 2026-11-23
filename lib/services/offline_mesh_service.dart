import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../core/platform/bluetooth_mesh_support.dart';
import 'platform_sos_queue.dart'
    if (dart.library.js_interop) 'platform_sos_queue_web.dart';

class OfflineMeshService {
  static final OfflineMeshService _instance = OfflineMeshService._internal();
  factory OfflineMeshService() => _instance;
  OfflineMeshService._internal();

  final _platformQueue = PlatformSosQueue();
  Future<Database>? _database;
  Future<void>? _sync;
  Timer? _retryTimer;

  Future<Database> _openDatabase() async {
    final directory = await getDatabasesPath();
    return openDatabase(
      join(directory, 'resq_offline.db'),
      onCreate: (db, _) => db
          .execute('CREATE TABLE sos_queue(id TEXT PRIMARY KEY, payload TEXT)'),
      version: 1,
    );
  }

  Future<Database> get _db => _database ??= _openDatabase();

  void start() {
    if (_retryTimer != null) return;
    final auth = FirebaseAuth.instance;
    final connectivity = Connectivity();
    FirebaseStorage.instance.setMaxUploadRetryTime(const Duration(seconds: 30));
    auth.authStateChanges().listen((_) => unawaited(syncOfflineData()));
    connectivity.onConnectivityChanged
        .listen((_) => unawaited(syncOfflineData()));
    _retryTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(syncOfflineData()),
    );
  }

  Future<bool> isOffline() async => (await Connectivity().checkConnectivity())
      .contains(ConnectivityResult.none);

  Future<void> queueSosReport(String id, Map<String, dynamic> data) async {
    final payload = jsonEncode(data);
    if (supportsBluetoothMesh) {
      await (await _db).insert('sos_queue', {'id': id, 'payload': payload});
      return;
    }
    await _platformQueue.save(id, payload);
  }

  Future<void> broadcastSos(Map<String, dynamic> data) async {
    if (!supportsBluetoothMesh) return;
    final payload = Uint8List.fromList(utf8.encode(jsonEncode(data)));
    try {
      await Nearby().startAdvertising(
        'ResQ-Node',
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: (id, info) =>
            Nearby().acceptConnection(id, onPayLoadRecieved: (_, __) {}),
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            unawaited(_sendToPeer(id, payload));
          }
        },
        onDisconnected: (_) {},
      );
    } catch (error) {
      debugPrint('SOS mesh advertising failed: $error');
    }
  }

  Future<void> _sendToPeer(String id, Uint8List payload) async {
    try {
      await Nearby().sendBytesPayload(id, payload);
    } catch (error) {
      debugPrint('SOS mesh send failed: $error');
    }
  }

  Future<void> syncOfflineData() async {
    final activeSync = _sync;
    if (activeSync != null) return activeSync;
    final sync = _syncQueuedReports();
    _sync = sync;
    try {
      await sync;
    } finally {
      _sync = null;
    }
  }

  Future<void> _syncQueuedReports() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || await isOffline()) return;

      if (supportsBluetoothMesh) {
        final db = await _db;
        for (final row in await db.query('sos_queue')) {
          final id = row['id'] as String;
          if (await _tryPublish(id, row['payload'] as String, user.uid)) {
            await db.delete('sos_queue', where: 'id = ?', whereArgs: [id]);
          }
        }
        return;
      }

      final reports = await _platformQueue.readAll();
      for (final report in reports.entries) {
        if (await _tryPublish(report.key, report.value, user.uid)) {
          await _platformQueue.remove(report.key);
        }
      }
    } catch (error) {
      debugPrint('SOS queue sync failed: $error');
    }
  }

  Future<bool> _tryPublish(String id, String payload, String uid) async {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['ownerUid'] != null && data['ownerUid'] != uid) return false;
      final files = data.remove('queuedMedia') as List<dynamic>? ?? [];
      final legacyLocation = data['location'];
      if (!data.containsKey('ownerUid') &&
          legacyLocation is Map &&
          legacyLocation['latitude'] == 34.0522 &&
          legacyLocation['longitude'] == -118.2437) {
        data['location'] = null;
      }
      data['ownerUid'] = uid;
      data['timestamp'] =
          Timestamp.fromDate(DateTime.parse(data['timestamp'] as String));
      final firestore = FirebaseFirestore.instance;
      final report = firestore.collection('sos_reports').doc(id);
      try {
        await report.set(data).timeout(const Duration(seconds: 30));
      } on FirebaseException catch (error) {
        if (error.code != 'permission-denied') rethrow;
        final existing = await report
            .get(const GetOptions(source: Source.server))
            .timeout(const Duration(seconds: 30));
        if (existing.data()?['ownerUid'] != uid) rethrow;
      }

      final attachments = <Map<String, String>>[];
      for (final (index, file) in files.indexed) {
        final ref = FirebaseStorage.instance.ref('sos_media/$uid/$id/$index');
        final contentType = file['contentType'] as String;
        await ref.putData(
          base64Decode(file['bytes'] as String),
          SettableMetadata(contentType: contentType),
        );
        attachments.add({
          'name': file['name'] as String,
          'storagePath': ref.fullPath,
          'contentType': contentType,
        });
      }
      if (attachments.isNotEmpty) {
        await report.update({'media_attachments': attachments}).timeout(
            const Duration(seconds: 30));
      }
      return true;
    } catch (error) {
      debugPrint('SOS sync failed for $id: $error');
      return false;
    }
  }
}
