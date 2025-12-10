import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

// Import project kamu (Biarkan tetap ada)
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';
import 'package:spareapp_unhas/core/utils/no_animation_route.dart';

const Color primaryColor = Color(0xFFD32F2F);

// ===============================================================
// 1. HALAMAN PROFIL (READ ONLY)
// ===============================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nama = 'Loading...';
  String _email = 'Loading...';
  String _nim = '-';
  String _jabatan = '-';
  String _noHp = '-';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && mounted) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _nama = data['nama'] ?? 'User';
            _email = data['email'] ?? user.email ?? '-';
            _nim = data['nim'] ?? '-';
            _noHp = data['no_hp'] ?? '-';
            _photoUrl = data['photo_url'];

            String role = data['role'] ?? 'mahasiswa';
            if (role == 'admin')
              _jabatan = 'Super Admin';
            else if (role == 'dosen')
              _jabatan = 'Dosen';
            else
              _jabatan = 'Mahasiswa';
          });
        }
      } catch (e) {
        debugPrint("Error loading profile: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // Tambahkan scroll agar aman di layar kecil
        child: Column(
          children: [
            // --- HEADER & FOTO (Metode Transform) ---
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none, // Biarkan visual meluap
              children: [
                // 1. Kotak Merah Header
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryColor, Color(0xFFE74C3C)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Judul Profil
                Positioned(
                  top: 60,
                  child: Text(
                    'Profil',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                // 3. Foto Profil (Menggunakan Transform agar tidak error hit-test)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 130.0,
                  ), // Dorong ke bawah header
                  child: Container(
                    width: 105,
                    height: 105,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.grey[200],
                      image: DecorationImage(
                        image: (_photoUrl != null && _photoUrl!.isNotEmpty)
                            ? NetworkImage(_photoUrl!) as ImageProvider
                            : const AssetImage(
                                'lib/assets/icons/foto-profil.jpg',
                              ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Nama & Email
            Text(
              _nama,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                fontFamily: 'Poppins',
              ),
            ),

            // Profile Data Fields
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileField(context, 'Nama Lengkap', _nama),
                  const SizedBox(height: 16),
                  _buildProfileField(
                    context,
                    _jabatan == 'Mahasiswa' ? 'NIM' : 'NIP',
                    _nim,
                  ),
                  const SizedBox(height: 16),
                  _buildProfileField(context, 'Jabatan', _jabatan),
                  const SizedBox(height: 16),
                  _buildProfileField(context, 'Nomor Whatsapp', _noHp),
                  const SizedBox(height: 16),
                  _buildProfileField(context, 'Email', _email),
                  const SizedBox(height: 32),
                  // Tombol Edit Profil
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          NoAnimationPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        ).then((_) {
                          _fetchUserData();
                        });
                      },
                      child: Text(
                        'Edit Profil',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 4,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              if (_jabatan == 'Super Admin')
                Navigator.pushNamed(context, '/home');
              else
                Navigator.pushNamed(context, '/home_user');
              break;
            case 1:
              Navigator.pushNamed(context, '/facilities');
              break;
            case 2:
              Navigator.pushNamed(context, '/notification');
              break;
            case 3:
              Navigator.pushNamed(context, '/booking_history');
              break;
            case 4:
              break;
          }
        },
      ),
    );
  }

  Widget _buildProfileField(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE0B0AF)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontFamily: 'Poppins',
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// 2. HALAMAN EDIT PROFIL (DIPERBAIKI AGAR BISA KLIK)
// ===============================================================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nipController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _selectedImageFile;
  String? _currentPhotoUrl;
  bool _isLoading = false;

  // --- CONFIG CLOUDINARY ---
  final cloudinary = CloudinaryPublic(
    'dgk74prij',
    'spare_app_preset',
    cache: false,
  );

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _namaController.text = data['nama'] ?? '';
          _nipController.text = data['nim'] ?? '';
          _whatsappController.text = data['no_hp'] ?? '';
          _emailController.text = data['email'] ?? '';
          _currentPhotoUrl = data['photo_url'];

          String role = data['role'] ?? 'mahasiswa';
          if (role == 'admin')
            _jabatanController.text = 'Super Admin';
          else if (role == 'dosen')
            _jabatanController.text = 'Dosen';
          else
            _jabatanController.text = 'Mahasiswa';
        });
      }
    }
  }

  // FUNGSI BUKA GALERI (WEB: BUKA FILE EXPLORER)
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Gagal ambil gambar: $e");
    }
  }

  // FUNGSI SIMPAN
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl = _currentPhotoUrl;

      // Upload ke Cloudinary
      if (_selectedImageFile != null) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImageFile!.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'user_photos',
            publicId: user.uid,
          ),
        );
        newPhotoUrl = response.secureUrl;
      }

      // Update Firestore
      Map<String, dynamic> updateData = {
        'nama': _namaController.text.trim(),
        'no_hp': _whatsappController.text.trim(),
      };
      if (newPhotoUrl != null) {
        updateData['photo_url'] = newPhotoUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nipController.dispose();
    _jabatanController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Scroll view agar aman dari overflow keyboard
              child: Column(
                children: [
                  // --- HEADER EDIT (PERBAIKAN VISUAL & KLIK) ---
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Header Merah
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [primaryColor, Color(0xFFE74C3C)],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 2. Judul
                      Positioned(
                        top: 60,
                        child: Text(
                          'Edit Profil',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                fontFamily: 'Poppins',
                              ),
                        ),
                      ),

                      // 3. FOTO & TOMBOL KAMERA (PERBAIKAN)
                      // Menggunakan Padding top alih-alih Positioned agar ada di 'flow' layout
                      // Ini memastikan tombol kamera BISA DIKLIK karena tidak "mengambang" di luar area stack
                      Padding(
                        padding: const EdgeInsets.only(top: 130.0),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 105,
                              height: 105,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                color: Colors.grey[200],
                                image: DecorationImage(
                                  image: _selectedImageFile != null
                                      ? FileImage(_selectedImageFile!)
                                            as ImageProvider
                                      : (_currentPhotoUrl != null &&
                                            _currentPhotoUrl!.isNotEmpty)
                                      ? NetworkImage(_currentPhotoUrl!)
                                      : const AssetImage(
                                          'lib/assets/icons/foto-profil.jpg',
                                        ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // TOMBOL KAMERA (INKWELL UNTUK EFEK KLIK)
                            InkWell(
                              onTap: _pickImage, // Fungsi buka galeri
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryColor,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Preview Nama & Email
                  Text(
                    _namaController.text.isNotEmpty
                        ? _namaController.text
                        : 'User',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _emailController.text,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  // Edit Form
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditField(
                          context,
                          'Nama Lengkap',
                          _namaController,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          context,
                          _jabatanController.text == 'Mahasiswa'
                              ? 'NIM'
                              : 'NIP',
                          _nipController,
                          isReadOnly: true,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          context,
                          'Jabatan',
                          _jabatanController,
                          isReadOnly: true,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          context,
                          'Nomor Whatsapp',
                          _whatsappController,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildEditField(
                          context,
                          'Email',
                          _emailController,
                          isReadOnly: true,
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: () {
                              _showSaveDialog(context);
                            },
                            child: Text(
                              'Simpan',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 4,
        onItemTapped: (index) {},
      ),
    );
  }

  Widget _buildEditField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    bool isReadOnly = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: isReadOnly,
          keyboardType: keyboardType,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            fillColor: isReadOnly ? Colors.grey[100] : Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0B0AF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0B0AF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Simpan Perubahan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menyimpan perubahan profil?',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () {
                Navigator.pop(context);
                _saveProfile();
              },
              child: Text(
                'Simpan',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
