import 'dart:io';

import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/helpers/document_viewer.dart';
import 'package:emasjid_pro/app/helpers/permission_helper.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

class AsetDetailController extends GetxController {
  final RxMap<String, dynamic> assetData = <String, dynamic>{}.obs;
  final StorageService storageService = StorageService();
  final RxBool isLoading = true.obs;

  final RxList<Map<String, dynamic>> depreciationData =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingDepreciation = false.obs;
  final RxString formattedTotalDepreciation = 'Rp 0'.obs;

  Rx<File?> selectedPictureFile = Rx<File?>(null);
  final isUpdatingPicture = false.obs;

  final RxList<Map<String, dynamic>> assetDocuments =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingDocuments = false.obs;
  final RxBool isUploadingDocument = false.obs;

  late TabController tabController;

  String formatDate(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString);
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  } catch (e) {
    print('Error parsing date: $e');
    return dateString;
  }
}

  @override
  void onInit() {
    super.onInit();

    final assetNo = Get.arguments;

    if (assetNo != null) {
      loadAssetDetail(assetNo.toString());
      loadAssetDepreciation(assetNo.toString());
      loadAssetDocuments(assetNo.toString());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'No aset tidak valid',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        Future.delayed(Duration(seconds: 1), () => Get.back());
      });
    }
  }

  Future<void> loadAssetDetail(String assetNo) async {
    isLoading.value = true;

    try {
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset-detail/$assetNo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          assetData.value = data['data'];
        } else {
          Get.snackbar('Error', 'Gagal memuat detail aset');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAssetDepreciation(String assetNo) async {
    isLoadingDepreciation.value = true;

    try {
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/assets/$assetNo/depreciation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          depreciationData.value =
              List<Map<String, dynamic>>.from(data['data']);
          formattedTotalDepreciation.value =
              data['formatted_total_depreciation'] ?? 'Rp 0';
        } else {
          Get.snackbar('Error', 'Gagal memuat data penyusutan');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoadingDepreciation.value = false;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
        return AppColors.success;
      case 'tidak aktif':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  void navigateToEditAsset() {
    Get.toNamed(Routes.ASET_EDIT, arguments: assetData.value);
  }

  void navigateToAddDepreciation() {
    Get.toNamed(Routes.ASET_PENYUSUTAN_TAMBAH, arguments: {
      'asset_no': assetData.value['id'],
      'asset_name': assetData.value['name']
    });
  }

  void editDepreciation(Map<String, dynamic> depreciationItem) {
    Get.toNamed(Routes.ASET_PENYUSUTAN_EDIT, arguments: depreciationItem);
  }

  void deleteDepreciation(int depreciationNo) async {
    try {
      String? token = storageService.getToken();

      final response = await http.delete(
        Uri.parse(
            '${BaseUrl.baseUrl}/assets/depreciation/$depreciationNo/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          Get.snackbar(
            'Berhasil',
            'Data penyusutan berhasil dihapus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );

          reloadData();
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal menghapus data');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> reloadData() async {
    final assetId = assetData.value['id']?.toString();
    if (assetId != null) {
      await Future.wait([
        loadAssetDetail(assetId),
        loadAssetDepreciation(assetId),
        loadAssetDocuments(assetId),
      ]);
    }
  }

  void showDeleteDepreciationConfirmation(int depreciationNo, String name) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Remix.error_warning_line,
              color: AppColors.danger,
              size: 24,
            ),
            SizedBox(width: AppResponsive.w(2)),
            Text(
              'Hapus Permanen',
              style: AppText.h6(color: AppColors.dark),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus PERMANEN data penyusutan "$name"?\n\nData akan dihapus sepenuhnya dan tidak dapat dikembalikan.',
          style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.8)),
        ),
        contentPadding: AppResponsive.padding(horizontal: 6, vertical: 2),
        titlePadding: AppResponsive.padding(horizontal: 6, vertical: 4),
        actionsPadding: AppResponsive.padding(horizontal: 6, vertical: 3),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dark,
                    side: BorderSide(color: AppColors.dark.withOpacity(0.3)),
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: AppText.bodyMedium(color: AppColors.dark),
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.w(3)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    deleteDepreciation(depreciationNo);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Remix.delete_bin_line,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: AppResponsive.w(1)),
                      Text(
                        'Hapus',
                        style: AppText.bodyMedium(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void pickAssetPicture() async {
    try {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isDenied) {
          final storageStatus = await Permission.storage.request();
          if (storageStatus.isDenied) {
            Get.snackbar(
              'Permission Required',
              'Storage permission is required to select pictures.',
              snackPosition: SnackPosition.TOP,
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
        selectedPictureFile.value = file;
        _showUpdatePictureConfirmation();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void _showUpdatePictureConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Remix.image_line,
              color: AppColors.primary,
              size: 24,
            ),
            SizedBox(width: AppResponsive.w(2)),
            Text(
              'Ganti Foto Aset',
              style: AppText.h6(color: AppColors.dark),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mengganti foto aset ini?',
          style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.8)),
        ),
        contentPadding: AppResponsive.padding(horizontal: 6, vertical: 2),
        titlePadding: AppResponsive.padding(horizontal: 6, vertical: 4),
        actionsPadding: AppResponsive.padding(horizontal: 6, vertical: 3),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    selectedPictureFile.value = null;
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dark,
                    side: BorderSide(color: AppColors.dark.withOpacity(0.3)),
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: AppText.bodyMedium(color: AppColors.dark),
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.w(3)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    updateAssetPicture();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Ganti',
                    style: AppText.bodyMedium(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void uploadNewAssetPicture() async {
    try {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isDenied) {
          final storageStatus = await Permission.storage.request();
          if (storageStatus.isDenied) {
            Get.snackbar(
              'Permission Required',
              'Storage permission is required to select pictures.',
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

        try {
          isUpdatingPicture.value = true;
          String? token = storageService.getToken();
          final assetId = assetData.value['id'];

          final uri =
              Uri.parse('${BaseUrl.baseUrl}/aset/$assetId/upload-picture');
          var request = http.MultipartRequest('POST', uri);

          request.headers['Authorization'] = 'Bearer $token';

          request.files.add(
            await http.MultipartFile.fromPath(
              'picture',
              file.path,
            ),
          );

          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 201) {
            final data = json.decode(response.body);
            if (data['success']) {
              assetData.value = {
                ...assetData.value,
                'picture': data['data']['picture_url'],
                'picture_path': data['data']['picture_path'],
              };

              Get.snackbar(
                'Berhasil',
                'Foto aset berhasil diupload',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
            } else {
              Get.snackbar('Error', data['message'] ?? 'Gagal mengupload foto');
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
          isUpdatingPicture.value = false;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void updateAssetPicture() async {
    if (selectedPictureFile.value == null) return;

    try {
      isUpdatingPicture.value = true;
      String? token = storageService.getToken();
      final assetId = assetData.value['id'];

      final uri = Uri.parse('${BaseUrl.baseUrl}/aset/$assetId/update-picture');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'picture',
          selectedPictureFile.value!.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          assetData.value = {
            ...assetData.value,
            'picture': data['data']['picture_url'],
            'picture_path': data['data']['picture_path'],
          };

          Get.snackbar(
            'Berhasil',
            'Foto aset berhasil diperbarui',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal memperbarui foto');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isUpdatingPicture.value = false;
      selectedPictureFile.value = null;
    }
  }

  void showDeletePictureConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Remix.delete_bin_line,
              color: AppColors.danger,
              size: 24,
            ),
            SizedBox(width: AppResponsive.w(2)),
            Text(
              'Hapus Foto Aset',
              style: AppText.h6(color: AppColors.dark),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus foto aset ini? Foto yang dihapus tidak dapat dikembalikan.',
          style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.8)),
        ),
        contentPadding: AppResponsive.padding(horizontal: 6, vertical: 2),
        titlePadding: AppResponsive.padding(horizontal: 6, vertical: 4),
        actionsPadding: AppResponsive.padding(horizontal: 6, vertical: 3),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dark,
                    side: BorderSide(color: AppColors.dark.withOpacity(0.3)),
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: AppText.bodyMedium(color: AppColors.dark),
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.w(3)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    deleteAssetPicture();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Hapus',
                    style: AppText.bodyMedium(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteAssetPicture() async {
    try {
      isUpdatingPicture.value = true;
      String? token = storageService.getToken();
      final assetId = assetData.value['id'];

      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}/aset/$assetId/delete-picture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          assetData.value = {
            ...assetData.value,
            'picture': null,
            'picture_path': null,
          };

          Get.snackbar(
            'Berhasil',
            'Foto aset berhasil dihapus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal menghapus foto');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isUpdatingPicture.value = false;
    }
  }

  void showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus aset ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteAsset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void deleteAsset() async {
    try {
      String? token = storageService.getToken();

      final response = await http.delete(
        Uri.parse('${BaseUrl.baseUrl}/aset-delete/${assetData.value['id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          Get.snackbar(
            'Berhasil',
            'Aset telah dihapus',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );

          Future.delayed(Duration(seconds: 1), () {
            Get.back(result: {
              'deleted': true,
              'assetId': assetData.value['id'],
            });
          });
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal menghapus aset');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> loadAssetDocuments(String assetNo) async {
    isLoadingDocuments.value = true;

    try {
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/aset/$assetNo/documents'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          assetDocuments.value =
              List<Map<String, dynamic>>.from(data['data']['documents']);
        } else {
          Get.snackbar('Error', 'Gagal memuat dokumen');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoadingDocuments.value = false;
    }
  }

  void uploadAssetDocument() async {
    try {
      final hasPermission = await PermissionHelper.requestStoragePermission();
      if (!hasPermission) {
        PermissionHelper.showPermissionDeniedDialog();
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);

        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'Ukuran file tidak boleh lebih dari 10MB',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
          );
          return;
        }

        try {
          isUploadingDocument.value = true;
          String? token = storageService.getToken();
          final assetId = assetData.value['id'];

          final uri =
              Uri.parse('${BaseUrl.baseUrl}/aset/$assetId/upload-document');
          var request = http.MultipartRequest('POST', uri);

          request.headers['Authorization'] = 'Bearer $token';

          request.files.add(
            await http.MultipartFile.fromPath(
              'document',
              file.path,
            ),
          );

          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode == 201) {
            final data = json.decode(response.body);
            if (data['success']) {
              Get.snackbar(
                'Berhasil',
                'Dokumen berhasil diupload',
                snackPosition: SnackPosition.TOP,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );

              loadAssetDocuments(assetId.toString());
            } else {
              Get.snackbar(
                  'Error', data['message'] ?? 'Gagal mengupload dokumen');
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
          isUploadingDocument.value = false;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memilih file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void updateAssetDocument(int documentIndex, String documentName) async {
    try {
      final hasPermission = await PermissionHelper.requestStoragePermission();
      if (!hasPermission) {
        PermissionHelper.showPermissionDeniedDialog();
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);

        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          Get.snackbar(
            'Error',
            'Ukuran file tidak boleh lebih dari 10MB',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
          );
          return;
        }

        _showUpdateDocumentConfirmation(documentIndex, documentName, file);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memilih file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  void _showUpdateDocumentConfirmation(
      int documentIndex, String documentName, File file) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Remix.file_edit_line,
              color: AppColors.primary,
              size: 24,
            ),
            SizedBox(width: AppResponsive.w(2)),
            Text(
              'Ganti Dokumen',
              style: AppText.h6(color: AppColors.dark),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin mengganti dokumen "$documentName"?',
          style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.8)),
        ),
        contentPadding: AppResponsive.padding(horizontal: 6, vertical: 2),
        titlePadding: AppResponsive.padding(horizontal: 6, vertical: 4),
        actionsPadding: AppResponsive.padding(horizontal: 6, vertical: 3),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dark,
                    side: BorderSide(color: AppColors.dark.withOpacity(0.3)),
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: AppText.bodyMedium(color: AppColors.dark),
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.w(3)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _processUpdateDocument(documentIndex, file);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Ganti',
                    style: AppText.bodyMedium(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _processUpdateDocument(int documentIndex, File file) async {
    try {
      isUploadingDocument.value = true;
      String? token = storageService.getToken();
      final assetId = assetData.value['id'];

      final uri = Uri.parse(
          '${BaseUrl.baseUrl}/aset/$assetId/update-document/$documentIndex');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'document',
          file.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          Get.snackbar(
            'Berhasil',
            'Dokumen berhasil diperbarui',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );

          loadAssetDocuments(assetId.toString());
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal memperbarui dokumen');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isUploadingDocument.value = false;
    }
  }

  void showDeleteDocumentConfirmation(int documentIndex, String documentName) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Remix.delete_bin_line,
              color: AppColors.danger,
              size: 24,
            ),
            SizedBox(width: AppResponsive.w(2)),
            Text(
              'Hapus Dokumen',
              style: AppText.h6(color: AppColors.dark),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus dokumen "$documentName"? Dokumen yang dihapus tidak dapat dikembalikan.',
          style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.8)),
        ),
        contentPadding: AppResponsive.padding(horizontal: 6, vertical: 2),
        titlePadding: AppResponsive.padding(horizontal: 6, vertical: 4),
        actionsPadding: AppResponsive.padding(horizontal: 6, vertical: 3),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dark,
                    side: BorderSide(color: AppColors.dark.withOpacity(0.3)),
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: AppText.bodyMedium(color: AppColors.dark),
                  ),
                ),
              ),
              SizedBox(width: AppResponsive.w(3)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    deleteAssetDocument(documentIndex);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    padding: AppResponsive.padding(vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Hapus',
                    style: AppText.bodyMedium(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteAssetDocument(int documentIndex) async {
    try {
      isUploadingDocument.value = true;
      String? token = storageService.getToken();
      final assetId = assetData.value['id'];

      final response = await http.delete(
        Uri.parse(
            '${BaseUrl.baseUrl}/aset/$assetId/delete-document/$documentIndex'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          Get.snackbar(
            'Berhasil',
            'Dokumen berhasil dihapus',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );

          loadAssetDocuments(assetId.toString());
        } else {
          Get.snackbar('Error', data['message'] ?? 'Gagal menghapus dokumen');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan');
    } finally {
      isUploadingDocument.value = false;
    }
  }

  void openDocument(String documentUrl, String documentName) async {
    try {
      final Uri url = Uri.parse(documentUrl);

      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka dokumen',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    }
  }

  Map<String, dynamic> getDepreciationInfo() {
    double initialValue = assetData.value['value'] is int
        ? assetData.value['value'].toDouble()
        : (assetData.value['value'] ?? 0.0);

    double depreciationPerYear = assetData.value['depreciation'] is int
        ? assetData.value['depreciation'].toDouble()
        : (assetData.value['depreciation'] ?? 0.0);

    String purchaseDate = assetData.value['date_purchase'] ?? '';
    int yearsSincePurchase = 0;
    if (purchaseDate.isNotEmpty) {
      try {
        DateTime purchase = DateTime.parse(purchaseDate);
        DateTime now = DateTime.now();
        yearsSincePurchase = now.year - purchase.year;
      } catch (e) {
        yearsSincePurchase = 0;
      }
    }

    double totalDepreciation = depreciationPerYear * yearsSincePurchase;
    double currentValue = initialValue - totalDepreciation;
    if (currentValue < 0) currentValue = 0;

    double depreciationPercent =
        initialValue > 0 ? (totalDepreciation / initialValue) * 100 : 0.0;

    return {
      'initialValue': initialValue,
      'currentValue': currentValue,
      'depreciationAmount': totalDepreciation,
      'depreciationPercent': depreciationPercent,
    };
  }

  IconData getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Remix.file_pdf_line;
      case 'doc':
      case 'docx':
        return Remix.file_word_line;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Remix.image_line;
      default:
        return Remix.file_line;
    }
  }

  Color getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return AppColors.danger;
      case 'doc':
      case 'docx':
        return AppColors.info;
      case 'jpg':
      case 'png':
        return AppColors.success;
      default:
        return AppColors.dark;
    }
  }
}
