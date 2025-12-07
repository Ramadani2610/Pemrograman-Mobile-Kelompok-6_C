import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_textfield.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // ===== BACKGROUND MERAH DENGAN SHAPE MELENGKUNG (SAMA SEPERTI LOGIN) =====
          ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              height: screenHeight * 0.5,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.mainGradient,
              ),
            ),
          ),

          // ===== KONTEN =====
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // HEADER: LOGO FULL SPARE DI TENGAH (opsional, sama seperti login)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 24, right: 24),
                  child: Center(
                    child: Image.asset(
                      'lib/assets/icons/logo_no-bg.png', // sesuaikan dengan path Prof
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
                          // === Back row (← Back) di atas kiri ===
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  // fallback kalau nanti halaman ini dibuka pakai pushReplacement
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
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
                                overlayColor: AppColors.secondaryText.withOpacity(0.1),
                              ),
                            ),
                          ),
const SizedBox(height: 16),

                          const SizedBox(height: 16),

                          // === Heading center ===
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
                                onPressed: () {
                                  // TODO: panggil API kirim email reset
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  'Kirim Email',
                                  style: AppTextStyles.button1.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // "Didn't get your email?  Resend!"
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
                                      onTap: () {
                                        // TODO: trigger resend
                                      },
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
