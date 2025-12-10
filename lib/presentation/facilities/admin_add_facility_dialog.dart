import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';

class AdminAddFacilityPage extends StatefulWidget {
  const AdminAddFacilityPage({super.key});

  static void navigate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAddFacilityPage(),
      ),
    );
  }

  @override
  State<AdminAddFacilityPage> createState() => _AdminAddFacilityPageState();
}

class _AdminAddFacilityPageState extends State<AdminAddFacilityPage> {
  DateTime? _selectedDate;
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _merekController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Listener untuk mendeteksi perubahan pada text fields
    _namaController.addListener(_checkForChanges);
    _merekController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    setState(() {
      _hasChanges = _namaController.text.isNotEmpty ||
          _merekController.text.isNotEmpty ||
          _selectedDate != null;
    });
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFD32F2F),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F),
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _checkForChanges();
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Fungsi untuk menampilkan alert konfirmasi batal
  Future<void> _showCancelConfirmation(BuildContext context) async {
    if (!_hasChanges) {
      // Jika tidak ada perubahan, langsung kembali
      Navigator.pop(context);
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Batalkan Tambah Fasilitas?'),
          content: const Text(
            'Data yang sudah diisi akan hilang. Apakah Anda yakin ingin membatalkan?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: Text(
                'Lanjut Isi',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Ya, Batalkan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _namaController.removeListener(_checkForChanges);
    _merekController.removeListener(_checkForChanges);
    _namaController.dispose();
    _merekController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan tombol kembali dan judul
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => _showCancelConfirmation(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tambah Fasilitas',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.titleText,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Form Input Fields
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Fasilitas',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.titleText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Masukkan nama fasilitas',
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tanggal Masuk dengan Date Picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Masuk',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.titleText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _showDatePicker(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_selectedDate),
                              style: TextStyle(
                                color: _selectedDate == null 
                                    ? Colors.grey[600] 
                                    : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merek',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.titleText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextFormField(
                        controller: _merekController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Masukkan merek',
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Upload Gambar Section
                Text(
                  'Unggah Gambar',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleText,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // Tambahkan fungsi untuk memilih gambar
                  },
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unggah Gambar',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Batal dan Simpan
                Row(
                  children: [
                    // Tombol Batal
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => _showCancelConfirmation(context),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.titleText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tombol Simpan dengan warna merah
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_namaController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Nama fasilitas harus diisi'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (_selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tanggal masuk harus dipilih'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (_merekController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Merek harus diisi'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fasilitas berhasil ditambahkan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Simpan',
                            style: AppTextStyles.body1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}