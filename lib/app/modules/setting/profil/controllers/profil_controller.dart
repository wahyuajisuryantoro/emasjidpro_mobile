import 'dart:convert';
import 'dart:io';

import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ProfilController extends GetxController {
 final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  final RxString name = "".obs;
  final RxString picture = "".obs;
  final RxString email = "".obs;
  final RxBool isLoading = false.obs;
  final RxBool isLogoutLoading = false.obs;
  final RxBool isLoadingProfile = false.obs;

  @override
  void onInit() {
    loadProfileData();
    super.onInit();
  }

  Future<void> loadProfileData() async {
    try {
      isLoadingProfile.value = true;
      final token = _storageService.getToken();

      if (token == null) {
        print('No token found');
        _handleNoToken();
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/get-profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          final profileData = data['data'];

          name.value = profileData['name'] ?? '';
          email.value = profileData['email'] ?? '';
          picture.value = profileData['picture'] ?? '';
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat data profile');
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading profile: $e');

      Get.snackbar(
        'Error',
        'Gagal memuat data profile dari server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void _handleNoToken() {
    Get.snackbar(
      'Session Expired',
      'Silakan login ulang',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.warning,
      colorText: Colors.white,
    );
    Get.offAllNamed(Routes.LOGIN);
  }

  void _handleUnauthorized() {
    _storageService.clearStorage();
    Get.snackbar(
      'Session Expired',
      'Silakan login ulang',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
    );
    Get.offAllNamed(Routes.LOGIN);
  }

  void showPhotoOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Foto Profile',
              style: AppText.h6(color: AppColors.dark),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('Ambil Foto', style: AppText.bodyMedium()),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Pilih dari Galeri', style: AppText.bodyMedium()),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadProfilePicture(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadProfilePicture(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  Future<void> uploadProfilePicture(File imageFile) async {
    try {
      isLoading.value = true;
      final token = _storageService.getToken();

      if (token == null) {
        _handleNoToken();
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.baseUrl}/update-picture'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          picture.value = data['data']['picture_url'];
          Get.snackbar(
            'Berhasil',
            'Foto profile berhasil diperbarui',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        } else {
          throw Exception(data['message'] ?? 'Upload failed');
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Upload failed');
      }
    } catch (e) {
      print('Upload error: $e');
      Get.snackbar(
        'Error',
        'Gagal upload foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: AppColors.danger,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Konfirmasi Logout',
              style: AppText.bodyMedium(color: AppColors.dark),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari aplikasi?',
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: AppText.button(color: AppColors.dark),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => ElevatedButton(
                onPressed: isLogoutLoading.value
                    ? null
                    : () {
                        Get.back();
                        logout();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLogoutLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Keluar',
                        style: AppText.button(color: AppColors.white),
                      ),
              )),
        ],
      ),
    );
  }

  Future<void> logout() async {
    try {
      isLogoutLoading.value = true;

      final token = _storageService.getToken();
      if (token != null) {
        try {
          final response = await http.post(
            Uri.parse('${BaseUrl.baseUrl}/logout'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            print('Server logout success: ${data['message']}');
          } else {
            print('Server logout failed with status: ${response.statusCode}');
          }
        } catch (e) {
          print('Server logout error: $e');
        }
      }

      await _storageService.clearStorage();
      name.value = "";
      picture.value = "";
      email.value = "";

      Get.snackbar(
        'Berhasil',
        'Logout berhasil',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      print('Logout error: $e');
      Get.snackbar(
        'Error',
        'Terjadi Kesalahan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLogoutLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadProfileData();
  }
}
