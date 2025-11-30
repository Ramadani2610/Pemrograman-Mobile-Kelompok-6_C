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
  static const Color border = Color(0xFFDADADA);

  static const Color noButton = Color(0xFFDADADA);

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
    'Teknik Sipil': Color(0xFFFEF100),
    'Teknik Mesin': Color(0xFF152456),
    'Teknik Perkapalan': Color(0xFFF07400),
    'Teknik Elektro': Color(0xFF237618),
    'Arsitektur': Color(0xFFAAAEB6),
    'Teknik Geologi': Color(0xFF63330A),
    'Teknik Industri': Color(0xFFDF0000),
    'Teknik Kelautan': Color(0xFF86CDF9),
    'Teknik Sistem Perkapalan': Color(0xFFBE01FE),
    'PWK': Color(0xFFF0E78D),
    'Teknik Pertambangan': Color(0xFF974A00),
    'Teknik Informatika': Color(0xFF2EA7F7),
    'Teknik Lingkungan': Color(0xFFB1FF99),
    'Teknik Metalurgi dan Material': Color(0xFFFF6B6D),
    'Teknik Geodesi': Color(0xFF292824),
};

/// Ambil warna berdasarkan nama
static Color getDepartmentColor(String deptName) {
    return departmentColors[deptName] ?? Colors.grey;
  }
}