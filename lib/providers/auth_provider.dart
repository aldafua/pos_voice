import 'package:flutter/foundation.dart';

import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo);

  final AuthRepository _repo;

  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    final u = await _repo.login(username.trim(), password);
    _loading = false;
    if (u == null) {
      _error = 'Username atau password salah.';
    } else {
      _user = u;
    }
    notifyListeners();
    return u != null;
  }

  void logout() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
