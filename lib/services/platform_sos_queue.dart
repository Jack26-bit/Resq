import 'package:shared_preferences/shared_preferences.dart';

class PlatformSosQueue {
  static const _prefix = 'resq.sos.';

  Future<void> save(String id, String payload) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString('$_prefix$id', payload)) {
      throw StateError('Could not save this SOS on the device.');
    }
  }

  Future<Map<String, String>> readAll() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final key in prefs.getKeys())
        if (key.startsWith(_prefix))
          key.substring(_prefix.length): prefs.getString(key)!,
    };
  }

  Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove('$_prefix$id')) {
      throw StateError('Could not remove the synced SOS from the queue.');
    }
  }
}
