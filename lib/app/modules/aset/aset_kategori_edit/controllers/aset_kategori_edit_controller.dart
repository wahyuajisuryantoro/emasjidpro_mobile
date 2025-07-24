import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AsetKategoriEditController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isLoadingDetail = true.obs;

  // Data kategori yang akan diedit
  final categoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data kategori dari arguments
    if (Get.arguments != null) {
      final category = Get.arguments as Map<String, dynamic>;
      
      // Ambil ID dari arguments
      if (category['id'] != null) {
        categoryId.value = category['id'].toString();
      }
      
      // Set data langsung dari arguments tanpa perlu load ulang
      if (category['name'] != null) {
        nameController.text = category['name'].toString();
      }
      if (category['description'] != null) {
        descriptionController.text = category['description'].toString();
      }
      
      // Set loading detail ke false karena data sudah ada
      isLoadingDetail.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama kategori harus diisi';
    }
    if (value.trim().length < 3) {
      return 'Nama kategori minimal 3 karakter';
    }
    return null;
  }

  Future<void> updateCategory() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.put(
        Uri.parse('${BaseUrl.baseUrl}/aset/update-categories/${categoryId.value}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          Get.back(result: true);
          Future.delayed(Duration(milliseconds: 100), () {
            Get.snackbar(
              'Berhasil',
              'Kategori berhasil diperbarui',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.success,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
              margin: EdgeInsets.all(16),
            );
          });
        } else {
          Get.snackbar(
            'Error',
            'Terjadi Kesalahan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
            margin: EdgeInsets.all(16),
          );
        }
      } else {
        if (response.statusCode == 409) {
          try {
            final Map<String, dynamic> errorData = json.decode(response.body);
            String errorMessage = errorData['message'] ?? 'Kategori dengan nama tersebut sudah ada';
            Get.snackbar(
              'Error',
              errorMessage,
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.danger,
              colorText: Colors.white,
              duration: Duration(seconds: 4),
              margin: EdgeInsets.all(16),
            );
          } catch (parseError) {
            Get.snackbar(
              'Error',
              'Kategori dengan nama tersebut sudah ada',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.danger,
              colorText: Colors.white,
              duration: Duration(seconds: 4),
              margin: EdgeInsets.all(16),
            );
          }
        } else {
          throw Exception('Gagal memperbarui kategori. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi Kesalahan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}