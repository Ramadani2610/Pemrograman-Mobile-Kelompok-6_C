// main.dart

import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:spareapp_unhas/firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// --- Perubahan di bagian ini: Penyesuaian Import Path ---
// Sesuaikan import path sesuai dengan lokasi file di folder presentation/auth
import 'package:spareapp_unhas/presentation/auth/splash_screen.dart';
import 'package:spareapp_unhas/presentation/auth/login_page.dart';
import 'package:spareapp_unhas/presentation/auth/forgot_password.dart';
import 'package:spareapp_unhas/presentation/home/home_page.dart';
import 'package:spareapp_unhas/presentation/profile/profile_page.dart';
import 'package:spareapp_unhas/presentation/home/user_home_page.dart';
import 'package:spareapp_unhas/presentation/facilities/facilities_page.dart';
import 'package:spareapp_unhas/presentation/facilities/admin_facilities_page.dart';
import 'package:spareapp_unhas/presentation/bookings/booking_history_page.dart';
import 'package:spareapp_unhas/presentation/bookings/review_booking.dart';
import 'package:spareapp_unhas/core/utils/no_animation_route.dart';

// Definisi warna utama (jika belum didefinisikan secara global)
const Color primaryColor = Color(0xFFD32F2F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi locale Indonesia untuk intl
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID'; // optional tapi bagus supaya konsisten

  runApp(const MyApp());
  // Firebase initialization disabled for now due to web compatibility issues
  // Uncomment and properly configure after running: flutter pub global activate flutterfire_cli
  // Then: flutterfire configure --project=spareapp-unhas-dev
  /*
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPARE App',
      theme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(fontFamily: 'Poppins'),
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
          bodySmall: TextStyle(fontFamily: 'Poppins'),
          labelLarge: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      // --- Definisikan Rute ---
      initialRoute: '/splash_screen',
      onGenerateRoute: (settings) {
        Widget page;

        switch (settings.name) {
          case '/splash_screen':
            page = const SplashScreen();
            break;
          case '/login':
            page = const LoginPage();
            break;
          case '/home':
            page = const HomePage();
            break;
          case '/home_user':
            page = const UserHomePage();
            break;
          case '/facilities':
            page = const FacilitiesPage();
            break;
          case '/admin_facilities':
            page = const AdminFacilitiesPage();
            break;
          case '/booking_history':
            page = const BookingHistoryPage();
            break;
          case '/forgot_password':
            page = const ForgotPasswordPage();
            break;
          case '/profile':
            page = const ProfilePage();
            break;
          case '/notification':
            page = const ReviewBookingsPage();
            break;
          default:
            page = const SplashScreen();
        }

        return NoAnimationPageRoute(
          builder: (context) => page,
          settings: settings,
        );
      },
    );
  }
}
