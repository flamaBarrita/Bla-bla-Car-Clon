import 'package:flutter/material.dart';

/// Paleta de colores Anahuac Oaxaca - Tema Light Profesional
class AnahuacColors {
  // Colores primarios
  static const Color PRIMARY_ORANGE = Color(0xFFE85D2B); // Naranja intenso Anáhuac
  static const Color PRIMARY_ORANGE_DARK = Color(0xFFD04A1A); // Naranja oscuro para hover
  static const Color PRIMARY_ORANGE_LIGHT = Color(0xFFF5DCD4); // Naranja muy claro para fondos

  // Colores de fondo y texto
  static const Color BACKGROUND_WHITE = Colors.white;
  static const Color TEXT_DARK = Color(0xFF2C2C2C); // Gris muy oscuro (nunca negro puro)
  static const Color TEXT_SECONDARY = Color(0xFF666666); // Gris medio
  static const Color TEXT_LIGHT = Color(0xFF999999); // Gris claro

  // Colores neutrales
  static const Color NEUTRAL_LIGHT_BG = Color(0xFFF8F8F8); // Gris muy claro para fondos
  static const Color NEUTRAL_BORDER = Color(0xFFE0E0E0); // Gris para bordes
  static const Color NEUTRAL_DIVIDER = Color(0xFFD9D9D9); // Gris para divisores

  // Colores de estado
  static const Color SUCCESS_GREEN = Color(0xFF4CAF50); // Verde profesional
  static const Color SUCCESS_LIGHT = Color(0xFFC8E6C9); // Verde claro
  static const Color ERROR_RED = Color(0xFFE74C3C); // Rojo profesional
  static const Color ERROR_LIGHT = Color(0xFFFFCDD2); // Rojo claro
  static const Color WARNING_AMBER = Color(0xFFFFC107); // Ámbar para advertencias
  static const Color INFO_BLUE = Color(0xFF2196F3); // Azul para información

  // Sombras sutiles
  static const CvShadow = BoxShadow(
    color: Colors.black,
    blurRadius: 8,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );
}

/// Definición completa de ThemeData para el diseño Anahuac Oaxaca
ThemeData buildAnahuacTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color principal
    primaryColor: AnahuacColors.PRIMARY_ORANGE,
    scaffoldBackgroundColor: AnahuacColors.BACKGROUND_WHITE,

    // App Bar con fondo blanco y acentos naranjas
    appBarTheme: AppBarTheme(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AnahuacColors.PRIMARY_ORANGE),
      titleTextStyle: const TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
      centerTitle: false,
    ),

    // Card con diseño limpio y sombra sutil
    cardTheme: CardThemeData(
      color: AnahuacColors.BACKGROUND_WHITE,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AnahuacColors.NEUTRAL_BORDER,
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
    ),

    // Colores generales
    colorScheme: ColorScheme.light(
      primary: AnahuacColors.PRIMARY_ORANGE,
      primaryContainer: AnahuacColors.PRIMARY_ORANGE_LIGHT,
      secondary: AnahuacColors.TEXT_SECONDARY,
      tertiary: AnahuacColors.NEUTRAL_LIGHT_BG,
      surface: AnahuacColors.BACKGROUND_WHITE,
      surfaceContainerHighest: AnahuacColors.NEUTRAL_LIGHT_BG,
      error: AnahuacColors.ERROR_RED,
      errorContainer: AnahuacColors.ERROR_LIGHT,
    ),

    // Text Theme con jerarquía clara
    textTheme: const TextTheme(
      // Títulos grandes
      displayLarge: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
      displaySmall: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),

      // Títulos medianos
      headlineLarge: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      headlineMedium: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      headlineSmall: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),

      // Texto de cuerpo
      bodyLarge: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
      bodyMedium: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),
      bodySmall: TextStyle(
        color: AnahuacColors.TEXT_SECONDARY,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      ),

      // Etiquetas y detalles
      labelLarge: TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        color: AnahuacColors.TEXT_SECONDARY,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: TextStyle(
        color: AnahuacColors.TEXT_LIGHT,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),

    // Botones primarios - Naranja Anáhuac
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AnahuacColors.PRIMARY_ORANGE,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AnahuacColors.PRIMARY_ORANGE.withOpacity(0.4),
        disabledForegroundColor: Colors.white.withOpacity(0.6),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        shadowColor: AnahuacColors.PRIMARY_ORANGE.withOpacity(0.3),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Botones secundarios - Outline
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AnahuacColors.PRIMARY_ORANGE,
        side: const BorderSide(
          color: AnahuacColors.PRIMARY_ORANGE,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Botones de texto
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AnahuacColors.PRIMARY_ORANGE,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    ),

    // Input Fields - Fondos claros con bordes sutiles
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AnahuacColors.NEUTRAL_LIGHT_BG,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: AnahuacColors.TEXT_SECONDARY,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: AnahuacColors.TEXT_LIGHT,
        fontSize: 14,
      ),
      prefixIconColor: AnahuacColors.PRIMARY_ORANGE,
      suffixIconColor: AnahuacColors.TEXT_SECONDARY,
      errorStyle: const TextStyle(
        color: AnahuacColors.ERROR_RED,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AnahuacColors.NEUTRAL_BORDER,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AnahuacColors.NEUTRAL_BORDER,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AnahuacColors.PRIMARY_ORANGE,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AnahuacColors.ERROR_RED,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AnahuacColors.ERROR_RED,
          width: 2,
        ),
      ),
    ),

    // Tab Bar con estilo profesional
    tabBarTheme: const TabBarThemeData(
      labelColor: AnahuacColors.PRIMARY_ORANGE,
      unselectedLabelColor: AnahuacColors.TEXT_SECONDARY,
      indicatorColor: AnahuacColors.PRIMARY_ORANGE,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        letterSpacing: 0.2,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: AnahuacColors.NEUTRAL_BORDER,
      thickness: 0.5,
      space: 1,
    ),

    // Icons
    iconTheme: const IconThemeData(
      color: AnahuacColors.PRIMARY_ORANGE,
      size: 24,
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AnahuacColors.PRIMARY_ORANGE;
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: AnahuacColors.NEUTRAL_BORDER),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio Button
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AnahuacColors.PRIMARY_ORANGE;
        }
        return AnahuacColors.NEUTRAL_BORDER;
      }),
    ),

    // Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      selectedItemColor: AnahuacColors.PRIMARY_ORANGE,
      unselectedItemColor: AnahuacColors.TEXT_LIGHT,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AnahuacColors.PRIMARY_ORANGE;
        }
        return AnahuacColors.NEUTRAL_BORDER;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AnahuacColors.PRIMARY_ORANGE.withOpacity(0.3);
        }
        return AnahuacColors.NEUTRAL_BORDER.withOpacity(0.3);
      }),
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AnahuacColors.PRIMARY_ORANGE,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AnahuacColors.TEXT_DARK,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AnahuacColors.BACKGROUND_WHITE,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: const TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: AnahuacColors.TEXT_DARK,
        fontSize: 14,
      ),
    ),
  );
}
