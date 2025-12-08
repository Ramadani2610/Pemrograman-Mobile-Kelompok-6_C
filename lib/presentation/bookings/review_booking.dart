import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_widgets.dart';
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';

import '../../data/models/booking.dart';
import '../../data/models/room.dart';
import '../../data/models/facility.dart';
import '../../data/services/mock_booking_service.dart';
import '../../data/services/mock_room_service.dart';
import '../../data/services/mock_facility_service.dart';

enum _BookingFilter { all, classOnly, facilityOnly }

class ReviewBookingsPage extends StatefulWidget {
  const ReviewBookingsPage({super.key});

  @override
  State<ReviewBookingsPage> createState() => _ReviewBookingsPageState();
}

class _ReviewBookingsPageState extends State<ReviewBookingsPage> {
  final _bookingService = MockBookingService.instance;
  final _roomService = MockRoomService.instance;
  final _facilityService = MockFacilityService.instance;

  final _timeFormatter = DateFormat('HH:mm');
  final _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  List<Booking> _pendingBookings = [];
  _BookingFilter _filter = _BookingFilter.all;

  // untuk mapping cepat id → room / facility
  late final Map<String, Room> _roomsById;
  late final Map<String, Facility> _facilitiesById;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // ambil semua data mock
    final rooms = _roomService.getAll();
    final facilities = _facilityService.getAll();
    final pending = _bookingService.getByStatus('pending');

    _roomsById = {for (final r in rooms) r.id: r};
    _facilitiesById = {for (final f in facilities) f.id: f};

    setState(() {
      _pendingBookings = pending;
    });
  }

  List<Booking> get _visibleBookings {
    switch (_filter) {
      case _BookingFilter.classOnly:
        return _pendingBookings
            .where((b) => (b.roomId ?? '').isNotEmpty)
            .toList();
      case _BookingFilter.facilityOnly:
        return _pendingBookings
            .where((b) => (b.facilityId ?? '').isNotEmpty)
            .toList();
      case _BookingFilter.all:
      default:
        return _pendingBookings;
    }
  }

  // ====== ACTIONS ======

  Future<void> _approveBooking(Booking booking) async {
    // TODO: ganti 'admin001' dengan id admin yang sedang login (dari auth service)
    final ok = _bookingService.approve(booking.id, 'admin001');

    if (!ok) {
      _showSnack('Gagal menyetujui peminjaman.', isError: true);
      return;
    }

    setState(() {
      _pendingBookings.removeWhere((b) => b.id == booking.id);
    });
    _showSnack('Peminjaman telah disetujui.');
  }

  Future<void> _rejectBooking(Booking booking) async {
    final confirmed = await _showConfirmDialog(
      title: 'Tolak Peminjaman?',
      message:
          'Apakah Anda yakin ingin menolak peminjaman ini? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Ya, Tolak',
    );
    if (confirmed != true) return;

    final ok = _bookingService.reject(booking.id);
    if (!ok) {
      _showSnack('Gagal menolak peminjaman.', isError: true);
      return;
    }

    setState(() {
      _pendingBookings.removeWhere((b) => b.id == booking.id);
    });
    _showSnack('Peminjaman telah ditolak.');
  }

  void _showDetail(Booking booking) {
    final isClassBooking = (booking.roomId ?? '').isNotEmpty;
    final room = isClassBooking && booking.roomId != null
        ? _roomsById[booking.roomId]
        : null;
    final facility = !isClassBooking
        ? _facilitiesById[booking.facilityId]
        : null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Detail Peminjaman',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 12),
              _detailRow('Jenis',
                  isClassBooking ? 'Peminjaman Kelas' : 'Peminjaman Fasilitas'),
              if (room != null) ...[
                _detailRow('Ruang', '${room.name} • ${room.building}'),
                _detailRow('Lantai', room.floor),
              ],
              if (facility != null) ...[
                _detailRow('Fasilitas', facility.name),
                _detailRow('Kategori', facility.category),
              ],
              _detailRow(
                'Tanggal',
                _dateFormatter.format(booking.startDate),
              ),
              _detailRow(
                'Waktu',
                '${_timeFormatter.format(booking.startDate)}'
                ' - ${_timeFormatter.format(booking.endDate)}',
              ),
              if ((booking.purpose ?? '').isNotEmpty)
                _detailRow('Keperluan', booking.purpose),
              if ((booking.quantity ?? 0) > 0)
                _detailRow('Jumlah', '${booking.quantity} buah'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'ID Peminjaman: ${booking.id}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: AppTextStyles.heading3),
          content: Text(message, style: AppTextStyles.body2),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
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

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTextStyles.body2.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.mainGradientStart,
      ),
    );
  }

  // ====== BUILD ======

  @override
  Widget build(BuildContext context) {
    final todayLabel = _dateFormatter.format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar custom
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
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

            // Judul + tanggal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tinjau Peminjaman', style: AppTextStyles.heading1),
                  const SizedBox(height: 4),
                  Text(
                    'Hari ini • $todayLabel',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            Expanded(
              child: _visibleBookings.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada peminjaman menunggu persetujuan.',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: _visibleBookings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final booking = _visibleBookings[index];
                        return _buildBookingCard(booking);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 2,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/facilities');
            case 2:
              // Already on notification page
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

  // ====== UI HELPERS ======

  Widget _buildFilterChips() {
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.mainGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
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

  Widget _buildBookingCard(Booking booking) {
    final isClassBooking = (booking.roomId ?? '').isNotEmpty;
    final room =
        isClassBooking && booking.roomId != null ? _roomsById[booking.roomId] : null;
    final facility = !isClassBooking
        ? _facilitiesById[booking.facilityId]
        : null;

    final startTime = _timeFormatter.format(booking.startDate);
    final endTime = _timeFormatter.format(booking.endDate);

    final typeLabel = isClassBooking ? 'Kelas' : 'Fasilitas';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header merah "Nama Peminjam" + chip jenis
            Row(
              children: [
                Text(
                  'Nama Peminjam',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.mainGradientStart,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 8),

            // Info utama + "kartu biru/hijau/abu" di kanan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info ruangan / fasilitas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room?.name ?? facility?.name ?? '-',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (room != null)
                      Text(
                        room.name,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    if (facility != null)
                      Text(
                        facility.category,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '$startTime - $endTime',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.mainGradientStart,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Kartu info tujuan / mata kuliah
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isClassBooking
                          ? AppColors.info
                          : AppColors.secondaryText,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (booking.purpose ?? '').isNotEmpty
                          ? booking.purpose
                          : (isClassBooking
                              ? 'Kegiatan perkuliahan'
                              : 'Peminjaman fasilitas'),
                      style: AppTextStyles.body2.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Footer kecil: tanggal + id
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal: ${_dateFormatter.format(booking.startDate)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  '#${booking.id}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tombol aksi
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _smallActionButton(
                  label: 'Terima',
                  backgroundGradient: AppColors.mainGradient,
                  textColor: Colors.white,
                  onTap: () => _approveBooking(booking),
                ),
                const SizedBox(width: 8),
                _smallActionButton(
                  label: 'Batal',
                  backgroundColor: Colors.white,
                  borderColor: AppColors.border,
                  textColor: AppColors.secondaryText,
                  onTap: () => _rejectBooking(booking),
                ),
                const SizedBox(width: 8),
                _smallActionButton(
                  label: 'Lihat Detail',
                  backgroundGradient: AppColors.blueGradient,
                  textColor: Colors.white,
                  onTap: () => _showDetail(booking),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallActionButton({
    required String label,
    VoidCallback? onTap,
    Color? backgroundColor,
    Color? borderColor,
    LinearGradient? backgroundGradient,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          color: backgroundGradient == null ? backgroundColor : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }
}
