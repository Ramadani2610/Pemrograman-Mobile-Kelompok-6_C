import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';

class UserManagePage extends StatelessWidget {
  const UserManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Kelas & Fasilitas',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ===== HERO CARD / PENJELASAN SINGKAT =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.mainGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mainGradientStart.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Mahasiswa!',
                            style: AppTextStyles.body1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Di halaman ini kamu bisa cek jadwal, cari ruang kosong, '
                            'dan ajukan peminjaman kelas maupun fasilitas.',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.dashboard_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Apa yang bisa kamu lakukan?',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pilih salah satu menu di bawah untuk mulai mengelola kebutuhan kelas '
                'dan fasilitas belajar kamu.',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),

              const SizedBox(height: 18),

              // ===== GRID FITUR (4 KARTU) =====
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  _FeatureCard(
                    icon: Icons.event_note_outlined,
                    title: 'Jadwal Kelas',
                    description:
                        'Lihat jadwal kelas terkini.',
                    chipLabel: 'Lihat jadwal',
                    onTap: () {
                      Navigator.pushNamed(context, '/class_schedule');
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.search_outlined,
                    title: 'Cari Ruang Kelas',
                    description:
                        'Temukan ruang kelas kosong berdasarkan tanggal & waktu.',
                    chipLabel: 'Cari ruangan',
                    onTap: () {
                      Navigator.pushNamed(context, '/search_classroom');
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.meeting_room_outlined,
                    title: 'Reservasi Kelas',
                    description:
                        'Ajukan peminjaman ruang kelas.',
                    chipLabel: 'Ajukan kelas',
                    onTap: () {
                      Navigator.pushNamed(context, '/class_reservation');
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.devices_other_outlined,
                    title: 'Reservasi Fasilitas',
                    description:
                        'Pinjam proyektor, kabel HDMI, dan fasilitas lainnya.',
                    chipLabel: 'Ajukan fasilitas',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/user_facility_reservation',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ===== SECTION BANTUAN SINGKAT =====
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            AppColors.mainGradientStart.withOpacity(0.09),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: AppColors.mainGradientStart,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: mulai dari "Cari Ruang Kelas" jika kamu belum tahu '
                        'ruangan mana yang masih kosong untuk direservasi.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // ===== NAVBAR USER (posisi tab: Kelola) =====
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1, // asumsi tab ke-1 = menu kelas/kelola
        onItemTapped: (index) {
          if (index == 1) return; // sudah di sini
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home_user');
              break;
            case 1:
              // current page
              break;
            case 2:
              Navigator.pushReplacementNamed(
                context,
                '/user_notification',
              );
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/user_history');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String chipLabel;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.chipLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.mainGradientStart.withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + chip kecil di kanan atas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.mainGradient,
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.mainGradientStart.withOpacity(0.08),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.mainGradientStart,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Aktif',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mainGradientStart,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Icon(
                icon,
                size: 26,
                color: AppColors.mainGradientStart,
              ),
              const SizedBox(height: 6),

              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),

              Expanded(
                child: Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    chipLabel,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.mainGradientStart,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.mainGradientStart,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
