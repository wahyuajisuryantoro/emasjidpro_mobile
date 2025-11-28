import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_currency.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/neraca_saldo_controller.dart';

class NeracaSaldoView extends GetView<NeracaSaldoController> {
  const NeracaSaldoView({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Neraca', style: AppText.h5(color: AppColors.dark)),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: AppColors.dark),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchNeracaSaldo();
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
                        const CircularProgressIndicator(
                            color: AppColors.primary),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          'Memuat data neraca...',
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
                          onPressed: () => controller.fetchNeracaSaldo(),
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

                if (controller.aktivaLancar.isEmpty &&
                    controller.aktivaTetap.isEmpty &&
                    controller.kewajiban.isEmpty &&
                    controller.saldo.isEmpty) {
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
                          child: Icon(Icons.balance_outlined,
                              size: 48, color: Colors.grey[500]),
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          'Tidak ada data neraca yang ditemukan',
                          style: AppText.p(color: AppColors.dark),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppResponsive.h(1)),
                        Text(
                          'untuk ${controller.getCurrentPeriodText()}',
                          style: AppText.small(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }
                return _buildNeracaSaldoContent();
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

  Widget _buildNeracaSaldoContent() {
    return SingleChildScrollView(
      padding: AppResponsive.padding(horizontal: 2, vertical: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Neraca - ${controller.getCurrentPeriodText()}',
              style: AppText.h6()),
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
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                // AKTIVA Header
                Container(
                  width: double.infinity,
                  padding: AppResponsive.padding(all: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text('Aktiva', style: AppText.pSmallBold(color: AppColors.primary)),
                ),
                
                // Aktiva Lancar Section
                _buildSubCategorySection('Aktiva Lancar', controller.aktivaLancar),
                
                // Aktiva Tetap Section  
                _buildSubCategorySection('Aktiva Tetap', controller.aktivaTetap),
                
                // Total Aktiva
                _buildTotalRow('Jumlah Aktiva', controller.totalLeft.value, AppColors.primary),
                
                SizedBox(height: AppResponsive.h(1)),
                
                // PASIVA - Kewajiban Section
                _buildSubCategorySection('Kewajiban', controller.kewajiban),
                
                // Modal Section
                _buildSubCategorySection('Modal', controller.saldo),
                
                // Total Kewajiban dan Modal
                Container(
                  padding: AppResponsive.padding(horizontal: 2, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Jumlah Kewajiban dan Modal',
                            style: AppText.pSmallBold(color: AppColors.dark))),
                      Text(controller.formattedTotalRight.value,
                          style: AppText.pSmallBold(color: AppColors.dark)),
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

  Widget _buildSubCategorySection(String title, RxList items) {
    // Hitung total untuk sub kategori ini
    num subTotal = items.fold(0, (sum, item) => sum + (item['saldo_akhir'] ?? 0));
    
    return Column(
      children: [
        // Sub kategori header
        Container(
          width: double.infinity,
          padding: AppResponsive.padding(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(color: Colors.grey[100]),
          child: Text(title, style: AppText.pSmallBold(color: AppColors.dark)),
        ),
        
        // Items dalam sub kategori atau pesan "tidak ada data"
        if (items.isEmpty)
          Container(
            padding: AppResponsive.padding(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5))
            ),
            child: Row(
              children: [
                SizedBox(width: AppResponsive.w(2)),
                Expanded(
                  child: Text(
                    'Tidak ada data',
                    style: AppText.pSmall(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  )
                ),
              ],
            ),
          )
        else
          ...items.map((item) {
            return Container(
              padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 0.5))
              ),
              child: Row(
                children: [
                  SizedBox(width: AppResponsive.w(2)),
                  Expanded(
                    child: Text(item['account_name'] ?? '', style: AppText.pSmall())
                  ),
                  Text(AppCurrency.formatNumber(item['saldo_akhir']), 
                       style: AppText.pSmall(color: AppColors.dark)),
                ],
              ),
            );
          }).toList(),
        
        // Sub total
        Container(
          padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1))
          ),
          child: Row(
            children: [
              Expanded(
                child: Text('Jumlah $title', 
                           style: AppText.pSmallBold(color: AppColors.dark))
              ),
              Text(AppCurrency.formatNumber(subTotal), 
                   style: AppText.pSmallBold(color: AppColors.dark)),
            ],
          ),
        ),
        
        SizedBox(height: AppResponsive.h(1)),
      ],
    );
  }

  Widget _buildTotalRow(String title, num value, Color color) {
    return Container(
      padding: AppResponsive.padding(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: color, width: 2))
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: AppText.pSmallBold(color: color))
          ),
          Text(AppCurrency.formatNumber(value), 
               style: AppText.pSmallBold(color: color)),
        ],
      ),
    );
  }
}