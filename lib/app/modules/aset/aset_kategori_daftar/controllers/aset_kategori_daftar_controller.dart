import 'dart:convert';

import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:remixicon/remixicon.dart';

class AsetKategoriDaftarController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  
  final isLoading = true.obs;

  
  final categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;

      final username = storage.getUsername();
      if (username == null) {
        throw Exception('User not logged in');
      }

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset/categories'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          categories.value = (data as List).map((category) {
            return {
              'id': category['id'],
              'name': category['name'],
              'description': category['description'] ?? '',
            };
          }).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memuat kategori');
        }
      } else {
        throw Exception(
            'Gagal memuat kategori. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat kategori: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      categories.clear();
    } finally {
      isLoading.value = false;
    }
  }

  
  void navigateToAddCategory() {
    Get.toNamed(Routes.ASET_KATEGORI_TAMBAH);
  }

  
  void navigateToEditCategory(Map<String, dynamic> category) {
    Get.toNamed(Routes.ASET_KATEGORI_EDIT, arguments: category);
  }

  void _showCannotDeleteDialog(
      String message, int assetCount, String assetExamples) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Remix.error_warning_line,
              color: AppColors.warning,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Tidak Dapat Dihapus',
              style: AppText.h6(color: AppColors.dark),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: AppText.bodyMedium(color: AppColors.dark),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail:',
                    style: AppText.bodyMedium(
                      color: AppColors.warning,
                
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Jumlah aset: $assetCount',
                    style: AppText.small(color: AppColors.dark),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Contoh aset: $assetExamples',
                    style: AppText.small(color: AppColors.dark),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Pindahkan atau hapus aset yang menggunakan kategori ini terlebih dahulu.',
              style: AppText.small(color: AppColors.dark.withOpacity(0.7)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Mengerti',
              style: AppText.button(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  
  void showDeleteConfirmation(Map<String, dynamic> category) {
  Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Icon(
            Remix.delete_bin_line,
            color: AppColors.danger,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Hapus Kategori',
            style: AppText.h6(color: AppColors.dark),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apakah Anda yakin ingin menghapus kategori "${category['name']}"?',
            style: AppText.bodyMedium(color: AppColors.dark),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Remix.information_line,
                  color: AppColors.danger,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kategori akan dihapus permanen dan tidak dapat dikembalikan.',
                    style: AppText.small(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Batal',
            style: AppText.button(color: AppColors.dark),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            deleteCategory(category['id']);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: Text(
            'Hapus',
            style: AppText.button(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
  
  Future<void> deleteCategory(int categoryId) async {
    try {
      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}/aset/delete-categories/$categoryId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          Get.snackbar(
            'Berhasil',
            'Kategori berhasil dihapus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(16),
          );

          
          loadCategories();
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
      } else if (response.statusCode == 409) {
        
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          String errorMessage =
              errorData['message'] ?? 'Kategori masih digunakan';

          
          if (errorData['details'] != null) {
            final details = errorData['details'];
            final assetCount = details['asset_count'] ?? 0;
            final assetExamples = details['asset_examples'] ?? '';

            
            _showCannotDeleteDialog(errorMessage, assetCount, assetExamples);
          } else {
            Get.snackbar(
              'Tidak Dapat Dihapus',
              errorMessage,
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.warning,
              colorText: Colors.white,
              duration: Duration(seconds: 5),
              margin: EdgeInsets.all(16),
            );
          }
        } catch (parseError) {
          Get.snackbar(
            'Tidak Dapat Dihapus',
            'Kategori masih digunakan oleh aset lain',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.warning,
            colorText: Colors.white,
            duration: Duration(seconds: 4),
            margin: EdgeInsets.all(16),
          );
        }
      } else {
        throw Exception(
            'Gagal menghapus kategori. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat menghapus kategori',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(16),
      );
    }
  }

  
  void showCategoryOptions(Map<String, dynamic> category) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              category['name'],
              style: AppText.h6(color: AppColors.dark),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.primary),
              title: Text('Edit Kategori',
                  style: AppText.pSmall(color: AppColors.dark)),
              onTap: () {
                Get.back();
                navigateToEditCategory(category);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.danger),
              title: Text('Hapus Kategori',
                  style: AppText.pSmall(color: AppColors.dark)),
              onTap: () {
                Get.back();
                showDeleteConfirmation(category);
              },
            ),
          ],
        ),
      ),
    );
  }
}
