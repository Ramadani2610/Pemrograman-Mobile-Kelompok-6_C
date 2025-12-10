import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';
import 'package:spareapp_unhas/core/utils/no_animation_route.dart';

const Color primaryColor = Color(0xFFD32F2F);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header (Profil) with curved bottom and centered title (same as EditProfile)
          Stack(
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
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back button row (left)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Title moved above avatar (Positioned below)
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),

              // Avatar overlapping the curved bottom
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          image: const DecorationImage(
                            image: AssetImage(
                              'lib/assets/icons/foto-profil.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title positioned above avatar so it's always visible
              Positioned(
                top: 48,
                left: 0,
                right: 0,
                child: Center(
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
              ),
            ],
          ),
          const SizedBox(height: 56),

          // Name & email centered under avatar (same as EditProfile)
          Center(
            child: Column(
              children: [
                Text(
                  'Admin',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin@gmail.com',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          // Profile Data
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileField(context, 'Nama Lengkap', 'Admin123'),
                  const SizedBox(height: 16),
                  _buildProfileField(context, 'NIP', '08123456'),
                  const SizedBox(height: 16),
                  _buildProfileField(context, 'Jabatan', 'Super Admin'),
                  const SizedBox(height: 16),
                  _buildProfileField(context, 'Nomor Whatsapp', '0851234567'),
                  const SizedBox(height: 16),
                  _buildProfileField(context, 'Email', 'Admin@gmail.com'),
                  const SizedBox(height: 32),
                  // Edit Profile Button
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
                        );
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 4,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/manage');
              break;
            case 2:
              Navigator.pushNamed(context, '/notification');
              break;
            case 3:
              Navigator.pushNamed(context, '/booking_history');
              break;
            case 4:
              // Already on profile page
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
        SizedBox(
          width: double.infinity,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
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
        ),
      ],
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _namaController;
  late TextEditingController _nipController;
  late TextEditingController _jabatanController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: 'Admin123');
    _nipController = TextEditingController(text: '08123456');
    _jabatanController = TextEditingController(text: 'Super Admin');
    _whatsappController = TextEditingController(text: '0851234567');
    _emailController = TextEditingController(text: 'Admin@gmail.com');
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
      body: Column(
        children: [
          // Header (Edit Profil) with curved bottom and centered title
          Stack(
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
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back button aligned left
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Title moved above avatar (Positioned below)
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),

              // Avatar overlapping the curved bottom; slightly lower overlap
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          image: const DecorationImage(
                            image: AssetImage(
                              'lib/assets/icons/foto-profil.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Title positioned above avatar so it's always visible
              Positioned(
                top: 48,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Edit Profil',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 56),

          // Name & email centered under avatar
          Center(
            child: Column(
              children: [
                Text(
                  'Admin',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin@gmail.com',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          // Edit Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditField(context, 'Nama Lengkap', _namaController),
                  const SizedBox(height: 16),
                  _buildEditField(context, 'NIP', _nipController),
                  const SizedBox(height: 16),
                  _buildEditField(context, 'Jabatan', _jabatanController),
                  const SizedBox(height: 16),
                  _buildEditField(
                    context,
                    'Nomor Whatsapp',
                    _whatsappController,
                  ),
                  const SizedBox(height: 16),
                  _buildEditField(context, 'Email', _emailController),
                  const SizedBox(height: 32),
                  // Save Button
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 4,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home_user');
              break;
            case 1:
              Navigator.pushNamed(context, '/facilities');
              break;
            case 2:
              // Notifications page (to be implemented)
              break;
            case 3:
              Navigator.pushNamed(context, '/booking_history');
              break;
            case 4:
              // Already on profile page
              break;
          }
        },
      ),
    );
  }

  Widget _buildEditField(
    BuildContext context,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins'),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            fillColor: Colors.white,
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
              onPressed: () {
                Navigator.pop(context);
              },
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profil berhasil disimpan'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pop(context);
                });
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
