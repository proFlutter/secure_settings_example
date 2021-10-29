import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:secure_storage_example/util/cached_settings.dart';
import 'package:secure_storage_example/util/file_utils.dart';
import 'package:cryptography/cryptography.dart';

import 'encrypt_utils.dart';

/// Name: secure_settings
/// Description: Caches and securely stores user settings on the device
/// Created by: Pascal Robert on 29.09.2021
/// Last edited by: Pascal Robert on 29.10.2021

class SecureSettings {
  static const String encryptionSeedStorageKey = 'encryption_seed';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FileUtils _fileService;

  CachedSettings _cachedSettings;
  bool _initialized = false;

  SecureSettings(this._cachedSettings, this._fileService);

  /// Encryption needs to be initialized before it can be used
  Future<void> initializeSecureSettings() async {
    final SimpleKeyPair settingsKeyPair = await _getOrCreateEncryptionKeyPair();
    await EncryptUtils.initializeEncryption(settingsKeyPair);
    _initialized = true;
  }

  /// Tries to load the saved seed from the secureStorage and creates a new one if none is stored.
  /// New seed is saved immediately in secure storage
  Future<SimpleKeyPair> _getOrCreateEncryptionKeyPair() async {
    final String? seedAsString = await _secureStorage.read(key: encryptionSeedStorageKey);

    final seed = (seedAsString == null || seedAsString.isEmpty)
        ? EncryptUtils.fillBytesWithSecureRandomNumbers(EncryptUtils.keyLengthBytes)
        : seedAsString.codeUnits;

    _saveSeed(seed);

    return await EncryptUtils.generateKeyPair(keyPairSeed: seed);
  }

  void _saveSeed(List<int> seed) async {
    _secureStorage.write(key: encryptionSeedStorageKey, value: String.fromCharCodes(seed));
  }

  Future<void> saveSettings() async {
    /// Make sure encryption is initialized before running encryption
    if (!_initialized) {
      await initializeSecureSettings();
    }
    final Codec obfuscator = utf8.fuse(base64);
    final String obfuscatedSettings = obfuscator.encode(_cachedSettings.toJson().toString());

    /// Encrypt settings after obfuscation
    final List<int> encryptedSettings = await EncryptUtils.encryptSettings(obfuscatedSettings.codeUnits);

    _fileService.saveSettings(encryptedSettings);
  }

  Future<void> loadSettings() async {
    /// Make sure encryption is initialized before running decryption
    if (!_initialized) {
      await initializeSecureSettings();
    }

    final List<int> loadedSettings = await _fileService.loadSettings();

    /// Decrypt the loaded settings
    final List<int> decryptedSettings = await EncryptUtils.decryptSettings(loadedSettings);

    final String obfuscatedSettings = String.fromCharCodes(decryptedSettings);
    final Codec obfuscator = utf8.fuse(base64);

    final String settingsAsString = obfuscator.decode(obfuscatedSettings);
    _cachedSettings = CachedSettings.fromJson(settingsAsString);
  }

  Future<void> _saveValue(String key, String value) async {
    _cachedSettings[key] = value;
  }

  Future<String> _loadValue(String key) async {
    if (!_cachedSettings.containsKey(key)) {
      await loadSettings();
    }
    return _cachedSettings[key].toString();
  }

  Future<void> saveString(String key, String value) async {
    _saveValue(key, value);
  }

  Future<String> loadString(String key) async {
    return _loadValue(key);
  }

  Future<void> saveInt(String key, int value) async {
    _saveValue(key, value.toString());
  }

  Future<int> loadInt(String key) async {
    return int.parse(await _loadValue(key));
  }

  /// ...
}
