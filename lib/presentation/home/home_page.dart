import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

// --- IMPORT WAJIB UNTUK DATA USER ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
import 'package:spareapp_unhas/data/services/route_guard.dart';
import 'package:spareapp_unhas/data/services/auth_service.dart';
// ------------------------------------

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
  int _selectedIndex = 0;

  // Variabel Data User Dinamis
  String _currentName = 'Admin';
  String _currentEmail = '';
  String? _photoUrl; // Variable untuk menyimpan link foto

  // Running clock state
  DateTime _now = DateTime.now();
  Timer? _timer;

  // Calendar events
  final Map<DateTime, Map<String, dynamic>> _eventsMap = {};
  Map<String, dynamic>? _selectedEvent;
  DateTime? _selectedEventDate;
  DateTime _displayMonth = DateTime.now();
  OverlayEntry? _popupOverlay;

  @override
  void initState() {
    super.initState();

    // 1. PANGGIL LISTENER REALTIME
    _listenToUserData();

    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });

    _displayMonth = DateTime(2025, 12, 1);
    _loadCalendarEvents();

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

  // --- FUNGSI REALTIME LISTENER (UPDATE OTOMATIS) ---
  void _listenToUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Ambil Email langsung dari Auth (backup)
      _currentEmail = user.email ?? 'Tidak ada email';

      // Dengarkan perubahan di Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen(
            (DocumentSnapshot doc) {
              if (doc.exists && mounted) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                setState(() {
                  _currentName = data['nama'] ?? 'Admin';
                  // Update foto jika ada perubahan di database
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

  // HELPER UNTUK GAMBAR PROFIL
  ImageProvider _getProfileImage() {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return NetworkImage(_photoUrl!); // Pakai foto Cloudinary
    }
    return const AssetImage(
      'lib/assets/icons/foto-profil.jpg',
    ); // Default asset
  }
  // -----------------------------------

  @override
  void dispose() {
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

  String get _formattedTime {
    final h = _now.hour.toString().padLeft(2, '0');
    final m = _now.minute.toString().padLeft(2, '0');
    final s = _now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Future<void> _loadCalendarEvents() async {
    try {
      final raw = await rootBundle.loadString(
        'lib/assets/calendar_events.json',
      );
      final data = jsonDecode(raw);
      final List events = data['events'] ?? [];
      final Map<DateTime, Map<String, dynamic>> parsed = {};
      for (final e in events) {
        try {
          final date = DateTime.parse(e['date']);
          final key = DateTime(date.year, date.month, date.day);
          parsed[key] = Map<String, dynamic>.from(e as Map);
        } catch (_) {
          // ignore malformed
        }
      }
      setState(() {
        _eventsMap.clear();
        _eventsMap.addAll(parsed);
      });
    } catch (e) {
      // ignore, keep empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: <Widget>[
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => setState(
                            () => _showProfileMenu = !_showProfileMenu,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.mainGradientStart,
                                width: 2,
                              ),
                            ),
                            // FOTO PROFIL DI HEADER (KIRI ATAS)
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  _getProfileImage(), // <--- PAKAI HELPER
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.mainGradientStart,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Greeting (UPDATED)
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Halo, ',
                            style: AppTextStyles.heading1,
                          ),
                          TextSpan(
                            // TAMPILKAN NAMA ASLI DI SINI
                            text: '$_currentName!',
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.mainGradientStart,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Stats card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: AppColors.mainGradient,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _statItem('15', 'Departemen'),
                          Container(
                            width: 1,
                            height: 48,
                            color: Colors.white24,
                          ),
                          _statItem(_formattedTime, 'Waktu'),
                          Container(
                            width: 1,
                            height: 48,
                            color: Colors.white24,
                          ),
                          _statItem('30', 'Sesi Belajar'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Statistics header
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
                        boxShadow: <BoxShadow>[
                          BoxShadow(color: AppColors.cardShadow, blurRadius: 8),
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

                    // Calendar header with month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Kalender Akademik',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                setState(() {
                                  _displayMonth = DateTime(
                                    _displayMonth.year,
                                    _displayMonth.month - 1,
                                    1,
                                  );
                                });
                              },
                              icon: Icon(
                                Icons.chevron_left,
                                color: AppColors.mainGradientStart,
                              ),
                            ),
                            Text(
                              DateFormat.yMMMM().format(_displayMonth),
                              style: AppTextStyles.body2.copyWith(
                                color:
                                    _displayMonth.year == 2025 &&
                                        _displayMonth.month == 12
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                setState(() {
                                  _displayMonth = DateTime(
                                    _displayMonth.year,
                                    _displayMonth.month + 1,
                                    1,
                                  );
                                });
                              },
                              icon: Icon(
                                Icons.chevron_right,
                                color: AppColors.mainGradientStart,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Weekday header with initials
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(child: Center(child: Text('S'))),
                        Expanded(child: Center(child: Text('S'))),
                        Expanded(child: Center(child: Text('R'))),
                        Expanded(child: Center(child: Text('K'))),
                        Expanded(child: Center(child: Text('J'))),
                        Expanded(child: Center(child: Text('S'))),
                        Expanded(child: Center(child: Text('M'))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildCalendar(),
                    const SizedBox(height: 12),
                    // Selected event detail (shown when user taps a marked date)
                    if (_selectedEvent != null && _selectedEventDate != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'dd MMMM yyyy',
                                    ).format(_selectedEventDate!),
                                    style: AppTextStyles.body1.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _selectedEvent!['title']?.toString() ??
                                        'Keterangan',
                                    style: AppTextStyles.body2,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _weekdayName(_selectedEventDate!),
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),

                    // Package header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Paket Fasilitas',
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Horizontal scrollable facility cards
                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          _facilityCard(
                            'Paket Fasilitas',
                            '15 Terpinjam',
                            'lib/assets/icons/proyektor.jpg',
                          ),
                          _facilityCard(
                            'Remote Tv',
                            '5 Terpinjam',
                            'lib/assets/icons/remote-tv.jpg',
                          ),
                          _facilityCard(
                            'Kabel Terminal',
                            '4 Terpinjam',
                            'lib/assets/icons/terminal colokan.jpg',
                          ),
                          _facilityCard(
                            'Spidol',
                            '2 Terpinjam',
                            'lib/assets/icons/spidol.jpeg',
                          ),
                          _facilityCard(
                            'Kabel HDMI',
                            '0 Terpinjam',
                            'lib/assets/icons/kabel hdmi.jpg',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          // Blur overlay
          if (_showProfileMenu)
            GestureDetector(
              onTap: () => setState(() => _showProfileMenu = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // Dropdown menu (simplified)
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
                    gradient: AppColors.mainGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              // FOTO DI DALAM MENU DROPDOWN
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    _getProfileImage(), // <--- PAKAI HELPER
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // --- UPDATED NAME ---
                                  Text(
                                    _currentName,
                                    style: AppTextStyles.body1.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // --- UPDATED EMAIL ---
                                  Text(
                                    _currentEmail,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withOpacity(0.8),
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (int index) {
          setState(() => _selectedIndex = index);
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
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _statItem(String title, String subtitle) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
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
          style: AppTextStyles.caption.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _facilityCard(String title, String subtitle, String imagePath) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/admin_facilities'),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.mainGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.mainGradientStart.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 80,
                width: double.infinity,
                color: Colors.white.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    Icons.devices_other,
                    size: 40,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  String _weekdayName(DateTime d) {
    const names = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return names[d.weekday - 1];
  }
}
