// lib/core/widgets/app_dialogs.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Dialog konfirmasi standar (2 tombol: Batal / OK)
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelLabel = 'Batal',
  String confirmLabel = 'OK',
  bool isDestructive = false, // kalau true, tombol merah
}) {
  final Color primary = AppColors.mainGradientStart;
  final Color confirmColor = isDestructive ? AppColors.error : primary;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.titleText,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          // Batal (flat)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelLabel,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Konfirmasi (pill merah)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              backgroundColor: confirmColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: AppTextStyles.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Dialog info / error 1 tombol (mis: "Data Belum Lengkap")
Future<void> showAppInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String buttonLabel = 'Tutup',
  bool isError = false,
}) {
  final Color accent = isError ? AppColors.error : AppColors.mainGradientStart;

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        title: Text(
          title,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.titleText,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                buttonLabel,
                style: AppTextStyles.body2.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
