import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/kas_dan_bank_laporan_controller.dart';

class KasDanBankLaporanView extends GetView<KasDanBankLaporanController> {
  const KasDanBankLaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Laporan Kas & Bank',
          style: AppText.h5(color: AppColors.dark),
        ),
        leading: IconButton(
          icon: Icon(
            Remix.arrow_left_s_line,
            color: AppColors.dark,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppResponsive.padding(all: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              margin: AppResponsive.margin(bottom: 3),
              padding: AppResponsive.padding(all: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppResponsive.w(4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Remix.wallet_3_line,
                    size: AppResponsive.w(12),
                    color: AppColors.white,
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Text(
                    'Cetak Laporan Kas & Bank',
                    style: AppText.h5(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppResponsive.h(0.5)),
                  Text(
                    'Pilih bulan untuk mencetak laporan kas & bank',
                    style:
                        AppText.pSmall(color: AppColors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Month Selection
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppResponsive.w(3)),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    title: Text(
                      'Laporan Bulanan',
                      style: AppText.h6(color: AppColors.primary),
                    ),
                    subtitle: Text(
                      'Laporan rincian saldo dan riwayat transaksi kas & bank per bulan',
                      style: AppText.pSmall(color: AppColors.dark.withOpacity(0.6)),
                    ),
                    value: true,
                    groupValue: true,
                    onChanged: (value) {},
                    activeColor: AppColors.primary,
                    contentPadding: AppResponsive.padding(
                      horizontal: 4,
                      vertical: 1,
                    ),
                  ),
                  Divider(
                    color: AppColors.muted,
                    height: 1,
                    indent: AppResponsive.w(4),
                    endIndent: AppResponsive.w(4),
                  ),
                  Padding(
                    padding: AppResponsive.padding(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    child: _buildMonthSelector(),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppResponsive.h(4)),

            // Generate Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: AppResponsive.h(7),
              child: ElevatedButton(
                onPressed: controller.isLoading.value 
                    ? null 
                    : () => controller.generateReport(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppResponsive.w(3)),
                  ),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: AppResponsive.w(5),
                            height: AppResponsive.w(5),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(width: AppResponsive.w(3)),
                          Text(
                            'Membuat PDF...',
                            style: AppText.button(color: AppColors.white),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.white,
                            size: AppResponsive.w(6),
                          ),
                          SizedBox(width: AppResponsive.w(2)),
                          Text(
                            'Cetak Laporan',
                            style: AppText.button(color: AppColors.white),
                          ),
                        ],
                      ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Obx(() => Container(
          width: double.infinity,
          padding: AppResponsive.padding(all: 3),
          decoration: BoxDecoration(
            color: AppColors.muted.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppResponsive.w(2)),
            border: Border.all(color: AppColors.muted),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: controller.selectedMonth.value,
              hint: Text(
                'Pilih Bulan',
                style: AppText.p(color: AppColors.dark.withOpacity(0.6)),
              ),
              isExpanded: true,
              dropdownColor: AppColors.white,
              items: controller.months.map((month) {
                return DropdownMenuItem<int>(
                  value: month['value'],
                  child: Text(
                    month['label'],
                    style: AppText.p(color: AppColors.dark),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectMonth(value);
                }
              },
            ),
          ),
        ));
  }
}