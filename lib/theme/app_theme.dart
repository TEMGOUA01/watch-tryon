import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales - Thème Dark & Gold Premium
  static const Color primaryColor = Color(0xFF0B0F1A); // Dark Midnight Blue (Background)
  static const Color secondaryColor = Color(0xFFD4AF37); // Aureus Gold (Accent)
  static const Color backgroundColor = Color(0xFF0B0F1A);
  static const Color surfaceColor = Color(0xFF1A2235); // Cartes et éléments surélevés
  static const Color surfaceLightColor = Color(0xFF121826); // Alt Cartes
  static const Color textPrimaryColor = Colors.white; // Blanc
  static const Color textSecondaryColor = Colors.grey; // Gris
  static const Color errorColor = Color(0xFFE53E3E); // Rouge vif
  static const Color successColor = Color(0xFF38A169); // Vert vif
  static const Color warningColor = Color(0xFFD69E2E); // Jaune

  // Couleurs de fond pour les écrans
  static const Color welcomeHeaderColor = primaryColor;
  static const Color loginHeaderColor = primaryColor;
  static const Color registrationHeaderColor = primaryColor;

  // Couleurs des boutons
  static const Color buttonPrimaryColor = secondaryColor;
  static const Color buttonSecondaryColor = surfaceColor;
  static const Color buttonOutlineColor = secondaryColor;

  // Couleurs des champs de saisie
  static const Color inputBackgroundColor = Color(0xFF121826);
  static const Color inputBorderColor = Color(0xFF1A2235);
  static const Color inputFocusColor = secondaryColor;

  // Couleurs des vagues de séparation
  static const Color waveColor = surfaceColor;

  // Dimensions et espacements
  static const double defaultPadding = 24.0;
  static const double smallPadding = 16.0;
  static const double largePadding = 32.0;
  static const double buttonHeight = 55.0;
  static const double borderRadius = 16.0;
  static const double largeBorderRadius = 24.0;

  // Ombres
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(color: Color(0x33000000), blurRadius: 15, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> lightShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  // Thème principal de l'application (Maintenant Sombre par défaut)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: secondaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: primaryColor,
        onSecondary: primaryColor,
        onSurface: textPrimaryColor,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: secondaryColor),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
          fontFamily: 'Montserrat', // Assurez-vous que cette police est chargée plus tard, ou laissez Roboto par défaut
        ),
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonPrimaryColor,
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 3,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonOutlineColor,
          side: const BorderSide(color: buttonOutlineColor, width: 2),
          minimumSize: const Size(double.infinity, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.transparent,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: inputFocusColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: const TextStyle(color: textSecondaryColor),
      ),

      // Cartes
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(largeBorderRadius),
          side: BorderSide(color: secondaryColor.withValues(alpha: 0.1), width: 1),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.4),
      ),

      // Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: secondaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
    );
  }

  // Styles de texte
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
    height: 1.4,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondaryColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  // Styles pour les écrans d'authentification
  static const TextStyle authTitleStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle authSubtitleStyle = TextStyle(
    fontSize: 16,
    color: textSecondaryColor,
    height: 1.4,
  );

  static const TextStyle welcomeTitleStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: secondaryColor,
  );

  static const TextStyle welcomeSubtitleStyle = TextStyle(
    fontSize: 18,
    color: textSecondaryColor,
    height: 1.4,
  );

  // --- NOUVEAUTÉS PREMIUM AUREUSGOLD ---

  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFF9F295), // Or clair
      Color(0xFFE0AA3E), // Or moyen
      Color(0xFFB8860B), // Or sombre
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration glassDecoration({double borderRadiusVal = 24.0}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(borderRadiusVal),
      border: Border.all(
        color: secondaryColor.withValues(alpha: 0.2), 
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 30,
          spreadRadius: -5,
        ),
      ],
    );
  }
}
