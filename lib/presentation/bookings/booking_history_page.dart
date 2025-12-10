import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/bottom_nav_bar.dart';

import '../../data/models/booking.dart';
import '../../data/services/mock_booking_service.dart';

class BookingHistoryAdminPage extends StatefulWidget {
  const BookingHistoryAdminPage({super.key});

  @override
  State<BookingHistoryAdminPage> createState() =>
      _BookingHistoryAdminPageState();
}

class _BookingHistoryAdminPageState extends State<BookingHistoryAdminPage> {
  final _service = MockBookingService.instance;
  final _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  final TextEditingController _searchController = TextEditingController();

  // semua data dari service
  List<Booking> _allBookings = [];

  // yang benar-benar ditampilkan
  List<Booking> _visibleBookings = [];

  // tab kategori
  _AdminCategory _category = _AdminCategory.all;

  // filter status & waktu
  _AdminStatusFilter _statusFilter = _AdminStatusFilter.all;
  _AdminTimeFilter _timeFilter = _AdminTimeFilter.all;

  // counter untuk badge di tab
  int _countAll = 0;
  int _countClass = 0;
  int _countFacility = 0;

  int _selectedBottomIndex = 3;

  @override
  void initState() {
    super.initState();
    _service.seed();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    final all = _service.getAll()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    setState(() {
      _allBookings = all;
    });
    _applyFilters();
  }

  // ===================== FILTER LOGIC =====================

  void _applyFilters() {
    final now = DateTime.now();
    var list = List<Booking>.from(_allBookings);

    // 1. filter status
    list = list.where((b) {
      switch (_statusFilter) {
        case _AdminStatusFilter.all:
          return true;
        case _AdminStatusFilter.approved:
          return b.status == 'approved';
        case _AdminStatusFilter.returned:
          return b.status == 'returned';
        case _AdminStatusFilter.rejected:
          return b.status == 'rejected';
      }
    }).toList();

    // 2. filter rentang waktu
    list = list.where((b) {
      final d = b.startDate;
      switch (_timeFilter) {
        case _AdminTimeFilter.all:
          return true;
        case _AdminTimeFilter.today:
          return d.year == now.year &&
              d.month == now.month &&
              d.day == now.day;
        case _AdminTimeFilter.thisWeek:
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek =
              startOfWeek.add(const Duration(days: 7)); // [start, start+7)
          return !d.isBefore(startOfWeek) && d.isBefore(endOfWeek);
        case _AdminTimeFilter.thisMonth:
          return d.year == now.year && d.month == now.month;
      }
    }).toList();

    // 3. filter search
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((b) {
        final name = (b.name ?? '').toLowerCase();
        final dept = (b.department ?? '').toLowerCase();
        final course = (b.courseName ?? '').toLowerCase();
        final cls = (b.className ?? '').toLowerCase();
        final room = (b.roomId ?? '').toLowerCase();
        final facility = (b.facilityId ?? '').toLowerCase();
        return name.contains(q) ||
            dept.contains(q) ||
            course.contains(q) ||
            cls.contains(q) ||
            room.contains(q) ||
            facility.contains(q);
      }).toList();
    }

    // 4. hitung counter per kategori
    final classList =
        list.where((b) => (b.roomId ?? '').isNotEmpty).toList();
    final facilityList =
        list.where((b) => (b.facilityId ?? '').isNotEmpty).toList();

    // 5. apply kategori tab
    late final List<Booking> visible;
    switch (_category) {
      case _AdminCategory.all:
        visible = list;
        break;
      case _AdminCategory.classOnly:
        visible = classList;
        break;
      case _AdminCategory.facilityOnly:
        visible = facilityList;
        break;
    }

    setState(() {
      _visibleBookings = visible;
      _countAll = list.length;
      _countClass = classList.length;
      _countFacility = facilityList.length;
    });
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'returned':
        return 'Dikembalikan';
      case 'pending':
        return 'Menunggu';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'returned':
        return AppColors.info;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.secondaryText;
    }
  }

  // ===================== FILTER SHEET =====================

  Future<void> _openFilterSheet() async {
    var tempStatus = _statusFilter;
    var tempTime = _timeFilter;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // drag handle
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Riwayat',
                            style: AppTextStyles.heading3
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempStatus = _AdminStatusFilter.all;
                                tempTime = _AdminTimeFilter.all;
                              });
                            },
                            child: Text(
                              'Reset',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.mainGradientStart,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ===== STATUS =====
                      Text(
                        'Status',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _filterPill(
                            label: 'Semua',
                            isSelected:
                                tempStatus == _AdminStatusFilter.all,
                            onTap: () => setModalState(
                              () => tempStatus = _AdminStatusFilter.all,
                            ),
                          ),
                          _filterPill(
                            label: 'Disetujui',
                            isSelected:
                                tempStatus == _AdminStatusFilter.approved,
                            onTap: () => setModalState(
                              () => tempStatus = _AdminStatusFilter.approved,
                            ),
                          ),
                          _filterPill(
                            label: 'Ditolak',
                            isSelected:
                                tempStatus == _AdminStatusFilter.rejected,
                            onTap: () => setModalState(
                              () => tempStatus = _AdminStatusFilter.rejected,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ===== WAKTU =====
                      Text(
                        'Rentang Waktu',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _filterPill(
                            label: 'Semua',
                            isSelected: tempTime == _AdminTimeFilter.all,
                            onTap: () => setModalState(
                              () => tempTime = _AdminTimeFilter.all,
                            ),
                          ),
                          _filterPill(
                            label: 'Hari ini',
                            isSelected: tempTime == _AdminTimeFilter.today,
                            onTap: () => setModalState(
                              () => tempTime = _AdminTimeFilter.today,
                            ),
                          ),
                          _filterPill(
                            label: 'Minggu ini',
                            isSelected:
                                tempTime == _AdminTimeFilter.thisWeek,
                            onTap: () => setModalState(
                              () => tempTime = _AdminTimeFilter.thisWeek,
                            ),
                          ),
                          _filterPill(
                            label: 'Bulan ini',
                            isSelected:
                                tempTime == _AdminTimeFilter.thisMonth,
                            onTap: () => setModalState(
                              () => tempTime = _AdminTimeFilter.thisMonth,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ===== TOMBOL TERAPKAN (GRADIENT) =====
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _statusFilter = tempStatus;
                              _timeFilter = tempTime;
                            });
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: AppColors.mainGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cardShadow,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Terapkan Filter',
                              style: AppTextStyles.button1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _filterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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


  // ===================== BUILD =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------- HEADER -------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Peminjaman',
                          style: AppTextStyles.heading1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Log lengkap semua peminjaman',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune, size: 20),
                      color: AppColors.mainGradientStart,
                      onPressed: _openFilterSheet,
                    ),
                  ),
                ],
              ),
            ),

            // ------- TABS (Semua / Kelas / Fasilitas) -------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCategoryTabs(),
            ),
            const SizedBox(height: 12),

            // ------- SEARCH BAR -------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _applyFilters(),
                decoration: InputDecoration(
                  hintText:
                      'Cari nama peminjam, jurusan, mata kuliah, ruangan...',
                  hintStyle: AppTextStyles.body2.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.mainGradientStart,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ------- LIST -------
            Expanded(
              child: _visibleBookings.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data peminjaman untuk filter saat ini.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: _visibleBookings.length,
                      itemBuilder: (context, i) {
                        final b = _visibleBookings[i];
                        return _AdminHistoryCard(
                          booking: b,
                          dateFormatter: _dateFormatter,
                          statusLabel: _statusLabel(b.status),
                          statusColor: _statusColor(b.status),
                          onDetailTap: () =>
                              _showDetailBottomSheet(b),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ------- NAVBAR ADMIN -------
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 3,
        useRoleRouting: true,
      ),

    );
  }

  // ===================== CATEGORY TABS =====================

  Widget _buildCategoryTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _categoryTab(
          label: 'Semua',
          count: _countAll,
          isSelected: _category == _AdminCategory.all,
          onTap: () {
            setState(() => _category = _AdminCategory.all);
            _applyFilters();
          },
        ),
        _categoryTab(
          label: 'Kelas',
          count: _countClass,
          isSelected: _category == _AdminCategory.classOnly,
          onTap: () {
            setState(() => _category = _AdminCategory.classOnly);
            _applyFilters();
          },
        ),
        _categoryTab(
          label: 'Fasilitas',
          count: _countFacility,
          isSelected: _category == _AdminCategory.facilityOnly,
          onTap: () {
            setState(() => _category = _AdminCategory.facilityOnly);
            _applyFilters();
          },
        ),
      ],
    );
  }

  Widget _categoryTab({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.mainGradientStart
                        : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.mainGradientStart.withOpacity(0.12)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    count.toString(),
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected
                          ? AppColors.mainGradientStart
                          : AppColors.secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2,
              width: isSelected ? 28 : 0,
              decoration: BoxDecoration(
                color: AppColors.mainGradientStart,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== DETAIL SHEET =====================

  void _showDetailBottomSheet(Booking booking) {
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
                  _detailRow('Status', _statusLabel(booking.status),
                      valueColor: _statusColor(booking.status)),
                  if ((booking.className ?? '').isNotEmpty)
                    _detailRow('Kelas', booking.className!),
                  if ((booking.courseName ?? '').isNotEmpty)
                    _detailRow('Mata Kuliah', booking.courseName!),
                  if ((booking.department ?? '').isNotEmpty)
                    _detailRow('Jurusan', booking.department!),
                  if ((booking.roomId ?? '').isNotEmpty)
                    _detailRow('Ruang Kelas', booking.roomId!),
                  if ((booking.facilityId ?? '').isNotEmpty)
                    _detailRow('Fasilitas', booking.facilityId!),
                  _detailRow(
                    'Dari',
                    _dateFormatter.format(booking.startDate),
                  ),
                  _detailRow(
                    'Hingga',
                    _dateFormatter.format(booking.endDate),
                  ),
                  if ((booking.purpose ?? '').isNotEmpty)
                    _detailRow('Tujuan', booking.purpose!),
                  if ((booking.rejectedReason ?? '').isNotEmpty)
                    _detailRow('Alasan Ditolak', booking.rejectedReason!),
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

// =============== ENUMS ===============

enum _AdminCategory { all, classOnly, facilityOnly }

enum _AdminStatusFilter { all, approved, returned, rejected }

enum _AdminTimeFilter { all, today, thisWeek, thisMonth }

// =============== CARD WIDGET ===============

class _AdminHistoryCard extends StatelessWidget {
  final Booking booking;
  final DateFormat dateFormatter;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onDetailTap;

  const _AdminHistoryCard({
    required this.booking,
    required this.dateFormatter,
    required this.statusLabel,
    required this.statusColor,
    required this.onDetailTap,
  });

  @override
  Widget build(BuildContext context) {
    final purpose = booking.purpose ?? '';
    final hasPurpose = purpose.isNotEmpty;

    final rejectReason = booking.rejectedReason ?? '';
    final hasRejectReason =
        booking.status == 'rejected' && rejectReason.isNotEmpty;

    final name = booking.name?.isNotEmpty == true
        ? booking.name!
        : 'Nama tidak tersedia';

    final idLine = (booking.roomId ?? '').isNotEmpty
        ? 'Ruang: ${booking.roomId}'
        : (booking.facilityId ?? '').isNotEmpty
            ? 'Fasilitas: ${booking.facilityId}'
            : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withOpacity(0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: nama peminjam + status
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.heading3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  statusLabel,
                  style: AppTextStyles.body2.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // info ruangan/fasilitas
          Text(
            idLine,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),

          // info akademik
          if ((booking.className ?? '').isNotEmpty ||
              (booking.courseName ?? '').isNotEmpty ||
              (booking.department ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            if ((booking.className ?? '').isNotEmpty)
              Text(
                'Kelas: ${booking.className}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            if ((booking.courseName ?? '').isNotEmpty)
              Text(
                'Mata Kuliah: ${booking.courseName}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            if ((booking.department ?? '').isNotEmpty)
              Text(
                'Jurusan: ${booking.department}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
          ],

          const SizedBox(height: 8),

          Text(
            'Jumlah: ${booking.quantity}x',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dari: ${dateFormatter.format(booking.startDate)}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                'Hingga: ${dateFormatter.format(booking.endDate)}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),

          if (hasPurpose) ...[
            const SizedBox(height: 8),
            Text(
              'Tujuan:',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              purpose,
              style: AppTextStyles.body2,
            ),
          ],

          if (hasRejectReason) ...[
            const SizedBox(height: 8),
            Text(
              'Alasan Ditolak:',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              rejectReason,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.error,
              ),
            ),
          ],

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: onDetailTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide(
                  color: statusColor,
                  width: 1.2,
                ),
              ),
              child: Text(
                'Lihat Detail',
                style: AppTextStyles.body2.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
