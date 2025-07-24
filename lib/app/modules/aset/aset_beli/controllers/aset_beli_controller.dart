import 'dart:io';

import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class AsetBeliController extends GetxController {
  final StorageService storageService = StorageService();

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final depreciationController = TextEditingController();
  final brandController = TextEditingController();
  final vendorController = TextEditingController();
  final economicLifeController = TextEditingController();

  final selectedCategory = Rxn<Map<String, dynamic>>();
  final selectedPaymentAccount = Rxn<Map<String, dynamic>>();
  final purchaseDate = Rx<DateTime?>(DateTime.now());

  final categories = <Map<String, dynamic>>[].obs;
  final paymentAccounts = <Map<String, dynamic>>[].obs;

  Rx<File?> pictureFile = Rx<File?>(null);
  final hasPicture = false.obs;
  final pictureName = ''.obs;
  final pictureSize = ''.obs;

  final isLoading = false.obs;
  final isLoadingCategories = false.obs;
  final isLoadingAccounts = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadPaymentAccounts();
  }

  void pickPicture() async {
    try {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        final documentsStatus =
            await Permission.manageExternalStorage.request();

        if (photosStatus.isDenied && documentsStatus.isDenied) {
          final storageStatus = await Permission.storage.request();
          if (storageStatus.isDenied) {
            Get.snackbar(
              'Permission Required',
              'Storage permission is required to select files. Please grant permission in app settings.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.danger,
              colorText: Colors.white,
            );
            return;
          }
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);

        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          Get.snackbar(
            'File Size Limit',
            'File size exceeds 5MB limit',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
          );
          return;
        }

        pictureFile.value = file;
        hasPicture.value = true;
        pictureName.value = result.files.single.name;
        pictureSize.value = '${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while picking the picture.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void removePicture() {
    hasPicture.value = false;
    pictureName.value = '';
    pictureSize.value = '';
    pictureFile.value = null;
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
        }
      }
    } catch (e) {
      print('Error loading payment accounts: $e');
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

  void buyAsset() async {
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      String? token = storageService.getToken();

      final uri = Uri.parse('${BaseUrl.baseUrl}/aset/buy');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = nameController.text;
      request.fields['no_category'] = selectedCategory.value!['id'].toString();
      request.fields['account_category'] = '2';
      request.fields['account_related'] = selectedPaymentAccount.value!['code'];
      request.fields['brand'] = brandController.text;
      request.fields['vendor'] = vendorController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['value'] =
          purchasePriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      request.fields['location'] = locationController.text;
      request.fields['date_purchase'] =
          DateFormat('yyyy-MM-dd').format(purchaseDate.value!);
      if (pictureFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'picture',
            pictureFile.value!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success']) {
          Get.snackbar(
            'Berhasil',
            'Aset berhasil dibeli dengan nilai ${data['data']['formatted_value']}',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );

          Future.delayed(Duration(seconds: 2), () {
            Get.back(result: {'purchased': true});
          });
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal membeli aset');
        }
      } else {
        String errorMessage = 'Gagal terhubung ke server';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {}
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
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

    if (selectedPaymentAccount.value == null) {
      _showValidationError('Akun pembayaran harus dipilih');
      return false;
    }

    if (purchaseDate.value == null) {
      _showValidationError('Tanggal pembelian harus diisi');
      return false;
    }

    if (purchasePriceController.text.isEmpty) {
      _showValidationError('Harga pembelian harus diisi');
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
    purchasePriceController.dispose();
    depreciationController.dispose();
    brandController.dispose();
    vendorController.dispose();
    economicLifeController.dispose();
    super.onClose();
  }
}
