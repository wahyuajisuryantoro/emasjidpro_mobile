import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class AsetDashboardController extends GetxController {
  final RxList categoryAset = [].obs;
  final RxList asetList = [].obs;
  
  RxDouble totalNilaiAset = 0.0.obs;
  RxString formattedTotalNilaiAset = "".obs;
  RxString formattedTotalPenyusutan = "".obs;
  RxString formattedNilaiAsetSaatIni = "".obs;
  
  final StorageService storageService = StorageService();
  
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAssets();
  }

   String formatDate(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString);
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  } catch (e) {
    print('Error parsing date: $e');
    return dateString;
  }
}

  void loadAssets() async {
    isLoading.value = true;

    try {
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/dashboard-aset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          formattedTotalNilaiAset.value = data['data']['formatted_total_nilai_aset'];
          formattedTotalPenyusutan.value = data['data']['formatted_total_penyusutan'];
          formattedNilaiAsetSaatIni.value = data['data']['formatted_nilai_aset_saat_ini'];
          
          categoryAset.value = data['data']['category_aset'];
          asetList.value = data['data']['aset_list'];
        } else {
          Get.snackbar('Error', 'Gagal memuat data dashboard aset');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan');
    } finally {
      isLoading.value = false;
    }
  }

  
  void navigateToAssetList() {
    Get.toNamed(Routes.ASET_DAFTAR);
  }

  
  void navigateToAddAsset() {
    Get.toNamed(Routes.ASET_TAMBAH);
  }

  
  void navigateToBuyAsset() {
    Get.toNamed(Routes.ASET_BELI);
  }

  
  void navigateToSellAsset() {
    Get.toNamed(Routes.ASET_JUAL);
  }

  void navigateToAssetDetail(Map<String, dynamic> asset) {
    final assetNo = asset['no'] ?? asset['id'];
    Get.toNamed(Routes.ASET_DETAIL, arguments: assetNo);
  }
}