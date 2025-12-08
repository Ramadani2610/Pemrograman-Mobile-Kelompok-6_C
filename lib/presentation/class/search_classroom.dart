import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SearchClassroomPage extends StatefulWidget {
  const SearchClassroomPage({super.key});

  @override
  State<SearchClassroomPage> createState() => _SearchClassroomPageState();
}

class _SearchClassroomPageState extends State<SearchClassroomPage> {
  final TextEditingController _searchController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  bool _isDefaultDateTime = true;

  // ---- Dummy data untuk contoh UI (nanti diganti backend) ----
  final Map<String, List<String>> _availableRoomsByFloor = {
    'Ground': ['G05', 'G06'],
    'Lantai 1': ['125', '119'],
    'Lantai 2': ['207', '210', '212', '214'],
    'Lantai 3': ['301', '309', '312'],
  };

  // Jadwal contoh untuk kelas 202
  final _room202Now = _ScheduleCardData(
    statusLabel: 'Sedang Berlangsung...',
    statusColor: Colors.red,
    room: '202',
    roomLabel: 'CR 100',
    time: '13:00 - 14:40',
    pillGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF3A78F2),
        Color(0xFF1A4EBE),
      ],
    ),
    pillText: 'Teknik Informatika 2023\nPemrograman Mobile C',
    department: 'Teknik Informatika',
  );

  final _room202Next = _ScheduleCardData(
    statusLabel: 'Akan Datang...',
    statusColor: Color(0xFF159C3E),
    room: '202',
    roomLabel: 'CR 100',
    time: '14:40 - 16:20',
    pillGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF33CC55),
        Color(0xFF159C3E),
      ],
    ),
    pillText: 'Teknik Elektro 2023\nMetode Penelitian',
    department: 'Teknik Elektro',
  );

  // Contoh jadwal jika user mencari nama mata kuliah
  final List<_ScheduleCardData> _courseToday = [
    _ScheduleCardData(
      statusLabel: 'Hari Ini',
      statusColor: AppColors.mainGradientStart,
      room: '202',
      roomLabel: 'CR 100',
      time: '13:00 - 14:40',
      pillGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3A78F2),
          Color(0xFF1A4EBE),
        ],
      ),
      pillText: 'Pemrograman Mobile C',
      department: 'Teknik Informatika',
    ),
    _ScheduleCardData(
      statusLabel: 'Hari Ini',
      statusColor: AppColors.mainGradientStart,
      room: '305',
      roomLabel: 'CR 305',
      time: '16:00 - 17:40',
      pillGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF3A78F2),
          Color(0xFF1A4EBE),
        ],
      ),
      pillText: 'Pemrograman Mobile C',
      department: 'teknik Informatika',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _isDefaultDateTime = false;
    });
  }

  String get _formattedDateTime {
    // 15 Nov 2025 / 14:11
    final dt = _selectedDateTime;
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${bulan[dt.month]} ${dt.year} / $jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ====== AppBar custom (back + chat) ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Kembali',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: ke halaman chat
                    },
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.mainGradientStart,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ====== Title ======
                    Text(
                      'Cari Kelas',
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 16),

                    // ====== Search Field ======
                    _buildSearchField(),

                    const SizedBox(height: 16),

                    // ====== Tanggal/Waktu + tombol kalender ======
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal/Waktu :',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (_isDefaultDateTime)
                                    Text(
                                      '(Default) ',
                                      style: AppTextStyles.body2.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  Flexible(
                                    child: Text(
                                      _formattedDateTime,
                                      style: AppTextStyles.body2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _pickDateTime,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppColors.mainGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mainGradientStart.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ====== Konten utama: tergantung query ======
                    if (query.isEmpty) ...[
                      _buildAvailableRoomsSection(),
                    ] else ...[
                      _buildSearchResultSection(query),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== WIDGET KECIL =====================

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: AppTextStyles.body1,
        decoration: InputDecoration(
          hintText: 'Cari Kelas/Mata Kuliah...',
          hintStyle: AppTextStyles.body2.copyWith(
            color: AppColors.secondaryText,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryText,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // --- state 1 & 2: list kelas tersedia ---
  Widget _buildAvailableRoomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelas Tersedia',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ..._availableRoomsByFloor.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _floorRoomList(entry.key, entry.value),
          ),
        ),
      ],
    );
  }

  Widget _floorRoomList(String floor, List<String> rooms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          floor,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rooms
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Text('•  '),
                      Text(
                        r,
                        style: AppTextStyles.body1,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // --- state 3: hasil pencarian ---
  Widget _buildSearchResultSection(String query) {
    final upper = query.toUpperCase();

    // Jika query numerik dan kita treat sebagai nomor kelas (contoh: 202)
    final bool looksLikeRoom =
        RegExp(r'^\d+$').hasMatch(upper) || upper.startsWith('G');

    if (looksLikeRoom) {
      if (upper == '202') {
        // contoh: ada jadwal untuk kelas 202
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScheduleCard(data: _room202Now),
            const SizedBox(height: 16),
            _ScheduleCard(data: _room202Next),
          ],
        );
      } else {
        // contoh: tidak ada jadwal di kelas ini
        return _emptyScheduleCard(
          title: 'Tidak ada kelas berjalan',
          message:
              'Saat ini tidak ada mata kuliah yang berlangsung di kelas $upper.',
        );
      }
    }

    // Kalau bukan nomor kelas → anggap nama mata kuliah
    // dan tampilkan jadwal hari ini (dummy data)
    if (_courseToday.isEmpty) {
      return _emptyScheduleCard(
        title: 'Jadwal tidak ditemukan',
        message:
            'Tidak ada jadwal mata kuliah "$query" pada hari ini. Coba ubah tanggal atau kata kunci.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal "$query" hari ini',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ..._courseToday.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ScheduleCard(data: d),
          ),
        ),
      ],
    );
  }

  Widget _emptyScheduleCard({
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.mainGradientStart,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== MODEL & CARD JADWAL =====================

class _ScheduleCardData {
  final String statusLabel;
  final Color statusColor;
  final String room;
  final String roomLabel;
  final String time;
  final Gradient pillGradient;
  final String pillText;
  final String department;

  _ScheduleCardData({
    required this.statusLabel,
    required this.statusColor,
    required this.room,
    required this.roomLabel,
    required this.time,
    required this.pillGradient,
    required this.pillText,
    required this.department,
  });
}

class _ScheduleCard extends StatelessWidget {
  final _ScheduleCardData data;

  const _ScheduleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final deptColor = AppColors.getDepartmentColor(data.department);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris atas: status + badge departemen
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.statusLabel,
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: data.statusColor,
                ),
              ),
              _DepartmentBadge(
                name: data.department,
                color: deptColor,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Info kelas + pill mata kuliah (seperti sebelumnya)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.room,
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    data.roomLabel,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.time,
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: data.pillGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    data.pillText,
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DepartmentBadge extends StatelessWidget {
  final String name;
  final Color color;

  const _DepartmentBadge({
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.7), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.titleText,
            ),
          ),
        ],
      ),
    );
  }
}


