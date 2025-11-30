import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  /// errorText: kalau tidak null → border merah + teks error ditampilkan
  final String? errorText;

  /// path aset untuk icon eye (opsional, default pakai nama di bawah)
  final String eyeVisibleAsset;
  final String eyeHiddenAsset;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.errorText,
    this.eyeVisibleAsset = 'assets/icons/eye_visible.png',
    this.eyeHiddenAsset = 'assets/icons/eye_hidden.png',
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscurePassword = true;
  bool _hasFocus = false;

  @override
  Widget build(BuildContext context) {
    final bool isPasswordField = widget.obscureText;
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    // Tentukan dekorasi border luar (AnimatedContainer)
    Gradient? outerGradient;
    Color? outerColor;

    if (hasError) {
      // PRIORITAS: error → border merah
      outerGradient = null;
      outerColor = AppColors.error;
    } else if (_hasFocus) {
      // Fokus → border gradient
      outerGradient = AppColors.mainGradient;
      outerColor = null;
    } else {
      // Default → border abu-abu
      outerGradient = null;
      outerColor = AppColors.border;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (focus) {
            setState(() {
              _hasFocus = focus;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              gradient: outerGradient,
              color: outerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: widget.controller,
                obscureText: isPasswordField ? _obscurePassword : false,
                keyboardType: widget.keyboardType,
                style: AppTextStyles.body1,
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: AppTextStyles.body2,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),

                  // prefix icon (opsional)
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _hasFocus
                              ? AppColors.mainGradientStart
                              : AppColors.secondaryText,
                        )
                      : null,

                  // suffix icon: eye toggle pakai aset kalau field password
                  suffixIcon: isPasswordField
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Image.asset(
                              _obscurePassword
                                  ? widget.eyeHiddenAsset
                                  : widget.eyeVisibleAsset,
                              width: 20,
                              height: 20,
                              color: _hasFocus
                                  ? AppColors.mainGradientStart
                                  : AppColors.secondaryText,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),

        // Teks error di bawah field (jika ada)
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
