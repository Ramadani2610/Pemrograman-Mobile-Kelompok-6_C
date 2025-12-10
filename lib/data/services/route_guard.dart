import 'package:shared_preferences/shared_preferences.dart';

// lib/data/services/route_guard.dart
class RouteGuard {
  static String? _userRole;
  static String? _username;
  static String? _userType;

  // Simpan data login
  static void setUserData(String role, String username) {
    _userRole = role;
    _username = username;
  }

  // Clear data login
  static void clearUserData() {
    _userRole = null;
    _username = null;
  }

  // Cek role user
  static String? get userRole => _userRole;
  static String? get username => _username;
  static String? get userType => _userType;

  // Cek jika user adalah admin
  static bool get isAdmin => _userRole == 'admin';

  // Cek jika user sudah login
  static bool get isLoggedIn => _userRole != null;

  /// Setter untuk menyimpan user info setelah login berhasil
  /// Dipanggil dari login_page.dart ketika login sukses
  static Future<void> setUserInfo({
    required String username,
    required String userType,
  }) async {
    _username = username;
    _userType = userType;
    _userRole = userType;

    // Simpan juga ke SharedPreferences untuk persistensi
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_username', username);
      await prefs.setString('user_type', userType);
    } catch (e) {
      // ignore
    }
  }

  /// Load user info dari SharedPreferences (restore session saat app startup)
  static Future<void> loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _username = prefs.getString('user_username');
      _userType = prefs.getString('user_type');
      _userRole = _userType;
    } catch (e) {
      // ignore
    }
  }

  /// Clear semua user info saat logout
  static Future<void> clearUserInfo() async {
    _username = null;
    _userType = null;
    _userRole = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_username');
      await prefs.remove('user_type');
    } catch (e) {
      // ignore
    }
  }
}
