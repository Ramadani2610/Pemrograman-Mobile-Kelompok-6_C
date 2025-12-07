// main.dart

import 'package:flutter/material.dart';

// --- Perubahan di bagian ini: Penyesuaian Import Path ---
// Sesuaikan import path sesuai dengan lokasi file di folder presentation/auth
import 'package:spareapp_unhas/presentation/auth/splash_screen.dart'; 
import 'package:spareapp_unhas/presentation/auth/login_page.dart';    
import 'package:spareapp_unhas/presentation/auth/forgot_password.dart'; 

// Definisi warna utama (jika belum didefinisikan secara global)
const Color primaryColor = Color(0xFFD32F2F); 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPARE App',
      theme: ThemeData(
        // ... (Pengaturan Tema)
        primaryColor: primaryColor,
        primarySwatch: Colors.red,
        // ...
      ),
      // --- Definisikan Rute ---
      initialRoute: '/', 
      routes: {
        // Panggil kelas widget yang telah diimport dari presentation/auth/
        '/': (context) => const SplashScreen(), // Splash Screen
        '/login': (context) => const LoginPage(), // Login Page
        '/forgot_password': (context) => const ForgotPasswordPage(), // Forgot Password Page
      },
    );
  }
}