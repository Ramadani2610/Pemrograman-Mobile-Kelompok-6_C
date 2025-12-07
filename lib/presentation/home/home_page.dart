import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showProfileMenu = false;
  final LayerLink _layerLink = LayerLink();

  int _selectedIndex = 0; // <-- untuk BottomNavBar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // <-- pakai core
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====== TOP BAR ======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showProfileMenu = !_showProfileMenu;
                        });
                      },
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage(
                          'lib/assets/icons/Logo-Resmi-Unhas-1.png',
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.mainGradientStart, // <-- dari core
                    ),
                  ),
                ],
              ),

              // ====== PROFILE DROPDOWN ======
              if (_showProfileMenu)
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(0, 50),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 280,
                      decoration: BoxDecoration(
                        gradient: AppColors.mainGradient, // <-- core gradient
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Profil
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(
                                    'lib/assets/icons/Logo-Resmi-Unhas-1.png',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Admin',
                                        style: AppTextStyles.body1.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'admin@gmail.com',
                                        style: AppTextStyles.caption.copyWith(
                                          color:
                                              Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 1),
                          // Menu Items
                          _buildProfileMenuItem(
                            context,
                            Icons.settings_outlined,
                            'Pengaturan Akun',
                            () {
                              setState(() => _showProfileMenu = false);
                              Navigator.pushNamed(context, '/profile');
                            },
                          ),
                          _buildProfileMenuItem(
                            context,
                            Icons.dark_mode_outlined,
                            'Tema',
                            () {
                              setState(() => _showProfileMenu = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tema')),
                              );
                            },
                          ),
                          _buildProfileMenuItem(
                            context,
                            Icons.description_outlined,
                            'Bahasa',
                            () {
                              setState(() => _showProfileMenu = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Bahasa')),
                              );
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(color: Colors.white24, height: 1),
                          ),
                          _buildProfileMenuItem(
                            context,
                            Icons.headphones_outlined,
                            'Bantuan dan Dukungan',
                            () {
                              setState(() => _showProfileMenu = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bantuan dan Dukungan'),
                                ),
                              );
                            },
                          ),
                          _buildProfileMenuItem(
                            context,
                            Icons.info_outlined,
                            'Syarat dan Ketentuan',
                            () {
                              setState(() => _showProfileMenu = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Syarat dan Ketentuan'),
                                ),
                              );
                            },
                          ),
                          _buildProfileMenuItem(
                            context,
                            Icons.help_outline,
                            'Tentang Aplikasi',
                            () {
                              setState(() => _showProfileMenu = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tentang Aplikasi'),
                                ),
                              );
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(color: Colors.white24, height: 1),
                          ),
                          _buildProfileMenuItem(
                            context,
                            Icons.logout_outlined,
                            'Keluar',
                            () {
                              setState(() => _showProfileMenu = false);
                              _showLogoutDialog(context);
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // ====== GREETING ======
              GestureDetector(
                onTap: _showProfileMenu
                    ? () {
                        setState(() {
                          _showProfileMenu = false;
                        });
                      }
                    : null,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Halo, ',
                        style: AppTextStyles.heading1, // <-- core heading
                      ),
                      TextSpan(
                        text: 'Admin!',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.mainGradientStart,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ====== STATS CARD ======
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: AppColors.mainGradient, // <-- core gradient
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('15', 'Departemen'),
                    Container(width: 1, height: 48, color: Colors.white24),
                    _statItem('07:50:20', 'Waktu'),
                    Container(width: 1, height: 48, color: Colors.white24),
                    _statItem('30', 'Sesi Belajar'),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ====== Statistik Peminjaman ======
              Text(
                'Statistik Peminjaman',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Chart Placeholder',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.mainGradientEnd,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ====== Kalender Akademik ======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kalender Akademik',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'November 2025',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCalendar(),
              const SizedBox(height: 12),

              // ====== Paket Fasilitas ======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paket Fasilitas',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.mainGradient,        
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/admin_facilities'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        foregroundColor: Colors.white,        
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(
                        'Kelola',
                        style: AppTextStyles.button2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _listItem('Paket Fasilitas', '15 Terpinjam'),
              _listItem('Remote Tv', '5 Terpinjam'),
              _listItem('Kabel Terminal', '4 Terpinjam'),
              _listItem('Spidol', '2 Terpinjam'),
              _listItem('Kabel HDMI', '0 Terpinjam'),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // ====== BOTTOM NAV BAR (pakai widget custom) ======
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
          // TODO: tambahkan navigasi antar page sesuai index
        },
      ),
    );
  }

  // ================= Helper Widgets (belum diubah banyak) =================

  Widget _statItem(String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.body1.copyWith(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _listItem(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient, // <-- core gradient
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.body2.copyWith(
          color: AppColors.mainGradientStart,
        ),
      ),
      trailing: Icon(
        Icons.more_horiz,
        color: AppColors.mainGradientStart,
      ),
    );
  }

  Widget _buildCalendar() {
    return GridView.builder(
      shrinkWrap: true, // ⬅️ biar tingginya mengikuti isi
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,  // jarak antar tanggal
        mainAxisSpacing: 12,
      ),
      itemCount: 35,
      itemBuilder: (context, index) {
        final day = index - 4; // start from 1 at index 4
        final bool isActive = day >= 1 && day <= 30;
        final bool isHighlighted = day == 13 || day == 14;

        Color? bgColor;
        Gradient? gradient;

        if (!isActive) {
          bgColor = Colors.grey[200];
        } else if (isHighlighted) {
          bgColor = Colors.green;
        } else {
          gradient = AppColors.mainGradient; // tetap pakai gradient brand
        }

        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              isActive ? day.toString().padLeft(2, '0') : '',
              style: AppTextStyles.body2.copyWith(
                color: isActive ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      },
    );
  }

  

  Widget _buildProfileMenuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 0), // just to keep alignment? (bisa dihapus kalau mau)
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Keluar',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: AppTextStyles.body2,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: AppTextStyles.body2.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGradientStart,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                'Keluar',
                style: AppTextStyles.button1.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
