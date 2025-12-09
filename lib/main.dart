import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Halaman (presentation)
import 'package:spareapp_unhas/presentation/auth/splash_screen.dart';
import 'package:spareapp_unhas/presentation/auth/login_page.dart';
import 'package:spareapp_unhas/presentation/auth/forgot_password.dart';
import 'package:spareapp_unhas/presentation/home/home_page.dart';
import 'package:spareapp_unhas/presentation/home/user_home_page.dart';
import 'package:spareapp_unhas/presentation/profile/profile_page.dart';
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

const Color primaryColor = Color(0xFFD32F2F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia untuk intl
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPARE App',
      debugShowCheckedModeBanner: false,
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
      initialRoute: '/splash_screen',
      routes: {
        // AUTH
        '/splash_screen': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),

        // HOME
        '/home': (context) => const HomePage(),
        '/home_user': (context) => const UserHomePage(),

        // FACILITIES
        '/facilities': (context) => const FacilitiesPage(),
        '/admin_facilities': (context) => const AdminFacilitiesPage(),
        // '/admin_manage_facilities': (context) => const AdminManageFacilitiesPage(),
        '/facility_detail_tabs': (context) => const FacilityDetailTabsPage(facilityName: ''),

        // BOOKINGS
        '/booking_history': (context) => const BookingHistoryPage(),
        '/notification': (context) => const ReviewBookingsPage(),

        // PROFILE
        '/profile': (context) => const ProfilePage(),

        // MANAGE
        '/manage': (context) => const ManagePage(),

        // CLASSROOM
        '/main_classroom': (context) => const MainClassroomPage(),
        '/class_schedule': (context) => const ClassSchedulePage(),
        '/search_classroom': (context) => const SearchClassroomPage(),
        '/class_reservation': (context) => const ClassReservationPage(),
      },
    );
  }
}