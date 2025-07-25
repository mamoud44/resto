import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import '../../routes/app_routes.dart';

final pages = [
  const PageData(
    icon: Icons.fastfood_outlined,
    title: "Commandez vos plats préférés",
    subtitle: "Naviguez facilement et trouvez ce qui vous fait plaisir.",
    bgColor: Color(0xffB71C1C), // rouge foncé
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.shopping_cart_outlined,
    title: "Ajoutez-les au panier",
    subtitle: "Gérez vos choix sans effort, tout est sous contrôle.",
    bgColor: Color(0xffF44336), // rouge clair
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.delivery_dining,
    title: "Faites-vous livrer rapidement",
    subtitle: "On s’occupe du reste, savourez en toute tranquillité.",
    bgColor: Colors.white,
    textColor: Color(0xffB71C1C), // texte rouge sur fond blanc
    showButton: true,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        scaleFactor: 2,
        itemCount: pages.length,
        onChange: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        nextButtonBuilder: (context) {
          // Cacher le bouton "next" à la dernière page
          if (currentIndex == pages.length - 1) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Icon(Icons.navigate_next, size: screenWidth * 0.08),
          );
        },
        itemBuilder: (index) {
          final page = pages[index];
          return SafeArea(child: _Page(page: page));
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;
  final bool showButton;

  const PageData({
    this.title,
    this.subtitle,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
    this.showButton = false,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.textColor,
          ),
          child: Icon(page.icon, size: screenHeight * 0.1, color: page.bgColor),
        ),
        const SizedBox(height: 20),
        Text(
          page.title ?? "",
          style: TextStyle(
            color: page.textColor,
            fontSize: screenHeight * 0.035,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (page.subtitle != null)
          Text(
            page.subtitle!,
            style: TextStyle(
              color: page.textColor.withOpacity(0.85),
              fontSize: screenHeight * 0.02,
            ),
            textAlign: TextAlign.center,
          ),
        if (page.showButton) ...[
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: page.textColor,
              foregroundColor: page.bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Commencer",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ],
    );
  }
}
