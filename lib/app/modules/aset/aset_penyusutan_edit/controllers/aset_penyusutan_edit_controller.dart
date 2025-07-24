import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AsetPenyusutanEditController extends GetxController {
  final StorageService storageService = StorageService();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final valueController = TextEditingController();
  final transactionDate = Rx<DateTime?>(null);
  final depreciationNo = Rxn<int>();
  final depreciationData = <String, dynamic>{}.obs;
  final isLoading = false.obs;
  final isLoadingData = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
     depreciationNo.value = args['no']; 
      loadDepreciationData(args);
    }
  }

  void loadDepreciationData(Map<String, dynamic> data) {
    try {
      depreciationData.value = data;

      nameController.text = data['depreciation_name'] ?? '';
      descriptionController.text = data['description'] ?? '';
      valueController.text = data['value']?.toString() ?? '';

      if (data['date_transaction'] != null) {
        try {
          transactionDate.value = DateTime.parse(data['date_transaction']);
        } catch (e) {
          transactionDate.value = DateTime.now();
        }
      } else {
        transactionDate.value = DateTime.now();
      }
    } catch (e) {
      print('Error loading depreciation data: $e');
    } finally {
      isLoadingData.value = false;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  Future<void> selectTransactionDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: transactionDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      transactionDate.value = picked;
    }
  }

  void updateDepreciation() async {
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      String? token = storageService.getToken();

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/assets/depreciation/${depreciationNo.value}/edit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': nameController.text,
          'description': descriptionController.text,
          'value': int.parse(valueController.text.replaceAll(RegExp(r'[^0-9]'), '')),
          'date_transaction': DateFormat('yyyy-MM-dd').format(transactionDate.value!),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          Get.snackbar(
            'Berhasil',
            'Data penyusutan berhasil diperbarui dengan nilai',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );

          Future.delayed(Duration(seconds: 2), () {
            Get.back(result: {'updated': true});
          });
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal memperbarui data penyusutan');
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
    if (nameController.text.isEmpty) {
      _showValidationError('Nama penyusutan harus diisi');
      return false;
    }

    if (valueController.text.isEmpty) {
      _showValidationError('Nilai penyusutan harus diisi');
      return false;
    }

    if (transactionDate.value == null) {
      _showValidationError('Tanggal transaksi harus diisi');
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
    nameController.dispose();
    descriptionController.dispose();
    valueController.dispose();
    super.onClose();
  }
}