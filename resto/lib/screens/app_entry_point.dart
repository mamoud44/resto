import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resto/screens/splash_screen.dart';
import '../providers/auth_provider.dart';
import '../screens/onboarding/onboarding_screen.dart';

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLoggedIn = Provider.of<AuthProvider>(context).user != null;
    return isLoggedIn ? const SplashScreen() : const OnboardingScreen();
  }
}
