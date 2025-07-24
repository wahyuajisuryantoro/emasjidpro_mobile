import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class AsetEditController extends GetxController {
  final StorageService storageService = StorageService();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final valueController = TextEditingController();
  final depreciationController = TextEditingController();
  final brandController = TextEditingController();
  final vendorController = TextEditingController();
  final economicLifeController = TextEditingController();
  final linkController = TextEditingController();

  final selectedCategory = Rxn<Map<String, dynamic>>();
  final selectedPaymentAccount = Rxn<Map<String, dynamic>>();
  final purchaseDate = Rx<DateTime?>(null);

  final categories = <Map<String, dynamic>>[].obs;
  final paymentAccounts = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final isLoadingCategories = false.obs;
  final isLoadingAccounts = false.obs;

  Map<String, dynamic>? assetData;
  String? assetId;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is Map<String, dynamic>) {
      assetData = Get.arguments as Map<String, dynamic>;
      assetId = assetData!['id']?.toString();
      _populateFormWithAssetData();
    }

    loadCategories();
    loadPaymentAccounts();
  }

  void _populateFormWithAssetData() {
    if (assetData == null) return;

    nameController.text = assetData!['name']?.toString() ?? '';
    locationController.text = assetData!['location']?.toString() ?? '';
    descriptionController.text = assetData!['description']?.toString() ?? '';
    brandController.text = assetData!['brand']?.toString() ?? '';
    vendorController.text = assetData!['vendor']?.toString() ?? '';
    linkController.text = assetData!['link']?.toString() ?? '';

    if (assetData!['value'] != null) {
      valueController.text = assetData!['value'].toString();
    }

    if (assetData!['depreciation'] != null) {
      depreciationController.text = assetData!['depreciation'].toString();
    }

    if (assetData!['economic_life'] != null) {
      economicLifeController.text = assetData!['economic_life'].toString();
    }

    if (assetData!['date_purchase'] != null) {
      try {
        purchaseDate.value = DateTime.parse(assetData!['date_purchase']);
      } catch (e) {
        print('Error parsing date: $e');
        purchaseDate.value = DateTime.now();
      }
    }
  }

  void loadCategories() async {
    try {
      isLoadingCategories.value = true;
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          categories.value = List<Map<String, dynamic>>.from(data['data']);

          if (assetData != null && assetData!['category'] != null) {
            final categoryName = assetData!['category'].toString();
            final matchingCategory = categories.firstWhereOrNull(
                (cat) => cat['name'].toString() == categoryName);
            if (matchingCategory != null) {
              selectedCategory.value = matchingCategory;
            }
          }
        }
      }
    } catch (e) {
      print('Error loading categories: $e');
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void loadPaymentAccounts() async {
    try {
      isLoadingAccounts.value = true;
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset/payment-accounts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          paymentAccounts.value = List<Map<String, dynamic>>.from(data['data']);

          if (assetData != null && assetData!['account_info'] != null) {
            final accountCode =
                assetData!['account_info']['account_related_code']?.toString();
            if (accountCode != null) {
              final matchingAccount = paymentAccounts.firstWhereOrNull(
                  (acc) => acc['code'].toString() == accountCode);
              if (matchingAccount != null) {
                selectedPaymentAccount.value = matchingAccount;
              }
            }
          }
        }
      }
    } catch (e) {
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  Future<void> selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: purchaseDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      purchaseDate.value = picked;
    }
  }

  void updateAsset() async {
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      String? token = storageService.getToken();

      final requestBody = {
        'name': nameController.text,
        'no_category': selectedCategory.value!['id'],
        'brand': brandController.text,
        'vendor': vendorController.text,
        'description': descriptionController.text,
        'value':
            int.parse(valueController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'depreciation': int.parse(
            depreciationController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        'location': locationController.text,
        'economic_life': int.parse(economicLifeController.text),
        'date_purchase': DateFormat('yyyy-MM-dd').format(purchaseDate.value!),
        'link': linkController.text,
      };
      if (selectedPaymentAccount.value != null) {
        requestBody['account_related'] = selectedPaymentAccount.value!['code'];
      }
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/aset/$assetId/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          String message = data['message'] ?? 'Aset berhasil diperbarui';

          if (data['data']['depreciation_info'] != null) {
            final depreciationInfo = data['data']['depreciation_info'];
            message +=
                '\nPenyusutan ditambahkan: ${depreciationInfo['formatted_depreciation_added']}';
          }

          Get.snackbar(
            'Berhasil',
            message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
          Future.delayed(Duration(seconds: 2), () {
            Get.back(result: {'updated': true, 'asset': data['data']});
          });
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal memperbarui aset');
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Gagal memperbarui aset';

        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }

        if (errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          }
        }

        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      print('Error updating asset: $e');
      Get.snackbar('Error', 'Terjadi kesalahan');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty) {
      _showValidationError('Nama aset harus diisi');
      return false;
    }

    if (selectedCategory.value == null) {
      _showValidationError('Kategori aset harus dipilih');
      return false;
    }

    if (locationController.text.isEmpty) {
      _showValidationError('Lokasi aset harus diisi');
      return false;
    }

    if (purchaseDate.value == null) {
      _showValidationError('Tanggal pembelian harus diisi');
      return false;
    }

    if (valueController.text.isEmpty) {
      _showValidationError('Nilai aset harus diisi');
      return false;
    }

    if (depreciationController.text.isEmpty) {
      _showValidationError('Nilai penyusutan harus diisi');
      return false;
    }

    if (economicLifeController.text.isEmpty) {
      _showValidationError('Masa manfaat harus diisi');
      return false;
    }

    if (vendorController.text.isEmpty) {
      _showValidationError('Informasi vendor/penjual harus diisi');
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
    locationController.dispose();
    descriptionController.dispose();
    valueController.dispose();
    depreciationController.dispose();
    brandController.dispose();
    vendorController.dispose();
    economicLifeController.dispose();
    linkController.dispose();
    super.onClose();
  }
}
