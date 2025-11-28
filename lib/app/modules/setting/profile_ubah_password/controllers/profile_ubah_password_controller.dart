import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileUbahPasswordController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // Form controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  // Loading state
  final isLoading = false.obs;
  
  // Password visibility
  final isCurrentPasswordHidden = true.obs;
  final isNewPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  
  @override
  void onInit() {
    super.onInit();
  }
  
  // Toggle password visibility
  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordHidden.value = !isCurrentPasswordHidden.value;
  }
  
  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }
  
  // Update password function
  Future<void> updatePassword() async {
    // Validasi input
    if (currentPasswordController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Password saat ini harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    if (newPasswordController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Password baru harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    if (newPasswordController.text.length < 8) {
      Get.snackbar(
        'Gagal',
        'Password baru minimal 8 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    if (confirmPasswordController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Konfirmasi password harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar(
        'Gagal',
        'Konfirmasi password tidak sesuai',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    if (currentPasswordController.text == newPasswordController.text) {
      Get.snackbar(
        'Gagal',
        'Password baru harus berbeda dari password saat ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      String? token = _storageService.getToken();
      
      if (token == null) {
        Get.snackbar(
          'Error',
          'Token tidak ditemukan, silakan login ulang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        return;
      }
      Map<String, dynamic> requestData = {
        'current_password': currentPasswordController.text,
        'new_password': newPasswordController.text,
        'new_password_confirmation': confirmPasswordController.text,
      };
      
      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/update-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Clear form
          _clearForm();
          
          // Show success message
          Get.snackbar(
            'Berhasil',
            data['message'] ?? 'Password berhasil diperbarui',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          await Future.delayed(const Duration(seconds: 1));
          await _autoLogout();
          
        } else {
          throw Exception(data['message'] ?? 'Gagal memperbarui password');
        }
      } else if (response.statusCode == 422) {
        // Validation errors
        final data = json.decode(response.body);
        String errorMessage = data['message'] ?? 'Validasi gagal';
        
        if (data['errors'] != null) {
          Map<String, dynamic> errors = data['errors'];
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            }
          });
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.first;
          }
        }
        
        Get.snackbar(
          'Gagal',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        Get.snackbar(
          'Error',
          'Session expired, silakan login ulang',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        await _autoLogout();
      } else {
        // Server error
        try {
          final data = json.decode(response.body);
          throw Exception(data['message'] ?? 'Server error: ${response.statusCode}');
        } catch (e) {
          throw Exception('Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error updating password: $e');
      Get.snackbar(
        'Error',
        'Terjadi Kesalahan Server',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Clear form
  void _clearForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }
  
  // Auto logout after password change
  Future<void> _autoLogout() async {
    try {
      await _storageService.clearStorage();
      await Future.delayed(const Duration(seconds: 2));
      Get.offAllNamed(Routes.LOGIN); 
    } catch (e) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
  
  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}