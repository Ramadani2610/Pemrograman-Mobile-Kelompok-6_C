/// Service untuk validasi login SSO UNHAS
/// Username bisa berupa NIM (format: angka) atau "admin1"
/// Password untuk admin1 adalah "admin123"
/// Untuk NIM, password bisa berupa apapun (simulasi SSO UNHAS)
class AuthService {
  // Admin credentials
  static const String adminUsername = 'admin1';
  static const String adminPassword = 'admin123';

  // Format NIM UNHAS: biasanya 8 digit (contoh: 12345678)
  static const int nimLength = 8;

  /// Validasi login
  /// Returns:
  /// - success: true jika login berhasil
  /// - message: pesan error atau sukses
  /// - userType: 'admin' atau 'mahasiswa'
  static Map<String, dynamic> validateLogin({
    required String username,
    required String password,
  }) {
    // Trim whitespace
    username = username.trim();
    password = password.trim();

    // Validasi input kosong
    if (username.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Username dan password tidak boleh kosong',
        'userType': null,
      };
    }

    // Cek admin login
    if (username == adminUsername && password == adminPassword) {
      return {
        'success': true,
        'message': 'Login berhasil sebagai admin',
        'userType': 'admin',
        'username': username,
      };
    }

    // Cek NIM login (validasi format NIM)
    if (isValidNIM(username)) {
      // Simulasi SSO: password apapun diterima untuk NIM yang valid
      // Dalam implementasi nyata, ini akan hit API SSO UNHAS
      return {
        'success': true,
        'message': 'Login berhasil',
        'userType': 'mahasiswa',
        'username': username,
      };
    }

    // Username/NIM tidak terdaftar
    return {
      'success': false,
      'message': 'Username atau password yang digunakan tidak terdaftar',
      'userType': null,
    };
  }

  /// Validasi format NIM UNHAS
  /// NIM UNHAS terdiri dari 8 digit angka
  static bool isValidNIM(String nim) {
    // Cek apakah hanya berisi digit dan panjangnya 8
    return nim.length == nimLength && int.tryParse(nim) != null;
  }
}
