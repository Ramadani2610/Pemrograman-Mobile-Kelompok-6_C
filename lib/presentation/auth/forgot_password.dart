import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_textfield.dart';
// WAJIB import AuthService untuk memanggil fungsi reset password
import 'package:spareapp_unhas/data/services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false; 

  // Warna Merah Spesifik sesuai Gambar
  final Color _brandRed = const Color(0xFFD32F2F); 

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
        // Tampilkan Dialog Sukses Sesuai Desain Gambar
        _showImageStyleDialog(email);
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

  // --- IMPLEMENTASI DIALOG SESUAI GAMBAR ---
  void _showImageStyleDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.white,
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Ikon Amplop dalam Lingkaran Pink Lembut
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _brandRed.withOpacity(0.08), // Pink sangat muda
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    size: 48,
                    color: _brandRed,
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Judul "Cek Email Anda!"
                Text(
                  'Cek Email Anda!',
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // 3. Deskripsi
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.secondaryText, // Abu-abu
                      height: 1.5,
                      fontSize: 13,
                    ),
                    children: [
                      const TextSpan(text: 'Kami telah mengirimkan instruksi reset password ke:\n'),
                      TextSpan(
                        text: email,
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 4. Tombol OKE (Merah Solid)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandRed, // Merah Solid sesuai gambar
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Rounded penuh
                      ),
                    ),
                    child: const Text(
                      'OKE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 5. Teks "Belum menerima email?"
                Text(
                  "Belum menerima email?",
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                
                // 6. Tombol "Kirim Ulang" (Outline Merah)
                SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      _handleResetPassword(); // Kirim ulang
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: _brandRed, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    child: Text(
                      "Kirim Ulang",
                      style: TextStyle(
                        color: _brandRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

                          // Input Email
                          CustomTextField(
                            controller: emailController,
                            label: 'Masukkan email UNHAS Anda',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 28),

                          // Tombol Send Email
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.mainGradient,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : _handleResetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
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

                          // Text Kirim Ulang (Menggunakan TextSpan biasa karena tombol ada di dialog)
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Tidak menerima email? ",
                                  ),
                                  // Kita hapus tombol klik di sini karena sudah ada di Dialog
                                  // agar user fokus klik tombol Kirim Email dulu
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

// Clipper untuk Background Merah (Tetap sama)
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