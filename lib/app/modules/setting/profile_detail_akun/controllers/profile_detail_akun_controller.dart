import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileDetailAkunController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  // Form controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final birthController = TextEditingController();
  
  // Loading state
  final isLoading = false.obs;
  final isLoadingProfile = true.obs;
  
  // Gender options
  final genderOptions = <String>[
    'L', // Laki-laki
    'P', // Perempuan
  ];
  
  // Selected values
  final selectedGender = ''.obs;
  
  // Original profile data for comparison
  Map<String, dynamic> originalProfile = {};
  
  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }
  
  // Load current profile data
  Future<void> loadProfile() async {
    try {
      isLoadingProfile.value = true;
      
      // Get token from storage
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
      
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/get-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Load Profile Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final profileData = data['data'];
          originalProfile = Map<String, dynamic>.from(profileData);
          nameController.text = profileData['name'] ?? '';
          emailController.text = profileData['email'] ?? '';
          phoneController.text = profileData['phone'] ?? '';
          addressController.text = profileData['address'] ?? '';
          cityController.text = profileData['city'] ?? '';
          birthController.text = profileData['birth'] ?? '';
          selectedGender.value = profileData['sex'] ?? '';
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat data profile');
        }
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        Get.snackbar(
          'Error',
          'Session expired, silakan login ulang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        // Navigate to login
        _handleUnauthorized();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProfile.value = false;
    }
  }
  
  // Update profile function
  Future<void> updateProfile() async {
    // Validasi input
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nama harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Email harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    if (phoneController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nomor telepon harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    // Validasi email format
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        'Gagal',
        'Format email tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    try {
      isLoading.value = true;
      
      // Get token from storage
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
      
      // Prepare update data - only send changed fields
      Map<String, dynamic> updateData = {};
      
      if (nameController.text != originalProfile['name']) {
        updateData['name'] = nameController.text;
      }
      if (emailController.text != originalProfile['email']) {
        updateData['email'] = emailController.text;
      }
      if (phoneController.text != originalProfile['phone']) {
        updateData['phone'] = phoneController.text;
      }
      if (addressController.text != (originalProfile['address'] ?? '')) {
        updateData['address'] = addressController.text;
      }
      if (cityController.text != (originalProfile['city'] ?? '')) {
        updateData['city'] = cityController.text;
      }
      if (birthController.text != (originalProfile['birth'] ?? '')) {
        updateData['birth'] = birthController.text;
      }
      if (selectedGender.value != (originalProfile['sex'] ?? '')) {
        updateData['sex'] = selectedGender.value;
      }
      
      // If no changes, show message
      if (updateData.isEmpty) {
        Get.snackbar(
          'Info',
          'Tidak ada perubahan data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.info,
          colorText: Colors.white,
        );
        return;
      }
      
      print('Update Data: ${json.encode(updateData)}');
      
      final response = await http.post( // Kembali ke POST
        Uri.parse('${BaseUrl.baseUrl}/update-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );
      
      print('Update Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Update original profile with new data
          originalProfile = Map<String, dynamic>.from(data['data']);
          
          Get.snackbar(
            'Berhasil',
            'Profile berhasil diperbarui',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          
          // Kembali ke halaman sebelumnya setelah delay
          Future.delayed(const Duration(seconds: 1), () {
            Get.back(result: {
              'success': true,
              'updated': true,
            });
          });
        } else {
          throw Exception(data['message'] ?? 'Gagal memperbarui profile');
        }
      } else if (response.statusCode == 422) {
        // Validation errors
        final data = json.decode(response.body);
        String errorMessage = 'Validasi gagal';
        
        if (data['errors'] != null) {
          Map<String, dynamic> errors = data['errors'];
          List<String> errorMessages = [];
          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first.toString());
            }
          });
          errorMessage = errorMessages.join('\n');
        }
        
        Get.snackbar(
          'Validasi Gagal',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        Get.snackbar(
          'Error',
          'Session expired, silakan login ulang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        _handleUnauthorized();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Handle unauthorized access
  void _handleUnauthorized() {
    // Clear storage and navigate to login
    _storageService.clearStorage();
    // Navigate to login page - sesuaikan dengan route name Anda
    Get.offAllNamed('/login'); // atau Routes.LOGIN jika menggunakan named routes
  }
  
  // Format birth date for display
  void selectBirthDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (selectedDate != null) {
      birthController.text = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    }
  }
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    birthController.dispose();
    super.onClose();
  }
}