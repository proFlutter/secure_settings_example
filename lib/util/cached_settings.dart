import 'dart:convert';

/// Name: cached_settings
/// Description: Model class to hold cached settings
/// Created by: Pascal Robert on 29.09.2021
/// Last edited by: Pascal Robert on 29.10.2021

class CachedSettings {
  static const jsonSerializationKey = 'cachedSettings';
  final Map<String, String> _data;

  CachedSettings(this._data);

  factory CachedSettings.fromJson(String json) {
    final Map<String, dynamic> dataAsJson = jsonDecode(json);
    final Map<String, String> data = dataAsJson.map((key, value) => MapEntry<String, String>(key, value));
    return CachedSettings(data);
  }

  String toJson() {
    return json.encode(_data);
  }

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
