import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spareapp_unhas/data/services/auth_service.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/bottom_nav_bar.dart';

const Color primaryColor = AppColors.mainGradientStart;
const Color backgroundColor = AppColors.backgroundColor;

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

  // --- DATA USER DINAMIS ---
  String _displayName = 'Loading...';
  String _displayRole = '';
  String? _photoUrl; // Variable untuk link foto
  // -------------------------

  DateTime _now = DateTime.now();
  Timer? _timer;

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
    _listenToUserData(); // Panggil fungsi listener realtime

    _pageController = PageController(viewportFraction: 0.85);
    Future.delayed(const Duration(seconds: 3), _autoPlayCarousel);

    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });

    _displayMonth = DateTime(2025, 12, 1);
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
      });
    });
  }

  // --- FUNGSI REALTIME LISTENER ---
  void _listenToUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
            (DocumentSnapshot doc) {
              if (doc.exists && mounted) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                setState(() {
                  _displayName = data['nama'] ?? 'User';
                  String roleRaw = data['role'] ?? 'mahasiswa';
                  _displayRole =
                      roleRaw[0].toUpperCase() + roleRaw.substring(1);

                  // Ambil URL foto terbaru
                  _photoUrl = data['photo_url'];
                });
              }
            },
            onError: (e) {
              debugPrint("Error listening to user data: $e");
            },
          );
    }
  }

  // HELPER UNTUK GAMBAR
  ImageProvider _getProfileImage() {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return NetworkImage(_photoUrl!);
    }
    return const AssetImage('lib/assets/pictures/profile.jpg');
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

  String get _formattedTime {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
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
                  _buildSimpleHeader(context),
                  _buildUserProfileSection(),
                  _buildCarouselSection(),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildCalendar(),
                  ),
                ],
              ),
            ),
          ),

          if (_showProfileMenu)
            GestureDetector(
              onTap: () => setState(() => _showProfileMenu = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

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
                            // FOTO DI DROPDOWN
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    _getProfileImage(), // <--- PAKAI HELPER
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _displayRole,
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
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 0,
        useRoleRouting: true,
      ),

    );
  }

  Widget _buildSimpleHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
              // FOTO DI HEADER (KIRI ATAS)
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: _getProfileImage(), // <--- PAKAI HELPER
              ),
            ),
          ),

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
                    _displayName,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
                _buildProfileItem('15', 'Departemen', Icons.school),
                Container(width: 1, height: 48, color: Colors.white24),
                _buildProfileItem(_formattedTime, 'Waktu', Icons.access_time),
                Container(width: 1, height: 48, color: Colors.white24),
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
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
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentCarouselIndex = index),
                  itemCount: _campusImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          _campusImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey[200]),
                        ),
                      ),
                    );
                  },
                ),
              ],
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
    final int firstDayIndex = firstDay.weekday - 1;
    final int daysInMonth = DateTime(year, month + 1, 0).day;

    final int totalNeeded = firstDayIndex + daysInMonth;
    final int rowCount = (totalNeeded / 7).ceil();
    final int itemCount = rowCount * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 6,
        crossAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final int dayOffset = index - firstDayIndex;
        final DateTime cellDate = DateTime(year, month, 1 + dayOffset);

        final bool isCurrentMonth =
            cellDate.year == year && cellDate.month == month;

        final bool isToday =
            cellDate.year == _now.year &&
            cellDate.month == _now.month &&
            cellDate.day == _now.day;

        final DateTime eventKey = DateTime(
          cellDate.year,
          cellDate.month,
          cellDate.day,
        );
        final bool hasEvent = _eventsMap.containsKey(eventKey);

        final String dayText = cellDate.day.toString();

        Color textColor;
        if (isToday) {
          textColor = Colors.white;
        } else if (isCurrentMonth) {
          textColor = AppColors.titleText;
        } else {
          textColor = Colors.grey.withOpacity(0.45);
        }

        return GestureDetector(
          onTap: () {
            _removePopup();
            if (hasEvent) {
              setState(() {
                _selectedEventDate = eventKey;
                _selectedEvent = _eventsMap[eventKey];
              });
              _showPopupOverlay(context, eventKey, _eventsMap[eventKey]!);
            } else {
              setState(() {
                _selectedEventDate = null;
                _selectedEvent = null;
              });
            }
          },
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isToday)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.mainGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mainGradientStart.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        dayText,
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else if (isCurrentMonth)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.mainGradient,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1.8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          dayText,
                          style: AppTextStyles.body2.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.withOpacity(0.22)),
                    ),
                    child: Center(
                      child: Text(
                        dayText,
                        style: AppTextStyles.caption.copyWith(color: textColor),
                      ),
                    ),
                  ),

                if (hasEvent)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mainGradientStart,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showPopupOverlay(
    BuildContext context,
    DateTime date,
    Map<String, dynamic> event,
  ) {
    _removePopup();

    final overlayState = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _popupOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: position.dy - 100,
        left: position.dx + 50,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event['title']?.toString() ?? 'Kegiatan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_popupOverlay!);

    Future.delayed(const Duration(seconds: 3), () {
      _removePopup();
    });
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
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: AppTextStyles.body2.copyWith(color: Colors.white),
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
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService().logout();

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
