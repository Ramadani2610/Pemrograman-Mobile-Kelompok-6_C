import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/widgets/unhas_logo.dart';

// Definisikan warna utama
const Color primaryColor = Color(0xFFD32F2F);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // TODO: Tambahkan logika navigasi otomatis di sini
  // Misalnya, pindah ke halaman '/login' setelah 3 detik

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      // Pastikan Anda telah mendefinisikan rute '/login' di main.dart
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, Colors.red.shade300],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo UNHAS dengan efek shadow
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: Image.asset(
                    'lib/assets/icons/Logo-Resmi-Unhas-1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white.withOpacity(0.2),
                        child: const Icon(
                          Icons.storefront_outlined,
                          size: 80,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'SPARE',
                style:
                    Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ) ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Space & Property Allocation & Reservation',
                textAlign: TextAlign.center,
                style:
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: 'Poppins',
                    ) ??
                    TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
