import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Name: encrypt_utils
/// Description: Utility class that helps with the encryption details
/// Created by: Pascal Robert on 29.10.2021
/// Last edited by: Pascal Robert on 29.10.2021

class EncryptUtils {
  /// Specify your own key length depending on your security requirements here

  static const int keyLengthBytes = 32;
  static const int macLengthBytes = 16;
  static const int nonceLengthBytes = 16;
  static late SecretKey _cachedSettingsSecretKey;
  static late SimpleKeyPair _settingsKeyPair;

  static final Cipher _settingsEncryptionAlgorithm = AesGcm.with256bits(nonceLength: nonceLengthBytes);

  /// keyPair will be loaded from a secure storage and passed here on app start
  static Future<void> initializeEncryption(SimpleKeyPair keyPair) async {
    _settingsKeyPair = keyPair;
    _cachedSettingsSecretKey =
        await _settingsEncryptionAlgorithm.newSecretKeyFromBytes(await _settingsKeyPair.extractPrivateKeyBytes());
  }

  /// Generates a new key pair for local settings encryption if app is run for the first time
  static Future<SimpleKeyPair> generateKeyPair({List<int>? keyPairSeed}) async {
    return await X25519().newKeyPairFromSeed(keyPairSeed ?? fillBytesWithSecureRandomNumbers(keyLengthBytes));
  }

  /// Fill a list with a random sequence of bytes.
  static List<int> fillBytesWithSecureRandomNumbers(int numberOfBytes, {Random? random}) {
    List<int> bytes = [];
    random ??= Random.secure();
    for (var i = 0; i < numberOfBytes; i++) {
      bytes.add(random.nextInt(256));
    }
    return bytes;
  }

  /// Use this to encrypt local device settings
  static Future<List<int>> encryptSettings(List<int> settingsToEncrypt) async {
    final List<int> settingsNonce = fillBytesWithSecureRandomNumbers(nonceLengthBytes);

    final settingsSecretBox = await _settingsEncryptionAlgorithm.encrypt(settingsToEncrypt,
        secretKey: _cachedSettingsSecretKey, nonce: settingsNonce);

    final List<int> saltMacCipher = [];
    saltMacCipher.addAll(settingsNonce);
    saltMacCipher.addAll(settingsSecretBox.mac.bytes);
    saltMacCipher.addAll(settingsSecretBox.cipherText);

    return saltMacCipher;
  }

  /// Use this to decrypt local device settings
  static Future<List<int>> decryptSettings(List<int> encryptedSettings) async {
    final List<int> settingsNonce = encryptedSettings.getRange(0, nonceLengthBytes).toList();
    final Mac mac = Mac(encryptedSettings.getRange(nonceLengthBytes, nonceLengthBytes + macLengthBytes).toList());
    final List<int> cipherText =
        encryptedSettings.getRange(nonceLengthBytes + macLengthBytes, encryptedSettings.length).toList();
    final SecretBox settingsSecretBox = SecretBox(cipherText, nonce: settingsNonce, mac: mac);

    return await _settingsEncryptionAlgorithm.decrypt(settingsSecretBox, secretKey: _cachedSettingsSecretKey);
  }
}
