import 'package:dio/dio.dart';
import 'package:resto/models/home_model.dart';

class HomeService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/'));

  Future<List<HomMenu>> fetchHomeMenu() async {
    final response = await _dio.get('menu/home-menu/');
    final List data = response.data;
    return data.map((e) => HomMenu.fromJson(e)).toList();
  }
}
