// lib/presentation/home/user_home_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:spareapp_unhas/data/services/route_guard.dart';
import 'package:spareapp_unhas/data/services/auth_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/bottom_nav_bar.dart';

const Color primaryColor = Color(0xFFD32F2F);
const Color backgroundColor = Color(0xFFF8F9FA);

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentCarouselIndex = 0;
  int _selectedIndex = 0;
  late PageController _pageController;
  bool _showProfileMenu = false;

  // Untuk waktu real-time
  DateTime _now = DateTime.now();
  Timer? _timer;

  // Calendar events
  final Map<DateTime, Map<String, dynamic>> _eventsMap = {};
  Map<String, dynamic>? _selectedEvent;
  DateTime? _selectedEventDate;
  DateTime _displayMonth = DateTime.now();
  OverlayEntry? _popupOverlay;

  final List<String> _campusImages = [
    'lib/assets/pictures/campus1.jpg',
    'lib/assets/pictures/campus2.jpg',
    'lib/assets/pictures/campus3.jpg',
    'lib/assets/pictures/campus4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    Future.delayed(const Duration(seconds: 3), _autoPlayCarousel);

    // Inisialisasi waktu real-time
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });

    // Set displayed month to December 2025
    _displayMonth = DateTime(2025, 12, 1);

    // Add example events for December 2025
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _eventsMap[DateTime(2025, 12, 1)] = {
          'title': 'Awal Bulan Akademik',
          'date': '2025-12-01',
        };
        _eventsMap[DateTime(2025, 12, 5)] = {
          'title': 'Ujian Akhir Semester',
          'date': '2025-12-05',
        };
        _eventsMap[DateTime(2025, 12, 10)] = {
          'title': 'Seminar Hasil Penelitian',
          'date': '2025-12-10',
        };
        _eventsMap[DateTime(2025, 12, 15)] = {
          'title': 'Yudisium',
          'date': '2025-12-15',
        };
        _eventsMap[DateTime(2025, 12, 18)] = {
          'title': 'Wisuda Periode Desember',
          'date': '2025-12-18',
        };
        _eventsMap[DateTime(2025, 12, 20)] = {
          'title': 'Libur Semester',
          'date': '2025-12-20',
        };
        _eventsMap[DateTime(2025, 12, 25)] = {
          'title': 'Libur Natal',
          'date': '2025-12-25',
        };
        _eventsMap[DateTime(2025, 12, 31)] = {
          'title': 'Tutup Tahun Akademik',
          'date': '2025-12-31',
        };
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    _removePopup();
    super.dispose();
  }

  void _removePopup() {
    if (_popupOverlay != null) {
      _popupOverlay!.remove();
      _popupOverlay = null;
    }
  }

  void _autoPlayCarousel() {
    if (mounted) {
      final nextPage = (_currentCarouselIndex + 1) % _campusImages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      Future.delayed(const Duration(seconds: 5), _autoPlayCarousel);
    }
  }

  // Format waktu menjadi HH:MM:SS
  String get _formattedTime {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // Dapatkan nama user dari route guard
  String get _userName {
    final username = RouteGuard.username;
    if (RouteGuard.isAdmin) {
      return 'Admin';
    } else if (username != null) {
      return 'Mahasiswa $username';
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header sederhana: foto profil dan salam
                  _buildSimpleHeader(context),

                  // Profil User dengan Departemen, Waktu, dan Sesi Belajar
                  _buildUserProfileSection(),

                  // Carousel foto kampus
                  _buildCarouselSection(),

                  // Quick stats cards
                  _buildStatsSection(),

                  // Calendar section
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCalendar(),
                  ),

                  // Fasilitas populer
                  _buildPopularFacilities(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Blur overlay untuk menu profil
          if (_showProfileMenu)
            GestureDetector(
              onTap: () => setState(() => _showProfileMenu = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // Dropdown menu profil - HANYA Pengaturan Akun dan Keluar
          if (_showProfileMenu)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 280,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.95),
                        primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Foto profil di dropdown dengan border merah
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage(
                                  'lib/assets/pictures/profile.jpg',
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: primaryColor,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    RouteGuard.username ?? 'User',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
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
                      // HANYA Pengaturan Akun
                      _buildProfileMenuItem(
                        Icons.settings_outlined,
                        'Pengaturan Akun',
                        () {
                          setState(() => _showProfileMenu = false);
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(color: Colors.white24, height: 1),
                      ),
                      // HANYA Keluar
                      _buildProfileMenuItem(
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
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (int index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home_user');
              break;
            case 1:
              Navigator.pushNamed(context, '/facilities');
              break;
            case 2:
              Navigator.pushNamed(context, '/notification');
              break;
            case 3:
              Navigator.pushNamed(context, '/notification');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildSimpleHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Foto profil di kiri
          GestureDetector(
            onTap: () => setState(() => _showProfileMenu = !_showProfileMenu),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('lib/assets/pictures/profile.jpg'),
                child: Icon(Icons.person, color: primaryColor, size: 30),
              ),
            ),
          ),

          // Tulisan salam di tengah
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo,',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _userName,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ikon chat di kanan
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/chat'),
            icon: Icon(
              Icons.chat_bubble_outline,
              color: Colors.grey[700],
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Profil
          Text(
            'Statistik Anda',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Container untuk Departemen, Waktu, dan Sesi Belajar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.9),
                  primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Departemen
                _buildProfileItem('15', 'Departemen', Icons.school),

                // Pembatas vertikal
                Container(width: 1, height: 48, color: Colors.white24),

                // Waktu (real-time)
                _buildProfileItem(_formattedTime, 'Waktu', Icons.access_time),

                // Pembatas vertikal
                Container(width: 1, height: 48, color: Colors.white24),

                // Sesi Belajar
                _buildProfileItem('30', 'Sesi Belajar', Icons.book),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),

        // Nilai
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),

        // Label
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul Galeri Kampus tanpa tombol navigasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Galeri Kampus',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Carousel
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                  itemCount: _campusImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[200],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              _campusImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.photo,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.5),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fakultas Teknik',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Universitas Hasanuddin',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Titik indikator di BOTTOM (tengah bawah gambar)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _campusImages.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentCarouselIndex == index
                                ? Colors
                                      .white // Warna saat aktif
                                : Colors.white.withOpacity(
                                    0.5,
                                  ), // Warna saat tidak aktif
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Peminjaman',
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('15', 'Peminjaman\nAktif', Icons.event_note),
              _buildStatCard('7', 'Fasilitas\nTersedia', Icons.devices),
              _buildStatCard('3', 'Menunggu\nKonfirmasi', Icons.schedule),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildPopularFacilities() {
    final List<Map<String, dynamic>> facilities = [
      {
        'name': 'Ruangan Kelas',
        'available': '12 Tersedia',
        'icon': Icons.meeting_room,
        'color': Colors.blue,
      },
      {
        'name': 'Laboratorium',
        'available': '8 Tersedia',
        'icon': Icons.science,
        'color': Colors.green,
      },
      {
        'name': 'Auditorium',
        'available': '3 Tersedia',
        'icon': Icons.theaters,
        'color': Colors.orange,
      },
      {
        'name': 'Studio Multimedia',
        'available': '5 Tersedia',
        'icon': Icons.videocam,
        'color': Colors.purple,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fasilitas Populer',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 18,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/facilities'),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
                child: const Row(
                  children: [
                    Text('Lihat Semua'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: facilities.length,
              itemBuilder: (context, index) {
                final facility = facilities[index];
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(
                    right: index == facilities.length - 1 ? 0 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: facility['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            facility['icon'],
                            color: facility['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          facility['name'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          facility['available'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final year = _displayMonth.year;
    final month = _displayMonth.month;
    final firstDay = DateTime(year, month, 1);
    final firstWeekday = firstDay.weekday;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              DateFormat('MMMM yyyy').format(_displayMonth),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 2);
              final bool isCurrentMonth =
                  dayOffset >= 0 && dayOffset < daysInMonth;
              final dayNumber = isCurrentMonth ? dayOffset + 1 : 0;

              DateTime? cellDate;
              if (isCurrentMonth) {
                cellDate = DateTime(year, month, dayNumber);
              }

              final isToday =
                  cellDate != null &&
                  cellDate.year == _now.year &&
                  cellDate.month == _now.month &&
                  cellDate.day == _now.day;

              DateTime? eventKey;
              if (cellDate != null) {
                eventKey = DateTime(
                  cellDate.year,
                  cellDate.month,
                  cellDate.day,
                );
              }
              final hasEvent =
                  eventKey != null && _eventsMap.containsKey(eventKey);

              return GestureDetector(
                onTap: isCurrentMonth
                    ? () {
                        if (cellDate != null && hasEvent) {
                          final keyDate = DateTime(
                            cellDate.year,
                            cellDate.month,
                            cellDate.day,
                          );
                          setState(() {
                            _selectedEventDate = keyDate;
                            _selectedEvent = _eventsMap[keyDate];
                          });
                        }
                      }
                    : null,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrentMonth ? Colors.white : Colors.transparent,
                    border: Border.all(
                      color: isToday
                          ? primaryColor.withOpacity(0.8)
                          : isCurrentMonth
                          ? Colors.grey.shade300
                          : Colors.transparent,
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Text(
                          isCurrentMonth ? dayNumber.toString() : '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isToday ? primaryColor : Colors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      if (hasEvent)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
