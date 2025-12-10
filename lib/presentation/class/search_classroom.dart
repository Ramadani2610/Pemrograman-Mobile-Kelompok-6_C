import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SearchClassroomPage extends StatefulWidget {
  const SearchClassroomPage({super.key});

  @override
  State<SearchClassroomPage> createState() => _SearchClassroomPageState();
}

class _SearchClassroomPageState extends State<SearchClassroomPage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _searchKeyword = '';

  // Dummy data ruangan sementara
  final List<_RoomAvailability> _allRooms = const [
    _RoomAvailability(
      name: 'G01',
      floor: 'Ground',
      capacity: 40,
      isAvailable: true,
    ),
    _RoomAvailability(
      name: 'G02',
      floor: 'Ground',
      capacity: 35,
      isAvailable: false,
    ),
    _RoomAvailability(
      name: '101',
      floor: 'Lantai 1',
      capacity: 45,
      isAvailable: false,
    ),
    _RoomAvailability(
      name: '102',
      floor: 'Lantai 1',
      capacity: 50,
      isAvailable: true,
    ),
    _RoomAvailability(
      name: '201',
      floor: 'Lantai 2',
      capacity: 40,
      isAvailable: false,
    ),
    _RoomAvailability(
      name: '301',
      floor: 'Lantai 3',
      capacity: 60,
      isAvailable: true,
    ),
  ];

  // urutan lantai yang kita pakai untuk section
  final List<String> _floorOrder = const ['Ground', 'Lantai 1', 'Lantai 2', 'Lantai 3'];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (result != null) {
      setState(() => _selectedDate = result);
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (result != null) {
      setState(() => _selectedTime = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _selectedDate == null
        ? 'Pilih Tanggal'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}-'
          '${_selectedDate!.month.toString().padLeft(2, '0')}-'
          '${_selectedDate!.year}';

    final timeLabel = _selectedTime == null
        ? 'Pilih Waktu'
        : _selectedTime!.format(context);

    // 1) Ambil hanya ruangan yang TERPAKAI
    final occupiedRooms = _allRooms.where((room) => !room.isAvailable).toList();

    // 2) Filter berdasarkan keyword
    final kw = _searchKeyword.toLowerCase();
    final filteredOccupied = occupiedRooms.where((room) {
      if (kw.isEmpty) return true;
      return room.name.toLowerCase().contains(kw) ||
          room.floor.toLowerCase().contains(kw);
    }).toList();

    // 3) Kelompokkan berdasarkan lantai
    final Map<String, List<_RoomAvailability>> roomsByFloor = {};
    for (final room in filteredOccupied) {
      roomsByFloor.putIfAbsent(room.floor, () => []).add(room);
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
                    'Cari Ruang Kelas',
                    style: AppTextStyles.heading2,
                  ),
                  const Spacer(),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== SUBTITLE =====
                    Text(
                      'Lihat kelas yang sedang terpakai berdasarkan tanggal, waktu, atau nama ruangan.',
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 16),

                    // ===== TANGGAL / WAKTU =====
                    Text(
                      'Tanggal / Waktu',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _PickerField(
                            label: dateLabel,
                            icon: Icons.calendar_today_outlined,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PickerField(
                            label: timeLabel,
                            icon: Icons.access_time,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ===== SEARCH BAR =====
                    Text(
                      'Pencarian',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
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
                        hintText: 'Cari berdasarkan ruangan / lantai...',
                        hintStyle: AppTextStyles.body2
                            .copyWith(color: AppColors.secondaryText),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.mainGradientStart,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ===== SECTION TITLE UTAMA =====
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kelas yang Sedang Terpakai',
                          style: AppTextStyles.heading3.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (_selectedDate != null || _selectedTime != null)
                          Text(
                            'Sesuai waktu yang dipilih',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (roomsByFloor.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Center(
                          child: Text(
                            'Tidak ada kelas yang sedang terpakai.',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.secondaryText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      // Loop per lantai berdasarkan urutan yang diinginkan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _floorOrder
                            .where((floor) =>
                                roomsByFloor[floor]?.isNotEmpty ?? false)
                            .map((floor) {
                          final rooms = roomsByFloor[floor]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                floor,
                                style: AppTextStyles.body1.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                itemCount: rooms.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 4 / 3,
                                ),
                                itemBuilder: (context, index) {
                                  final room = rooms[index];
                                  return _buildRoomCard(
                                    roomName: room.name,
                                    floorLabel: room.floor,
                                    capacity: room.capacity,
                                    isAvailable: true,
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                            ],
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== WIDGET: ROOM CARD ======================

  Widget _buildRoomCard({
    required String roomName,
    required String floorLabel,
    required int capacity,
    required bool isAvailable,
  }) {
    // Untuk halaman ini kita memang ingin menampilkan TERPAKAI saja,
    // tapi parameter isAvailable tetap disiapkan kalau nanti dipakai ulang.
    final statusColor = isAvailable ? Colors.green : Colors.red;
    final statusText = isAvailable ? 'Tersedia' : 'Terpakai';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isAvailable
              ? AppColors.greenGradient.colors.first
              : AppColors.mainGradientStart.withOpacity(0.6),
          width: 0.7,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status dot + text
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: AppTextStyles.caption.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Nama ruangan
          Text(
            roomName,
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),

          // Lantai
          Text(
            floorLabel,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),

          // Kapasitas
          Row(
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                'Kapasitas $capacity orang',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ====================== PICKER FIELD WIDGET ======================

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: label.startsWith('Pilih')
                      ? AppColors.secondaryText
                      : AppColors.titleText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== MODEL LOCAL SEDERHANA ======================

class _RoomAvailability {
  final String name;
  final String floor;
  final int capacity;
  final bool isAvailable;

  const _RoomAvailability({
    required this.name,
    required this.floor,
    required this.capacity,
    required this.isAvailable,
  });
}
