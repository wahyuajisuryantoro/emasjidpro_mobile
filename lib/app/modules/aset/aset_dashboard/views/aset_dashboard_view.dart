import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/aset_dashboard_controller.dart';

class AsetDashboardView extends GetView<AsetDashboardController> {
  const AsetDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard Aset',
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
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  controller.loadAssets();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: AppResponsive.padding(all: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: AppResponsive.padding(all: 4),
                            child: Column(
                              children: [
                                // Total Nilai Aset
                                Column(
                                  children: [
                                    Text(
                                      'Total Nilai Aset Sekarang',
                                      style: AppText.h6(
                                          color:
                                              AppColors.white.withOpacity(0.9)),
                                    ),
                                    SizedBox(height: AppResponsive.h(0.5)),
                                    Obx(() => Text(
                                          controller
                                              .formattedTotalNilaiAset.value,
                                          style: AppText.h3(
                                              color: AppColors.white),
                                        )),
                                  ],
                                ),

                                SizedBox(height: AppResponsive.h(3)),

                                // Row untuk Total Penyusutan dan Nilai Saat Ini
                                Row(
                                  children: [
                                    // Total Penyusutan
                                    Expanded(
                                      child: Container(
                                        padding:
                                            AppResponsive.padding(all: 2.5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Remix.line_chart_line,
                                              color: AppColors.white
                                                  .withOpacity(0.8),
                                              size: 20,
                                            ),
                                            SizedBox(
                                                height: AppResponsive.h(1)),
                                            Text(
                                              'Total Penyusutan',
                                              style: AppText.bodySmall(
                                                color: AppColors.white
                                                    .withOpacity(0.9),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                                height: AppResponsive.h(0.5)),
                                            Obx(() => Text(
                                                  controller
                                                      .formattedTotalPenyusutan
                                                      .value,
                                                  style: AppText.bodyMedium(
                                                    color: AppColors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: AppResponsive.w(3)),

                                    // Nilai Aset Saat Ini
                                    Expanded(
                                      child: Container(
                                        padding:
                                            AppResponsive.padding(all: 2.5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Remix.money_dollar_circle_line,
                                              color: AppColors.white
                                                  .withOpacity(0.8),
                                              size: 20,
                                            ),
                                            SizedBox(
                                                height: AppResponsive.h(1)),
                                            Text(
                                              'Nilai Saat Ini',
                                              style: AppText.bodySmall(
                                                color: AppColors.white
                                                    .withOpacity(0.9),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                                height: AppResponsive.h(0.5)),
                                            Obx(() => Text(
                                                  controller
                                                      .formattedNilaiAsetSaatIni
                                                      .value,
                                                  style: AppText.bodyMedium(
                                                    color: AppColors.white,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppResponsive.h(4)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Jual Aset
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.ASET_DAFTAR);
                                },
                                child: Container(
                                  margin: AppResponsive.margin(horizontal: 1),
                                  padding: AppResponsive.padding(all: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: AppResponsive.w(10),
                                        height: AppResponsive.w(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Remix.archive_line,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      SizedBox(height: AppResponsive.h(1)),
                                      Text(
                                        'Daftar Aset',
                                        style: AppText.pSmallBold(
                                            color: AppColors.dark),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Beli Aset
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.ASET_BELI);
                                },
                                child: Container(
                                  margin: AppResponsive.margin(horizontal: 1),
                                  padding: AppResponsive.padding(all: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: AppResponsive.w(10),
                                        height: AppResponsive.w(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Remix.shopping_cart_2_line,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      SizedBox(height: AppResponsive.h(1)),
                                      Text(
                                        'Beli',
                                        style: AppText.pSmallBold(
                                            color: AppColors.dark),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Laporan
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.ASET_LAPORAN);
                                },
                                child: Container(
                                  margin: AppResponsive.margin(horizontal: 1),
                                  padding: AppResponsive.padding(all: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: AppResponsive.w(10),
                                        height: AppResponsive.w(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Remix.file_chart_line,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      SizedBox(height: AppResponsive.h(1)),
                                      Text(
                                        'Laporan',
                                        style: AppText.pSmallBold(
                                            color: AppColors.dark),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppResponsive.h(4)),
                        Text(
                          'Kategori Aset',
                          style: AppText.h6(color: AppColors.dark),
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        _buildAssetCategoryList(),
                        SizedBox(height: AppResponsive.h(4)),
                        Text(
                          'Aset Terbaru',
                          style: AppText.h6(color: AppColors.dark),
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        _buildRecentAssetsList(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: controller.navigateToBuyAsset,
            child: Container(
              padding: AppResponsive.padding(all: 3),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Remix.shopping_cart_2_line,
                    color: AppColors.white,
                    size: 28,
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Text(
                    'Beli Aset',
                    style: AppText.bodyMedium(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: AppResponsive.w(3)),
        Expanded(
          child: InkWell(
            onTap: controller.navigateToSellAsset,
            child: Container(
              padding: AppResponsive.padding(all: 3),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.danger.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Remix.exchange_dollar_line,
                    color: AppColors.white,
                    size: 28,
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Text(
                    'Jual Aset',
                    style: AppText.bodyMedium(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCategoryList() {
    return Obx(() => Column(
          children: [
            // List kategori yang ada
            ...controller.categoryAset.map<Widget>((category) {
              return _buildCategoryItem(category: category);
            }).toList(),

            // Spacing
            SizedBox(height: AppResponsive.h(2)),

            // Tombol Tambah Kategori (Outline style)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.toNamed(Routes.ASET_KATEGORI_DAFTAR);
                },
                icon: Icon(
                  Remix.add_line,
                  size: 20,
                  color: AppColors.primary,
                ),
                label: Text(
                  'Tambahkan Kategori Aset',
                  style: AppText.button(color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  padding: AppResponsive.padding(vertical: 2.5, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildCategoryItem({
    required Map<String, dynamic> category,
  }) {
    return Container(
      margin: AppResponsive.padding(bottom: 2),
      padding: AppResponsive.padding(all: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Container(
            padding: AppResponsive.padding(all: 1.5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Remix.archive_stack_line,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          SizedBox(width: AppResponsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['name'],
                  style: AppText.bodyMedium(
                    color: AppColors.dark,
                  ),
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  category['formatted_total_value'] ??
                      category['total_value'].toString(),
                  style: AppText.bodySmall(
                    color: AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAssetsList() {
    return Obx(() => Column(
          children: controller.asetList.map<Widget>((aset) {
            return _buildAssetItem(aset: aset);
          }).toList(),
        ));
  }

  Widget _buildAssetItem({
    required Map<String, dynamic> aset,
  }) {
    return InkWell(
      onTap: () {
        controller.navigateToAssetDetail(aset);
      },
      child: Container(
        margin: AppResponsive.padding(bottom: 2),
        padding: AppResponsive.padding(all: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Container(
              padding: AppResponsive.padding(all: 2),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Remix.archive_2_line,
                color: AppColors.info,
                size: 24,
              ),
            ),
            SizedBox(width: AppResponsive.w(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aset['name'],
                    style: AppText.bodyMedium(
                      color: AppColors.dark,
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(0.5)),
                  Text(
                    controller.formatDate(aset['date_purchase']),
                    style: AppText.bodySmall(
                      color: AppColors.dark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  aset['formatted_value'] ?? aset['value'].toString(),
                  style: AppText.bodyMedium(
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Icon(
                  Remix.arrow_right_s_line,
                  color: AppColors.dark,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
