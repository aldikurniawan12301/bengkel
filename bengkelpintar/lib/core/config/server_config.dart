import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class ServerConfig extends ChangeNotifier {
  ServerConfig._(this._preferences, this._overrideUrl);

  static const overrideKey = 'api_base_url_override';

  final SharedPreferences _preferences;
  String? _overrideUrl;

  static Future<ServerConfig> load() async {
    final preferences = await SharedPreferences.getInstance();
    return ServerConfig._(preferences, preferences.getString(overrideKey));
  }

  String get defaultUrl => ApiConfig.baseUrl;
  String get effectiveUrl => _overrideUrl ?? defaultUrl;
  String get editableUrl => effectiveUrl;
  bool get hasOverride => _overrideUrl != null;

  static bool isValidUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.contains(RegExp(r'\s'))) return false;
    final uri = Uri.tryParse(trimmed);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<bool> save(String value) async {
    final trimmed = value.trim();
    if (!isValidUrl(trimmed)) return false;
    await _preferences.setString(overrideKey, trimmed);
    _overrideUrl = trimmed;
    notifyListeners();
    return true;
  }

  Future<void> restoreDefault() async {
    await _preferences.remove(overrideKey);
    _overrideUrl = null;
    notifyListeners();
  }
}
