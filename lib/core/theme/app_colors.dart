import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFF3A72F8);
  static const Color primaryLight = Color(0xFF9EBBFF);
  static const Color secondary = Color(0xFFBBAAFF);
  static const Color secondaryLight = Color(0xFFD6D6FF);
  
  // Фоны
  static const Color background = Color(0xFFFAFBFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Текст
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  
  // Акценты
  static const Color accent = Color(0xFF00C896);
  static const Color accentLight = Color(0xFFE8F5F2);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF4D4D);
  
  // Границы и разделители
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF0F0F0);
  
  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3A72F8), Color(0xFF9EBBFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFBBAAFF), Color(0xFFD6D6FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFFE8F5F2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFB020), Color(0xFFFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
