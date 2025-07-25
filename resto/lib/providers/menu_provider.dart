import 'package:flutter/material.dart';
import 'package:resto/models/category_model.dart';
import 'package:resto/models/menu_model.dart' show MenuItem;
import 'package:resto/services/menu_service.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _menuService = MenuService();

  List<MenuItem> _items = [];
  List<Category> _categories = [];

  List<MenuItem> get items => _items;
  List<Category> get categories => _categories;

  Future<void> loadMenu({int? categoryId}) async {
    _items = await _menuService.fetchMenuItems(categoryId: categoryId);
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _menuService.fetchCategories();
    notifyListeners();
  }

  List<MenuItem> filterByCategory(int categoryId) {
    return _items.where((item) => item.categoryId == categoryId).toList();
  }
}
