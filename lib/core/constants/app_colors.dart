import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // MAIN COLORS
  static const Color mainGradientStart = Color(0xFFAD0001);
  static const Color mainGradientEnd = Color(0xFFF26C4E);
  static const Color backgroundColor = Color(0xFFFFFFFF);

  // GRADIENT
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mainGradientStart, mainGradientEnd],
    stops: [0.23, 1.00],
  );
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF19612B), Color(0xFF34C759)],
    stops: [0.00, 1.00]
  );
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0E00AD), Color(0xFF4EA0F2)],
    stops: [0.23, 1.00]
  );

  /// NEUTRALS
  static const Color titleText = Colors.black;
  static const Color secondaryText = Color(0xFF979797);

  static const Color noButton = Color(0xFFDADADA) ;

  // STATUS COLOR
  static const Color success = Color(0xFF43A047); // hijau
  static const Color warning = Color(0xFFF9A825); // kuning
  static const Color error = Color(0xFFD32F2F);   // merah error
  static const Color info = Color(0xFF1976D2);    // biru info

  // CARD TEMPLATE
  static const Color cardBackground = Colors.white;
  static const Color cardBorder = Color(0xFFAD0001);
  static const Color cardShadow = Color(0x5CBB452F);

  // CLASS CATEGORY : NON-CLASS
  static const Color nonClassColor = Color(0xFF979797);

  // CLASS CATEGORY : LECTURE CLASS
  // Key warna departemen

  static const Map<String, Color> departmentColors = {
    'Teknik Sipil': Color(0xFF1E88E5),
    'Teknik Mesin': Color(0xFFF4511E),
    'Teknik Perkapalan': Color(0xFF00897B),
    'Teknik Elektro': Color(0xFFFFB300),
    'Arsitektur': Color(0xFF8E24AA),
    'Teknik Geologi': Color(0xFF5D4037),
    'Teknik Industri': Color(0xFF3949AB),
    'Teknik Kelautan': Color(0xFF00ACC1),
    'Teknik Sistem Perkapalan': Color(0xFF6D4C41),
    'PWK': Color(0xFF7CB342),
    'Teknik Pertambangan': Color(0xFF6A1B9A),
    'Teknik Informatika': Color(0xFFEF6C00),
    'Teknik Lingkungan': Color(0xFF2E7D32),
    'Teknik Metalurgi dan Material': Color(0xFF757575),
    'Teknik Geodesi': Color(0xFF00838F),
};

/// Ambil warna berdasarkan nama
static Color getDepartmentColor(String deptName) {
    return departmentColors[deptName] ?? Colors.grey;
  }
}