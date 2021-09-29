import 'dart:convert';

import 'package:secure_storage_example/util/cached_settings.dart';
import 'package:secure_storage_example/util/file_utils.dart';

/// Name: secure_settings
/// Description: Caches and securely stores user settings on the device
/// Created by: Pascal Robert on 29.09.2021
/// Last edited by: Pascal Robert on 29.09.2021

class SecureSettings {
  CachedSettings _cachedSettings;
  final FileUtils _fileService;

  SecureSettings(this._cachedSettings, this._fileService);

  Future<void> saveSettings() async {
    _fileService.saveSettings(_cachedSettings.toJson().toString().codeUnits);
  }

  Future<void> loadSettings() async {
    final List<int> loadedSettings = await _fileService.loadSettings();
    final String settingsAsString = String.fromCharCodes(loadedSettings);
    _cachedSettings = CachedSettings.fromJson(jsonDecode(settingsAsString));
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
