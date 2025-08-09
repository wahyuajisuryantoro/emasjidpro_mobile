import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:emasjid_pro/app/utils/app_currency.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/laporan_pendapatan_beban_controller.dart';

class LaporanPendapatanBebanView extends GetView<LaporanPendapatanBebanController> {
  const LaporanPendapatanBebanView({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pendapatan & Beban', style: AppText.h5(color: AppColors.dark)),
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
          await controller.fetchLaporanPendapatanBeban();
        },
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          'Memuat data pendapatan dan beban...',
                          style: AppText.p(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.isError.value) {
                  return _buildErrorState();
                }

                if (controller.pendapatanData.isEmpty && controller.bebanData.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildLaporanContent();
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.showExportModal(),
        backgroundColor: AppColors.primary,
        icon: Icon(Remix.file_pdf_2_line, color: AppColors.white),
        label: Text('Cetak Laporan', style: AppText.button(color: AppColors.white)),
      ),
    );
  }


Widget _buildLaporanContent() {
  return SingleChildScrollView(
    padding: AppResponsive.padding(horizontal: 2, vertical: 1),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                SizedBox(height: AppResponsive.h(1.5)),
         Text('Laporan Pendapatan & Beban - ${controller.getCurrentPeriodText()}', 
             style: AppText.h6(color: AppColors.dark)),
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
          child: Column(
            children: [
              // Pendapatan Section
              Container(
                width: double.infinity,
                padding: AppResponsive.padding(all: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  'PENDAPATAN',
                  style: AppText.pSmallBold(color: AppColors.dark),
                ),
              ),
              
              // Pendapatan Items
              ...controller.pendapatanData.map((item) {
                return Container(
                  padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: AppResponsive.w(4)),
                      Expanded(
                        child: Text(
                          item['account_name'] ?? '',
                          style: AppText.pSmall(),
                        ),
                      ),
                      Text(
                        AppCurrency.formatNumber(item['total_value']),
                        style: AppText.pSmall(color: AppColors.dark),
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              // Total Pendapatan
              if (controller.pendapatanData.isNotEmpty)
                Container(
                  padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.05),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: AppResponsive.w(8)),
                      Expanded(
                        child: Text(
                          'Total Pendapatan',
                          style: AppText.pSmallBold(color: AppColors.dark),
                        ),
                      ),
                      Text(
                        controller.formattedTotalPendapatan.value,
                        style: AppText.pSmallBold(color: AppColors.dark),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: AppResponsive.h(2)),
              
              // Beban Section
              Container(
                width: double.infinity,
                padding: AppResponsive.padding(all: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                ),
                child: Text(
                  'BEBAN',
                  style: AppText.pSmallBold(color: AppColors.danger),
                ),
              ),
              
              // Beban Items
              ...controller.bebanData.map((item) {
                return Container(
                  padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: AppResponsive.w(4)),
                      Expanded(
                        child: Text(
                          item['account_name'] ?? '',
                          style: AppText.pSmall(),
                        ),
                      ),
                      Text(
                        AppCurrency.formatNumber(item['total_value']),
                        style: AppText.pSmall(color: AppColors.dark),
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              // Total Beban
              if (controller.bebanData.isNotEmpty)
                Container(
                  padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.05),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: AppResponsive.w(8)),
                      Expanded(
                        child: Text(
                          'Total Beban',
                          style: AppText.pSmallBold(color: AppColors.danger),
                        ),
                      ),
                      Text(
                        controller.formattedTotalBeban.value,
                        style: AppText.pSmallBold(color: AppColors.dark),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: AppResponsive.h(2)),
            
              Container(
                padding: AppResponsive.padding(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: controller.isSurplus.value 
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.surplusDefisitText.value,
                        style: AppText.pSmallBold(
                          color: controller.isSurplus.value 
                            ? AppColors.primary 
                            : AppColors.warning,
                        ),
                      ),
                    ),
                    Text(
                      controller.formattedSurplusDefisit.value,
                      style: AppText.pSmallBold(
                        color: controller.isSurplus.value 
                          ? AppColors.primary 
                          : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: AppResponsive.h(8)),
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
              onPressed: controller.fetchLaporanPendapatanBeban,
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
                Remix.receipt_line,
                size: 48,
                color: AppColors.info,
              ),
            ),
            SizedBox(height: AppResponsive.h(2)),
            Text(
              'Tidak Ada Data',
              style: AppText.h6(color: AppColors.dark),
            ),
            SizedBox(height: AppResponsive.h(1)),
            Text(
              'Tidak ada data pendapatan dan beban untuk periode ${controller.getCurrentPeriodText()}',
              style: AppText.bodyMedium(
                color: AppColors.dark.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
            
            // Month selection
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
            
            // Year selection
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
            
            // Action buttons
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
                    child: Text('Batal', style: AppText.p(color: AppColors.dark)),
                  ),
                ),
                SizedBox(width: AppResponsive.w(2)),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.fetchLaporanPendapatanBeban();
                      Get.back();
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text('Terapkan', style: AppText.p(color: Colors.white)),
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