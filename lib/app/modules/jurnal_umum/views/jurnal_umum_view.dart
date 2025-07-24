import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/jurnal_umum_controller.dart';

class JurnalUmumView extends GetView<JurnalUmumController> {
  const JurnalUmumView({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Jurnal Umum', style: AppText.h5(color: AppColors.dark)),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: AppColors.dark),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppColors.primary),
            onPressed: () => _showMonthYearPicker(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchJournalEntries();
        },
        child: Column(
          children: [
            _buildStatsSection(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                            color: AppColors.primary),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          'Memuat data jurnal...',
                          style: AppText.p(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.isError.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: AppResponsive.padding(all: 3),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.error_outline,
                              size: 48, color: AppColors.danger),
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          controller.errorMessage.value,
                          style: AppText.p(color: AppColors.danger),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchJournalEntries(),
                          icon:
                              const Icon(Icons.refresh, color: AppColors.white),
                          label: Text('Coba Lagi',
                              style: AppText.p(color: AppColors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: AppResponsive.padding(
                                horizontal: 4, vertical: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.journalEntries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: AppResponsive.padding(all: 3),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.article_outlined,
                              size: 48, color: Colors.grey[500]),
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          'Tidak ada data jurnal yang ditemukan',
                          style: AppText.p(color: AppColors.dark),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppResponsive.h(1)),
                        Text(
                          'untuk periode ${controller.getCurrentPeriodText()}',
                          style: AppText.small(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return _buildJournalTable();
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

  Widget _buildStatsSection() {
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
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

  Widget _buildJournalTable() {
    return SingleChildScrollView(
      padding: AppResponsive.padding(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daftar Jurnal', style: AppText.h6()),
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
                    label: Text('Nama Akun', style: AppText.pSmallBold()),
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
                rows: _buildJournalRows(),
              ),
            ),
          ),
          SizedBox(height: AppResponsive.h(8)),
        ],
      ),
    );
  }

  List<DataRow> _buildJournalRows() {
    List<DataRow> rows = [];

    for (var journal in controller.journalEntries) {
      var debitEntry = journal['entries'].firstWhere(
          (entry) => entry['status'] == 'debit',
          orElse: () => null);
      var creditEntry = journal['entries'].firstWhere(
          (entry) => entry['status'] == 'credit',
          orElse: () => null);

      if (debitEntry != null && creditEntry != null) {
        rows.add(
          DataRow(
            color: rows.length % 2 == 0
                ? WidgetStateProperty.all(Colors.white)
                : WidgetStateProperty.all(Colors.grey[50]),
            cells: [
              DataCell(Text(
                journal['formatted_date'] ?? '',
                style: AppText.small(color: Colors.grey[600]),
              )),
              DataCell(Text(
                debitEntry['account_name'] ?? '',
                style: AppText.pSmall(),
              )),
              DataCell(Text(
                debitEntry['formatted_debit'] ?? '',
                style: AppText.pSmall(color: AppColors.primary),
                textAlign: TextAlign.right,
              )),
              DataCell(Text('', style: AppText.pSmall())),
            ],
          ),
        );

        rows.add(
          DataRow(
            color: rows.length % 2 == 0
                ? WidgetStateProperty.all(Colors.white)
                : WidgetStateProperty.all(Colors.grey[50]),
            cells: [
              DataCell(Text(
                journal['formatted_date'] ?? '',
                style: AppText.small(color: Colors.grey[600]),
              )),
              DataCell(Text(
                creditEntry['account_name'] ?? '',
                style: AppText.pSmall(),
              )),
              DataCell(Text('', style: AppText.pSmall())),
              DataCell(Text(
                creditEntry['formatted_credit'] ?? '',
                style: AppText.pSmall(color: AppColors.danger),
                textAlign: TextAlign.right,
              )),
            ],
          ),
        );
      }
    }

    return rows;
  }

  void _showMonthYearPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: AppResponsive.padding(horizontal: 3, vertical: 2),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pilih Periode', style: AppText.h5(color: AppColors.dark)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: AppResponsive.h(1)),
            Text('Bulan', style: AppText.pSmallBold()),
            SizedBox(height: AppResponsive.h(1)),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: AppResponsive.padding(horizontal: 2, vertical: 1),
              child: Obx(() => DropdownButtonFormField<int>(
                    value: controller.selectedMonth.value,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primary),
                    items: controller.monthOptions.map((month) {
                      return DropdownMenuItem<int>(
                        value: month['value'],
                        child: Text(month['label'], style: AppText.pSmall()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedMonth.value = value;
                      }
                    },
                  )),
            ),
            SizedBox(height: AppResponsive.h(2)),
            Text('Tahun', style: AppText.pSmallBold()),
            SizedBox(height: AppResponsive.h(1)),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: AppResponsive.padding(horizontal: 2, vertical: 1),
              child: Obx(() => TextFormField(
                    initialValue: controller.selectedYear.value.toString(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Masukkan tahun',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        final year = int.tryParse(value);
                        if (year != null && year > 1900 && year <= 2100) {
                          controller.selectedYear.value = year;
                        }
                      }
                    },
                  )),
            ),
            SizedBox(height: AppResponsive.h(4)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: AppResponsive.padding(vertical: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        Text('Batal', style: AppText.p(color: AppColors.dark)),
                  ),
                ),
                SizedBox(width: AppResponsive.w(2)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.fetchJournalEntries();
                      Get.back();
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label:
                        Text('Terapkan', style: AppText.p(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: AppResponsive.padding(vertical: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
}
