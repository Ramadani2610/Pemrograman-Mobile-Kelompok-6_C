// lib/data/services/route_guard.dart
class RouteGuard {
  static String? _userRole;
  static String? _username;

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
  
  // Cek jika user adalah admin
  static bool get isAdmin => _userRole == 'admin';
  
  // Cek jika user sudah login
  static bool get isLoggedIn => _userRole != null;
}
