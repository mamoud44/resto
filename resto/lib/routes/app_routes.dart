import 'package:flutter/material.dart';
import 'package:resto/models/menu_model.dart';
import 'package:resto/models/order_summary_model.dart';
import 'package:resto/screens/auth/login_screen.dart';
import 'package:resto/screens/auth/signup_screen.dart';
import 'package:resto/screens/home/home_screen.dart';
import 'package:resto/screens/home/pages/bonus_page.dart';
import 'package:resto/screens/home/pages/cart_page.dart';
import 'package:resto/screens/home/pages/order_detail_page.dart';
import 'package:resto/screens/home/pages/orders_page.dart';
import 'package:resto/screens/home/pages/profile_page.dart';
import 'package:resto/screens/menu/daily_menu.dart' hide MenuItem;
import 'package:resto/screens/menu/menu_detail_page.dart';
import 'package:resto/screens/menu/menu_page.dart' show MenuPage;
import 'package:resto/screens/onboarding/onboarding_screen.dart';
import 'package:resto/screens/splash_screen.dart';

class AppRoutes {
  // Routes nommées
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String dailyMenu = '/daily-menu';
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';
  static const String bonus = '/bonus';
  static const String profil = '/profil';
  static const String menuDetail = '/menu-detail';
  static const String cart = '/cart';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    late Widget page;

    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case onboarding:
        page = const OnboardingScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case signup:
        page = const SignupScreen();
        break;
      case home:
        page = const HomeScreen();
        break;
      case menu:
        page = const MenuPage();
        break;
      case dailyMenu:
        page = const DailyMenuPage();
        break;
      case cart:
        page = const CartPage();
        break;
      case orders:
        page = const OrdersPage();
        break;
      case orderDetail:
        final order = settings.arguments as OrderSummary; // ✅ Cast correct
        page = OrderDetailPage(order: order);
        break;

      case bonus:
        page = const BonusPage();
        break;
      case profil:
        page = const ProfilePage();
        break;
      case menuDetail:
        final menuItem = settings.arguments as MenuItem;
        page = MenuDetailPage(item: menuItem);
        break;
      default:
        return null;
    }

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
