import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aureus_background.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AureusBackground(
      child: Column(
        children: [
          // Logo Section
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: AppTheme.secondaryColor,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'AureusGold',
                  style: AppTheme.welcomeTitleStyle.copyWith(
                    fontSize: 40,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'L\'excellence de l\'investissement',
                  style: AppTheme.welcomeSubtitleStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Action Section (Glassmorphism Card)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              decoration: AppTheme.glassDecoration(
                borderRadiusVal: 40.0,
              ).copyWith(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'BIENVENUE',
                            style: AppTheme.welcomeTitleStyle.copyWith(
                              fontSize: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Découvrez le marché de l\'or et investissez dans votre avenir financier avec notre plateforme premium.',
                            style: AppTheme.welcomeSubtitleStyle.copyWith(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Login Button with Gradient
                          Container(
                            width: double.infinity,
                            height: AppTheme.buttonHeight,
                            decoration: BoxDecoration(
                              gradient: AppTheme.goldGradient,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              child: const Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Register Button Outline
                          SizedBox(
                            width: double.infinity,
                            height: AppTheme.buttonHeight,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.secondaryColor,
                                side: BorderSide(
                                  color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                                );
                              },
                              child: const Text("S'inscrire"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
