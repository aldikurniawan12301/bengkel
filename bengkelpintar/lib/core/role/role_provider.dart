import 'package:flutter/foundation.dart';

enum UserRole { mechanic, admin }

/// Sementara untuk T-03; akan diganti dengan sesi login pada T-07.
class RoleProvider extends ChangeNotifier {
  UserRole _role = UserRole.mechanic;

  UserRole get role => _role;

  String get roleCode => _role == UserRole.admin ? 'A' : 'M';

  void setRole(UserRole role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
  }
}
