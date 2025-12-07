import 'package:flutter/material.dart';
// import kept intentionally for future use if needed

const Color primaryColor = Color(0xFFD32F2F);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showProfileMenu = false;
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

              // Profile Dropdown Menu
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
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFD32F2F), Color(0xFFE74C3C)],
                        ),
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'admin@gmail.com',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withOpacity(
                                                0.8,
                                              ),
                                              fontFamily: 'Poppins',
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
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ) ??
                            const TextStyle(
                              fontSize: 28,
                              fontFamily: 'Poppins',
                            ),
                      ),
                      TextSpan(
                        text: 'Admin!',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ) ??
                            const TextStyle(
                              fontSize: 28,
                              fontFamily: 'Poppins',
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Stats Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFFF6B6B)],
                  ),
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

              // Statistik Peminjaman (chart placeholder)
              Text(
                'Statistik Peminjaman',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Chart Placeholder',
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Kalender Akademik (simple grid)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kalender Akademik',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'November 2025',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontFamily: 'Poppins'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCalendar(),

              const SizedBox(height: 20),

              // List of items (sample)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paket Fasilitas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/admin_facilities'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Kelola', style: TextStyle(fontSize: 12)),
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

      // Bottom navigation bar styled similar to the mock
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFFF6B6B)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home, color: Colors.white),
            Icon(Icons.shopping_basket_outlined, color: Colors.white),
            Icon(Icons.notifications_none, color: Colors.white),
            Icon(Icons.receipt_long, color: Colors.white),
            Icon(Icons.settings, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontFamily: 'Poppins'),
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
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFFF6B6B)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
      ),
      trailing: const Icon(Icons.more_horiz, color: Colors.red),
    );
  }

  Widget _buildCalendar() {
    // Simple calendar grid (1..30)
    return SizedBox(
      height: 220,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.1,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: 35,
        itemBuilder: (context, index) {
          // show days 26-30 previous month as empty small squares
          final day = index - 4; // start from 1 at index 4
          final bool isActive = day >= 1 && day <= 30;
          final bool isHighlighted = day == 13 || day == 14;
          return Container(
            decoration: BoxDecoration(
              color: isActive
                  ? (isHighlighted ? Colors.green : const Color(0xFFD32F2F))
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              gradient: isActive && !isHighlighted
                  ? const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFD32F2F)],
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                isActive ? day.toString().padLeft(2, '0') : '',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        },
      ),
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
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontFamily: 'Poppins',
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
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
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text(
                'Keluar',
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
