import 'package:flutter/material.dart';
import 'package:spareapp_unhas/data/models/facility.dart';
import 'package:spareapp_unhas/presentation/facilities/facility_detail_page.dart';
import 'package:spareapp_unhas/data/services/mock_facility_service.dart';
import 'package:spareapp_unhas/core/widgets/bottom_nav_bar.dart';
import 'package:spareapp_unhas/core/utils/no_animation_route.dart';


const Color _primaryColor = Color(0xFFD32F2F);

class FacilitiesPage extends StatefulWidget {
  const FacilitiesPage({super.key});

  @override
  State<FacilitiesPage> createState() => _FacilitiesPageState();
}

class _FacilitiesPageState extends State<FacilitiesPage>
    with SingleTickerProviderStateMixin {
  final service = MockFacilityService.instance;
  List<Facility> _items = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    service.seed();
    _items = service.getAll();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  List<Facility> get _filtered {
    final idx = _tabController.index;
    if (idx == 0) {
      // Tersedia
      return _items.where((f) => f.available > 0).toList();
    } else if (idx == 1) {
      // Dipinjam (some borrowed)
      return _items
          .where((f) => f.available < f.quantity && f.quantity > 0)
          .toList();
    } else {
      // Lainnya (kosong / rusak)
      return _items.where((f) => f.available == 0).toList();
    }
  }

  void _reload() {
    setState(() {
      _items = service.getAll();
    });
  }

  void _onDelete(String id) {
    service.delete(id);
    _reload();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Fasilitas dihapus')));
  }

  void _openEdit(Facility f) async {
    // reuse admin dialog or navigate to admin edit - for now show simple dialog
    final nameCtrl = TextEditingController(text: f.name);
    final form = GlobalKey<FormState>();
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Fasilitas'),
        content: Form(
          key: form,
          child: TextFormField(
            controller: nameCtrl,
            validator: (v) => (v ?? '').isEmpty ? 'Nama wajib' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (form.currentState?.validate() ?? false) {
                f.name = nameCtrl.text;
                service.update(f.id, f);
                Navigator.pop(context, true);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (res == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar-like row with back and add
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFE74C3C)],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kembali',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/admin_facilities'),
                  ),
                ],
              ),
            ),

            // Summary card overlapping
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 36, // spacer to allow overlap
                  color: Colors.transparent,
                ),
                Positioned(
                  top: -28,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'lib/assets/icons/Logo-Resmi-Unhas-1.png',
                              width: 90,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Proyektor',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Total: 80 Unit',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Tersedia: 50 Unit',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Dipinjam: 30 Unit',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Tabs container with rounded top
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: _primaryColor,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.black,
                      tabs: const [
                        Tab(text: 'Tersedia'),
                        Tab(text: 'Dipinjam'),
                        Tab(text: 'Lainnya'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: _buildListView()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              // Already on facilities page
              break;
            case 2:
              // Notifications page (to be implemented)
              break;
            case 3:
              Navigator.pushNamed(context, '/booking_history');
              break;
            case 4:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildListView() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final f = list[i];
        return InkWell(
          onTap: () => Navigator.push(
            context,
            NoAnimationPageRoute(
              builder: (_) => FacilityDetailPage(facility: f),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color.fromRGBO(211, 47, 47, 0.6)), 
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06), 
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'lib/assets/icons/Logo-Resmi-Unhas-1.png',
                      width: 96,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Status: ${f.available > 0 ? 'Tersedia' : (f.available < f.quantity ? 'Dipinjam' : 'Kosong')}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Masuk: 15/04/2005',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onPressed: () => _openEdit(f),
                        child: const Text('Edit'),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                        onPressed: () => _onDelete(f.id),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
