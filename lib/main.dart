import 'package:flutter/material.dart';
// --- FIREBASE SETUP ---
import 'package:firebase_core/firebase_core.dart';
import 'package:spareapp_unhas/firebase_options.dart';
// ----------------------

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spareapp_unhas/data/services/route_guard.dart';

// --- IMPORTS PAGE ---
import 'package:spareapp_unhas/presentation/auth/splash_screen.dart';
import 'package:spareapp_unhas/presentation/auth/login_page.dart';
import 'package:spareapp_unhas/presentation/auth/forgot_password.dart';
import 'package:spareapp_unhas/presentation/home/home_page.dart';
import 'package:spareapp_unhas/presentation/profile/profile_page.dart';
import 'package:spareapp_unhas/presentation/home/user_home_page.dart';
import 'package:spareapp_unhas/presentation/facilities/admin_facilities_page.dart';
import 'package:spareapp_unhas/presentation/facilities/facility_reservation.dart';
import 'package:spareapp_unhas/presentation/facilities/facility_detail_tabs_page.dart';
import 'package:spareapp_unhas/presentation/bookings/booking_history_page.dart';
import 'package:spareapp_unhas/presentation/bookings/booking_history_user.dart';
import 'package:spareapp_unhas/presentation/bookings/review_booking.dart';
import 'package:spareapp_unhas/presentation/bookings/user_notification.dart';
import 'package:spareapp_unhas/presentation/manage/manage_page.dart';
import 'package:spareapp_unhas/presentation/manage/manage_user.dart';
import 'package:spareapp_unhas/presentation/class/main_classroom.dart';
import 'package:spareapp_unhas/presentation/class/class_schedule.dart';
import 'package:spareapp_unhas/presentation/class/search_classroom.dart';
import 'package:spareapp_unhas/presentation/class/class_reservation.dart';

// Definisi warna utama
const Color primaryColor = Color(0xFFD32F2F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INISIALISASI FIREBASE ---
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  // -----------------------------

  // Inisialisasi locale Indonesia untuk intl
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  // Load user info (Restore Session Login)
  await RouteGuard.loadUserInfo();

  runApp(const MyApp());
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
        // --- AUTH FLOW ---
        '/splash_screen': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),

        // --- HOME ---
        '/home': (context) => const HomePage(), // ADMIN
        '/home_user': (context) => const UserHomePage(), // MAHASISWA/DOSEN
        // --- FACILITIES ---
        '/admin_facilities': (context) => const AdminFacilitiesPage(),

        // PERBAIKAN: Menambahkan parameter 'items' dan 'imagePath' yang hilang
        '/facility_detail_tabs': (context) => const FacilityDetailTabsPage(
          facilityName: '',
          items: [], // <-- Parameter yang hilang (asumsi List)
          imagePath: '', // <-- Parameter yang hilang (asumsi String)
        ),

        '/user_facility_reservation': (context) =>
            const FacilityReservationPage(),
        '/facilities': (context) => const FacilityReservationPage(),

        // --- BOOKINGS & HISTORY ---
        '/booking_history': (context) => const BookingHistoryAdminPage(),
        '/user_history': (context) => const BookingHistoryUserPage(),
        '/notification': (context) => const ReviewBookingsPage(),
        '/user_notification': (context) => const UserNotificationsPage(),

        // --- PROFILE ---
        '/profile': (context) => const ProfilePage(),

        // --- MANAGE (ADMIN) ---
        '/manage': (context) => const ManagePage(),
        '/manage_user': (context) => const UserManagePage(),

        // --- CLASSROOM ---
        '/main_classroom': (context) => const MainClassroomPage(),
        '/class_schedule': (context) => const ClassSchedulePage(),
        '/search_classroom': (context) => const SearchClassroomPage(),
        '/class_reservation': (context) => const ClassReservationPage(),
      },
    );
  }
}
