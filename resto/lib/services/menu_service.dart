import 'package:dio/dio.dart';
import 'package:resto/models/category_model.dart';
import '../models/menu_model.dart';

class MenuService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/'));

  Future<List<MenuItem>> fetchMenuItems({int? categoryId}) async {
    final response = await _dio.get(
      'menu/menu-items/',
      queryParameters: categoryId != null ? {'category': categoryId} : null,
    );
    final List data = response.data;
    return data.map((e) => MenuItem.fromJson(e)).toList();
  }

  Future<List<Category>> fetchCategories() async {
    final response = await _dio.get('menu/categories/');
    final List data = response.data;
    return data.map((e) => Category.fromJson(e)).toList();
  }
}
