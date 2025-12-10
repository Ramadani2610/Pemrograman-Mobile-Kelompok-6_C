import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/bottom_nav_bar.dart';

class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({super.key});

  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

// ===== MODEL LOCAL NOTIFIKASI =====

enum NotificationType {
  bookingCreated,
  bookingApproved,
  bookingRejected,
  bookingReminder,
  bookingEnded,
  system,
}

class UserNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
  final String? relatedBookingId;
  bool isRead;

  UserNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.relatedBookingId,
    this.isRead = false,
  });
}

enum _NotificationFilter {
  all,
  unread,
  bookingOnly,
  systemOnly,
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {
  final DateFormat _timeFormatter = DateFormat('HH:mm');
  final DateFormat _dateFormatter = DateFormat('EEEE, dd MMM yyyy', 'id_ID');

  final List<UserNotification> _notifications = [];
  _NotificationFilter _filter = _NotificationFilter.all;

  int _selectedBottomIndex = 2; // index notifikasi di navbar user

  @override
  void initState() {
    super.initState();
    _seedDummyNotifications();
  }

  // ===== DUMMY DATA UNTUK UI PREVIEW =====
  void _seedDummyNotifications() {
    final now = DateTime.now();

    _notifications.addAll([
      UserNotification(
        id: 'n1',
        title: 'Reservasi Berhasil Dibuat',
        message:
            'Peminjaman ruang kelas CR101 pada 12 Des 2025 telah berhasil direkam.',
        createdAt: now.subtract(const Duration(minutes: 10)),
        type: NotificationType.bookingCreated,
        relatedBookingId: 'b001',
        isRead: false,
      ),
      UserNotification(
        id: 'n2',
        title: 'Reservasi Disetujui',
        message:
            'Peminjaman fasilitas Projector A-01 sudah DISSETUJUI admin. Silakan ambil tepat waktu.',
        createdAt: now.subtract(const Duration(hours: 1)),
        type: NotificationType.bookingApproved,
        relatedBookingId: 'b002',
        isRead: false,
      ),
      UserNotification(
        id: 'n3',
        title: 'Reservasi Ditolak',
        message:
            'Pengajuan penggunaan Auditorium FT ditolak: tidak ada surat resmi kegiatan.',
        createdAt: now.subtract(const Duration(hours: 5)),
        type: NotificationType.bookingRejected,
        relatedBookingId: 'b003',
        isRead: true,
      ),
      UserNotification(
        id: 'n4',
        title: 'Pengingat Peminjaman Segera Berakhir',
        message:
            'Peminjaman ruang kelas CR203 akan berakhir dalam 15 menit. Mohon segera menyelesaikan aktivitas.',
        createdAt: now.subtract(const Duration(hours: 7)),
        type: NotificationType.bookingReminder,
        relatedBookingId: 'b004',
        isRead: false,
      ),
      UserNotification(
        id: 'n5',
        title: 'Peminjaman Selesai',
        message:
            'Terima kasih, peminjaman fasilitas Laptop Lab 02 telah ditandai selesai oleh admin.',
        createdAt: now.subtract(const Duration(days: 1)),
        type: NotificationType.bookingEnded,
        relatedBookingId: 'b005',
        isRead: true,
      ),
      UserNotification(
        id: 'n6',
        title: 'Info Sistem',
        message:
            'Aplikasi SPaRE akan mengalami pemeliharaan pada 15 Des 2025 pukul 22.00 - 23.00 WITA.',
        createdAt: now.subtract(const Duration(days: 2)),
        type: NotificationType.system,
        isRead: true,
      ),
    ]);

    // urutkan terbaru di atas
    _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ====== FILTERING & GROUPING ======

  List<UserNotification> get _filteredNotifications {
    return _notifications.where((n) {
      switch (_filter) {
        case _NotificationFilter.all:
          return true;
        case _NotificationFilter.unread:
          return !n.isRead;
        case _NotificationFilter.bookingOnly:
          return n.type != NotificationType.system;
        case _NotificationFilter.systemOnly:
          return n.type == NotificationType.system;
      }
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Map<String, List<UserNotification>> _groupByDate(
    List<UserNotification> list,
  ) {
    final Map<String, List<UserNotification>> grouped = {};

    for (final n in list) {
      final dateOnly = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      final label = _buildDateLabel(dateOnly);

      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(n);
    }

    return grouped;
  }

  String _buildDateLabel(DateTime date) {
    final today = DateTime.now();
    final dToday = DateTime(today.year, today.month, today.day);
    final dTarget = DateTime(date.year, date.month, date.day);

    final diff = dTarget.difference(dToday).inDays;

    if (diff == 0) {
      return 'Hari ini';
    } else if (diff == -1) {
      return 'Kemarin';
    } else {
      return _dateFormatter.format(date);
    }
  }

  // ====== UI HELPER UNTUK TIPE NOTIF ======

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingCreated:
        return Icons.playlist_add_check_circle_outlined;
      case NotificationType.bookingApproved:
        return Icons.check_circle_outline;
      case NotificationType.bookingRejected:
        return Icons.cancel_outlined;
      case NotificationType.bookingReminder:
        return Icons.alarm;
      case NotificationType.bookingEnded:
        return Icons.checklist_rtl;
      case NotificationType.system:
        return Icons.info_outline;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingCreated:
        return AppColors.mainGradientStart;
      case NotificationType.bookingApproved:
        return AppColors.success;
      case NotificationType.bookingRejected:
        return AppColors.error;
      case NotificationType.bookingReminder:
        return AppColors.warning;
      case NotificationType.bookingEnded:
        return AppColors.info;
      case NotificationType.system:
        return AppColors.mainGradientStart;
    }
  }

  String _labelForType(NotificationType type) {
    switch (type) {
      case NotificationType.bookingCreated:
        return 'Reservasi';
      case NotificationType.bookingApproved:
        return 'Disetujui';
      case NotificationType.bookingRejected:
        return 'Ditolak';
      case NotificationType.bookingReminder:
        return 'Pengingat';
      case NotificationType.bookingEnded:
        return 'Selesai';
      case NotificationType.system:
        return 'Sistem';
    }
  }

  // ====== AKSI ======

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _onTapNotification(UserNotification n) {
    setState(() {
      n.isRead = true;
    });

    // TODO: kalau mau, bisa diarahkan ke halaman detail peminjaman
    // if (n.relatedBookingId != null) {
    //   Navigator.pushNamed(context, '/booking_detail', arguments: n.relatedBookingId);
    // }
  }

  // ====== BUILD ======

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;
    final grouped = _groupByDate(filtered);
    final dateKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Notifikasi',
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (filtered.any((n) => !n.isRead))
                    TextButton(
                      onPressed: _markAllAsRead,
                      child: Text(
                        'Tandai semua terbaca',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.mainGradientStart,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lihat update terbaru reservasi dan peminjaman Anda.',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ===== FILTER TABS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip(
                      label: 'Semua',
                      isSelected: _filter == _NotificationFilter.all,
                      onTap: () =>
                          setState(() => _filter = _NotificationFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Belum dibaca',
                      isSelected: _filter == _NotificationFilter.unread,
                      onTap: () =>
                          setState(() => _filter = _NotificationFilter.unread),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Peminjaman',
                      isSelected: _filter == _NotificationFilter.bookingOnly,
                      onTap: () => setState(
                        () => _filter = _NotificationFilter.bookingOnly,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _filterChip(
                      label: 'Sistem',
                      isSelected: _filter == _NotificationFilter.systemOnly,
                      onTap: () => setState(
                        () => _filter = _NotificationFilter.systemOnly,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ===== LIST NOTIFIKASI =====
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Belum ada notifikasi untuk filter yang dipilih.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: dateKeys.length,
                      itemBuilder: (context, index) {
                        final dateLabel = dateKeys[index];
                        final items = grouped[dateLabel] ?? [];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              dateLabel,
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...items.map(
                              (n) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: _buildNotificationCard(n),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // ===== BOTTOM NAVBAR USER =====
      bottomNavigationBar: const BottomNavBar(
        selectedIndex: 2,
        useRoleRouting: true,
      ),

    );
  }

  // ====== UI KOMponen ======

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

  Widget _buildNotificationCard(UserNotification n) {
    final typeColor = _colorForType(n.type);
    final icon = _iconForType(n.type);
    final typeLabel = _labelForType(n.type);
    final timeLabel = _timeFormatter.format(n.createdAt);

    return GestureDetector(
      onTap: () => _onTapNotification(n),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: n.isRead
                ? AppColors.border
                : typeColor.withOpacity(0.6),
            width: n.isRead ? 1 : 1.3,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + indikator belum dibaca
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        typeColor.withOpacity(0.15),
                        typeColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: typeColor,
                    size: 22,
                  ),
                ),
                if (!n.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: typeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),

            // Teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // judul + jam
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight:
                                n.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppColors.titleText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Text(
                    n.message,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: typeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              typeLabel,
                              style: AppTextStyles.caption.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!n.isRead) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Baru',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mainGradientStart,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
