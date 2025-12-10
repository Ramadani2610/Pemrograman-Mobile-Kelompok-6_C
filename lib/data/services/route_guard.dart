import 'package:shared_preferences/shared_preferences.dart';

/// RouteGuard: Mengelola session user dan memberikan akses ke informasi user
/// yang sedang login (username, isAdmin, dll).
///
/// Ini digunakan untuk:
/// - Menyimpan informasi user setelah login berhasil
/// - Mengakses info user di berbagai halaman (home, profile, dll)
/// - Validasi akses halaman berdasarkan role (admin vs mahasiswa)
class RouteGuard {
  static String? _username;
  static String? _userType; // 'admin' atau 'mahasiswa'
  static bool _isAdmin = false;

  /// Getter untuk username user yang sedang login
  static String? get username => _username;

  /// Getter untuk user type (admin atau mahasiswa)
  static String? get userType => _userType;

  /// Getter untuk mengecek apakah user adalah admin
  static bool get isAdmin => _isAdmin;

  /// Setter untuk menyimpan user info setelah login berhasil
  /// Dipanggil dari login_page.dart ketika login sukses
  static Future<void> setUserInfo({
    required String username,
    required String userType,
  }) async {
    _username = username;
    _userType = userType;
    _isAdmin = (userType == 'admin');

    // Simpan juga ke SharedPreferences untuk persistensi
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_username', username);
      await prefs.setString('user_type', userType);
    } catch (e) {
      // ignore
    }
  }

  /// Load user info dari SharedPreferences (untuk restore session)
  /// Dipanggil dari main.dart saat app startup
  static Future<void> loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _username = prefs.getString('user_username');
      _userType = prefs.getString('user_type');
      _isAdmin = (_userType == 'admin');
    } catch (e) {
      // ignore
    }
  }

  /// Clear semua user info saat logout
  /// Dipanggil dari auth_service.dart saat logout
  static Future<void> clearUserInfo() async {
    _username = null;
    _userType = null;
    _isAdmin = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_username');
      await prefs.remove('user_type');
    } catch (e) {
      // ignore
    }
  }
}
