import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/aset_daftar_jual_controller.dart';

class AsetDaftarJualView extends GetView<AsetDaftarJualController> {
  const AsetDaftarJualView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Daftar Aset Terjual',
          style: AppText.h5(color: AppColors.dark),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Remix.arrow_left_s_line,
            color: AppColors.dark,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Remix.search_line,
              color: AppColors.dark,
            ),
            onPressed: () => controller.toggleSearchBar(),
          ),
          IconButton(
            icon: Icon(
              Remix.filter_3_line,
              color: AppColors.dark,
            ),
            onPressed: () => controller.toggleFilterPanel(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Obx(() => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: controller.isSearchVisible.value ? AppResponsive.h(8) : 0,
            child: controller.isSearchVisible.value
                ? Container(
                    color: Colors.white,
                    padding: AppResponsive.padding(horizontal: 5),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari aset terjual...',
                        hintStyle: AppText.p(color: AppColors.dark.withOpacity(0.4)),
                        prefixIcon: Icon(Remix.search_line, color: AppColors.dark.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.dark.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.dark.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: AppResponsive.padding(vertical: 2, horizontal: 3),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          )),

          // Summary Card
          Obx(() => Container(
            margin: AppResponsive.padding(all: 3),
            padding: AppResponsive.padding(all: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.danger,
                  AppColors.danger.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Aset Terjual',
                          style: AppText.bodyMedium(color: AppColors.white),
                        ),
                        Text(
                          '${controller.totalSoldAssets.value} Aset',
                          style: AppText.h6(color: AppColors.white),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Nilai Penjualan',
                          style: AppText.bodyMedium(color: AppColors.white),
                        ),
                        Text(
                          controller.formattedTotalSellValue.value,
                          style: AppText.h6(color: AppColors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )),

          // Filter Panel
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: controller.isFilterVisible.value ? null : 0,
            child: controller.isFilterVisible.value
                ? _buildFilterPanel()
                : const SizedBox(),
          )),

          // Active Filters
          Obx(() => Visibility(
            visible: controller.hasActiveFilters(),
            child: _buildActiveFilters(),
          )),

          // Sold Assets List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.loadSoldAssets();
              },
              child: _buildSoldAssetsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: AppResponsive.padding(all: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter',
            style: AppText.h6(color: AppColors.dark),
          ),
          SizedBox(height: AppResponsive.h(2)),

          // Kategori Filter
          Text(
            'Kategori',
            style: AppText.bodyMedium(color: AppColors.dark),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.categories.map((category) {
              bool isSelected = category == 'Semua'
                  ? controller.selectedCategories.isEmpty
                  : controller.selectedCategories.contains(category);

              return FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  controller.toggleCategoryFilter(category);
                },
                backgroundColor: AppColors.white,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: AppText.small(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.dark,
                ),
              );
            }).toList(),
          )),

          SizedBox(height: AppResponsive.h(2)),

          // Tanggal Penjualan Filter
          Text(
            'Tanggal Penjualan',
            style: AppText.bodyMedium(color: AppColors.dark),
          ),
          SizedBox(height: AppResponsive.h(1)),
          InkWell(
            onTap: controller.showDateRangeDialog,
            child: Container(
              padding: AppResponsive.padding(horizontal: 2, vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dark.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Remix.calendar_line,
                    size: 20,
                    color: AppColors.dark.withOpacity(0.7),
                  ),
                  SizedBox(width: AppResponsive.w(1)),
                  Expanded(
                    child: Obx(() => Text(
                      controller.getDateRangeText(),
                      style: AppText.small(
                        color: controller.hasDateFilter()
                            ? AppColors.dark
                            : AppColors.dark.withOpacity(0.5),
                      ),
                    )),
                  ),
                  Icon(
                    Remix.arrow_down_s_line,
                    size: 20,
                    color: AppColors.dark.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppResponsive.h(3)),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.resetFilters,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: AppResponsive.padding(vertical: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Reset',
                    style: AppText.button(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.w(2)),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: controller.applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: AppResponsive.padding(vertical: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Terapkan Filter',
                    style: AppText.button(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: AppResponsive.padding(horizontal: 3, vertical: 2),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Aktif',
                style: AppText.small(color: AppColors.dark),
              ),
              InkWell(
                onTap: controller.resetFilters,
                child: Text(
                  'Hapus Semua',
                  style: AppText.small(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.h(1)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Kategori Chips
              ...controller.selectedCategories.map((category) {
                return Chip(
                  label: Text(category),
                  labelStyle: AppText.small(color: AppColors.primary),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  deleteIcon: Icon(Remix.close_line, size: 16, color: AppColors.primary),
                  onDeleted: () => controller.toggleCategoryFilter(category),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                );
              }),

              // Search Chip
              Obx(() {
                if (controller.searchQuery.value.isNotEmpty) {
                  return Chip(
                    label: Text('Pencarian: "${controller.searchQuery.value}"'),
                    labelStyle: AppText.small(color: AppColors.primary),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    deleteIcon: Icon(Remix.close_line, size: 16, color: AppColors.primary),
                    onDeleted: () => controller.resetSearchFilter(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  );
                }
                return SizedBox();
              }),

              // Tanggal Chip
              Obx(() {
                if (controller.hasDateFilter()) {
                  return Chip(
                    label: Text('Tanggal: ${controller.getDateRangeText()}'),
                    labelStyle: AppText.small(color: AppColors.primary),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    deleteIcon: Icon(Remix.close_line, size: 16, color: AppColors.primary),
                    onDeleted: () => controller.resetDateFilter(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  );
                }
                return SizedBox();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoldAssetsList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.filteredSoldAssets.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Remix.inbox_line,
                size: 64,
                color: AppColors.dark.withOpacity(0.3),
              ),
              SizedBox(height: AppResponsive.h(2)),
              Text(
                'Tidak ada aset terjual ditemukan',
                style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.7)),
              ),
              SizedBox(height: AppResponsive.h(1)),
              if (controller.hasActiveFilters())
                Text(
                  'Coba ubah filter pencarian',
                  style: AppText.small(color: AppColors.dark.withOpacity(0.5)),
                ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: AppResponsive.padding(all: 3),
        itemCount: controller.filteredSoldAssets.length,
        itemBuilder: (context, index) {
          final asset = controller.filteredSoldAssets[index];
          return _buildSoldAssetCard(asset);
        },
      );
    });
  }

  Widget _buildSoldAssetCard(Map<String, dynamic> asset) {
    return InkWell(
      onTap: () => controller.showSoldAssetDetails(asset),
      child: Container(
        margin: AppResponsive.padding(bottom: 2),
        padding: AppResponsive.padding(all: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.danger.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Content Column (kiri)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset Name dan Code
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          asset['name'],
                          style: AppText.bodyMedium(
                            color: AppColors.dark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: AppResponsive.w(2)),
                      Container(
                        padding: AppResponsive.padding(horizontal: 1.5, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          asset['code_asset'],
                          style: AppText.small(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppResponsive.h(2)),

                  // Sell Value dan Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            asset['formatted_sell_value'],
                            style: AppText.bodyMedium(
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'Harga Jual',
                            style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                          ),
                        ],
                      ),
                      Container(
                        padding: AppResponsive.padding(horizontal: 1, vertical: 0.5),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          asset['status'],
                          style: AppText.small(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppResponsive.h(1)),

                  // Date info
                  Row(
                    children: [
                      Icon(
                        Remix.calendar_line,
                        size: 16,
                        color: AppColors.dark.withOpacity(0.6),
                      ),
                      SizedBox(width: AppResponsive.w(1)),
                      Text(
                        asset['date_sell'],
                        style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                      ),
                    ],
                  ),

                  SizedBox(height: AppResponsive.h(0.5)),

                  // Sold to info
                  Row(
                    children: [
                      Icon(
                        Remix.user_line,
                        size: 16,
                        color: AppColors.dark.withOpacity(0.6),
                      ),
                      SizedBox(width: AppResponsive.w(1)),
                      Expanded(
                        child: Text(
                          'Dijual kepada: ${asset['sell_to']}',
                          style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon (kanan, di tengah vertikal)
            SizedBox(width: AppResponsive.w(3)),
            Icon(
              Remix.arrow_right_s_line,
              size: 20,
              color: AppColors.dark.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }
}