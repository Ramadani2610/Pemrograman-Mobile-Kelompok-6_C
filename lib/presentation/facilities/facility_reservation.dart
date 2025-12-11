import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_search/dropdown_search.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_widgets.dart';

class FacilityReservationPage extends StatefulWidget {
  const FacilityReservationPage({super.key});

  @override
  State<FacilityReservationPage> createState() =>
      _FacilityReservationPageState();
}

class _FacilityReservationPageState extends State<FacilityReservationPage> {
  // ----- dummy data ruang kelas -----
  final List<String> _rooms = ['CR 100', 'CR 101', 'CR 102', 'Lab 201'];
  final List<String> _courses = [
    'Pemrograman Mobile C',
    'Metode Penelitian',
    'Sistem Basis Data',
  ];

  // ----- fasilitas yang bisa dipinjam -----
  final List<String> _facilityOptions = const [
    'Proyektor',
    'Terminal',
    'Remote TV',
    'Spidol',
    'Kabel HDMI',
    'Penghapus',
  ];

  // ----- state -----
  DateTime? _selectedDate;
  TimeOfDay? _pickupTime;
  String? _selectedRoom;
  String? _selectedCourse;
  final Set<String> _selectedFacilities = {};

  final DateFormat _dateFormatter = DateFormat('dd-MM-yyyy');

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

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

  Future<void> _pickPickupTime() async {
    final now = TimeOfDay.now();
    final result = await showTimePicker(
      context: context,
      initialTime: _pickupTime ?? now,
    );
    if (result != null) {
      setState(() => _pickupTime = result);
    }
  }

  // ====== VALIDASI ======

  String? _validateForm() {
    final missing = <String>[];

    if (_selectedDate == null) {
      missing.add('• Tanggal');
    }
    if (_pickupTime == null) {
      missing.add('• Waktu Ambil');
    }
    if (_selectedRoom == null) {
      missing.add('• Ruang Kelas');
    }
    if (_selectedCourse == null) {
      missing.add('• Mata Kuliah');
    }
    if (_selectedFacilities.isEmpty) {
      missing.add('• Minimal pilih 1 fasilitas');
    }

    // misal jam ambil tidak boleh sebelum jam 07.00
    if (_pickupTime != null) {
      final pickMinutes = _toMinutes(_pickupTime!);
      final minMinutes = _toMinutes(const TimeOfDay(hour: 7, minute: 0));
      if (pickMinutes < minMinutes) {
        return 'Waktu ambil terlalu pagi.\n'
            'Silakan pilih jam setelah 07.00.';
      }
    }

    if (missing.isEmpty) return null;

    return 'Mohon lengkapi data berikut:\n${missing.join('\n')}';
  }


  // ====== DIALOG FLOW ======

  Future<void> _onSubmit() async {
    final errorMessage = _validateForm();
    if (errorMessage != null) {
      await _showInfoDialog(
        title: 'Data Belum Lengkap',
        message: errorMessage,
      );
      return;
    }

    // Trigger warning / konfirmasi
    final confirmed = await _showConfirmDialog(
      title: 'Ajukan Peminjaman Fasilitas?',
      message:
          'Pastikan tanggal, waktu ambil, ruang kelas, dan fasilitas yang '
          'dipilih sudah benar.\n\n'
          'PERHATIAN:\n'
          '- Fasilitas WAJIB dikembalikan dalam keadaan baik.\n'
          '- Kerusakan / kehilangan menjadi tanggung jawab peminjam.\n\n'
          'Apakah Anda yakin ingin mengajukan peminjaman?',
      confirmLabel: 'Ya, Ajukan',
    );
    if (confirmed != true) return;

    // ====== DI SINI NANTI PANGGIL BACKEND ======
    // Contoh pseudo:
    // await FacilityReservationService.instance.createReservation(
    //   date: _selectedDate!,
    //   pickupTime: _pickupTime!,
    //   room: _selectedRoom!,
    //   facilities: _selectedFacilities.toList(),
    // );

    await _showInfoDialog(
      title: 'Berhasil',
      message:
          'Peminjaman fasilitas berhasil diajukan.\n'
          'Silakan menunggu persetujuan dari admin.',
    );

    if (!mounted) return;
    Navigator.pop(context); // kembali ke halaman sebelumnya
  }

  Future<void> _onCancel() async {
    final confirmed = await _showConfirmDialog(
      title: 'Batalkan Peminjaman?',
      message:
          'Proses pengisian reservasi fasilitas akan dibatalkan. '
          'Apakah Anda yakin?',
      confirmLabel: 'Ya, Batalkan',
    );
    if (confirmed != true) return;

    await _showInfoDialog(
      title: 'Dibatalkan',
      message: 'Peminjaman fasilitas batal diajukan.',
    );

    if (!mounted) return;
    Navigator.pop(context);
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        : _dateFormatter.format(_selectedDate!);

    final pickupLabel =
        _pickupTime == null ? 'Waktu Ambil' : _pickupTime!.format(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar custom (tanpa ikon chat)
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
                    'Reservasi Fasilitas',
                    style: AppTextStyles.heading2,
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
                    Text(
                      'Reservasi Fasilitas',
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

                    // ---------- WAKTU AMBIL ----------
                    Text(
                      'Waktu Ambil',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _PickerField(
                      label: pickupLabel,
                      icon: Icons.access_time,
                      onTap: _pickPickupTime,
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
                    DropdownButtonFormField<String>(
                      value: _selectedRoom,
                      decoration: _inputDecoration('Pilih Kelas'),
                      items: _rooms
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: AppTextStyles.body1),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedRoom = val);
                      },
                    ),

                    const SizedBox(height: 20),

                    // ---------- MATA KULIAH ----------
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

                    const SizedBox(height: 20),

                    // ---------- FASILITAS ----------
                    Text(
                      'Fasilitas yang Dipinjam',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih fasilitas yang ingin digunakan (minimal 1).',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFacilityCheckboxes(),

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

  Widget _buildFacilityCheckboxes() {
    return Column(
      children: _facilityOptions.map((f) {
        final isSelected = _selectedFacilities.contains(f);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.mainGradientStart
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedFacilities.add(f);
                } else {
                  _selectedFacilities.remove(f);
                }
              });
            },
            title: Text(
              f,
              style: AppTextStyles.body1,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.mainGradientStart,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
        );
      }).toList(),
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
                  color: label.startsWith('Pilih') || label.startsWith('Waktu')
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
