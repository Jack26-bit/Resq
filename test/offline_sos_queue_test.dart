import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resqnet/services/offline_mesh_service.dart';
import 'package:resqnet/services/platform_sos_queue.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('SOS is saved on a desktop without mesh support', () async {
    SharedPreferences.setMockInitialValues({});
    const report = {'description': 'Test SOS', 'location': null};

    await OfflineMeshService().queueSosReport('test-report', report);

    final saved = await PlatformSosQueue().readAll();
    expect(saved, {'test-report': jsonEncode(report)});
  });
}
