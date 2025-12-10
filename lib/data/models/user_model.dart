class UserModel {
  final String uid;
  final String nama;
  final String nim;
  final String role; // 'admin' atau 'mahasiswa'
  final String email;
  final String? jurusan;

  UserModel({
    required this.uid,
    required this.nama,
    required this.nim,
    required this.role,
    required this.email,
    this.jurusan,
  });

  // Mengubah Data dari Firestore (Map) ke Object Dart
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      nama: data['nama'] ?? '',
      nim: data['nim'] ?? '',
      role: data['role'] ?? 'mahasiswa',
      email: data['email'] ?? '',
      jurusan: data['jurusan'],
    );
  }

  // Mengubah Object Dart ke Map (untuk upload ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'nim': nim,
      'role': role,
      'email': email,
      'jurusan': jurusan,
    };
  }
}