import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_widgets.dart';

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
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _selectedRoom;
  String? _selectedReason;
  String? _selectedCourse;

  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  PlatformFile? _letterFile; // upload file (foto/pdf)
  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  @override
  void dispose() {
    _orgNameController.dispose();
    _eventNameController.dispose();
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

  Future<void> _pickStartTime() async {
    final now = TimeOfDay.now();
    final result = await showTimePicker(
      context: context,
      initialTime: _startTime ?? now,
    );
    if (result != null) {
      setState(() => _startTime = result);
    }
  }

  Future<void> _pickEndTime() async {
    final base = _startTime ?? TimeOfDay.now();
    final result = await showTimePicker(
      context: context,
      initialTime: _endTime ?? base,
    );
    if (result != null) {
      setState(() => _endTime = result);
    }
  }

  Future<void> _pickLetterFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _letterFile = result.files.first;
      });
    }
  }

  /// ====== VALIDASI FORM ======
  String? _validateForm() {
    final missing = <String>[];

    if (_selectedDate == null) {
      missing.add('• Tanggal');
    }
    if (_startTime == null) {
      missing.add('• Waktu Mulai');
    }
    if (_endTime == null) {
      missing.add('• Waktu Selesai');
    }
    if (_selectedRoom == null) {
      missing.add('• Ruang Kelas');
    }
    if (_selectedReason == null) {
      missing.add('• Alasan Reservasi');
    }

    // validasi lanjutan tergantung alasan
    if (_selectedReason == _reasonClass) {
      if (_selectedCourse == null) {
        missing.add('• Mata Kuliah (untuk kelas pengganti/tambahan)');
      }
    }

    if (_selectedReason == _reasonOrg) {
      if (_orgNameController.text.trim().isEmpty) {
        missing.add('• Nama Organisasi');
      }
      if (_eventNameController.text.trim().isEmpty) {
        missing.add('• Nama Kegiatan');
      }
      if (_letterFile == null) {
        missing.add('• Surat/Bukti Pengantar Peminjaman (file)');
      }
    }

    // cek logika waktu kalau keduanya sudah terisi
    if (_startTime != null && _endTime != null) {
      final start = _toMinutes(_startTime!);
      final end = _toMinutes(_endTime!);
      if (end <= start) {
        return 'Rentang waktu tidak valid.\n'
            'Waktu selesai harus lebih besar dari waktu mulai.';
      }
    }

    if (missing.isEmpty) return null;

    return 'Mohon lengkapi data berikut:\n${missing.join('\n')}';
  }

  // ====== DIALOG FLOW ======
  Future<void> _onSubmit() async {
    // validasi wajib isi
    final errorMessage = _validateForm();
    if (errorMessage != null) {
      await _showInfoDialog(
        title: 'Data Belum Lengkap',
        message: errorMessage,
      );
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'Ajukan Peminjaman?',
      message:
          'Pastikan data reservasi sudah benar. Apakah Anda yakin ingin '
          'mengajukan peminjaman kelas?',
      confirmLabel: 'Ya, Ajukan',
    );
    if (confirmed != true) return;


    // ====== DI SINI NANTI PANGGIL BACKEND ======
    // Misalnya:
    // await ClassReservationService.instance.createReservation(
    //   date: _selectedDate!,
    //   startTime: _startTime!,
    //   endTime: _endTime!,
    //   room: _selectedRoom!,
    //   reason: _selectedReason!,
    //   course: _selectedCourse,
    //   orgName: _orgNameController.text,
    //   eventName: _eventNameController.text,
    //   attachment: _letterFile,
    // );
    //
    // Backend akan menyimpan data dengan status "pending".
    // Halaman Tinjau Peminjaman admin tinggal membaca semua booking
    // dengan status = "pending" dari backend.

    await _showInfoDialog(
      title: 'Berhasil',
      message: 'Peminjaman kelas berhasil diajukan.',
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/main_classroom',
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
      '/main_classroom',
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

    final startLabel =
        _startTime == null ? 'Waktu Mulai' : _startTime!.format(context);
    final endLabel =
        _endTime == null ? 'Waktu Selesai' : _endTime!.format(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar custom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reservasi Kelas',
                    style: AppTextStyles.heading2,
                  ),
                  const Spacer(),
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
                    Text(
                      'Reservasi Kelas Manual',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---------- TANGGAL ----------
                    Text(
                      'Tanggal',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PickerField(
                      label: dateLabel,
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDate,
                    ),

                    const SizedBox(height: 20),

                    // ---------- WAKTU MULAI & SELESAI ----------
                    Text(
                      'Waktu',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _PickerField(
                            label: startLabel,
                            icon: Icons.access_time,
                            onTap: _pickStartTime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PickerField(
                            label: endLabel,
                            icon: Icons.access_time,
                            onTap: _pickEndTime,
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
                      itemAsString: (String item) => item,
                      onChanged: (val) {
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
                          _selectedCourse = null;
                          _orgNameController.clear();
                          _eventNameController.clear();
                          _letterFile = null;
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
      // --- alasan: kelas pengganti/tambahan ---
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
            itemAsString: (String item) => item,
            onChanged: (val) {
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
          OutlinedButton.icon(
            onPressed: _pickLetterFile,
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.border),
              backgroundColor: Colors.white,
            ),
            icon: const Icon(Icons.upload_file, size: 18),
            label: Text(
              _letterFile == null
                  ? 'Pilih file (JPG/PNG/PDF)'
                  : _letterFile!.name,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.titleText,
              ),
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
                  color: label.startsWith('Pilih') ||
                          label.startsWith('Waktu')
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
