import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CartService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/'));
  final _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async => await _storage.read(key: 'access');

  Future<void> _refreshToken() async {
    final refresh = await _storage.read(key: 'refresh');
    if (refresh == null) throw Exception("Aucun token de rafraîchissement");

    final response = await _dio.post(
      'accounts/token/refresh/',
      data: {'refresh': refresh},
    );
    await _storage.write(key: 'access', value: response.data['access']);
  }

  Future<Response> _requestWithRetry(
    Future<Response> Function(String token) request,
  ) async {
    String? token = await _getAccessToken();
    if (token == null) throw Exception("Token d'accès manquant");

    try {
      return await request(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _refreshToken();
        token = await _getAccessToken();
        return await request(token!);
      } else {
        rethrow;
      }
    }
  }

  Future<List<dynamic>> fetchCartItems() async {
    final response = await _requestWithRetry((token) {
      return _dio.get(
        'orders/orderitems/panier/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    });
    return response.data;
  }

  /// ✅ Retourne l’ID de l’article créé
  Future<int> addCartItem(Map<String, dynamic> payload) async {
    final response = await _requestWithRetry((token) {
      return _dio.post(
        'orders/orderitems/',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    });
    return response.data['id'];
  }

  Future<void> updateCartItem(int id, Map<String, dynamic> payload) async {
    await _requestWithRetry((token) {
      return _dio.put(
        'orders/orderitems/$id/',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    });
  }

  Future<void> deleteCartItem(int id) async {
    await _requestWithRetry((token) {
      return _dio.delete(
        'orders/orderitems/$id/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    });
  }

  Future<void> clearCart() async {
    await _requestWithRetry((token) {
      return _dio.delete(
        'orders/orderitems/vider/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    });
  }
}
