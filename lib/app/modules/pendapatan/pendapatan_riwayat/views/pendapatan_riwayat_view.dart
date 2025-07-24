import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/pendapatan_riwayat_controller.dart';

class PendapatanRiwayatView extends GetView<PendapatanRiwayatController> {
  const PendapatanRiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initResponsive(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Riwayat Pendapatan',
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
        ],
      ),
      body: Column(
        children: [
          Obx(() => AnimatedContainer(
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
                      hintText: 'Cari transaksi...',
                      hintStyle:
                          AppText.p(color: AppColors.dark.withOpacity(0.4)),
                      prefixIcon: Icon(Remix.search_line,
                          color: AppColors.dark.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.dark.withOpacity(0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.dark.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding:
                          AppResponsive.padding(vertical: 2, horizontal: 3),
                    ),
                  ),
                ),
              )),
          _buildFilterBar(),
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : controller.filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionList()),
          ),
        ],
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
                  onTap: () => _showSortOptionsSheet(),
                  child: Container(
                    padding:
                        AppResponsive.padding(vertical: 1.2, horizontal: 2),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: AppColors.dark.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Remix.filter_3_line,
                          color: AppColors.dark.withOpacity(0.5),
                          size: 16,
                        ),
                        SizedBox(width: AppResponsive.w(1)),
                        Expanded(
                          child: Text(
                            'Urutkan',
                            style: AppText.small(color: AppColors.dark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.separated(
      padding: AppResponsive.padding(all: 3),
      itemCount: controller.filteredTransactions.length,
      separatorBuilder: (context, index) => Divider(
        height: AppResponsive.h(4),
        color: AppColors.dark.withOpacity(0.1),
      ),
      itemBuilder: (context, index) {
        final transaction = controller.filteredTransactions[index];
        return _buildTransactionItem(transaction);
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final bool isIncome =
        transaction['isIncome'] ?? (transaction['status'] == 'debit');

    return InkWell(
      onTap: () => controller.showTransactionDetails(transaction),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppResponsive.padding(all: 2),
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isIncome ? Remix.funds_box_fill : Remix.hand_coin_fill,
              color: isIncome ? AppColors.primary : AppColors.danger,
              size: 22,
            ),
          ),
          SizedBox(width: AppResponsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction['title'],
                        style: AppText.pSmall(color: AppColors.dark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  transaction['description'],
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  transaction['date'],
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction['formatted_amount'] ?? transaction['amount'],
                style: AppText.pSmallBold(
                    color: isIncome ? AppColors.primary : AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Remix.file_search_line,
            size: 70,
            color: AppColors.dark.withOpacity(0.3),
          ),
          SizedBox(height: AppResponsive.h(2)),
          Text(
            'Belum Ada Transaksi',
            style: AppText.h5(color: AppColors.dark.withOpacity(0.7)),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Text(
            'Tidak ada data transaksi yang ditemukan',
            style: AppText.pSmall(color: AppColors.dark.withOpacity(0.5)),
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
                _buildPeriodOption('Hari Ini'),
                _buildPeriodOption('Minggu Ini'),
                _buildPeriodOption('Bulan Ini'),
                _buildPeriodOption('Tahun Ini'),
                _buildPeriodOption('Semua Waktu'),
                _buildPeriodOption('Kustom...'),
                SizedBox(height: AppResponsive.h(2)),
              ],
            ),
          ),
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
                      ? AppColors.primary
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
            _buildSortOption('Kategori (A-Z)', 'category_asc'),
            _buildSortOption('Kategori (Z-A)', 'category_desc'),
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
                      ? AppColors.primary
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
