import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';

import 'package:spareapp_unhas/data/models/booking.dart';
import 'package:spareapp_unhas/data/services/mock_booking_service.dart';

/// Riwayat peminjaman dari perspektif USER (peminjam)
class BookingHistoryUserPage extends StatefulWidget {
  final String? userId;
  const BookingHistoryUserPage({super.key, this.userId});

  @override
  State<BookingHistoryUserPage> createState() =>
      _BookingHistoryUserPageState();
}

class _BookingHistoryUserPageState extends State<BookingHistoryUserPage> {
  final _service = MockBookingService.instance;
  final _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  List<Booking> items = [];

  /// Filter status untuk user:
  _UserStatusFilter _statusFilter = _UserStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _service.seed(); // dummy data
    _load();
  }

  void _load() {
    final all = _service.getAll();

    // kalau userId diset, filter hanya milik user tsb
    final forUser = widget.userId == null
        ? all
        : all.where((b) => b.userId == widget.userId).toList();

    List<Booking> filtered;

    switch (_statusFilter) {
      case _UserStatusFilter.all:
        // riwayat: semua status KECUALI pending
        filtered = forUser.where((b) => b.status != 'pending').toList();
        break;
      case _UserStatusFilter.approved:
        filtered = forUser.where((b) => b.status == 'approved').toList();
        break;
      case _UserStatusFilter.returned:
        filtered = forUser.where((b) => b.status == 'returned').toList();
        break;
      case _UserStatusFilter.rejected:
        filtered = forUser.where((b) => b.status == 'rejected').toList();
        break;
    }

    // Urutkan dari peminjaman terbaru
    filtered.sort((a, b) => b.startDate.compareTo(a.startDate));

    setState(() {
      items = filtered;
    });
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'returned':
        return 'Dikembalikan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'returned':
        return AppColors.info;
      default:
        return AppColors.secondaryText;
    }
  }

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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Peminjaman',
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ringkasan peminjaman yang pernah Anda ajukan',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // ------- STATUS TABS (Semua / Disetujui / Dikembalikan / Ditolak) -------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStatusTabs(),
            ),
            const SizedBox(height: 16),

            // ------- LIST -------
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada riwayat peminjaman.',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final b = items[i];
                        return _HistoryCard(
                          booking: b,
                          dateFormatter: _dateFormatter,
                          statusLabel: _getStatusLabel(b.status),
                          statusColor: _getStatusColor(b.status),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ------- NAVBAR (tab Riwayat User) -------
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 3,
        useRoleRouting: true,
      ),

    );
  }

  // ===================== STATUS TABS =====================

  Widget _buildStatusTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statusTab(
          label: 'Semua',
          filter: _UserStatusFilter.all,
        ),
        _statusTab(
          label: 'Selesai',
          filter: _UserStatusFilter.returned,
        ),
        _statusTab(
          label: 'Ditolak',
          filter: _UserStatusFilter.rejected,
        ),
      ],
    );
  }

  Widget _statusTab({
    required String label,
    required _UserStatusFilter filter,
  }) {
    final isSelected = _statusFilter == filter;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _statusFilter = filter;
          });
          _load();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body2.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.mainGradientStart
                    : AppColors.secondaryText,
              ),
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
}

// ===================== ENUM =====================

enum _UserStatusFilter { all, approved, returned, rejected }

// ===================== CARD WIDGET =====================

class _HistoryCard extends StatelessWidget {
  final Booking booking;
  final DateFormat dateFormatter;
  final String statusLabel;
  final Color statusColor;

  const _HistoryCard({
    required this.booking,
    required this.dateFormatter,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    // Id ruangan/fasilitas untuk ditampilkan
    final facilityId = booking.facilityId ?? '';
    final roomId = booking.roomId ?? '';
    final displayId =
        facilityId.isNotEmpty ? facilityId : (roomId.isNotEmpty ? roomId : '-');

    // Tujuan / alasan
    final purposeText = booking.purpose ?? '';
    final hasPurpose = purposeText.isNotEmpty;

    // Alasan ditolak
    final rejectReason = booking.rejectedReason ?? '';
    final showRejectReason =
        booking.status == 'rejected' && rejectReason.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: statusColor.withOpacity(0.7),
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
          // header: id + status
          Row(
            children: [
              Expanded(
                child: Text(
                  displayId,
                  style: AppTextStyles.heading3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

          // jumlah
          Text(
            'Jumlah: ${booking.quantity}x',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),

          // tanggal dari – hingga
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

          // Tujuan (kalau ada)
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
              purposeText,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.titleText,
              ),
            ),
          ],

          // Alasan ditolak (kalau status rejected)
          if (showRejectReason) ...[
            const SizedBox(height: 8),
            Text(
              'Alasan Ditolak:',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              rejectReason,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.titleText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
