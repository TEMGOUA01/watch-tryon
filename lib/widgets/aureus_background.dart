import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AureusBackground extends StatelessWidget {
  final Widget child;
  const AureusBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Orb doré en haut à gauche
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryColor.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Orb doré en bas à droite
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Filtre de flou très intense pour l'effet "Glow" (Glassmorphism)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: const SizedBox(),
            ),
          ),
          // Contenu par dessus
          SafeArea(child: child),
        ],
      ),
    );
  }
}
