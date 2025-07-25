import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> saveTokens(String access, String refresh) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> clearTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // LOGIN (email or phone)
  Future<Map<String, dynamic>> login(String login, String password) async {
    final url = Uri.parse("${baseUrl}api/accounts/login/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"login": login, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokens(data['access'], data['refresh']);
      return data;
    } else {
      throw Exception('Échec de la connexion: ${response.body}');
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String password2,
  }) async {
    final url = Uri.parse("${baseUrl}api/accounts/register/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "password": password,
        "password2": password2,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur inscription: ${response.body}');
    }
  }

  // GET PROFILE
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('Utilisateur non connecté');

    final url = Uri.parse("${baseUrl}api/accounts/me/");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur récupération profil: ${response.body}');
    }
  }

  // GET CATEGORIES
  Future<List<dynamic>> getCategories() async {
    final url = Uri.parse("${baseUrl}api/menu/categories/");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur récupération catégories: ${response.body}');
    }
  }

  // GET MENU ITEMS (optionnel: filtrer par category id)
  Future<List<dynamic>> getMenuItems({int? categoryId}) async {
    String urlStr = "${baseUrl}api/menu/items/";
    if (categoryId != null) {
      urlStr += "?category=$categoryId";
    }
    final url = Uri.parse(urlStr);

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur récupération menu: ${response.body}');
    }
  }

  // LOGOUT (simple suppression des tokens)
  Future<void> logout() async {
    await clearTokens();
  }
}
