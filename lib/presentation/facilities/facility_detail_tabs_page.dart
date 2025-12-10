import 'package:flutter/material.dart';
import 'package:spareapp_unhas/core/constants/app_colors.dart';
import 'package:spareapp_unhas/core/constants/app_text_styles.dart';
import 'package:spareapp_unhas/data/models/facility_item_model.dart';

class FacilityDetailTabsPage extends StatefulWidget {
  final String facilityName;
  final String imagePath;
  final List<FacilityItem> items;

  const FacilityDetailTabsPage({
    super.key,
    required this.facilityName,
    required this.imagePath,
    required this.items,
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
                Tab(text: 'Rusak'),
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
            _buildTab('Tersedia'),
            _buildTab('Dipinjam'),
            _buildTab('Rusak'),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String status) {
    // Filter items berdasarkan status
    final filteredItems = widget.items
        .where((item) => item.status == status)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(FacilityItem item) {
    final statusColor = _getStatusColor(item.status);
    
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
            // Gambar Fasilitas
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.backgroundColor,
                      child: Icon(
                        Icons.image,
                        size: 30,
                        color: AppColors.secondaryText,
                      ),
                    );
                  },
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
                    '${item.code} ${widget.facilityName}',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Status: ${item.status}',
                        style: AppTextStyles.body2.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.status == 'Dipinjam' && item.lastBorrowed != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            'oleh ${item.lastBorrowed!}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masuk: ${item.entryDate}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Edit untuk SEMUA status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (item.status == 'Dipinjam' && item.lastBorrowed != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Dipinjam oleh\n${item.lastBorrowed!}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                OutlinedButton(
                  onPressed: () => _showEditDialog(item),
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

  void _showEditDialog(FacilityItem item) {
    final nameController = TextEditingController(
        text: '${item.code} ${widget.facilityName}');
    final entryDateController = TextEditingController(text: item.entryDate);
    final descriptionController = TextEditingController(text: item.description);
    final lastBorrowedController =
        TextEditingController(text: item.lastBorrowed ?? '');

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
                controller: nameController,
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
                controller: entryDateController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Masuk',
                  labelStyle: AppTextStyles.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (item.status == 'Dipinjam')
                TextFormField(
                  controller: lastBorrowedController,
                  decoration: InputDecoration(
                    labelText: 'Dipinjam Oleh',
                    labelStyle: AppTextStyles.caption,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (item.status == 'Dipinjam') const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: item.status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: AppTextStyles.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: ['Tersedia', 'Dipinjam', 'Rusak']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  labelStyle: AppTextStyles.caption,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              // Simpan perubahan
              setState(() {
                // Update data item
              });
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