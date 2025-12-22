import 'package:flutter/material.dart';

class AppColors {
  // Sapphire Veil Palette
  static const Color primary = Color(0xFF0F52BA); // Sapphire Blue
  static const Color primaryDark = Color(0xFF0A3D8F); // Darker Sapphire
  static const Color primaryLight = Color(0xFF4C89E3); // Lighter Blue
  
  static const Color accent = Color(0xFF00CED1); // Dark Turquoise / Neon Teal
  static const Color accentSecondary = Color(0xFFFFD700); // Gold for premium feel
  
  // Backgrounds
  static const Color background = Color(0xFFF0F4F8); // Very light cool blue-grey
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  
  // Text
  static const Color text = Color(0xFF1E293B); // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textLight = Colors.white; // For dark backgrounds

  // Functional
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  
  // Legacy mappings (preserving for compatibility)
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF94A3B8);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F52BA), Color(0xFF0A3D8F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}