import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'route_guard.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login Cerdas menggunakan NIM/NIP
  /// Sistem akan mengecek database untuk menentukan email yang digunakan.
  Future<UserModel> loginWithNim({
    required String nim,
    required String password,
  }) async {
    try {
      // 1. Bersihkan input
      String cleanNim = nim.trim();
      String cleanPass = password.trim();
      String emailToUse = "";

      // 2. CEK DATABASE DULU (Lookup Email berdasarkan NIM/NIP)
      // Ini memungkinkan user login pakai NIM, tapi sistem backend login pakai email aslinya (Gmail/Unhas)
      try {
        var userQuery = await _firestore
            .collection('users')
            .where('nim', isEqualTo: cleanNim) // Cari dokumen dengan NIM ini
            .limit(1)
            .get();

        if (userQuery.docs.isNotEmpty) {
          // KETEMU! Ambil email asli dari database
          // Ini otomatis menangani:
          // - Mahasiswa (@student.unhas.ac.id)
          // - Dosen (@unhas.ac.id)
          // - Admin/Testing (@gmail.com)
          emailToUse = userQuery.docs.first.data()['email'];
        } else {
          // TIDAK KETEMU: Default ke format email mahasiswa
          // Ini untuk jaga-jaga jika data belum ada di DB tapi sudah ada di Auth
          emailToUse = "$cleanNim@student.unhas.ac.id";
        }
      } catch (e) {
        // Jika error saat cek DB (misal koneksi), gunakan default format mahasiswa
        emailToUse = "$cleanNim@student.unhas.ac.id";
      }

      // 3. Login ke Firebase Auth menggunakan Email yang Ditemukan
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: emailToUse,
        password: cleanPass,
      );

      // 4. Ambil Data Detail User (Role, Nama, dll) untuk Session
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception(
          "Login berhasil, tapi data profil tidak ditemukan di Database.",
        );
      }

      // 5. Kembalikan data user ke UI
      return UserModel.fromMap(
        doc.data() as Map<String, dynamic>,
        result.user!.uid,
      );
    } on FirebaseAuthException catch (e) {
      // Handle error khas Firebase dengan pesan bahasa Indonesia
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception("Username/NIM atau Kata Sandi salah.");
      } else if (e.code == 'network-request-failed') {
        throw Exception("Periksa koneksi internet Anda.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Format email pada akun ini tidak valid.");
      } else if (e.code == 'too-many-requests') {
        throw Exception(
          "Terlalu banyak percobaan login. Silakan tunggu beberapa saat.",
        );
      }
      throw Exception("Terjadi kesalahan: ${e.message}");
    } catch (e) {
      // Membersihkan pesan error agar enak dibaca di UI
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }

  /// Logout: Keluar dari Firebase & Hapus Data Lokal
  Future<void> logout() async {
    try {
      // 1. Logout dari Firebase
      await _auth.signOut();

      // 2. Hapus data session user
      await RouteGuard.clearUserInfo();

      // 3. Hapus data 'Ingat Saya' (Opsional)
      // Jika Anda ingin user tetap diingat username-nya setelah logout, hapus bagian ini.
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
    } catch (e) {
      // ignore error
    }
  }

  // --- FUNGSI RESET PASSWORD ---
  /// Mengirim link reset password ke email user
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Tangkap error spesifik Firebase
      if (e.code == 'user-not-found') {
        throw Exception('Email tidak terdaftar di sistem.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Format email tidak valid.');
      } else {
        throw Exception(e.message ?? 'Gagal mengirim email reset.');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
