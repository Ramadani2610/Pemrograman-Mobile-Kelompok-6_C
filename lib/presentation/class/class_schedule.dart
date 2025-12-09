import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  // ====== DUMMY DATA SEMENTARA ======
  // runtime helper
  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  final List<String> _floors = ['Ground', 'Lantai 1', 'Lantai 2', 'Lantai 3'];
  int _selectedFloorIndex = 0;
  String _searchKeyword = '';

  late final List<RoomSchedule> _allRooms;

  @override
  void initState() {
    super.initState();

    // contoh dummy jadwal:
    _allRooms = [
      RoomSchedule(
        roomCode: 'G01',
        buildingCode: 'CR 100',
        floor: 'Ground',
        slots: [
          ClassSlot(
            startTime: const TimeOfDay(hour: 7, minute: 50),
            endTime: const TimeOfDay(hour: 8, minute: 40),
            department: 'Teknik Mesin',
            courseName: 'Mekanika Kuantum',
          ),
          ClassSlot(
            startTime: const TimeOfDay(hour: 9, minute: 30),
            endTime: const TimeOfDay(hour: 10, minute: 20),
            department: 'Teknik Metalurgi dan Material',
            courseName: 'Matematika Dasar I',
          ),
          ClassSlot(
            startTime: const TimeOfDay(hour: 14, minute: 40),
            endTime: const TimeOfDay(hour: 15, minute: 30),
            department: 'Teknik Kelautan',
            courseName: 'Matematika Dasar II',
          ),
        ],
      ),
      RoomSchedule(
        roomCode: 'G02',
        buildingCode: 'CR 100',
        floor: 'Ground',
        slots: [
          ClassSlot(
            startTime: const TimeOfDay(hour: 8, minute: 40),
            endTime: const TimeOfDay(hour: 10, minute: 20),
            department: 'Teknik Informatika',
            courseName: 'Pemrograman Mobile C',
          ),
        ],
      ),
      RoomSchedule(
        roomCode: '101',
        buildingCode: 'CR 100',
        floor: 'Lantai 1',
        slots: [
          ClassSlot(
            startTime: const TimeOfDay(hour: 7, minute: 50),
            endTime: const TimeOfDay(hour: 9, minute: 30),
            department: 'Teknik Sipil',
            courseName: 'Struktur Beton I',
          ),
        ],
      ),
      // tambahkan ruangan lain sesuai kebutuhan...
    ];
  }

  @override
  Widget build(BuildContext context) {
    final selectedFloor = _floors[_selectedFloorIndex];

    final roomsOnFloor = _allRooms
        .where((room) => room.floor == selectedFloor)
        .where((room) {
          if (_searchKeyword.isEmpty) return true;
          final kw = _searchKeyword.toLowerCase();
          return room.roomCode.toLowerCase().contains(kw) ||
              room.buildingCode.toLowerCase().contains(kw) ||
              room.slots.any(
                (s) =>
                    s.courseName.toLowerCase().contains(kw) ||
                    s.department.toLowerCase().contains(kw),
              );
        })
        .toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
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
                    'Jadwal Kelas',
                    style: AppTextStyles.heading2,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.mainGradientStart,
                    ),
                  ),
                ],
              ),
            ),

            // ===== FLOOR TABS (chip) =====
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: List.generate(_floors.length, (index) {
                  final isSelected = index == _selectedFloorIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        _floors[index],
                        style: AppTextStyles.body2.copyWith(
                          color:
                              isSelected ? Colors.white : AppColors.titleText,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.mainGradientStart,
                      backgroundColor: const Color(0xFFF4F4F4),
                      onSelected: (_) {
                        setState(() {
                          _selectedFloorIndex = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),

            // ===== SEARCH BAR =====
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchKeyword = val;
                  });
                },
                style: AppTextStyles.body1,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.secondaryText, size: 20),
                  hintText: 'Cari kelas / mata kuliah...',
                  hintStyle: AppTextStyles.body2
                      .copyWith(color: AppColors.secondaryText),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppColors.mainGradientStart,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // ===== LIST JADWAL PER RUANG =====
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemBuilder: (context, index) {
                  final room = roomsOnFloor[index];
                  return _RoomScheduleCard(
                    room: room,
                    timeToMinutes: _timeToMinutes,
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: roomsOnFloor.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== MODEL LOCAL =====================

class ClassSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String department;
  final String courseName;

  ClassSlot({
    required this.startTime,
    required this.endTime,
    required this.department,
    required this.courseName,
  });
}

class RoomSchedule {
  final String roomCode;
  final String buildingCode;
  final String floor;
  final List<ClassSlot> slots;

  RoomSchedule({
    required this.roomCode,
    required this.buildingCode,
    required this.floor,
    required this.slots,
  });
}

// ===================== WIDGET CARD PER RUANG =====================

class _RoomScheduleCard extends StatelessWidget {
  _RoomScheduleCard({
    required this.room,
    required this.timeToMinutes,
  });

  final RoomSchedule room;
  final int Function(TimeOfDay) timeToMinutes;

  // range hari 07:50 - 17:10
  final TimeOfDay _dayStart = const TimeOfDay(hour: 7, minute: 50);
  final TimeOfDay _dayEnd = const TimeOfDay(hour: 17, minute: 10);

  static const double _pxPerMinute = 2.0;

  @override
  Widget build(BuildContext context) {
    final totalMinutes =
        timeToMinutes(_dayEnd) - timeToMinutes(_dayStart);
    final totalWidth = totalMinutes * _pxPerMinute;

    final timeTicks = <TimeOfDay>[
      const TimeOfDay(hour: 7, minute: 50),
      const TimeOfDay(hour: 8, minute: 40),
      const TimeOfDay(hour: 9, minute: 30),
      const TimeOfDay(hour: 10, minute: 20),
      const TimeOfDay(hour: 11, minute: 10),
      const TimeOfDay(hour: 12, minute: 0),
      const TimeOfDay(hour: 13, minute: 0),
      const TimeOfDay(hour: 13, minute: 50),
      const TimeOfDay(hour: 14, minute: 40),
      const TimeOfDay(hour: 15, minute: 30),
      const TimeOfDay(hour: 16, minute: 20),
      const TimeOfDay(hour: 17, minute: 10),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label ruang di kiri
          SizedBox(
            width: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomCode,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 2),
                Text(
                  room.buildingCode,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 4),
                Icon(Icons.meeting_room_outlined,
                    size: 16, color: AppColors.secondaryText),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Timeline di kanan (scroll horizontal)
          Expanded(
            child: SizedBox(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  child: Stack(
                    children: [
                      // garis waktu + titik jam
                      Positioned.fill(
                        top: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 18,
                              child: Stack(
                                children: timeTicks.map((t) {
                                  final left = (timeToMinutes(t) -
                                          timeToMinutes(_dayStart)) *
                                      _pxPerMinute;
                                  return Positioned(
                                    left: left,
                                    top: 0,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatTime(t),
                                          style: AppTextStyles.caption
                                              .copyWith(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // garis dasar timeline
                            Container(
                              height: 1,
                              color: const Color(0xFFE0E0E0),
                            ),
                          ],
                        ),
                      ),

                      // slot-slot mata kuliah
                      ...room.slots.map((slot) {
                        final start =
                            timeToMinutes(slot.startTime);
                        final end = timeToMinutes(slot.endTime);
                        final left = (start -
                                timeToMinutes(_dayStart)) *
                            _pxPerMinute;
                        final width =
                            (end - start) * _pxPerMinute;

                        final deptColor = AppColors.getDepartmentColor(
                          slot.department,
                        );

                        return Positioned(
                          left: left,
                          top: 28,
                          child: Container(
                            width: width,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: deptColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: FittedBox(
                              alignment: Alignment.centerLeft,
                              fit: BoxFit.scaleDown,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot.department,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    slot.courseName,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
