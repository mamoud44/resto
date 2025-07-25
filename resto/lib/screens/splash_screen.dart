import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resto/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;

  /// Tu peux passer une callback pour la redirection à la fin
  const SplashScreen({super.key, this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _steamController;
  late final AnimationController _textFadeController;

  @override
  void initState() {
    super.initState();

    // Rotation continue cloche
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Vapeur (opacité + translation)
    _steamController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Texte fade in/out
    _textFadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Timer pour redirection après 3 sec
    Timer(const Duration(seconds: 20), () {
      if (widget.onFinished != null) {
        widget.onFinished!();
      } else {
        // Par défaut, pop ou redirige où tu veux :
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _steamController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = 150.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cloche + vapeur
            SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cloche tournante
                  RotationTransition(
                    turns: _rotationController,
                    child: CustomPaint(
                      size: Size(size, size),
                      painter: BellPainter(),
                    ),
                  ),

                  // Vapeur animée
                  Positioned(
                    top: size * 0.25,
                    child: AnimatedBuilder(
                      animation: _steamController,
                      builder: (context, child) {
                        double animValue = _steamController.value;
                        return Opacity(
                          opacity: animValue,
                          child: Transform.translate(
                            offset: Offset(0, -30 * animValue),
                            child: const SteamWidget(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Texte animé fade in/out
            FadeTransition(
              opacity: _textFadeController,
              child: const Text(
                "Savourez bientôt l'excellence : votre festin se prépare !",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dessin de la cloche de service (simplifiée)
class BellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.shade700
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;

    final center = Offset(width / 2, height / 2);

    // Base cloche (demi-cercle)
    final baseRect = Rect.fromCenter(
      center: center,
      width: width * 0.8,
      height: height * 0.6,
    );
    final basePath = Path()
      ..arcTo(baseRect, 0, 3.14, false)
      ..lineTo(center.dx + width * 0.4, center.dy + height * 0.3)
      ..lineTo(center.dx - width * 0.4, center.dy + height * 0.3)
      ..close();

    canvas.drawPath(basePath, paint);

    // Bouton en haut de la cloche (petit cercle)
    final buttonCenter = Offset(center.dx, center.dy - height * 0.3);
    canvas.drawCircle(
      buttonCenter,
      width * 0.08,
      paint..color = Colors.red.shade900,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Vapeur stylisée simple avec 3 courbes
class SteamWidget extends StatelessWidget {
  const SteamWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(40, 60), painter: SteamPainter());
  }
}

class SteamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(size.width * 0.3, size.height);
    path1.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.7,
      size.width * 0.4,
      size.height * 0.4,
    );
    path1.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.2,
      size.width * 0.3,
      0,
    );

    final path2 = Path();
    path2.moveTo(size.width * 0.6, size.height);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.6,
      size.width * 0.7,
      size.height * 0.3,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.1,
      size.width * 0.6,
      0,
    );

    final path3 = Path();
    path3.moveTo(size.width * 0.5, size.height);
    path3.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.5,
      size.width * 0.8,
      size.height * 0.2,
    );
    path3.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.05,
      size.width * 0.7,
      0,
    );

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
