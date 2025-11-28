import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/hutang_daftar_controller.dart';

class HutangDaftarView extends GetView<HutangDaftarController> {
  const HutangDaftarView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initResponsive(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Daftar Hutang',
          style: AppText.h5(color: AppColors.dark),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Remix.arrow_left_s_line,
            color: AppColors.dark,
          ),
          onPressed: () => Get.back(result: true),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Remix.search_line,
              color: AppColors.dark,
            ),
            onPressed: () => controller.toggleSearchBar(),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() => RefreshIndicator(
                onRefresh: () async {
                  await controller.refreshData();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height:
                      controller.isSearchVisible.value ? AppResponsive.h(8) : 0,
                  child: Container(
                    color: Colors.white,
                    padding: AppResponsive.padding(horizontal: 5),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari hutang...',
                        hintStyle:
                            AppText.p(color: AppColors.dark.withOpacity(0.4)),
                        prefixIcon: Icon(Remix.search_line,
                            color: AppColors.dark.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColors.dark.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppColors.dark.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.warning),
                        ),
                        contentPadding:
                            AppResponsive.padding(vertical: 2, horizontal: 3),
                      ),
                    ),
                  ),
                ),
              )),
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchDaftarHutang(),
              color: AppColors.primary,
              child: Obx(() => controller.isLoading.value
                  ? Center(
                      child:
                          CircularProgressIndicator(color: AppColors.warning))
                  : controller.filteredHutang.isEmpty
                      ? _buildEmptyState()
                      : _buildHutangList()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.navigateToTambahHutang();
        },
        backgroundColor: AppColors.primary,
        icon: Icon(Remix.add_line, color: AppColors.white),
        label: Text(
          'Tambah Hutang',
          style: AppText.button(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: AppResponsive.padding(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => _showPeriodFilterSheet(),
                  child: Container(
                    padding:
                        AppResponsive.padding(vertical: 1.2, horizontal: 2),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.dark.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Remix.calendar_event_line,
                          color: AppColors.dark.withOpacity(0.5),
                          size: 16,
                        ),
                        SizedBox(width: AppResponsive.w(1)),
                        Expanded(
                          child: Obx(() => Text(
                                controller.selectedPeriod.value,
                                style: AppText.small(color: AppColors.dark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                        Icon(
                          Remix.arrow_down_s_line,
                          color: AppColors.dark.withOpacity(0.5),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.w(2)),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () => _showStatusFilterSheet(),
                  child: Container(
                    padding:
                        AppResponsive.padding(vertical: 1.2, horizontal: 2),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.dark.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Remix.flag_line,
                          color: AppColors.dark.withOpacity(0.5),
                          size: 16,
                        ),
                        SizedBox(width: AppResponsive.w(1)),
                        Expanded(
                          child: Obx(() => Text(
                                controller.selectedStatus.value,
                                style: AppText.small(color: AppColors.dark),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ),
                        Icon(
                          Remix.arrow_down_s_line,
                          color: AppColors.dark.withOpacity(0.5),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.h(2)),
          Row(
            children: [
              Text(
                'Urutan:',
                style: AppText.small(color: AppColors.dark.withOpacity(0.7)),
              ),
              SizedBox(width: AppResponsive.w(2)),
              GestureDetector(
                onTap: () => _showSortOptionsSheet(),
                child: Container(
                  padding: AppResponsive.padding(vertical: 1, horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Remix.sort_asc,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      SizedBox(width: AppResponsive.w(1)),
                      Obx(() => Text(
                            controller.sortLabel.value,
                            style: AppText.small(color: AppColors.warning),
                          )),
                      SizedBox(width: AppResponsive.w(1)),
                      Icon(
                        Remix.arrow_down_s_line,
                        color: AppColors.warning,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: Get.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Remix.file_search_line,
                size: 70,
                color: AppColors.dark,
              ),
              SizedBox(height: AppResponsive.h(2)),
              Text(
                'Belum Ada Hutang',
                style: AppText.h5(color: AppColors.dark.withOpacity(0.7)),
              ),
              SizedBox(height: AppResponsive.h(1)),
              Text(
                'Tidak ada data hutang yang ditemukan',
                style: AppText.pSmall(color: AppColors.dark.withOpacity(0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHutangList() {
    return ListView.separated(
      padding: AppResponsive.padding(all: 5),
      itemCount: controller.filteredHutang.length,
      separatorBuilder: (context, index) => Divider(
        height: AppResponsive.h(4),
        color: AppColors.dark.withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final hutang = controller.filteredHutang[index];
        return _buildHutangItem(hutang);
      },
    );
  }

  Widget _buildHutangItem(Map<String, dynamic> hutang) {
    return InkWell(
      onTap: () => controller.navigateToDetailHutang(hutang['id']),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppResponsive.w(10),
            height: AppResponsive.w(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                hutang['nama'].toString().isNotEmpty
                    ? hutang['nama'].toString().substring(0, 1)
                    : 'H',
                style: AppText.h5(color: AppColors.primary),
              ),
            ),
          ),
          SizedBox(width: AppResponsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hutang['nama']?.toString() ?? 'Hutang',
                  style: AppText.pSmallBold(color: AppColors.dark),
                ),
                SizedBox(height: AppResponsive.h(1)),
                Text(
                  hutang['kategori']?.toString() ?? 'Umum',
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hutang['formatted_sisa']?.toString() ?? 'Rp 0',
                style: AppText.pSmallBold(color: AppColors.dark),
              ),
              SizedBox(height: AppResponsive.h(0.5)),
              Container(
                padding: AppResponsive.padding(horizontal: 1.5, vertical: 0.5),
                decoration: BoxDecoration(
                  color: hutang['status'] == 'Lunas'
                      ? AppColors.success
                      : AppColors.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  hutang['status']?.toString() ?? 'Belum Lunas',
                  style: AppText.small(color: AppColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPeriodFilterSheet() {
    Get.bottomSheet(
      ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.7,
        ),
        child: Container(
          padding: AppResponsive.padding(all: 5),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: AppResponsive.w(10),
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.dark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: AppResponsive.h(3)),
                Text(
                  'Pilih Periode',
                  style: AppText.h5(color: AppColors.dark),
                ),
                SizedBox(height: AppResponsive.h(3)),
                _buildPeriodOption('Semua'),
                _buildPeriodOption('Hari Ini'),
                _buildPeriodOption('Minggu Ini'),
                _buildPeriodOption('Bulan Ini'),
                _buildPeriodOption('Tahun Ini'),
                _buildPeriodOption('Kustom...'),
                SizedBox(height: AppResponsive.h(2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusFilterSheet() {
    Get.bottomSheet(
      Container(
        padding: AppResponsive.padding(all: 5),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: AppResponsive.w(10),
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.dark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: AppResponsive.h(3)),
            Text(
              'Pilih Status',
              style: AppText.h5(color: AppColors.dark),
            ),
            SizedBox(height: AppResponsive.h(3)),
            _buildStatusOption('Semua'),
            _buildStatusOption('Belum Lunas'),
            _buildStatusOption('Lunas'),
            SizedBox(height: AppResponsive.h(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodOption(String period) {
    return InkWell(
      onTap: () {
        controller.setSelectedPeriod(period);
        Get.back();

        if (period == 'Kustom...') {
          controller.showCustomDateRangePicker();
        }
      },
      child: Padding(
        padding: AppResponsive.padding(vertical: 2),
        child: Row(
          children: [
            Obx(() => Icon(
                  controller.selectedPeriod.value == period
                      ? Remix.checkbox_circle_fill
                      : Remix.checkbox_blank_circle_line,
                  color: controller.selectedPeriod.value == period
                      ? AppColors.warning
                      : AppColors.dark.withOpacity(0.3),
                  size: 22,
                )),
            SizedBox(width: AppResponsive.w(3)),
            Text(
              period,
              style: AppText.p(color: AppColors.dark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String status) {
    return InkWell(
      onTap: () {
        controller.setSelectedStatus(status);
        Get.back();
      },
      child: Padding(
        padding: AppResponsive.padding(vertical: 2),
        child: Row(
          children: [
            Obx(() => Icon(
                  controller.selectedStatus.value == status
                      ? Remix.checkbox_circle_fill
                      : Remix.checkbox_blank_circle_line,
                  color: controller.selectedStatus.value == status
                      ? AppColors.warning
                      : AppColors.dark.withOpacity(0.3),
                  size: 22,
                )),
            SizedBox(width: AppResponsive.w(3)),
            Text(
              status,
              style: AppText.p(color: AppColors.dark),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptionsSheet() {
    Get.bottomSheet(
      Container(
        padding: AppResponsive.padding(all: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: AppResponsive.w(10),
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.dark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: AppResponsive.h(3)),
            Text(
              'Urutkan Berdasarkan',
              style: AppText.h5(color: AppColors.dark),
            ),
            SizedBox(height: AppResponsive.h(3)),
            _buildSortOption('Terbaru', 'newest'),
            _buildSortOption('Terlama', 'oldest'),
            _buildSortOption('Nominal Tertinggi', 'highest'),
            _buildSortOption('Nominal Terendah', 'lowest'),
            _buildSortOption('Nama (A-Z)', 'nama_asc'),
            _buildSortOption('Nama (Z-A)', 'nama_desc'),
            SizedBox(height: AppResponsive.h(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    return InkWell(
      onTap: () {
        controller.setSortOption(value, label);
        Get.back();
      },
      child: Padding(
        padding: AppResponsive.padding(vertical: 1),
        child: Row(
          children: [
            Obx(() => Icon(
                  controller.sortKey.value == value
                      ? Remix.radio_button_fill
                      : Remix.radio_button_line,
                  color: controller.sortKey.value == value
                      ? AppColors.warning
                      : AppColors.dark.withOpacity(0.3),
                  size: 22,
                )),
            SizedBox(width: AppResponsive.w(3)),
            Text(
              label,
              style: AppText.p(color: AppColors.dark),
            ),
          ],
        ),
      ),
    );
  }
}
