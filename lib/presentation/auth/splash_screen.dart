import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Tunggu 5 detik lalu pindah ke halaman login
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // Gradient utama aplikasi (merah SPARE)
          gradient: AppColors.mainGradient,
        ),
        child: Center(
          // Logo SPARE full (teks + lambang UNHAS)
          child: Image.asset(
            'lib/assets/icons/logo_no-bg.png', 
            width: 230,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
