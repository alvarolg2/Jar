import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jar/ui/common/app_colors.dart';

ThemeData getAppThemeData() {
  final textTheme = GoogleFonts.poppinsTextTheme();
  
  return ThemeData(
    primaryColor: kcBrandPrimary,
    primaryColorDark: kcBrandPrimaryDark,
    scaffoldBackgroundColor: kcBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kcBrandPrimary,
      primary: kcBrandPrimary,
      secondary: kcBrandAccent,
      background: kcBackground,
      surface: kcSurface,
      error: kcDefectiveColor,
      brightness: Brightness.light,
    ),
    
    // Tipografía
    textTheme: textTheme.copyWith(
      titleLarge: textTheme.titleLarge?.copyWith(
        color: kcTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: textTheme.titleMedium?.copyWith(
        color: kcTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: textTheme.bodyLarge?.copyWith(color: kcTextPrimary),
      bodyMedium: textTheme.bodyMedium?.copyWith(color: kcTextSecondary),
      labelLarge: textTheme.labelLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Tema de AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: kcBrandPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: Colors.white,
      ),
    ),
    
    // Tema de Botones
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kcBrandAccent,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kcBrandAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: textTheme.labelLarge,
      ),
    ),
    
    // Tema de Tarjetas (Cards)
    cardTheme: CardThemeData(
      color: kcSurface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Tema de Formularios
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kcSurface,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kcBrandAccent, width: 2),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(color: kcTextSecondary),
      helperStyle: textTheme.bodySmall?.copyWith(color: kcBrandAccent),
      floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: kcBrandAccent),
    ),
    
    // Tema de BottomSheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kcSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      elevation: 5,
    ),
  );
}