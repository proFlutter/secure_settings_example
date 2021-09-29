import 'dart:convert';

/// Name: cached_settings
/// Description: Model class to hold cached settings
/// Created by: Pascal Robert on 29.09.2021
/// Last edited by: Pascal Robert on 29.09.2021

class CachedSettings {
  static const jsonSerializationKey = 'cachedSettings';
  final Map<String, String> _data;

  CachedSettings(this._data);

  factory CachedSettings.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> innerJson = json[jsonSerializationKey];
    final Map<String, String> deserializedData = <String, String>{};

    innerJson.forEach((key, value) {
      deserializedData[key] = value;
    });
    return CachedSettings(deserializedData);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> innerJson = <String, dynamic>{};

    _data.forEach((key, value) {
      innerJson['\"$key\"'] = '\"$value\"';
    });

    return <String, dynamic>{'\"$jsonSerializationKey\"': innerJson};
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
