import 'package:flutter/material.dart';
import 'package:spareapp_unhas/data/services/route_guard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Import ini untuk Autofill

// --- TAMBAHAN IMPORT BARU ---
import 'package:spareapp_unhas/data/services/auth_service.dart';
import 'package:spareapp_unhas/data/models/user_model.dart';
// ----------------------------

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/custom_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

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

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final remember = prefs.getBool('remember_me') ?? false;
      if (remember) {
        final savedUsername = prefs.getString('saved_username') ?? '';
        final savedPassword = prefs.getString('saved_password') ?? '';
        if (mounted) {
          setState(() {
            _rememberMe = true;
            _usernameController.text = savedUsername;
            _passwordController.text = savedPassword;
          });
        }
      }
    } catch (e) {
      // ignore errors silently for now
    }
  }

  // ===== LOGIC LOGIN DENGAN PERBAIKAN AUTOFILL =====
  void _handleLogin() async {
    // 1. Validasi Input Kosong
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Username/NIM dan Kata Sandi tidak boleh kosong',
            style: AppTextStyles.body2.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Panggil Service Login Firebase
      final AuthService authService = AuthService();

      UserModel user = await authService.loginWithNim(
        nim: _usernameController.text,
        password: _passwordController.text,
      );

      // --- PERBAIKAN AUTOFILL TAMBAHAN ---
      // Perintah ini WAJIB dipanggil saat login sukses agar HP menawarkan menyimpan password
      TextInput.finishAutofillContext();
      // ------------------------------------

      // 3. Jika Berhasil: Simpan Session & Credentials
      await _saveOrClearCredentials();

      await RouteGuard.setUserInfo(username: user.nama, userType: user.role);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // 4. Arahkan Halaman Sesuai Role
        if (user.role == 'admin') {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/home_user');
        }
      }
    } catch (e) {
      // 5. Jika Gagal: Tampilkan Error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String message = e.toString().replaceAll("Exception: ", "");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: AppTextStyles.body2.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  // ===============================================

  Future<void> _saveOrClearCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_username', _usernameController.text);
        await prefs.setString('saved_password', _passwordController.text);
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_username');
        await prefs.remove('saved_password');
      }
    } catch (e) {
      // ignore
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

          // ===== KONTEN (HEADER + CARD) =====
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // ===== HEADER =====
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

                const SizedBox(height: 24),

                // ===== CARD PUTIH (FORM) =====
                Transform.translate(
                  offset: const Offset(0, 16), // sedikit turun dari curve
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
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
                      // --- PERBAIKAN: AutofillGroup membungkus kolom input ---
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // === TITLE CENTER: Welcome + subtitle ===
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Selamat Datang!',
                                    style: AppTextStyles.heading1,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Silahkan Masuk ke Akun Anda',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Username
                            Text(
                              'Username',
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _usernameController,
                              label: 'Masukkan Username',
                              prefixIcon: Icons.person_outline,
                              autofillHints: const [
                                AutofillHints.username,
                              ], // Hint Autofill
                            ),
                            const SizedBox(height: 24),

                            // Password
                            Text(
                              'Kata Sandi',
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Masukkan kata sandi',
                              obscureText: true,
                              prefixIcon: Icons.lock_outline,
                              autofillHints: const [
                                AutofillHints.password,
                              ], // Hint Autofill
                            ),
                            const SizedBox(height: 16),

                            // Remember Me
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppColors.mainGradientStart,
                                  onChanged: (val) {
                                    setState(() {
                                      _rememberMe = val ?? false;
                                    });
                                  },
                                ),
                                Text(
                                  'Ingat Saya?',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Login Button (gradient)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppColors.mainGradient,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
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
                                          'Masuk',
                                          style: AppTextStyles.button1.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Forgot Password
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/forgot_password',
                                  );
                                },
                                child: Text(
                                  'Lupa Kata Sandi?',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
