import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';

class PlatformSosQueue {
  static const _store = 'reports';
  Future<IDBDatabase>? _opening;

  Future<IDBDatabase> _open() async {
    final request = window.indexedDB.open('resq_sos_queue', 1);
    final result = Completer<IDBDatabase>();
    request.onupgradeneeded = ((Event _) {
      (request.result as IDBDatabase).createObjectStore(_store);
    }).toJS;
    request.onsuccess = ((Event _) {
      result.complete(request.result as IDBDatabase);
    }).toJS;
    request.onerror = ((Event _) {
      result.completeError(StateError('Could not open the browser SOS queue.'));
    }).toJS;
    return result.future;
  }

  Future<void> save(String id, String payload) async {
    await _transaction('readwrite', (store) {
      return store.put(jsonEncode([id, payload]).toJS, id.toJS);
    });
  }

  Future<Map<String, String>> readAll() async {
    final result = await _transaction('readonly', (store) => store.getAll());
    final rows = (result as JSArray<JSString>).toDart;
    return Map.fromEntries(rows.map((row) {
      final values = jsonDecode(row.toDart) as List<dynamic>;
      return MapEntry(values[0] as String, values[1] as String);
    }));
  }

  Future<void> remove(String id) async {
    await _transaction('readwrite', (store) => store.delete(id.toJS));
  }

  Future<JSAny?> _transaction(
    String mode,
    IDBRequest Function(IDBObjectStore) run,
  ) async {
    final database = await (_opening ??= _open());
    final transaction = database.transaction(_store.toJS, mode);
    final done = Completer<JSAny?>();
    final request = run(transaction.objectStore(_store));
    transaction.oncomplete = ((Event _) {
      done.complete(request.result);
    }).toJS;
    transaction.onabort = ((Event _) {
      done.completeError(
          StateError('The browser could not save or read the SOS queue.'));
    }).toJS;
    return done.future;
  }
}
