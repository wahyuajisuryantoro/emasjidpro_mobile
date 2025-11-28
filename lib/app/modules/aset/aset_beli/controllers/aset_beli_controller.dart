// ===== PERBAIKAN FLUTTER CONTROLLER =====
// File: aset_beli_controller.dart

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
  final brandController = TextEditingController();
  final vendorController = TextEditingController();
  final economicLifeController = TextEditingController();

  final selectedAssetAccount = Rxn<Map<String, dynamic>>();
  final selectedPaymentAccount = Rxn<Map<String, dynamic>>();
  final selectedCategory = Rxn<Map<String, dynamic>>();
  final purchaseDate = Rx<DateTime?>(DateTime.now());

  // PERBAIKAN: Pisahkan data akun aset dan akun pembayaran
  final assetAccounts = <Map<String, dynamic>>[].obs; // Akun Aktiva Tetap
  final paymentAccounts = <Map<String, dynamic>>[].obs; // Akun Kas/Bank
  final categories = <Map<String, dynamic>>[].obs;

  Rx<File?> attachmentFile = Rx<File?>(null);
  final hasAttachment = false.obs;
  final attachmentName = ''.obs;
  final attachmentSize = ''.obs;

  final isLoading = false.obs;
  final isLoadingAssetAccounts = false.obs;
  final isLoadingPaymentAccounts = false.obs;
  final isLoadingCategories = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadAssetAccounts(); // Load akun aset
    loadPaymentAccounts(); // Load akun pembayaran
  }

  // PERBAIKAN: Method terpisah untuk load akun aset
  void loadAssetAccounts() async {
    try {
      isLoadingAssetAccounts.value = true;
      String? token = storageService.getToken();

      print('Loading asset accounts...');
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset/accounts'), // Endpoint terpisah
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Asset accounts response status: ${response.statusCode}');
      print('Asset accounts response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          assetAccounts.value = List<Map<String, dynamic>>.from(data['data']);
          print('Asset accounts loaded: ${assetAccounts.length}');
        } else {
          print('API returned success=false: ${data['message']}');
          Get.snackbar(
            'Error',
            'Gagal memuat akun aset: ${data['message']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
          );
        }
      } else {
        print('HTTP Error loading asset accounts: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Gagal memuat akun aset: HTTP ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error loading asset accounts: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data akun aset: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoadingAssetAccounts.value = false;
    }
  }

  // PERBAIKAN: Method terpisah untuk load akun pembayaran
  void loadPaymentAccounts() async {
    try {
      isLoadingPaymentAccounts.value = true;
      String? token = storageService.getToken();

      print('Loading payment accounts...');
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset/payment-accounts'), // Endpoint terpisah
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Payment accounts response status: ${response.statusCode}');
      print('Payment accounts response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          paymentAccounts.value = List<Map<String, dynamic>>.from(data['data']);
          print('Payment accounts loaded: ${paymentAccounts.length}');
          
          // Debug: Print account data
          print('Payment accounts data: ${paymentAccounts.value}');
        } else {
          print('API returned success=false: ${data['message']}');
          Get.snackbar(
            'Error',
            'Gagal memuat akun pembayaran: ${data['message']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
          );
        }
      } else {
        print('HTTP Error loading payment accounts: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Gagal memuat akun pembayaran: HTTP ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error loading payment accounts: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data akun pembayaran: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPaymentAccounts.value = false;
    }
  }

  // Method load categories tetap sama
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

  // PERBAIKAN: Method buyAsset - ganti endpoint dan tambah debug
  void buyAsset() async {
    if (!_validateInputs()) return;

    try {
      isLoading.value = true;
      String? token = storageService.getToken();
      final uri = Uri.parse('${BaseUrl.baseUrl}/aset/buy');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = nameController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['asset_account'] = selectedAssetAccount.value!['code'];
      request.fields['cash_account'] = selectedPaymentAccount.value!['code'];
      request.fields['value'] = purchasePriceController.text.replaceAll(RegExp(r'[^0-9]'), '');
      request.fields['economic_life'] = economicLifeController.text.isNotEmpty
          ? economicLifeController.text
          : '5';
      request.fields['purchase_date'] = DateFormat('yyyy-MM-dd').format(purchaseDate.value!);
      request.fields['brand'] = brandController.text;
      request.fields['vendor'] = vendorController.text;
      request.fields['location'] = locationController.text;

      if (selectedCategory.value != null) {
        request.fields['no_category'] = selectedCategory.value!['id'].toString();
      }
      print('Request fields: ${request.fields}');

      if (attachmentFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'attachment',
            attachmentFile.value!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Buy asset response status: ${response.statusCode}');
      print('Buy asset response body: ${response.body}');
      
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
          if (errorData['errors'] != null) {
            Map<String, dynamic> errors = errorData['errors'];
            errorMessage = errors.values.first.first;
          }
          if (errorData['available_accounts'] != null) {
            print('Available accounts: ${errorData['available_accounts']}');
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
        Get.snackbar('Error', errorMessage);
      }
    } catch (e) {
      print('Exception in buyAsset: $e');
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method lainnya tetap sama (pickAttachment, removeAttachment, dll.)
  void pickAttachment() async {
    try {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        final documentsStatus = await Permission.manageExternalStorage.request();

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
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
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

        attachmentFile.value = file;
        hasAttachment.value = true;
        attachmentName.value = result.files.single.name;
        attachmentSize.value = '${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while picking the attachment.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void removeAttachment() {
    hasAttachment.value = false;
    attachmentName.value = '';
    attachmentSize.value = '';
    attachmentFile.value = null;
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

  bool _validateInputs() {
    if (nameController.text.isEmpty) {
      _showValidationError('Nama aset harus diisi');
      return false;
    }

    if (selectedCategory.value == null) {
      _showValidationError('Kategori aset harus dipilih');
      return false;
    }

    if (selectedAssetAccount.value == null) {
      _showValidationError('Akun aset harus dipilih');
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
    brandController.dispose();
    vendorController.dispose();
    economicLifeController.dispose();
    super.onClose();
  }
}