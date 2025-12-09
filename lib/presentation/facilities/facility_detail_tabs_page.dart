import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';

class FacilityDetailTabsPage extends StatefulWidget {
  final String facilityName;

  const FacilityDetailTabsPage({
    super.key,
    required this.facilityName,
  });

  @override
  State<FacilityDetailTabsPage> createState() =>
      _FacilityDetailTabsPageState();
}

class _FacilityDetailTabsPageState extends State<FacilityDetailTabsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.facilityName,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.titleText,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.mainGradientStart,
              indicatorWeight: 3,
              labelColor: AppColors.mainGradientStart,
              unselectedLabelColor: AppColors.secondaryText,
              labelStyle: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.body2,
              tabs: const [
                Tab(text: 'Tersedia'),
                Tab(text: 'Dipinjam'),
                Tab(text: 'Lainnya'),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF7F7F7),
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAvailableTab(),
            _buildBorrowedTab(),
            _buildOtherTab(),
          ],
        ),
      ),
    );
  }

  // ================== TABS ==================

  Widget _buildAvailableTab() {
    final items = ['A1', 'A2', 'A3', 'A5', 'A6'];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(
          items[index],
          'Tersedia',
          '15/04/2005',
          'Isab wira',
          showEditButton: false,
        );
      },
    );
  }

  Widget _buildBorrowedTab() {
    final items = ['A1', 'A2', 'A3', 'A4', 'A5', 'A6'];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(
          items[index],
          'Dipinjam',
          '15/04/2005',
          'Isab wira',
          showEditButton: true,
        );
      },
    );
  }

  Widget _buildOtherTab() {
    final items = ['R1', 'R2', 'R3', 'R4', 'R5'];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(
          items[index],
          'Rusak',
          '15/04/2005',
          '-',
          showEditButton: false,
        );
      },
    );
  }

  // ================== CARD ==================

  Widget _buildItemCard(
    String code,
    String status,
    String entryDate,
    String lastBorrowed, {
    required bool showEditButton,
  }) {
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kode Item
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  code,
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info Item
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$code ${widget.facilityName}',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: $status',
                    style: AppTextStyles.body2.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk: $entryDate',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Kolom kanan (untuk yang dipinjam)
            if (showEditButton)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    lastBorrowed,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _showEditDialog(
                      '$code ${widget.facilityName}',
                      entryDate,
                      lastBorrowed,
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.mainGradientStart,
                        width: 1.2,
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.mainGradientStart,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return AppColors.success;
      case 'Dipinjam':
        return AppColors.warning;
      case 'Rusak':
        return AppColors.error;
      default:
        return AppColors.secondaryText;
    }
  }

  // ================== EDIT DIALOG ==================

  void _showEditDialog(String name, String entryDate, String lastBorrowed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Fasilitas',
          style: AppTextStyles.heading3,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  labelText: 'Nama Fasilitas',
                  labelStyle: AppTextStyles.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: entryDate,
                decoration: InputDecoration(
                  labelText: 'Tanggal Masuk',
                  labelStyle: AppTextStyles.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: AppTextStyles.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Terakhir dipinjam: $lastBorrowed',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTextStyles.button2.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainGradientStart,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Perubahan berhasil disimpan',
                    style: AppTextStyles.body2.copyWith(color: Colors.white),
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              'Simpan',
              style: AppTextStyles.button2.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
