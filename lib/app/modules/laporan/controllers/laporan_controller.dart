import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LaporanController extends GetxController {
  final isLoading = false.obs;
  
  
  void downloadReportAsPdf() {
    isLoading.value = true;
    
    
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      
      Get.snackbar(
        'Sukses',
        'Laporan PDF berhasil diunduh',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
    });
  }
  
  void downloadReportAsExcel() {
    isLoading.value = true;
    
    
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      
      Get.snackbar(
        'Sukses',
        'Laporan Excel berhasil diunduh',
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
    });
  }
  
  @override
  void onInit() {
    super.onInit();
  }
  
  @override
  void onReady() {
    super.onReady();
  }
  
  @override
  void onClose() {
    super.onClose();
  }
}