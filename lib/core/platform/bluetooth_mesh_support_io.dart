import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

bool get supportsBluetoothMesh =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Returns true when permission requests for storage/media are supported
/// (i.e. running on Android or iOS). This mirrors the Bluetooth support
/// guard but is kept as a separate helper for permission checks.
bool isWebSupportedPermission() => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
