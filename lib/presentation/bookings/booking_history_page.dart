import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';

import 'package:spareapp_unhas/data/models/booking.dart';
import 'package:spareapp_unhas/data/services/mock_booking_service.dart';

class BookingHistoryPage extends StatefulWidget {
  final String? userId;
  const BookingHistoryPage({super.key, this.userId});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  final _service = MockBookingService.instance;
  final _dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

  List<Booking> items = [];
  String selectedStatus = 'semua'; // semua, approved, returned, rejected

  @override
  void initState() {
    super.initState();
    _service.seed();
    _load();
  }

  void _load() {
    final all = _service.getAll();

    setState(() {
      if (selectedStatus == 'semua') {
        items = all.where((b) => b.status != 'pending').toList();
      } else {
        items = all.where((b) => b.status == selectedStatus).toList();
      }
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Riwayat Peminjaman',
                style: AppTextStyles.heading1,
              ),
            ),

            // ------- FILTER -------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip('semua', 'Semua'),
                  _buildFilterChip('approved', 'Disetujui'),
                  _buildFilterChip('returned', 'Dikembalikan'),
                  _buildFilterChip('rejected', 'Ditolak'),
                ],
              ),
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

      // ------- NAVBAR (tab Riwayat) -------
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 3,
        onItemTapped: (index) {
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
              // already here
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = selectedStatus == value;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedStatus = value;
            _load();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.mainGradient : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.border,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.titleText,
            ),
          ),
        ),
      ),
    );
  }
}

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
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
          // header: nama + status
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.facilityId.isNotEmpty
                      ? booking.facilityId
                      : booking.roomId ?? '-',
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
          const SizedBox(height: 12),

          // jumlah
          Text(
            'Jumlah: ${booking.quantity}x',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 8),

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

          if (booking.purpose.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Tujuan:',
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              booking.purpose,
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
