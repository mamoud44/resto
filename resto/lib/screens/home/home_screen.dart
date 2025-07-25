import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resto/screens/home/pages/cart_page.dart';
import 'package:resto/screens/home/pages/explore_page.dart';
import 'package:resto/screens/home/pages/profile_page.dart';
import 'package:resto/screens/menu/daily_menu.dart';
import 'package:resto/screens/menu/menu_page.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0}); // 👈 index par défaut

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    ExplorePage(userName: '', userLocation: ''),
    MenuPage(),
    CartPage(),
    DailyMenuPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // 👈 initialise avec l’index reçu
  }

  @override
  Widget build(BuildContext context) {
    final Color redColor = Colors.red.shade700;
    final Color whiteColor = Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,

        body: IndexedStack(index: _selectedIndex, children: _pages),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: redColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: BottomNavigationBar(
              backgroundColor: redColor,
              selectedItemColor: whiteColor,
              unselectedItemColor: whiteColor.withOpacity(0.7),
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu),
                  label: 'Menu',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Panier',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.today),
                  label: 'Menu du jour',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
