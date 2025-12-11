import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;

  /// kalau tidak null → tampil border merah + text error
  final String? errorText;

  // --- PERBAIKAN: Tambahkan parameter autofillHints ---
  final Iterable<String>? autofillHints;
  // ---------------------------------------------------

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.errorText,
    this.autofillHints, // <-- Tambahkan ke konstruktor
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscurePassword = true;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    // kalau bukan field password, tidak perlu obscure
    if (!widget.obscureText) {
      _obscurePassword = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPasswordField = widget.obscureText;
    final bool hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    // tentukan border luar: normal / gradient / error
    Gradient? outerGradient;
    Color? outerColor;

    if (hasError) {
      outerGradient = null;
      outerColor = AppColors.error;
    } else if (_hasFocus) {
      outerGradient = AppColors.mainGradient;
      outerColor = null;
    } else {
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

                // --- PERBAIKAN: Meneruskan autofillHints ---
                autofillHints: widget.autofillHints,

                // ------------------------------------------
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: AppTextStyles.body2,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),

                  // prefix icon opsional
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _hasFocus
                              ? AppColors.mainGradientStart
                              : AppColors.secondaryText,
                        )
                      : null,

                  // 👁 eye toggle pakai Material Icons
                  suffixIcon: isPasswordField
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: _hasFocus
                                ? AppColors.mainGradientStart
                                : AppColors.secondaryText,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),

        // teks error di bawah field
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
