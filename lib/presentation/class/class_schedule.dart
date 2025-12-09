import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<ClassSchedulePage> createState() => _ClassSchedulePageState();
}

class _ClassSchedulePageState extends State<ClassSchedulePage> {
  // ====== RUNTIME HELPER ======
  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  final List<String> _floors = ['Ground', 'Lantai 1', 'Lantai 2', 'Lantai 3'];
  int _selectedFloorIndex = 0;

  String _searchKeyword = '';
  String? _selectedDepartment; // null = semua departemen

  late final List<RoomSchedule> _allRooms;
  late final List<String> _departments;

  @override
  void initState() {
    super.initState();

    // ====== DUMMY DATA SEMENTARA ======
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

    // generate daftar departemen unik dari semua slot
    final deptSet = <String>{};
    for (final room in _allRooms) {
      for (final slot in room.slots) {
        deptSet.add(slot.department);
      }
    }
    _departments = deptSet.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFloor = _floors[_selectedFloorIndex];

    // 1. filter berdasarkan lantai
    List<RoomSchedule> roomsOnFloor =
        _allRooms.where((room) => room.floor == selectedFloor).toList();

    // 2. filter berdasarkan keyword
    if (_searchKeyword.isNotEmpty) {
      final kw = _searchKeyword.toLowerCase();
      roomsOnFloor = roomsOnFloor.where((room) {
        final inRoom = room.roomCode.toLowerCase().contains(kw) ||
            room.buildingCode.toLowerCase().contains(kw);
        final inSlots = room.slots.any(
          (s) =>
              s.courseName.toLowerCase().contains(kw) ||
              s.department.toLowerCase().contains(kw),
        );
        return inRoom || inSlots;
      }).toList();
    }

    // 3. filter berdasarkan departemen (jika dipilih)
    if (_selectedDepartment != null) {
      final dept = _selectedDepartment!;
      roomsOnFloor = roomsOnFloor
          .map((room) {
            final filteredSlots =
                room.slots.where((s) => s.department == dept).toList();
            if (filteredSlots.isEmpty) return null;
            return RoomSchedule(
              roomCode: room.roomCode,
              buildingCode: room.buildingCode,
              floor: room.floor,
              slots: filteredSlots,
            );
          })
          .whereType<RoomSchedule>()
          .toList();
    }

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

            // ===== FLOOR TABS (Ground / Lantai 1 / ...) =====
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: List.generate(_floors.length, (index) {
                  final isSelected = index == _selectedFloorIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _gradientChip(
                      label: _floors[index],
                      isSelected: isSelected,
                      onTap: () {
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
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.secondaryText,
                    size: 20,
                  ),
                  hintText: 'Cari kelas / mata kuliah...',
                  hintStyle: AppTextStyles.body2
                      .copyWith(color: AppColors.secondaryText),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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

            // ===== DEPARTMENT FILTER =====
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Filter Departemen',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // chip "Semua"
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _outlinedChip(
                      label: 'Semua',
                      isSelected: _selectedDepartment == null,
                      onTap: () {
                        setState(() {
                          _selectedDepartment = null;
                        });
                      },
                    ),
                  ),
                  ..._departments.map((dept) {
                    final isSelected = _selectedDepartment == dept;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _outlinedChip(
                        label: dept,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedDepartment =
                                isSelected ? null : dept;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ===== LIST JADWAL PER RUANG =====
            Expanded(
              child: roomsOnFloor.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada jadwal untuk filter yang dipilih.',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final room = roomsOnFloor[index];
                        return _RoomScheduleCard(
                          room: room,
                          timeToMinutes: _timeToMinutes,
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemCount: roomsOnFloor.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== CHIP DENGAN GRADIENT UNTUK LANTAI ======
  Widget _gradientChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.mainGradient : null,
          color: isSelected ? null : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: isSelected ? Colors.white : AppColors.titleText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ====== CHIP OUTLINE UNTUK FILTER DEPARTEMEN ======
  Widget _outlinedChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color borderColor =
        isSelected ? AppColors.mainGradientStart : AppColors.border;

    final Color textColor =
        isSelected ? AppColors.mainGradientStart : AppColors.titleText;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
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
      padding: const EdgeInsets.all(12),
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
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.roomCode,
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  room.buildingCode,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.meeting_room_outlined,
                  size: 16,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Timeline di kanan (scroll horizontal)
          Expanded(
            child: SizedBox(
              height: 92,
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
                              height: 22,
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
                          top: 30,
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
