// main.dart

import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:spareapp_unhas/firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spareapp_unhas/data/services/route_guard.dart';

// Sesuaikan import path sesuai dengan lokasi file di folder presentation/auth
import 'package:spareapp_unhas/presentation/auth/splash_screen.dart';
import 'package:spareapp_unhas/presentation/auth/login_page.dart';
import 'package:spareapp_unhas/presentation/auth/forgot_password.dart';
import 'package:spareapp_unhas/presentation/home/home_page.dart';
import 'package:spareapp_unhas/presentation/profile/profile_page.dart';
import 'package:spareapp_unhas/presentation/home/user_home_page.dart';
import 'package:spareapp_unhas/presentation/facilities/facilities_page.dart';
import 'package:spareapp_unhas/presentation/facilities/admin_facilities_page.dart';
import 'package:spareapp_unhas/presentation/facilities/facility_detail_tabs_page.dart';
import 'package:spareapp_unhas/presentation/bookings/booking_history_page.dart';
import 'package:spareapp_unhas/presentation/bookings/review_booking.dart';
import 'package:spareapp_unhas/presentation/manage/manage_page.dart';
import 'package:spareapp_unhas/presentation/class/main_classroom.dart';
import 'package:spareapp_unhas/presentation/class/class_schedule.dart';
import 'package:spareapp_unhas/presentation/class/search_classroom.dart';
import 'package:spareapp_unhas/presentation/class/class_reservation.dart';

// Definisi warna utama (jika belum didefinisikan secara global)
const Color primaryColor = Color(0xFFD32F2F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi locale Indonesia untuk intl
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID'; // optional tapi bagus supaya konsisten

  // Load user info dari SharedPreferences (restore session jika ada)
  await RouteGuard.loadUserInfo();

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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPARE App',
      debugShowCheckedModeBanner: false,

      initialRoute: '/splash_screen',
      routes: {
        // AUTH FLOW
        '/splash_screen': (context) => const SplashScreen(), // SPLASH SCREEN
        '/login': (context) => const LoginPage(), // LOGIN PAGE
        '/forgot_password': (context) =>
            const ForgotPasswordPage(), // FORGOT PASSWORD PAGE
        // HOME
        '/home': (context) => const HomePage(), // ADMIN HOME PAGE
        '/home_user': (context) => const UserHomePage(), // USER HOME PAGE
        // FACILITIES
        '/facilities': (context) =>
            const FacilitiesPage(), // USER FACILITIES PAGE
        '/admin_facilities': (context) =>
            const AdminFacilitiesPage(), // ADMIN FACILITIES PAGE
        '/facility_detail_tabs': (context) =>
            const FacilityDetailTabsPage(facilityName: ''),
        // BOOKINGS
        '/booking_history': (context) =>
            const BookingHistoryPage(), // BOOKING HISTORY PAGE
        '/notification': (context) =>
            const ReviewBookingsPage(), // REVIEW BOOKINGS PAGE
        // PROFILE
        '/profile': (context) => const ProfilePage(), // PROFILE PAGE
        // MANAGE
        '/manage': (context) => const ManagePage(), // MANAGE PAGE
        // CLASSROOM
        '/main_classroom': (context) =>
            const MainClassroomPage(), // MAIN CLASSROOM PAGE
        '/class_schedule': (context) =>
            const ClassSchedulePage(), // CLASS SCHEDULE PAGE
        '/search_classroom': (context) =>
            const SearchClassroomPage(), // SEARCH CLASSROOM PAGE
        '/class_reservation': (context) =>
            const ClassReservationPage(), // CLASS RESERVATION PAGE
      },
    );
  }
}
