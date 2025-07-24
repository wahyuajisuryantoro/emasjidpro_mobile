import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/piutang_laporan_controller.dart';

class PiutangLaporanView extends GetView<PiutangLaporanController> {
  const PiutangLaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Laporan Piutang',
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
                    AppColors.lightBlue,
                    AppColors.info,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppResponsive.w(4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Remix.hand_coin_line,
                    size: AppResponsive.w(12),
                    color: AppColors.white,
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Text(
                    'Cetak Laporan Piutang',
                    style: AppText.h5(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppResponsive.h(0.5)),
                  Text(
                    'Laporan lengkap data piutang yang belum lunas',
                    style:
                        AppText.pSmall(color: AppColors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Report Option
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppResponsive.w(3)),
                border: Border.all(
                  color: AppColors.lightBlue,
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
              child: RadioListTile<bool>(
                title: Text(
                  'Cetak Laporan Piutang',
                  style: AppText.h6(color: AppColors.lightBlue),
                ),
                subtitle: Text(
                  'Laporan semua data piutang beserta cicilan yang sudah diterima',
                  style: AppText.pSmall(color: AppColors.dark.withOpacity(0.6)),
                ),
                value: true,
                groupValue: true,
                onChanged: (value) {},
                activeColor: AppColors.lightBlue,
                contentPadding: AppResponsive.padding(
                  horizontal: 4,
                  vertical: 2,
                ),
               
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
                  backgroundColor: AppColors.lightBlue,
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
}