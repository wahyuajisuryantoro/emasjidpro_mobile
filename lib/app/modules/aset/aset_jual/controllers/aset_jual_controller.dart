import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AsetJualController extends GetxController {
  final StorageService storageService = StorageService();
  final sellValueController = TextEditingController();
  final sellToController = TextEditingController();
  final descriptionController = TextEditingController();

  final sellDate = Rx<DateTime?>(DateTime.now());
  final selectedAssetNo = RxnString();
  final selectedAssetData = Rx<Map<String, dynamic>>({});
  final isAssetLocked = false.obs;
  final availableAssets = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments['no'] != null) {
      selectedAssetNo.value = Get.arguments['no'].toString();
      isAssetLocked.value = true;
      loadAssetDetail(selectedAssetNo.value!);
    } else {
      loadAvailableAssets();
    }
  }

  void loadAssetDetail(String no) async {
    try {
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset-detail/$no'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          selectedAssetData.value = data['data'];
        }
      }
    } catch (e) {
      print('Error loading asset detail: $e');
    }
  }

  void loadAvailableAssets() async {
    try {
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset-list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          availableAssets.value = List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      print('Error loading available assets: $e');
    }
  }

  void selectAsset(String no) {
    selectedAssetNo.value = no;
    final asset = availableAssets.firstWhere((a) => a['id'].toString() == no);
    selectedAssetData.value = asset;
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  Future<void> selectSellDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: sellDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      sellDate.value = picked;
    }
  }

  void sellAsset() async {
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      String? token = storageService.getToken();

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/aset-sell/${selectedAssetNo.value}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'sell_value': int.parse(
              sellValueController.text.replaceAll(RegExp(r'[^0-9]'), '')),
          'date_sell': DateFormat('yyyy-MM-dd').format(sellDate.value!),
          'sell_to': sellToController.text,
          'description': descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          Get.snackbar(
            'Berhasil',
            'Aset berhasil dijual dengan harga ${data['data']['formatted_sell_value']}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );

          Future.delayed(Duration(seconds: 2), () {
            Get.back(result: {'sold': true});
          });
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal menjual aset');
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

  bool _validateInputs() {
    if (selectedAssetNo.value == null || selectedAssetNo.value!.isEmpty) {
      _showValidationError('Pilih aset yang akan dijual');
      return false;
    }

    if (sellDate.value == null) {
      _showValidationError('Tanggal penjualan harus diisi');
      return false;
    }

    if (sellValueController.text.isEmpty) {
      _showValidationError('Harga jual harus diisi');
      return false;
    }

    if (sellToController.text.isEmpty) {
      _showValidationError('Pembeli harus diisi');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    Get.snackbar(
      'Validasi Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    sellValueController.dispose();
    sellToController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
