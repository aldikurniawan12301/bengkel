import 'package:flutter/foundation.dart';

class MockServerUnavailableException implements Exception {
  const MockServerUnavailableException();

  @override
  String toString() => 'Server tidak dapat dihubungi.';
}

class MockFailureController extends ChangeNotifier {
  static MockFailureController? global;

  bool _enabled = false;

  bool get enabled => _enabled;

  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }

  void toggle() => setEnabled(!_enabled);

  static void ensureAvailable() {
    if (global?.enabled == true) {
      throw const MockServerUnavailableException();
    }
  }
}
