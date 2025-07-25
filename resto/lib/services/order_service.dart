import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:resto/models/order_summary_model.dart';

class OrderService {
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
    debugPrint("🔄 Nouveau token d'accès rafraîchi");
  }

  Future<Response> _requestWithRetry(
    Future<Response> Function(String token) request,
  ) async {
    String? token = await _getAccessToken();
    debugPrint("🔐 Token utilisé : $token");
    if (token == null) throw Exception("Token d'accès manquant");

    try {
      return await request(token);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint("⚠️ Token expiré, tentative de rafraîchissement...");
        await _refreshToken();
        token = await _getAccessToken();
        return await request(token!);
      } else {
        debugPrint(
          "❌ Erreur Dio : ${e.response?.statusCode} - ${e.response?.data}",
        );
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> submitOrder(Map<String, dynamic> payload) async {
    final response = await _requestWithRetry((token) {
      return _dio.post(
        'orders/orders/',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    });
    return response.data;
  }

  Future<Map<String, dynamic>> fetchOrderDetails(int orderId) async {
    final response = await _requestWithRetry((token) {
      return _dio.get(
        'orders/orders/$orderId/details/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    });
    return response.data;
  }

  Future<List<OrderSummary>> fetchOrderSummariesTyped() async {
    final response = await _requestWithRetry((token) {
      return _dio.get(
        'orders/orders/recap/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    });

    return List<Map<String, dynamic>>.from(
      response.data,
    ).map((json) => OrderSummary.fromJson(json)).toList();
  }
}
