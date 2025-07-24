import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:emasjid_pro/app/widgets/custom_navbar_bottom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import '../controllers/laporan_controller.dart';

class LaporanView extends GetView<LaporanController> {
  const LaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title:
            Text('Laporan Keuangan', style: AppText.h5(color: AppColors.dark)),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: AppResponsive.padding(horizontal: 3, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laporan Utama', style: AppText.pSmallBold()),
            SizedBox(height: AppResponsive.h(1.5)),
            _buildReportCard(
              title: 'Jurnal Umum',
              description: 'Catatan kronologis transaksi keuangan masjid',
              icon: Icons.book,
              color: AppColors.primary,
              onTap: () {
                Get.toNamed(Routes.JURNAL_UMUM);
              },
            ),
            _buildReportCard(
              title: 'Buku Besar',
              description: 'Rekapitulasi jurnal berdasarkan akun',
              icon: Icons.account_balance_wallet,
              color: AppColors.info,
              onTap: () {
                Get.toNamed(Routes.BUKU_BESAR);
              },
            ),
           
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: AppResponsive.margin(vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: AppResponsive.padding(all: 2),
            child: Row(
              children: [
                Container(
                  width: AppResponsive.w(12),
                  height: AppResponsive.w(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                SizedBox(width: AppResponsive.w(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.pSmallBold()),
                      SizedBox(height: AppResponsive.h(0.5)),
                      Text(
                        description,
                        style: AppText.small(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.dark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
