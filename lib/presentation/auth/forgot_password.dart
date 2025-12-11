import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_textfield.dart';
// WAJIB import AuthService untuk memanggil fungsi reset password
import 'package:spareapp_unhas/data/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  // <-- Diubah menjadi StatefulWidget
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

/// Clipper yang sama seperti di halaman Login untuk membentuk curve merah
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ====================================================================
// STATE BARU (LOGIKA)
// ====================================================================
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false; // Status loading untuk tombol

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // --- FUNGSI KIRIM EMAIL RESET ---
  Future<void> _handleResetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Harap masukkan email Anda",
            style: AppTextStyles.body2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(email);

      if (mounted) {
        // Tampilkan Dialog Sukses
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Email Terkirim"),
            content: Text(
              "Link reset password telah dikirim ke $email.\n\nSilakan cek kotak masuk (Inbox) atau Spam Anda.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  // Kita tidak menutup halaman agar user bisa "Kirim Ulang"
                },
                child: const Text(
                  "OK",
                  style: TextStyle(color: AppColors.mainGradientStart),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll("Exception: ", "");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: AppTextStyles.body2.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // ===== BACKGROUND MERAH DENGAN SHAPE MELENGKUNG =====
          ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              height: screenHeight * 0.5,
              width: double.infinity,
              decoration: const BoxDecoration(gradient: AppColors.mainGradient),
            ),
          ),

          // ===== KONTEN =====
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // HEADER LOGO
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 24, right: 24),
                  child: Center(
                    child: Image.asset(
                      'lib/assets/icons/logo_no-bg.png',
                      width: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ===== CARD PUTIH (FORM) =====
                Transform.translate(
                  offset: const Offset(0, 16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.nonClassColor,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tombol Kembali (Back)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                                color: AppColors.secondaryText,
                              ),
                              label: Text(
                                'Kembali',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                overlayColor: AppColors.secondaryText
                                    .withOpacity(0.1),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Heading Center
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Lupa Kata Sandi?',
                                  style: AppTextStyles.heading1,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Masukkan email UNHAS anda\nuntuk melakukan verifikasi!',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Label Email
                          Text(
                            'Email',
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Input Email (pakai CustomTextField)
                          CustomTextField(
                            controller: emailController,
                            label: 'Masukkan email UNHAS Anda',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 28),

                          // Tombol Send Email: gradient seperti login, tapi label "Send Email"
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.mainGradient,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ElevatedButton(
                                // Panggil fungsi reset
                                onPressed: _isLoading
                                    ? null
                                    : _handleResetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  // Menonaktifkan tombol jika loading
                                  disabledBackgroundColor: Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Kirim Email',
                                        style: AppTextStyles.button1.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Text Kirim Ulang
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "Tidak menerima email? ",
                                  ),
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.baseline,
                                    baseline: TextBaseline.alphabetic,
                                    child: GestureDetector(
                                      // Logika Kirim Ulang (Sama dengan Kirim Email)
                                      onTap: _isLoading
                                          ? null
                                          : _handleResetPassword,
                                      child: Text(
                                        'Kirim ulang!',
                                        style: AppTextStyles.body2.copyWith(
                                          color: AppColors.mainGradientStart,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
