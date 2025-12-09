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

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    // set displayed month to current month
    _displayMonth = DateTime(_now.year, _now.month, 1);
    // load calendar events from asset
    _loadCalendarEvents();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage(
                              'lib/assets/icons/foto-profil.jpg',
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
                              style: AppTextStyles.body2,
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
                    // Weekday header (Senin - Minggu)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Expanded(child: Center(child: Text('Senin'))),
                        Expanded(child: Center(child: Text('Selasa'))),
                        Expanded(child: Center(child: Text('Rabu'))),
                        Expanded(child: Center(child: Text('Kamis'))),
                        Expanded(child: Center(child: Text('Jumat'))),
                        Expanded(child: Center(child: Text('Sabtu'))),
                        Expanded(child: Center(child: Text('Minggu'))),
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
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.mainGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextButton.icon(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/admin_facilities',
                            ),
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
          ),

          // Blur overlay
          if (_showProfileMenu)
            GestureDetector(
              onTap: () => setState(() => _showProfileMenu = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // Dropdown menu
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
                            const CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(
                                'lib/assets/icons/foto-profil.jpg',
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
                      _buildProfileMenuItem(
                        Icons.dark_mode_outlined,
                        'Tema',
                        () {
                          setState(() => _showProfileMenu = false);
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(const SnackBar(content: Text('Tema')));
                        },
                      ),
                      _buildProfileMenuItem(
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
                        Icons.help_outline,
                        'Tentang Aplikasi',
                        () {
                          setState(() => _showProfileMenu = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tentang Aplikasi')),
                          );
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
              // Navigate to admin facilities so "Kelola Fasilitas" opens admin view
              Navigator.pushNamed(context, '/admin_facilities');
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

  Widget _listItem(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.body2.copyWith(color: AppColors.mainGradientStart),
      ),
      trailing: Icon(Icons.more_horiz, color: AppColors.mainGradientStart),
    );
  }

  Widget _legendBox({Gradient? gradient, Color? color, required String label}) {
    final box = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        gradient: gradient,
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Row(
      children: [
        box,
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _legendOutline({required String label}) {
    final box = Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return Row(
      children: [
        box,
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildCalendar() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (BuildContext context, int index) {
        final year = _displayMonth.year;
        final month = _displayMonth.month;
        final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sunday=0
        final daysInMonth = DateTime(year, month + 1, 0).day;
        final totalCells = ((firstWeekday + daysInMonth) / 7).ceil() * 7;
        final cellCount = totalCells;
        // ensure builder range covers cellCount
        if (index >= cellCount) return const SizedBox.shrink();

        final dayNumber = index - firstWeekday + 1;
        final bool isActive = dayNumber >= 1 && dayNumber <= daysInMonth;

        DateTime? tileDate;
        if (isActive) tileDate = DateTime(year, month, dayNumber);

        final bool isToday =
            tileDate != null &&
            tileDate.year == _now.year &&
            tileDate.month == _now.month &&
            tileDate.day == _now.day;

        DateTime? keyDate;
        if (tileDate != null) {
          keyDate = DateTime(tileDate.year, tileDate.month, tileDate.day);
        }

        final bool isMarked =
            keyDate != null && _eventsMap.containsKey(keyDate);

        Color? bgColor;
        Gradient? gradient;

        if (!isActive) {
          bgColor = Colors.grey[200];
        } else if (isMarked) {
          bgColor = Colors.orange.shade400;
        } else {
          gradient = AppColors.mainGradient;
        }

        return GestureDetector(
          onTap: () {
            if (isMarked && keyDate != null) {
              setState(() {
                _selectedEventDate = keyDate;
                _selectedEvent = _eventsMap[keyDate];
              });
            } else {
              setState(() {
                _selectedEvent = null;
                _selectedEventDate = null;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              gradient: gradient,
              borderRadius: BorderRadius.circular(8),
              border: isToday
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                isActive ? dayNumber.toString().padLeft(2, '0') : '',
                style: AppTextStyles.body2.copyWith(
                  color: isActive ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        );
      },
      itemCount: (() {
        final year = _displayMonth.year;
        final month = _displayMonth.month;
        final firstWeekday = DateTime(year, month, 1).weekday % 7;
        final daysInMonth = DateTime(year, month + 1, 0).day;
        return ((firstWeekday + daysInMonth) / 7).ceil() * 7;
      })(),
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
