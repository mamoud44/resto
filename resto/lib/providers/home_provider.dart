import 'package:flutter/material.dart';
import 'package:resto/models/home_model.dart';
import 'package:resto/providers/home_provider.dart' as _homeService;
import 'package:resto/services/home_service.dart';

class HomeProvider with ChangeNotifier {
  final HomeService _homeService = HomeService();

  Future<List<HomMenu>> fetchHomeMenu() async {
    return await _homeService.fetchHomeMenu();
  }
}

Future<List<HomMenu>> fetchHomeMenu() async {
  return await _homeService.fetchHomeMenu();
}

List<HomMenu> get homeMenu => _homeService.homeMenu;
