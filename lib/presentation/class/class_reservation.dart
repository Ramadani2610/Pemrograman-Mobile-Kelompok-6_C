import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';


class ClassReservationPage extends StatefulWidget {
  const ClassReservationPage({super.key});

  @override
  State<ClassReservationPage> createState() => _ClassReservationPageState();
}

class _ClassReservationPageState extends State<ClassReservationPage> {
  // ----- dummy data -----
  final List<String> _rooms = ['CR 100', 'CR 101', 'CR 102', 'Lab 201'];
  final List<String> _courses = [
    'Pemrograman Mobile C',
    'Metode Penelitian',
    'Sistem Basis Data',
  ];

  final String _reasonClass = 'Kelas Pengganti/Tambahan Mata Kuliah';
  final String _reasonOrg = 'Agenda Organisasi';

  // ----- state -----
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _selectedRoom;
  String? _selectedReason;
  String? _selectedCourse;

  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _letterController = TextEditingController();

  @override
  void dispose() {
    _orgNameController.dispose();
    _eventNameController.dispose();
    _letterController.dispose();
    super.dispose();
  }

  // ====== PICKERS ======
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

  // ====== DIALOG FLOW ======
  Future<void> _onSubmit() async {
    final confirmed = await _showConfirmDialog(
      title: 'Ajukan Peminjaman?',
      message:
          'Pastikan data reservasi sudah benar. Apakah Anda yakin ingin '
          'mengajukan peminjaman kelas?',
      confirmLabel: 'Ya, Ajukan',
    );
    if (confirmed != true) return;

    // di sini nanti panggil backend ajukan_peminjaman
    await _showInfoDialog(
      title: 'Berhasil',
      message: 'Peminjaman kelas berhasil diajukan.',
    );

    if (!mounted) return;
    // Kembali ke main_classroom
    Navigator.pushReplacementNamed(
      context,
      '/main_classroom', // TODO: sesuaikan dengan nama route yang Prof pakai
    );
  }

  Future<void> _onCancel() async {
    final confirmed = await _showConfirmDialog(
      title: 'Batalkan Peminjaman?',
      message:
          'Proses pengisian reservasi akan dibatalkan. '
          'Apakah Anda yakin ingin membatalkan?',
      confirmLabel: 'Ya, Batalkan',
    );
    if (confirmed != true) return;

    await _showInfoDialog(
      title: 'Dibatalkan',
      message: 'Peminjaman kelas batal diajukan.',
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/main_classroom', // TODO: sesuaikan route
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  Future<void> _showInfoDialog({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
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

  // ====== BUILD ======
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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar custom (tanpa pakai widget AppBar bawaan supaya mirip desain)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: nanti arahkan ke halaman chat
                    },
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.mainGradientStart,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      'Reservasi Kelas',
                      style: AppTextStyles.heading1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reservasi Kelas Manual',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---------- TANGGAL / WAKTU ----------
                    Text(
                      'Tanggal/Waktu',
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

                    const SizedBox(height: 20),

                    // ---------- RUANG KELAS ----------
                    Text(
                      'Ruang Kelas',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownSearch<String>(
                      items: _rooms,
                      selectedItem: _selectedRoom,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: _inputDecoration('Cari kelas...'),
                          style: AppTextStyles.body1,
                        ),
                      ),

                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: _inputDecoration('Pilih Kelas'),
                      ),

                      itemAsString: (String? item) => item ?? '',
                      onChanged: (String? val) {
                        setState(() => _selectedRoom = val);
                      },
                    ),



                    const SizedBox(height: 20),

                    // ---------- ALASAN RESERVASI ----------
                    Text(
                      'Alasan Reservasi',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedReason,
                      decoration: _inputDecoration('Pilih Alasan Reservasi'),
                      items: <String>[_reasonClass, _reasonOrg]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: AppTextStyles.body1),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedReason = val;
                          // reset field lanjutan setiap ganti alasan
                          _selectedCourse = null;
                          _orgNameController.clear();
                          _eventNameController.clear();
                          _letterController.clear();
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // ---------- PERTANYAAN LANJUTAN ----------
                    Text(
                      'Pertanyaan Lanjutan',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFollowUpSection(),

                    const SizedBox(height: 32),

                    // ---------- TOMBOL AKSI ----------
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Ajukan Peminjaman',
                            onPressed: _onSubmit,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _onCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.noButton,
                              foregroundColor: AppColors.titleText,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Batal',
                              style: AppTextStyles.button1.copyWith(
                                color: AppColors.titleText,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ====== UI HELPERS ======

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body2.copyWith(
        color: AppColors.secondaryText,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: AppColors.backgroundColor,
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
    );
  }

  Widget _buildFollowUpSection() {
    if (_selectedReason == _reasonClass) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mata Kuliah',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          DropdownSearch<String>(
            items: _courses,
            selectedItem: _selectedCourse,
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: _inputDecoration('Cari mata kuliah...'),
                style: AppTextStyles.body1,
              ),
            ),

            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: _inputDecoration('Pilih Mata Kuliah'),
            ),

            itemAsString: (String? item) => item ?? '',
            onChanged: (String? val) {
              setState(() => _selectedCourse = val);
            },
          ),
        ],
      );
    }


    if (_selectedReason == _reasonOrg) {
      // --- alasan: agenda organisasi ---
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama Organisasi',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _orgNameController,
            style: AppTextStyles.body1,
            decoration: _inputDecoration('Masukkan nama organisasi'),
          ),
          const SizedBox(height: 14),
          Text(
            'Nama Kegiatan',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _eventNameController,
            style: AppTextStyles.body1,
            decoration: _inputDecoration('Masukkan nama kegiatan'),
          ),
          const SizedBox(height: 14),
          Text(
            'Surat/Bukti Pengantar Peminjaman',
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _letterController,
            style: AppTextStyles.body1,
            decoration: _inputDecoration(
              'Tulis nomor surat / link drive / keterangan lain',
            ),
          ),
        ],
      );
    }

    // default ketika alasan belum dipilih
    return Text(
      'Pilih alasan reservasi terlebih dahulu untuk mengisi detail.',
      style: AppTextStyles.body2.copyWith(
        color: AppColors.secondaryText,
      ),
    );
  }
}

// ====== SMALL WIDGETS ======

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
