import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GradientWidgets {
  GradientWidgets._();
}

// Styling text berwarna maintGradient
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    Gradient? gradient,
  }) : gradient = gradient ?? AppColors.mainGradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

// Styling icon
class GradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;

  const GradientIcon({
    super.key,
    required this.icon,
    this.size = 24,
    Gradient? gradient,
  }) : gradient = gradient ?? AppColors.mainGradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}


// styling button 
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  final Gradient gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  
  final double? width;
  final double? height;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradient = AppColors.mainGradient,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.textStyle,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextStyle = textStyle ??
        const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        );

    final buttonContent = Center(
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(label, style: effectiveTextStyle),
    );

    return Opacity(
      opacity: (onPressed == null || isLoading) ? 0.7 : 1.0,
      child: InkWell(
        onTap: (onPressed == null || isLoading) ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: width,  
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: buttonContent,
        ),
      ),
    );
  }
}
