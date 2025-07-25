import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/'));
  final _storage = const FlutterSecureStorage();

  /// Inscription d’un nouvel utilisateur
  Future<void> register(Map<String, dynamic> data) async {
    await _dio.post('accounts/register/', data: data);
  }

  /// Connexion utilisateur
  Future<Map<String, dynamic>> login(String login, String password) async {
    final response = await _dio.post(
      'accounts/login/',
      data: {'login': login, 'password': password},
    );

    final access = response.data['access'];
    final refresh = response.data['refresh'];

    await _storage.write(key: 'access', value: access);
    await _storage.write(key: 'refresh', value: refresh);

    return response.data['user'];
  }

  /// Rafraîchit le token d’accès à partir du refresh token
  Future<void> refreshToken() async {
    final refresh = await _storage.read(key: 'refresh');
    if (refresh == null) throw Exception("Aucun token de rafraîchissement");

    final response = await _dio.post(
      'accounts/token/refresh/',
      data: {'refresh': refresh},
    );

    final newAccess = response.data['access'];
    await _storage.write(key: 'access', value: newAccess);
  }

  /// Récupération du profil utilisateur avec tentative de rafraîchissement
  Future<UserModel> getProfile() async {
    String? token = await _storage.read(key: 'access');
    if (token == null) throw Exception("Aucun token trouvé");

    try {
      final response = await _dio.get(
        'accounts/me/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await refreshToken();
        token = await _storage.read(key: 'access');
        final retry = await _dio.get(
          'accounts/me/',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        return UserModel.fromJson(retry.data['user']);
      } else {
        rethrow;
      }
    }
  }

  /// Mise à jour du profil avec gestion du token expiré
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    String? token = await _storage.read(key: 'access');

    try {
      final response = await _dio.put(
        'accounts/me/update/',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await refreshToken();
        token = await _storage.read(key: 'access');
        final retry = await _dio.put(
          'accounts/me/update/',
          data: data,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        return UserModel.fromJson(retry.data['user']);
      } else {
        rethrow;
      }
    }
  }

  /// Changement de mot de passe avec gestion du token expiré
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    String? token = await _storage.read(key: 'access');

    try {
      await _dio.post(
        'accounts/change-password/',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await refreshToken();
        token = await _storage.read(key: 'access');
        await _dio.post(
          'accounts/change-password/',
          data: {
            'current_password': currentPassword,
            'new_password': newPassword,
          },
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } else {
        rethrow;
      }
    }
  }

  /// Déconnexion (suppression des tokens)
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// Vérifie si un token est présent (utile pour l’écran d’accueil dynamique)
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access');
    return token != null;
  }
}
