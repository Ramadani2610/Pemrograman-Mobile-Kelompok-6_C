import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Poppins';

  // HEADINGS
  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 48 / 32,
    color: AppColors.titleText,
  );

  // Sub judul / section title 
  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 48 / 24,
    color: AppColors.titleText,
  );

  // Judul kecil / Card Title
  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 32 / 18,
  );

  // Highlight Title User
  static const TextStyle highlightTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 38 / 32,
  );

  /// Button utama
  static const TextStyle button1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, 
    height: 24 / 16,             
    letterSpacing: 0.3,
    color: Colors.white,        
  );

  /// Button kecil 
  static const TextStyle button2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w500, 
    height: 12 / 8,              
    letterSpacing: 0.3,
    color: Colors.white,         
  );



}