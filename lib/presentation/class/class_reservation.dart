import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_widgets.dart';
import '../../data/models/booking.dart';
import '../../core/widgets/date_time_picker.dart';
import '../../core/widgets/app_dialogs.dart';


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

  DateTime _combineDateAndTime(DateTime date, TimeOfDay time) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
}

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
    final result = await showAppDatePicker(
      context,
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
    final result = await showAppTimePicker(
      context,
      initialTime: _startTime ?? now,
    );
    if (result != null) {
      setState(() => _startTime = result);
    }
  }

  Future<void> _pickEndTime() async {
    final base = _startTime ?? TimeOfDay.now();
    final result = await showAppTimePicker(
      context,
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
  // 1. Validasi
  final errorMessage = _validateForm();
  if (errorMessage != null) {
    await showAppInfoDialog(
      context,
      title: 'Data Belum Lengkap',
      message: errorMessage,
    );
    return;
  }

  // 2. Konfirmasi
  final confirmed = await showAppConfirmDialog(
    context,
    title: 'Ajukan Peminjaman?',
    message:
        'Pastikan data reservasi sudah benar. Apakah Anda yakin ingin '
        'mengajukan peminjaman kelas?',
    confirmLabel: 'Ya, Ajukan',
    cancelLabel: 'Batal',
  );
  if (confirmed != true) return;

  // 3. Siapkan data tanggal & waktu
  final date = _selectedDate!;
  final startDate = _combineDateAndTime(date, _startTime!);
  final endDate = _combineDateAndTime(date, _endTime!);

  // 4. Ambil info user dari sistem login (contoh: RouteGuard / AuthService)
  // TODO: ganti dengan implementasi real prof
  final String? currentUserId = 'user001';        // misal dari FirebaseAuth.uid
  final String? currentUserName = 'Nadia Rauf';   // misal dari profile user
  final String? currentDepartment = 'Teknik Informatika';
  final String? currentClassName = 'TI 2023 A';

  // 5. Tentukan tipe purpose
  String purposeCode;
  if (_selectedReason == _reasonClass) {
    purposeCode = 'class_replacement';  // kelas pengganti/tambahan
  } else if (_selectedReason == _reasonOrg) {
    purposeCode = 'organization_event';
  } else {
    purposeCode = 'other';
  }

  // 6. (Opsional) upload file ke Firebase Storage, dapatkan URL
  // String? attachmentUrl;
  // if (_selectedReason == _reasonOrg && _letterFile != null) {
  //   attachmentUrl = await UploadService.uploadLetterFile(_letterFile!);
  // }

  // 7. Bangun objek Booking
  final now = DateTime.now();
  final newBooking = Booking(
    id: '',                // biarkan kosong → akan diisi di service (doc.id)
    userId: currentUserId,
    name: currentUserName,
    facilityId: null,      // karena ini reservasi kelas
    roomId: _selectedRoom, // IMPORTANT: pastikan ini ID ruangan yang sama dengan Room model
    startDate: startDate,
    endDate: endDate,
    status: 'pending',
    purpose: purposeCode,
    quantity: 1,
    createdAt: now,
    updatedAt: now,
    className: currentClassName,                // dari profil user
    courseName: _selectedReason == _reasonClass
        ? _selectedCourse
        : null,
    department: currentDepartment,
    organizationName: _selectedReason == _reasonOrg
        ? _orgNameController.text.trim()
        : null,
    eventName: _selectedReason == _reasonOrg
        ? _eventNameController.text.trim()
        : null,
    attachmentPath: null, // ganti dengan attachmentUrl kalau sudah ada upload
    rejectedBy: null,
    rejectedReason: null,
    actualReturnTime: null, // bukan fasilitas → null
  );

  // 8. Kirim ke backend (nanti ke Firebase)
  // Contoh pseudo-code:
  //
  // await BookingRepository.instance.createClassBooking(newBooking);
  //
  // di dalamnya kira-kira:
  //   final doc = bookingsCollection.doc();
  //   final bookingWithId = newBooking.copyWith(id: doc.id);
  //   await doc.set(bookingWithId.toMap());

  await showAppInfoDialog(
    context,
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
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Batalkan Peminjaman?',
      message:
          'Proses pengisian reservasi akan dibatalkan. '
          'Apakah Anda yakin ingin membatalkan?',
      confirmLabel: 'Ya, Batalkan',
    );
    if (confirmed != true) return;

    await showAppInfoDialog(
      context,
      title: 'Dibatalkan',
      message: 'Peminjaman kelas batal diajukan.',
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/main_classroom',
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
