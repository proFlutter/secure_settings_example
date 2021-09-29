import 'dart:convert';

/// Name: cached_settings
/// Description: Model class to hold cached settings
/// Created by: Pascal Robert on 29.09.2021
/// Last edited by: Pascal Robert on 29.09.2021

class CachedSettings {
  static const jsonSerializationKey = 'cachedSettings';
  final Map<String, String> _data;

  CachedSettings(this._data);

  factory CachedSettings.fromJson(Map<String, dynamic> json) => CachedSettings(jsonDecode(json[jsonSerializationKey]));

  Map<String, dynamic> toJson() => {
        jsonSerializationKey: jsonEncode(_data),
      };

  String operator [](String key) {
    return _data[key].toString();
  }

  void operator []=(String key, String value) {
    _data[key] = value;
  }

  bool containsKey(String key) {
    return _data.containsKey(key);
  }
}
