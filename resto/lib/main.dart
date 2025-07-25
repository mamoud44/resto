import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart'; // ✅ Import ajouté
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final isLoggedIn = await authProvider.initialize();

  final cartProvider = CartProvider();
  if (isLoggedIn) {
    await cartProvider.syncFromBackend(); // 🔁 Synchronisation du panier
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<MenuProvider>(create: (_) => MenuProvider()),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ), // ✅ Ajout ici
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Xalafood',
      theme: appTheme,
      home: isLoggedIn ? const SplashScreen() : const OnboardingScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page non trouvée"))),
        );
      },
    );
  }
}
