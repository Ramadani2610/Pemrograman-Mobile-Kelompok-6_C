import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';
import 'package:spareapp_unhas/core/utils/no_animation_route.dart';

const Color primaryColor = AppColors.mainGradientStart;

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
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER & FOTO (Metode Padding agar aman) ---
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
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
                        child: Container(),
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

                // 3. Foto Profil
                Padding(
                  padding: const EdgeInsets.only(top: 130.0),
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
                  // Tombol Menuju Edit Profil
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGradientStart,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
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
                        style: AppTextStyles.button1.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 4,
        useRoleRouting: true,
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
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: AppTextStyles.body2.copyWith(color: AppColors.titleText),
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// 2. HALAMAN EDIT PROFIL (PERBAIKAN UX & LOADING)
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

  // Status Loading Baru (Untuk UX yang lebih baik)
  bool _isInitializing = true; // Loading awal saat ambil data
  bool _isSaving = false; // Loading saat proses simpan/upload

  // --- CONFIG CLOUDINARY ---
  // JANGAN LUPA UPDATE INI YA!
  final cloudinary = CloudinaryPublic(
    'dgk74prij', // Cloud Name Kamu
    'spare_app_preset', // Upload Preset Kamu
    cache: false,
  );

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Load data awal (Anti Flicker)
  Future<void> _loadInitialData() async {
    setState(() => _isInitializing = true); // Mulai loading

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
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

          _isInitializing = false; // Selesai loading
        });
      }
    }
  }

  // FUNGSI BUKA GALERI (Fix untuk Web & Mobile)
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

  // FUNGSI SIMPAN (Dengan Overlay Loading)
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true); // Nyalakan overlay loading

    try {
      String? newPhotoUrl = _currentPhotoUrl;

      // 1. Upload ke Cloudinary (Jika ada file baru)
      if (_selectedImageFile != null) {
        // Tambahkan timestamp di publicId agar foto tidak kena cache browser/HP
        String uniqueId =
            '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImageFile!.path,
            resourceType: CloudinaryResourceType.Image,
            folder: 'user_photos',
            publicId: uniqueId,
          ),
        );
        newPhotoUrl = response.secureUrl;
      }

      // 2. Update Firestore
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
        // Tunda sebentar untuk UX yang lebih halus
        await Future.delayed(const Duration(milliseconds: 500));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil berhasil diperbarui!'),
            backgroundColor: AppColors.mainGradientStart,
          ),
        );

        Navigator.pop(context); // Tutup halaman
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false); // Matikan loading
    }
  }

  // Helper untuk menentukan gambar avatar
  ImageProvider _getAvatarImage() {
    if (_selectedImageFile != null) {
      // Prioritas 1: File lokal baru dipilih
      return FileImage(_selectedImageFile!);
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      // Prioritas 2: URL dari internet (Cloudinary)
      return NetworkImage(_currentPhotoUrl!);
    }
    // Prioritas 3: Default asset
    return const AssetImage('lib/assets/icons/foto-profil.jpg');
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
      backgroundColor: AppColors.backgroundColor,
      // Gunakan Stack agar bisa menumpuk Loading Overlay di atas Form
      body: Stack(
        children: [
          // LAYER 1: KONTEN FORMULIR
          _isInitializing
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.mainGradientStart,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- HEADER EDIT ---
                      Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
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
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  16,
                                  8,
                                ),
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

                          // FOTO & TOMBOL KAMERA
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
                                      image: _getAvatarImage(), // Pakai Helper
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // TOMBOL KAMERA (INKWELL)
                                InkWell(
                                  onTap: _pickImage,
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

                      // FORM FIELDS
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
                                  backgroundColor: AppColors.mainGradientStart,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 2,
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

          // LAYER 2: LOADING OVERLAY (POP UP SAAT MENYIMPAN)
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5), // Layar Gelap
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.mainGradientStart,
                      ),

                      const SizedBox(height: 16),
                      Text(
                        "Menyimpan Perubahan...",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.mainGradientStart,
                width: 2,
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGradientStart,
              ),
              onPressed: () {
                Navigator.pop(context);
                _saveProfile();
              },
              child: Text(
                'Simpan',
                style: AppTextStyles.button2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
