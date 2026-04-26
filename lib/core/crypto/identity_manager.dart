import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentityManager {
  static const String _x25519PrivKey = 'bitchat_x25519_priv';
  static const String _ed25519PrivKey = 'bitchat_ed25519_priv';

  late SimpleKeyPair _noiseKeyPair;
  late SimpleKeyPair _signingKeyPair;

  SimpleKeyPair get noiseKeyPair => _noiseKeyPair;
  SimpleKeyPair get signingKeyPair => _signingKeyPair;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    final x25519Base64 = prefs.getString(_x25519PrivKey);
    final ed25519Base64 = prefs.getString(_ed25519PrivKey);

    if (x25519Base64 == null || ed25519Base64 == null) {
      // Generate new keys
      await _generateNewKeys(prefs);
    } else {
      // Load existing keys
      await _loadKeys(x25519Base64, ed25519Base64);
    }
  }

  Future<void> _generateNewKeys(SharedPreferences prefs) async {
    final x25519 = X25519();
    _noiseKeyPair = await x25519.newKeyPair();
    
    final ed25519 = Ed25519();
    _signingKeyPair = await ed25519.newKeyPair();

    final noisePrivBytes = await _noiseKeyPair.extractPrivateKeyBytes();
    final signPrivBytes = await _signingKeyPair.extractPrivateKeyBytes();

    await prefs.setString(_x25519PrivKey, base64Encode(noisePrivBytes));
    await prefs.setString(_ed25519PrivKey, base64Encode(signPrivBytes));
  }

  Future<void> _loadKeys(String x25519Base64, String ed25519Base64) async {
    final x25519 = X25519();
    _noiseKeyPair = await x25519.newKeyPairFromSeed(base64Decode(x25519Base64));

    final ed25519 = Ed25519();
    _signingKeyPair = await ed25519.newKeyPairFromSeed(base64Decode(ed25519Base64));
  }

  Future<void> wipeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_x25519PrivKey);
    await prefs.remove(_ed25519PrivKey);
    await _generateNewKeys(prefs);
  }

  Future<String> getFingerprint() async {
    final pubKey = await _noiseKeyPair.extractPublicKey();
    final hash = await Sha256().hash(pubKey.bytes);
    return base64Encode(hash.bytes).substring(0, 16); // Short fingerprint
  }
}
