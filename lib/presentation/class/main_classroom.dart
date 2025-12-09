import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class MainClassroomPage extends StatefulWidget {
  const MainClassroomPage({super.key});

  @override
  State<MainClassroomPage> createState() => _MainClassroomPageState();
}

class _MainClassroomPageState extends State<MainClassroomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kiri: Back + Title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              const Icon(Icons.arrow_back_ios_new, size: 16),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kelola Kelas',
                            style: AppTextStyles.heading2.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                            ),
                          ),
                          Text(
                            'Admin Dashboard',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // =============== RINGKASAN HARI INI (HERO CARD) ===============
              _buildSummaryCard(),

              const SizedBox(height: 24),

              // =============== AKSI CEPAT ===============
              Text(
                'Aksi Cepat',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _quickActionCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'Jadwal',
                    description: 'Lihat timeline kelas\nper lantai.',
                    color: AppColors.mainGradientStart,
                    onTap: () =>
                        Navigator.pushNamed(context, '/class_schedule'),
                  ),
                  const SizedBox(width: 10),
                  _quickActionCard(
                    icon: Icons.search_outlined,
                    label: 'Cari',
                    description: 'Temukan ruang\nkelas kosong.',
                    color: Colors.blue.shade700,
                    onTap: () =>
                        Navigator.pushNamed(context, '/search_classroom'),
                  ),
                  const SizedBox(width: 10),
                  _quickActionCard(
                    icon: Icons.add_circle_outlined,
                    label: 'Reservasi',
                    description: 'Ajukan peminjaman\nkelas secara manual.',
                    color: Colors.green.shade700,
                    onTap: () =>
                        Navigator.pushNamed(context, '/class_reservation'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // =============== AKTIVITAS TERAKHIR ===============
              Text(
                'Aktivitas Terakhir',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              _activityItem(
                title: 'Pemakaian kelas G01',
                subtitle: 'Teknik Informatika • 13:00 - 14:40',
                statusLabel: 'Berlangsung',
                statusColor: AppColors.mainGradientStart,
              ),
              const SizedBox(height: 8),
              _activityItem(
                title: 'Reservasi Kelas 101',
                subtitle: 'Agenda Organisasi HIMATIF',
                statusLabel: 'Menunggu',
                statusColor: Colors.orange.shade700,
              ),
              const SizedBox(height: 8),
              _activityItem(
                title: 'Kelas 201 dikembalikan',
                subtitle: 'Metode Penelitian • Sesi selesai',
                statusLabel: 'Selesai',
                statusColor: Colors.green.shade700,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ================== HERO SUMMARY CARD ==================
  Widget _buildSummaryCard() {
    // Untuk sekarang masih dummy number.
    const total = 60;
    const used = 32;
    const available = 28;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.mainGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.6),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Hari Ini',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pantau pemakaian ruang kelas dan ketersediaan secara cepat.',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 angka utama
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryNumber(
                label: 'Total Kelas',
                value: '$total',
                icon: Icons.meeting_room_outlined,
              ),
              _summaryNumber(
                label: 'Terpakai',
                value: '$used',
                icon: Icons.event_busy_outlined,
              ),
              _summaryNumber(
                label: 'Tersedia',
                value: '$available',
                icon: Icons.event_available_outlined,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // progress bar simpel: ratio terpakai vs total
          LayoutBuilder(
            builder: (context, constraints) {
              final ratio = total == 0 ? 0.0 : used / total;
              final barWidth = constraints.maxWidth;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: barWidth,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        width: barWidth * ratio.clamp(0.0, 1.0),
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(ratio * 100).round()}% kelas sudah terpakai hari ini',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _summaryNumber({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ================== QUICK ACTION CARD ==================
  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.95),
                        color.withOpacity(0.75),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Text(
                  label,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================== ACTIVITY ITEM ==================
  Widget _activityItem({
    required String title,
    required String subtitle,
    required String statusLabel,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon bulat kiri
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.class_outlined,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Status pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
