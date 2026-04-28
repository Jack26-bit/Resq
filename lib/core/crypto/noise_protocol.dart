import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'identity_manager.dart';

/// Simplified wrapper representing the Noise_XX_25519_ChaChaPoly_SHA256 handshake and transport.
/// In a full implementation, this handles the 3-part handshake and key mixing.
class NoiseProtocol {
  final IdentityManager identityManager;
  SecretKey? _transportSendKey;
  SecretKey? _transportReceiveKey;

  NoiseProtocol(this.identityManager);

  bool get isReady => _transportSendKey != null && _transportReceiveKey != null;

  /// Simulates deriving symmetric keys from a peer's public key (for demonstration)
  /// In reality, this requires the 3-part XX handshake to establish forward secrecy.
  Future<void> establishSessionWithPeer(List<int> peerPublicKeyBytes) async {
    final x25519 = X25519();
    final peerPublicKey =
        SimplePublicKey(peerPublicKeyBytes, type: KeyPairType.x25519);

    final sharedSecret = await x25519.sharedSecretKey(
      keyPair: identityManager.noiseKeyPair,
      remotePublicKey: peerPublicKey,
    );

    // Derive send/receive keys via HKDF (simplified)
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
    final derivedKeyBytes = await hkdf.deriveKey(
      secretKey: sharedSecret,
      nonce: utf8.encode('bitchat_noise_xx_v1'),
    );

    // In a real Noise protocol, send and receive keys are distinct.
    _transportSendKey = derivedKeyBytes;
    _transportReceiveKey = derivedKeyBytes;
  }

  Future<List<int>> encryptPayload(List<int> payload) async {
    if (!isReady) throw Exception('Noise session not established');

    final chacha = Chacha20.poly1305Aead();
    final secretBox = await chacha.encrypt(
      payload,
      secretKey: _transportSendKey!,
    );

    // Prepend nonce to ciphertext
    return [
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes
    ];
  }

  Future<List<int>> decryptPayload(List<int> encryptedData) async {
    if (!isReady) throw Exception('Noise session not established');

    final chacha = Chacha20.poly1305Aead();
    // Assuming 12-byte nonce, and 16-byte MAC for Chacha20Poly1305
    final nonce = encryptedData.sublist(0, 12);
    final ciphertextLength = encryptedData.length - 12 - 16;
    final ciphertext = encryptedData.sublist(12, 12 + ciphertextLength);
    final mac = encryptedData.sublist(12 + ciphertextLength);

    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(mac),
    );

    return await chacha.decrypt(
      secretBox,
      secretKey: _transportReceiveKey!,
    );
  }
}
