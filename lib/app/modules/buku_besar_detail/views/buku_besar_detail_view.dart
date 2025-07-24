import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/buku_besar_detail_controller.dart';

class BukuBesarDetailView extends GetView<BukuBesarDetailController> {
  const BukuBesarDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Obx(() => Text(
              controller.accountData.value['full_name'] ?? 'Buku Besar Detail',
              style: AppText.h5(color: Colors.white),
            )),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
        },
        child: Column(
          children: [
            _buildSummarySection(),
            _buildSearchSection(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          'Memuat data buku besar...',
                          style: AppText.bodyMedium(
                            color: AppColors.dark.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.isError.value) {
                  return _buildErrorState();
                }

                if (controller.filteredEntries.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildDataTable();
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.showExportModal(),
        backgroundColor: AppColors.primary,
        icon: Icon(Remix.file_pdf_2_line, color: AppColors.white),
        label: Text('Cetak Laporan',
            style: AppText.button(color: AppColors.white)),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: AppResponsive.padding(vertical: 2, horizontal: 3),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: AppResponsive.padding(all: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward,
                                  color: Colors.white, size: 16),
                              SizedBox(width: AppResponsive.w(1)),
                              Text('Total Debit',
                                  style: AppText.pSmall(
                                      color: Colors.white.withOpacity(0.9))),
                            ],
                          ),
                          SizedBox(height: AppResponsive.h(0.5)),
                          Text(controller.formattedTotalDebit.value,
                              style: AppText.h5(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(2)),
                  Expanded(
                    child: Container(
                      padding: AppResponsive.padding(all: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward,
                                  color: Colors.white, size: 16),
                              SizedBox(width: AppResponsive.w(1)),
                              Text('Total Kredit',
                                  style: AppText.pSmall(
                                      color: Colors.white.withOpacity(0.9))),
                            ],
                          ),
                          SizedBox(height: AppResponsive.h(0.5)),
                          Text(controller.formattedTotalCredit.value,
                              style: AppText.h5(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppResponsive.h(1.5)),
              Row(
                children: [
                  Container(
                    padding:
                        AppResponsive.padding(horizontal: 1.5, vertical: 0.5),
                    decoration: BoxDecoration(
                      color: AppColors.dark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet,
                            size: 14, color: AppColors.dark.withOpacity(0.6)),
                        SizedBox(width: AppResponsive.w(1)),
                        Text(
                          'Saldo: ${controller.formattedBalance.value}',
                          style: AppText.small(
                              color: AppColors.dark.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(2)),
                  Container(
                    padding:
                        AppResponsive.padding(horizontal: 1.5, vertical: 0.5),
                    decoration: BoxDecoration(
                      color: AppColors.dark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: AppColors.dark.withOpacity(0.6)),
                        SizedBox(width: AppResponsive.w(1)),
                        Text(
                          'Menampilkan ${controller.totalCount} transaksi',
                          style: AppText.small(
                              color: AppColors.dark.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildSearchSection() {
    return Container(
      height: 80,
      padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.dark.withOpacity(0.1),
                ),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Cari kode, deskripsi atau user...',
                  hintStyle: AppText.bodyMedium(
                    color: AppColors.dark.withOpacity(0.5),
                  ),
                  prefixIcon: Icon(
                    Remix.search_line,
                    color: AppColors.dark.withOpacity(0.5),
                    size: 18, 
                  ),
                  border: InputBorder.none,
                  contentPadding: AppResponsive.padding(
                    horizontal: 3,
                    vertical: 2, 
                  ),
                ),
                style: AppText.bodyMedium(color: AppColors.dark),
              ),
            ),
          ),
          Obx(() => controller.searchQuery.value.isNotEmpty
              ? Container(
                  margin: AppResponsive.margin(left: 1.5),
                  child: IconButton(
                    onPressed: controller.clearSearch,
                    icon: Icon(
                      Remix.close_circle_line,
                      color: AppColors.dark.withOpacity(0.5),
                      size: 20, 
                    ),
                  ),
                )
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: AppResponsive.margin(all: 4),
        padding: AppResponsive.padding(all: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppResponsive.padding(all: 3),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Remix.error_warning_line,
                size: 48,
                color: AppColors.danger,
              ),
            ),
            SizedBox(height: AppResponsive.h(2)),
            Text(
              'Terjadi Kesalahan',
              style: AppText.h6(color: AppColors.dark),
            ),
            SizedBox(height: AppResponsive.h(1)),
            Text(
              controller.errorMessage.value,
              style: AppText.bodyMedium(
                color: AppColors.dark.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppResponsive.h(3)),
            ElevatedButton(
              onPressed: controller.refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: AppResponsive.padding(
                  horizontal: 6,
                  vertical: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Coba Lagi',
                style: AppText.bodyMedium(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: AppResponsive.margin(all: 4),
        padding: AppResponsive.padding(all: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppResponsive.padding(all: 3),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                controller.searchQuery.value.isNotEmpty
                    ? Remix.search_line
                    : Remix.file_list_line,
                size: 48,
                color: AppColors.info,
              ),
            ),
            SizedBox(height: AppResponsive.h(2)),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'Tidak Ada Hasil'
                  : 'Tidak Ada Transaksi',
              style: AppText.h6(color: AppColors.dark),
            ),
            SizedBox(height: AppResponsive.h(1)),
            Text(
              controller.searchQuery.value.isNotEmpty
                  ? 'Tidak ditemukan transaksi dengan kata kunci "${controller.searchQuery.value}"'
                  : 'Belum ada transaksi untuk akun ini',
              style: AppText.bodyMedium(
                color: AppColors.dark.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (controller.searchQuery.value.isNotEmpty) ...[
              SizedBox(height: AppResponsive.h(3)),
              OutlinedButton(
                onPressed: controller.clearSearch,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: AppResponsive.padding(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Hapus Pencarian',
                  style: AppText.bodyMedium(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      padding: AppResponsive.padding(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Detail Transaksi', style: AppText.h6()),
            
            ],
          ),
          SizedBox(height: AppResponsive.h(1.5)),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.grey[100]),
                dataRowMinHeight: 60,
                dataRowMaxHeight: 80,
                columnSpacing: 8,
                dividerThickness: 0.5,
                headingTextStyle: AppText.pSmallBold(color: AppColors.dark),
                columns: [
                  DataColumn(
                    label: Text('Tanggal', style: AppText.pSmallBold()),
                  ),
                  DataColumn(
                    label: Text('Deskripsi', style: AppText.pSmallBold()),
                  ),
                  DataColumn(
                    label: Text('Debit', style: AppText.pSmallBold()),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text('Kredit', style: AppText.pSmallBold()),
                    numeric: true,
                  ),
                ],
                rows: _buildDataRows(),
              ),
            ),
          ),
          SizedBox(height: AppResponsive.h(8)),
        ],
      ),
    );
  }

  List<DataRow> _buildDataRows() {
    List<DataRow> rows = [];

    for (int i = 0; i < controller.filteredEntries.length; i++) {
      final entry = controller.filteredEntries[i];

      rows.add(
        DataRow(
          color: i % 2 == 0
              ? MaterialStateProperty.all(Colors.white)
              : MaterialStateProperty.all(Colors.grey[50]),
          cells: [
            DataCell(Text(
              entry['formatted_date'] ?? '',
              style: AppText.small(color: Colors.grey[600]),
            )),
            DataCell(
              Container(
                constraints: BoxConstraints(maxWidth: 200),
                child: Text(
                  entry['description'] ?? '',
                  style: AppText.pSmall(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            DataCell(Text(
              entry['status'] == 'debit' ? entry['formatted_value'] ?? '' : '',
              style: AppText.pSmall(color: AppColors.success),
              textAlign: TextAlign.right,
            )),
            DataCell(Text(
              entry['status'] == 'credit' ? entry['formatted_value'] ?? '' : '',
              style: AppText.pSmall(color: AppColors.danger),
              textAlign: TextAlign.right,
            )),
          ],
        ),
      );
    }

    return rows;
  }
}