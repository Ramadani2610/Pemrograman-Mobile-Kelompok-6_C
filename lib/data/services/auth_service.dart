import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'route_guard.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Login menggunakan NIM dan Password
  /// Mengubah NIM menjadi email format: [NIM]@student.unhas.ac.id
  Future<UserModel> loginWithNim({
    required String nim,
    required String password,
  }) async {
    try {
      // 1. Bersihkan input
      String cleanNim = nim.trim();
      String cleanPass = password.trim();

      // 2. Trik: Ubah NIM jadi format Email
      // Contoh: H071191001 -> H071191001@student.unhas.ac.id
      String emailFormat = "$cleanNim@student.unhas.ac.id";

      // 3. Login ke Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: emailFormat,
        password: cleanPass,
      );

      // 4. Ambil Data Detail User dari Firestore
      // Kita butuh tahu dia 'admin' atau 'mahasiswa'
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (!doc.exists) {
        throw Exception("Login berhasil, tapi data user tidak ditemukan di Database.");
      }

      // 5. Kembalikan data user ke UI
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, result.user!.uid);

    } on FirebaseAuthException catch (e) {
      // Handle error khas Firebase
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception("NIM atau Password salah.");
      } else if (e.code == 'network-request-failed') {
        throw Exception("Periksa koneksi internet Anda.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Format NIM tidak valid.");
      }
      throw Exception("Terjadi kesalahan: ${e.message}");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Logout: Hapus session Firebase & Lokal
  Future<void> logout() async {
    try {
      // 1. Logout dari Firebase
      await _auth.signOut();

      // 2. Hapus data session di RouteGuard
      await RouteGuard.clearUserInfo();

      // 3. Hapus data 'Remember Me' di HP
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      
    } catch (e) {
      // ignore error
    }
  }
}