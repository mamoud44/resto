import 'package:flutter/material.dart';
import 'package:resto/models/user_model.dart';
import 'package:resto/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> login(String login, String password) async {
    final userData = await _authService.login(login, password);
    _user = UserModel.fromJson(userData);
    notifyListeners();
  }

  Future<void> register(Map<String, dynamic> data) async {
    await _authService.register(data);
  }

  Future<void> loadProfile() async {
    _user = await _authService.getProfile();
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final updatedUser = await _authService.updateProfile(data);
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _authService.changePassword(currentPassword, newPassword);
  }

  /// Initialise l'utilisateur au démarrage de l'app
  Future<bool> initialize() async {
    try {
      _user = await _authService.getProfile();
      notifyListeners();
      return true;
    } catch (_) {
      _user = null;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _authService.logout();
    _user = null;
    notifyListeners();
  }
}
