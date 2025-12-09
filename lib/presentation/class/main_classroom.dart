import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../presentation/class/search_classroom.dart';

class MainClassroomPage extends StatefulWidget {
  const MainClassroomPage({super.key});

  @override
  State<MainClassroomPage> createState() => _MainClassroomPageState();
}

class _MainClassroomPageState extends State<MainClassroomPage> {
  int _selectedBottomIndex = 0;

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
              // ======= TOP BAR (Back + Chat) =======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios_new, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Kembali',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.nonClassColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.mainGradientStart,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ======= TITLE =======
              Text(
                'Kelola Kelas',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              // ======= SUMMARY CARDS (60 / 32 / 28) =======
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      value: '60',
                      label: 'Total',
                      isTotal: true,
                      isUsed: false,
                      isAvailable: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      value: '32',
                      label: 'Terpakai',
                      isTotal: false,
                      isUsed: true,
                      isAvailable: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _summaryCard(
                      value: '28',
                      label: 'Tersedia',
                      isTotal: false,
                      isUsed: false,
                      isAvailable: true,
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 18),

              // ======= FILTER BUTTONS (Jadwal / Cari / Reservasi) =======
              Row(
                children: [
                  Expanded(
                    child: _roundedGradientButton(
                      label: 'Jadwal',
                      onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/class_schedule',
                                );
                              },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _roundedGradientButton(
                      label: 'Cari',
                      onTap: () {
                          Navigator.pushNamed(
                                  context,
                                  '/search_classroom',
                                );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _roundedGradientButton(
                      label: 'Reservasi',
                      onTap: () {
                        Navigator.pushNamed(
                                  context,
                                  '/class_reservation',
                                );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ======= SECTION TITLE =======
              Text(
                'Tinjau Peminjaman',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.titleText,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // ======= LOAN CARD =======
              _loanReviewCard(),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Lihat Lebih Banyak...',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // ======= BOTTOM NAVBAR (admin) =======
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemTapped: (index) {
          setState(() => _selectedBottomIndex = index);
          // TODO: sesuaikan navigation antar page admin jika perlu
        },
      ),
    );
  }

  // ===================================================================
  // WIDGET SUMMARY CARD (Total / Terpakai / Tersedia)
  // ===================================================================
  Widget _summaryCard({
    required String value,
    required String label,
    required bool isTotal,
    required bool isUsed,
    required bool isAvailable,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==== Angka ====
          isUsed
              ? ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.mainGradient.createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
                  child: Text(
                    value,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                    ),
                  ),
                )
              : isAvailable
                  ? ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.greenGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        value,
                        style: AppTextStyles.heading3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                        ),
                      ),
                    )
                  : Text(
                      value,
                      style: AppTextStyles.heading3.copyWith(
                        color: Color(0xFF676666),
                        fontWeight: FontWeight.w700,
                        fontSize: 26,
                      ),
                    ),

          const SizedBox(height: 4),

          // ==== Label ====
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: isTotal
                  ? AppColors.nonClassColor
                  : isUsed
                      ? AppColors.mainGradientStart
                      : Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // WIDGET ROUNDED GRADIENT BUTTON (Jadwal / Cari / Reservasi)
  // ===================================================================
  Widget _roundedGradientButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: AppColors.mainGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.button1.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // WIDGET CARD TINJAU PEMINJAMAN
  // ===================================================================
  Widget _loanReviewCard() {
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
          // Title merah
          Text(
            'Nama Peminjam',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.mainGradientStart,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // Info utama + mata kuliah (kartu biru)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info ruangan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '202',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'CR 100',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '13:00 - 14:40',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Kartu biru mata kuliah
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.blueGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Teknik Informatika 2023\nPemrograman Mobile C',
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

          // Tanggal
          Text(
            'Tanggal / Status Peminjam\n30/11/2025',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: 12),

          // Tombol aksi: Terima / Batal / Lihat Detail
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Terima (filled red)
              _smallActionButton(
                label: 'Terima',
                gradient: AppColors.mainGradient,
                textColor: Colors.white,
              ),
              const SizedBox(width: 8),

              // Batal (outline grey)
              _smallActionButton(
                label: 'Batal',
                background: Colors.white,
                borderColor: AppColors.border,
                textColor: AppColors.secondaryText,
              ),
              const SizedBox(width: 8),

              // Lihat Detail (biru)
              _smallActionButton(
                label: 'Lihat Detail',
                gradient: AppColors.blueGradient,
                textColor: Colors.white,
              ),
            ],
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
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
    );
  }
}
