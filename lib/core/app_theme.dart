import 'package:flutter/material.dart';

class AppColors {
  static const blue        = Color(0xFF003189);
  static const blueLight   = Color(0xFF1A73E8);
  static const blueSurface = Color(0xFFE8F0FE);
  static const red         = Color(0xFFE1000F);
  static const white       = Colors.white;
  static const background  = Color(0xFFF0F2F5);
  static const grey        = Color(0xFF6B7280);
  static const border      = Color(0xFFE5E7EB);
  static const text        = Color(0xFF111827);
  static const textMedium  = Color(0xFF374151);
  static const greyLight   = Color(0xFFF3F4F6);
  static const amber       = Color(0xFFF59E0B);
  static const amberSurface = Color(0xFFFEF3C7);
  static const green       = Color(0xFF18753C);
  static const greenSurface = Color(0xFFE8F5E9);
  static const purple      = Color(0xFF7C3AED);
  static const purpleSurface = Color(0xFFE8D5F5);
}

class AppText {
  static const h1 = TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.blue);
  static const h2 = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.blue);
  static const h3 = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text);
  static const sectionTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.blue);
  static const body = TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.5);
  static const small = TextStyle(fontSize: 12, color: AppColors.grey);
  static const caption = TextStyle(fontSize: 11, color: AppColors.grey);
  static const link = TextStyle(fontSize: 13, color: AppColors.blueLight, fontWeight: FontWeight.w600);
  static const label = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text);
}

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.blue, primary: AppColors.blue),
  scaffoldBackgroundColor: AppColors.background,
  useMaterial3: true,
);