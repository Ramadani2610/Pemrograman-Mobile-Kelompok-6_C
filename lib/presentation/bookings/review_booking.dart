import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/bottom_nav_bar.dart';

import '../../data/models/booking.dart';
import '../../data/models/room.dart';
import '../../data/models/facility.dart';
import '../../data/services/mock_booking_service.dart';
import '../../data/services/mock_room_service.dart';
import '../../data/services/mock_facility_service.dart';

class ReviewBookingsPage extends StatefulWidget {
  const ReviewBookingsPage({super.key});

  @override
  State<ReviewBookingsPage> createState() => _ReviewBookingsPageState();
}

class _ReviewBookingsPageState extends State<ReviewBookingsPage> {
  final _bookingService = MockBookingService.instance;
  final _roomService = MockRoomService.instance;
  final _facilityService = MockFacilityService.instance;

  final DateFormat _timeFormatter = DateFormat('HH:mm');
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  _BookingFilter _filter = _BookingFilter.all;
  _StatusTab _statusTab = _StatusTab.pending;

  List<Booking> _pendingBookings = [];
  List<Booking> _activeBookings = [];
  List<Booking> _completedBookings = [];
  List<Booking> _rejectedBookings = [];

  Map<String, Room> _roomsById = {};
  Map<String, Facility> _facilitiesById = {};

  int _selectedBottomIndex = 2; // tab notifikasi/admin review

  @override
  void initState() {
    super.initState();
    _bookingService.seed(); // dummy data
    _loadData();
  }

  void _loadData() {
    final rooms = _roomService.getAll();
    final facilities = _facilityService.getAll();

    int compareDesc(Booking a, Booking b) => b.startDate.compareTo(a.startDate);

    setState(() {
      _roomsById = {for (final r in rooms) r.id: r};
      _facilitiesById = {for (final f in facilities) f.id: f};

      _pendingBookings = _bookingService.getByStatus('pending')..sort(compareDesc);
      _activeBookings = _bookingService.getByStatus('approved')..sort(compareDesc);
      _completedBookings = _bookingService.getByStatus('returned')..sort(compareDesc);
      _rejectedBookings = _bookingService.getByStatus('rejected')..sort(compareDesc);
    });
  }

  // ========= FILTER BANTUAN =========

  List<Booking> _applyFilter(List<Booking> source) {
    switch (_filter) {
      case _BookingFilter.classOnly:
        return source.where((b) => (b.roomId ?? '').isNotEmpty).toList();
      case _BookingFilter.facilityOnly:
        return source.where((b) => (b.facilityId ?? '').isNotEmpty).toList();
      case _BookingFilter.all:
      default:
        return source;
    }
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_timeFormatter.format(start)} - ${_timeFormatter.format(end)}';
  }

  String _formatDate(DateTime date) => _dateFormatter.format(date);

  Color _statusColor(Booking booking) {
    switch (booking.status) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'returned':
        return AppColors.info;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.secondaryText;
    }
  }

  String _statusLabel(Booking booking) {
    switch (booking.status) {
      case 'pending':
        return 'Menunggu Tinjauan';
      case 'approved':
        return 'Sedang Digunakan';
      case 'returned':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return booking.status;
    }
  }

  String _typeLabel(Booking booking) {
    if ((booking.roomId ?? '').isNotEmpty) return 'Kelas';
    if ((booking.facilityId ?? '').isNotEmpty) return 'Fasilitas';
    return 'Lainnya';
  }

  // ========= AKSI STATUS =========

  Future<void> _approveBooking(Booking booking) async {
    final confirmed = await _showConfirmDialog(
      title: 'Terima Peminjaman?',
      message:
          'Peminjaman ini akan dipindahkan ke status "Sedang Digunakan". Pastikan data sudah benar.',
      confirmLabel: 'Ya, Terima',
    );

    if (confirmed != true) {
      _showSnack('Perubahan status dibatalkan.');
      return;
    }

    final ok = _bookingService.approve(booking.id, 'admin001');
    if (!ok) {
      _showSnack('Gagal memperbarui status peminjaman.', isError: true);
      return;
    }

    _loadData();
    _showSnack('Peminjaman diterima. Status: Sedang Digunakan.');
  }

  /// Dialog untuk meminta alasan penolakan.
  Future<String?> _askRejectReason() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Alasan Penolakan',
            style: AppTextStyles.heading3,
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            style: AppTextStyles.body2,
            decoration: InputDecoration(
              hintText: 'Masukkan alasan peminjaman ini ditolak',
              hintStyle: AppTextStyles.body2.copyWith(
                color: AppColors.secondaryText,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: AppTextStyles.button2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, controller.text.trim()),
              child: Text(
                'Lanjut',
                style: AppTextStyles.button2.copyWith(
                  color: AppColors.mainGradientStart,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result?.trim();
  }

  Future<void> _rejectBooking(Booking booking) async {
    // 1) Minta alasan dulu
    final reason = await _askRejectReason();
    if (reason == null || reason.isEmpty) {
      _showSnack('Alasan penolakan wajib diisi.');
      return;
    }

    // 2) Konfirmasi
    final confirmed = await _showConfirmDialog(
      title: 'Tolak Peminjaman?',
      message:
          'Peminjaman akan ditolak dengan alasan berikut:\n\n"$reason"\n\n'
          'Peminjam akan mendapatkan notifikasi. Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Ya, Tolak',
    );

    if (confirmed != true) {
      _showSnack('Perubahan status dibatalkan.');
      return;
    }

    // 3) Simpan ke service + alasan
    final ok = _bookingService.reject(
      booking.id,
      reason: reason,
      rejectedBy: 'admin001',
    );

    if (!ok) {
      _showSnack('Gagal menolak peminjaman.', isError: true);
      return;
    }

    _loadData();
    _showSnack('Peminjaman telah ditolak.');
  }

  // ========= INPUT WAKTU PENGEMBALIAN (KHUSUS FASILITAS) =========

  Future<DateTime?> _pickReturnTime(Booking booking) async {
    final now = DateTime.now();

    final initialTime = TimeOfDay.fromDateTime(now);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Pilih Waktu Pengembalian',
      builder: (context, child) {
        // opsional: sedikit styling
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return null;

    // Asumsikan tanggal pengembalian = hari ini
    final returnedAt = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );

    // Contoh validasi sederhana: tidak boleh sebelum waktu mulai booking
    if (returnedAt.isBefore(booking.startDate)) {
      _showSnack(
        'Waktu pengembalian tidak boleh sebelum waktu mulai peminjaman.',
        isError: true,
      );
      return null;
    }

    return returnedAt;
  }


  Future<void> _markAsReturned(Booking booking) async {
    final confirmed = await _showConfirmDialog(
      title: 'Tandai Selesai?',
      message:
          'Pastikan ruangan/fasilitas sudah benar-benar dikembalikan. Status akan diubah menjadi "Selesai".',
      confirmLabel: 'Ya, Selesai',
    );

    if (confirmed != true) {
      _showSnack('Perubahan status dibatalkan.');
      return;
    }

    final ok = _bookingService.markReturned(
      booking.id,
      returnedBy: 'admin001',
    );
    if (!ok) {
      _showSnack('Gagal memperbarui status peminjaman.', isError: true);
      return;
    }

    _loadData();
    _showSnack('Status peminjaman berhasil ditandai selesai.');
  }


  Future<void> _markAsReturnedFacility(Booking booking) async {
    // 1. Minta waktu pengembalian terlebih dahulu
    final returnedAt = await _pickReturnTime(booking);
    if (returnedAt == null) {
      // sudah di-handle snack di _pickReturnTime kalau invalid / batal
      return;
    }

    final formattedTime = _timeFormatter.format(returnedAt);

    // 2. Konfirmasi dengan menampilkan waktu pengembalian
    final confirmed = await _showConfirmDialog(
      title: 'Tandai Selesai (Fasilitas)?',
      message:
          'Fasilitas akan ditandai sudah dikembalikan pada pukul $formattedTime.\n'
          'Pastikan data sudah benar sebelum melanjutkan.',
      confirmLabel: 'Ya, Simpan',
    );

    if (confirmed != true) {
      _showSnack('Perubahan status dibatalkan.');
      return;
    }

    // 3. Simpan perubahan ke service
    final ok = _bookingService.markReturned(
      booking.id,
      actualReturnTime: returnedAt,
      returnedBy: 'admin001',
    );

    if (!ok) {
      _showSnack('Gagal memperbarui status peminjaman.', isError: true);
      return;
    }

    _loadData();
    _showSnack(
      'Peminjaman fasilitas ditandai selesai pada pukul $formattedTime.',
    );
  }



  // ========= DIALOG & SNACKBAR =========

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: AppTextStyles.heading3,
          ),
          content: Text(
            message,
            style: AppTextStyles.body2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Tidak',
                style: AppTextStyles.button2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                confirmLabel,
                style: AppTextStyles.button2.copyWith(
                  color: AppColors.mainGradientStart,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.body2.copyWith(color: Colors.white),
        ),
        backgroundColor:
            isError ? AppColors.error : AppColors.mainGradientStart,
      ),
    );
  }

  // ========= BUILD =========

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayLabel =
        DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(today);

    final pendingList = _applyFilter(_pendingBookings);
    final activeList = _applyFilter(_activeBookings);
    final completedList = _applyFilter(_completedBookings);
    final rejectedList = _applyFilter(_rejectedBookings);

    // list sesuai tab status
    late final List<Booking> currentList;
    late final String sectionTitle;
    late final String emptyLabel;

    switch (_statusTab) {
      case _StatusTab.pending:
        currentList = pendingList;
        sectionTitle = 'Menunggu Tinjauan';
        emptyLabel = 'Tidak ada peminjaman yang menunggu tinjauan.';
        break;
      case _StatusTab.active:
        currentList = activeList;
        sectionTitle = 'Sedang Digunakan';
        emptyLabel = 'Tidak ada peminjaman yang sedang digunakan.';
        break;
      case _StatusTab.completed:
        currentList = completedList;
        sectionTitle = 'Selesai';
        emptyLabel = 'Belum ada peminjaman yang selesai.';
        break;
      case _StatusTab.rejected:
        currentList = rejectedList;
        sectionTitle = 'Ditolak';
        emptyLabel = 'Tidak ada peminjaman yang ditolak.';
        break;
    }

    final allEmpty = currentList.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= HEADER =======
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tinjau Peminjaman',
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    todayLabel,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusTabs(
                    pending: pendingList.length,
                    active: activeList.length,
                    completed: completedList.length,
                    rejected: rejectedList.length,
                  ),
                  const SizedBox(height: 12),
                  _buildFilterTabs(),
                ],
              ),
            ),

            // ======= LIST SECTION =======
            Expanded(
              child: allEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          emptyLabel,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: _buildStatusSection(
                        title: sectionTitle,
                        bookings: currentList,
                        emptyLabel: emptyLabel,
                      ),
                    ),
            ),
          ],
        ),
      ),

      // ======= BOTTOM NAVBAR ADMIN =======
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemTapped: (index) {
          if (index == _selectedBottomIndex) return;
          setState(() => _selectedBottomIndex = index);

          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home_user');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/manage');
              break;
            case 2:
              // already here
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/booking_history');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  // ========= STATUS TABS (Menunggu / Berjalan / Selesai / Ditolak) =========

  Widget _buildStatusTabs({
    required int pending,
    required int active,
    required int completed,
    required int rejected,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _statusTabItem(
              label: 'Menunggu',
              count: pending,
              isSelected: _statusTab == _StatusTab.pending,
              onTap: () => setState(() => _statusTab = _StatusTab.pending),
            ),
            _statusTabItem(
              label: 'Berjalan',
              count: active,
              isSelected: _statusTab == _StatusTab.active,
              onTap: () => setState(() => _statusTab = _StatusTab.active),
            ),
            _statusTabItem(
              label: 'Selesai',
              count: completed,
              isSelected: _statusTab == _StatusTab.completed,
              onTap: () => setState(() => _statusTab = _StatusTab.completed),
            ),
            _statusTabItem(
              label: 'Ditolak',
              count: rejected,
              isSelected: _statusTab == _StatusTab.rejected,
              onTap: () => setState(() => _statusTab = _StatusTab.rejected),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 1,
          color: AppColors.border,
        ),
      ],
    );
  }

  Widget _statusTabItem({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color activeColor = AppColors.mainGradientStart;
    final Color inactiveColor = AppColors.secondaryText;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body2.copyWith(
                    color: isSelected ? activeColor : inactiveColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? activeColor.withOpacity(0.12)
                        : AppColors.border.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    count.toString(),
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: isSelected ? activeColor : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              height: 3,
              width: 28,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========= WIDGET SECTION STATUS =========

  Widget _buildStatusSection({
    required String title,
    required List<Booking> bookings,
    required String emptyLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (bookings.isEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              emptyLabel,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          )
        else
          Column(
            children: bookings
                .map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBookingCard(
                      b,
                      isFacility: (b.facilityId ?? '').isNotEmpty,
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  // ========= FILTER TAB (Semua / Kelas / Fasilitas) =========

  Widget _buildFilterTabs() {
    return Row(
      children: [
        _filterChip(
          label: 'Semua',
          isSelected: _filter == _BookingFilter.all,
          onTap: () => setState(() => _filter = _BookingFilter.all),
        ),
        const SizedBox(width: 8),
        _filterChip(
          label: 'Kelas',
          isSelected: _filter == _BookingFilter.classOnly,
          onTap: () => setState(() => _filter = _BookingFilter.classOnly),
        ),
        const SizedBox(width: 8),
        _filterChip(
          label: 'Fasilitas',
          isSelected: _filter == _BookingFilter.facilityOnly,
          onTap: () => setState(() => _filter = _BookingFilter.facilityOnly),
        ),
      ],
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.white,
          gradient: isSelected ? AppColors.mainGradient : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
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

  // ========= KARTU PEMINJAMAN =========

  Widget _buildBookingCard(
    Booking booking, {
    required bool isFacility,
  }) {
    final room = booking.roomId != null
      ? _roomsById[booking.roomId!]   // aman karena sudah dicek != null
      : null;

    final facility = isFacility && booking.facilityId != null
        ? _facilitiesById[booking.facilityId!] 
        : null;

    final statusColor = _statusColor(booking);
    final statusLabel = _statusLabel(booking);
    final typeLabel = _typeLabel(booking);

    // tombol aksi sesuai status
    final List<Widget> actions = [];

    if (booking.status == 'pending') {
      actions.addAll([
        _smallActionButton(
          label: 'Terima',
          gradient: AppColors.mainGradient,
          textColor: Colors.white,
          onTap: () => _approveBooking(booking),
        ),
        const SizedBox(width: 8),
        _smallActionButton(
          label: 'Tolak',
          background: Colors.white,
          borderColor: AppColors.border,
          textColor: AppColors.secondaryText,
          onTap: () => _rejectBooking(booking),
        ),
      ]);
    } else if (booking.status == 'approved') {
      actions.add(
        _smallActionButton(
          label: 'Tandai Selesai',
          gradient: AppColors.greenGradient,
          textColor: Colors.white,
          onTap: () {
            if (isFacility) {
              // KHUSUS FASILITAS → wajib isi waktu pengembalian
              _markAsReturnedFacility(booking);
            } else {
              // Kelas tetap seperti biasa
              _markAsReturned(booking);
            }
          },
        ),
      );
    }

    // tombol lihat detail selalu ada
    if (actions.isNotEmpty) {
      actions.add(const SizedBox(width: 8));
    }
    actions.add(
      _smallActionButton(
        label: 'Lihat Detail',
        gradient: AppColors.blueGradient,
        textColor: Colors.white,
        onTap: () => _showBookingDetail(
          booking,
          room: room,
          facility: facility,
        ),
      ),
    );

    final hasAcademicInfo =
        (booking.className != null && booking.className!.isNotEmpty) ||
            (booking.courseName != null && booking.courseName!.isNotEmpty) ||
            (booking.department != null && booking.department!.isNotEmpty);

    final hasRejectReason =
        booking.status == 'rejected' &&
        (booking.rejectedReason != null &&
            booking.rejectedReason!.trim().isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mainGradientStart, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: status + type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  typeLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Nama peminjam
          Text(
            booking.name ?? '-',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.mainGradientStart,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          // Ruang atau fasilitas
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isFacility ? Icons.devices_other : Icons.meeting_room_outlined,
                size: 18,
                color: AppColors.secondaryText,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isFacility
                      ? (facility?.name ?? '-')
                      : (room != null ? '${room.id} • ${room.building}' : '-'),
                  style: AppTextStyles.body2,
                ),
              ),
            ],
          ),

          // Info akademik (kelas, matkul, jurusan) → sesuai form reservasi kelas
          if (hasAcademicInfo) ...[
            const SizedBox(height: 6),
            if (booking.className != null && booking.className!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.school,
                      size: 16, color: AppColors.secondaryText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kelas: ${booking.className}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            if (booking.courseName != null && booking.courseName!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.menu_book,
                      size: 16, color: AppColors.secondaryText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Mata Kuliah: ${booking.courseName}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
            if (booking.department != null &&
                booking.department!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.apartment,
                      size: 16, color: AppColors.secondaryText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Jurusan: ${booking.department}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                ],
              ),
          ],

          const SizedBox(height: 6),

          // Tanggal & jam
          Row(
            children: [
              const Icon(Icons.date_range,
                  size: 18, color: AppColors.secondaryText),
              const SizedBox(width: 6),
              Text(
                _formatDate(booking.startDate),
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 18, color: AppColors.secondaryText),
              const SizedBox(width: 6),
              Text(
                _formatTimeRange(booking.startDate, booking.endDate),
                style: AppTextStyles.body2,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Tujuan (dari form reservasi)
          if ((booking.purpose ?? '').isNotEmpty) ...[
            Text(
              'Tujuan:',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              booking.purpose!,
              style: AppTextStyles.body2,
            ),
          ],

          // Alasan Ditolak (khusus status rejected)
          if (hasRejectReason) ...[
            const SizedBox(height: 8),
            Text(
              'Alasan Ditolak:',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              booking.rejectedReason!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.error,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // tombol aksi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: actions,
          ),
        ],
      ),
    );
  }

  Widget _smallActionButton({
    required String label,
    Color? background,
    Gradient? gradient,
    Color? borderColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.button2.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ========= BOTTOM SHEET DETAIL =========

  void _showBookingDetail(
    Booking booking, {
    Room? room,
    Facility? facility,
  }) {
    final hasRejectReason =
        booking.status == 'rejected' &&
        (booking.rejectedReason != null &&
            booking.rejectedReason!.trim().isNotEmpty);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    'Detail Peminjaman',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _detailRow('ID Peminjaman', booking.id),
                  _detailRow('Nama Peminjam', booking.name ?? '-'),
                  _detailRow('Tipe', _typeLabel(booking)),
                  _detailRow(
                    'Status',
                    _statusLabel(booking),
                    valueColor: _statusColor(booking),
                  ),
                  _detailRow(
                    'Tanggal',
                    _formatDate(booking.startDate),
                  ),
                  _detailRow(
                    'Waktu',
                    _formatTimeRange(
                      booking.startDate,
                      booking.endDate,
                    ),
                  ),
                  if (booking.className != null &&
                      booking.className!.isNotEmpty)
                    _detailRow('Kelas', booking.className!),
                  if (booking.courseName != null &&
                      booking.courseName!.isNotEmpty)
                    _detailRow('Mata Kuliah', booking.courseName!),
                  if (booking.department != null &&
                      booking.department!.isNotEmpty)
                    _detailRow('Jurusan', booking.department!),
                  if (room != null) ...[
                    _detailRow('Ruang Kelas', room.id),
                    _detailRow('Gedung', room.building),
                    _detailRow('Lantai', 'Lantai ${room.floor}'),
                  ],
                  if (facility != null) ...[
                    _detailRow('Fasilitas', facility.name),
                    _detailRow('Kode', facility.id ?? '-'),
                  ],
                  if ((booking.purpose ?? '').isNotEmpty)
                    _detailRow('Tujuan', booking.purpose!),
                  if (hasRejectReason)
                    _detailRow(
                      'Alasan Ditolak',
                      booking.rejectedReason!,
                      valueColor: AppColors.error,
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                color: valueColor ?? AppColors.titleText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// filter untuk tab atas (kelas/fasilitas)
enum _BookingFilter {
  all,
  classOnly,
  facilityOnly,
}

// tab status utama
enum _StatusTab {
  pending, // Menunggu
  active, // Berjalan
  completed, // Selesai
  rejected, // Ditolak
}
