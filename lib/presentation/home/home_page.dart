import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
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

  // Running clock state
  DateTime _now = DateTime.now();
  Timer? _timer;
  // Calendar events (loaded from assets) -> map date -> event data
  final Map<DateTime, Map<String, dynamic>> _eventsMap = {};
  Map<String, dynamic>? _selectedEvent;
  DateTime? _selectedEventDate;
  DateTime _displayMonth = DateTime.now();
  OverlayEntry? _popupOverlay;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    // set displayed month to December 2025
    _displayMonth = DateTime(2025, 12, 1);
    // load calendar events from asset
    _loadCalendarEvents();

    // Add example events for December 2025
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Contoh kegiatan kampus Desember 2025
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
                            child: const CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(
                                'lib/assets/icons/foto-profil.jpg',
                              ),
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

                    // Greeting
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Halo, ',
                            style: AppTextStyles.heading1,
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
                            'lib/assets/icons/facility1.jpg',
                          ),
                          _facilityCard(
                            'Remote Tv',
                            '5 Terpinjam',
                            'lib/assets/icons/facility2.jpg',
                          ),
                          _facilityCard(
                            'Kabel Terminal',
                            '4 Terpinjam',
                            'lib/assets/icons/facility3.jpg',
                          ),
                          _facilityCard(
                            'Spidol',
                            '2 Terpinjam',
                            'lib/assets/icons/facility4.jpg',
                          ),
                          _facilityCard(
                            'Kabel HDMI',
                            '0 Terpinjam',
                            'lib/assets/icons/facility5.jpg',
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
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                  'lib/assets/icons/foto-profil.jpg',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
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
    final firstWeekday = firstDay.weekday; // 1 (Senin) sampai 7 (Minggu)
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Cek apakah bulan yang ditampilkan adalah Desember 2025
    final bool isDecember2025 = year == 2025 && month == 12;

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
          // Header bulan dengan bulatan besar di tengah
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                _displayMonth.month.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Grid kalender dengan ukuran lebih kecil
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.0,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 42, // 6 minggu * 7 hari
            itemBuilder: (context, index) {
              // Hitung tanggal untuk sel ini
              final dayOffset =
                  index -
                  (firstWeekday -
                      2); // Disesuaikan agar Minggu di kolom pertama
              final bool isCurrentMonth =
                  dayOffset >= 0 && dayOffset < daysInMonth;
              final dayNumber = isCurrentMonth ? dayOffset + 1 : 0;

              DateTime? cellDate;
              if (isCurrentMonth) {
                cellDate = DateTime(year, month, dayNumber);
              }

              // Cek apakah hari ini
              final isToday =
                  cellDate != null &&
                  cellDate.year == _now.year &&
                  cellDate.month == _now.month &&
                  cellDate.day == _now.day;

              // Cek apakah ada event
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
                        _removePopup();
                        if (cellDate != null) {
                          final keyDate = DateTime(
                            cellDate.year,
                            cellDate.month,
                            cellDate.day,
                          );
                          if (_eventsMap.containsKey(keyDate)) {
                            setState(() {
                              _selectedEventDate = keyDate;
                              _selectedEvent = _eventsMap[keyDate];
                            });

                            // Tampilkan popup overlay
                            _showPopupOverlay(
                              context,
                              keyDate,
                              _eventsMap[keyDate]!,
                            );
                          } else {
                            setState(() {
                              _selectedEvent = null;
                              _selectedEventDate = null;
                            });
                          }
                        }
                      }
                    : null,
                child: Container(
                  margin: const EdgeInsets.all(1),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Container utama
                      Container(
                        width: 28, // Ukuran lebih kecil
                        height: 28, // Ukuran lebih kecil
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrentMonth
                              ? Colors.white
                              : Colors.transparent,
                          border: Border.all(
                            color: isToday
                                ? Colors.red.withOpacity(
                                    0.8,
                                  ) // Border merah untuk hari ini
                                : isCurrentMonth
                                ? Colors
                                      .grey
                                      .shade300 // Border abu-abu tipis untuk hari aktif
                                : Colors.transparent,
                            width: isToday ? 2 : 1,
                          ),
                          gradient: isToday
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.red.withOpacity(0.1),
                                    Colors.white,
                                  ],
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            isCurrentMonth ? dayNumber.toString() : '',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrentMonth
                                  ? (isToday
                                        ? Colors
                                              .red // Warna merah untuk hari ini
                                        : isDecember2025 && dayOffset < 0
                                        ? Colors
                                              .grey // Warna abu-abu untuk hari sebelum Desember 2025
                                        : Colors.black)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),

                      // Titik merah untuk menandai event (ditempatkan di bawah)
                      if (hasEvent && isCurrentMonth)
                        Positioned(
                          bottom: 1,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Legenda
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Legenda hari ini
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hari Ini',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Legenda event
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
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
        top: position.dy - 100, // Atur posisi popup
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

    // Hilangkan popup setelah 3 detik
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/login');
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
