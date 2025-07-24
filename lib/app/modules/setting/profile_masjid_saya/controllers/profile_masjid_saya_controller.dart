import 'dart:io';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ProfileMasjidSayaController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final tahunBerdiriController = TextEditingController();
  final pengurusController = TextEditingController();

  // Observable variables
  final isLoading = true.obs;
  final isUpdating = false.obs;
  final isEditMode = false.obs;
  final isUploadingLogo = false.obs;

  // Masjid data
  final RxString masjidName = ''.obs;
  final RxString address = ''.obs;
  final RxString city = ''.obs;
  final RxString tahunBerdiri = ''.obs;

  // Setting data
  final RxString pengurus = ''.obs;
  final RxString logoUrl = ''.obs;

  final RxBool hasMasjidData = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMasjidData();
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    cityController.dispose();
    tahunBerdiriController.dispose();
    pengurusController.dispose();
    super.onClose();
  }

  Future<void> loadMasjidData() async {
    try {
      isLoading.value = true;

      final token = _storageService.getToken();

      if (token == null) {
        _handleNoToken();
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/setting-masjid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] && data['data'] != null) {
          final responseData = data['data'];

          if (responseData['masjid'] != null) {
            final masjidData = responseData['masjid'];
            masjidName.value = masjidData['name'] ?? '';
            address.value = masjidData['address'] ?? '';
            city.value = masjidData['city'] ?? '';
            tahunBerdiri.value = masjidData['tahun_berdiri']?.toString() ?? '';
            hasMasjidData.value = true;

            _updateFormControllers();
          }

          if (responseData['setting'] != null) {
            final settingData = responseData['setting'];
            pengurus.value = settingData['pengurus'] ?? '';
            logoUrl.value = settingData['logo'] ?? '';
          }
        } else {
          hasMasjidData.value = false;
          Get.snackbar(
            'Info',
            data['message'] ?? 'Data masjid tidak ditemukan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.info,
            colorText: Colors.white,
          );
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        final data = json.decode(response.body);
        throw Exception(
            data['message'] ?? 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading masjid data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data masjid',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      hasMasjidData.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (isEditMode.value) {
      _updateFormControllers();
    }
  }

  void cancelEdit() {
    isEditMode.value = false;
    _updateFormControllers();
  }

  void _updateFormControllers() {
    nameController.text = masjidName.value;
    addressController.text = address.value;
    cityController.text = city.value;
    tahunBerdiriController.text = tahunBerdiri.value;
    pengurusController.text = pengurus.value;
  }

  Future<void> pickLogoFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await uploadLogo(File(image.path));
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

  Future<void> uploadLogo(File imageFile) async {
    try {
      isUploadingLogo.value = true;
      final token = _storageService.getToken();

      if (token == null) {
        _handleNoToken();
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.baseUrl}/update-setting'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'logo',
          imageFile.path,
          filename: 'logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

      request.fields['pengurus'] = pengurus.value;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          logoUrl.value = data['data']['setting']['logo'];
          Get.snackbar(
            'Berhasil',
            'Logo berhasil diperbarui',
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
        'Gagal upload logo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isUploadingLogo.value = false;
    }
  }

  Future<void> updateMasjidData() async {
    try {
      if (nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Nama masjid tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        return;
      }

      if (addressController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Alamat tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        return;
      }

      if (cityController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Kota tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        return;
      }

      if (tahunBerdiriController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Tahun berdiri tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        return;
      }

      // TAMBAH VALIDASI PENGURUS
      if (pengurusController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Nama pengurus tidak boleh kosong',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        return;
      }

      final tahun = int.tryParse(tahunBerdiriController.text.trim());
      if (tahun == null || tahun < 1800 || tahun > DateTime.now().year) {
        Get.snackbar(
          'Error',
          'Tahun berdiri tidak valid (1800-${DateTime.now().year})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        return;
      }

      isUpdating.value = true;
      final token = _storageService.getToken();

      if (token == null) {
        _handleNoToken();
        return;
      }

      // UPDATE MASJID DATA
      final masjidResponse = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/update-masjid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text.trim(),
          'address': addressController.text.trim(),
          'city': cityController.text.trim(),
          'tahun_berdiri': tahun,
        }),
      );

      if (masjidResponse.statusCode != 200) {
        final data = json.decode(masjidResponse.body);
        throw Exception(data['message'] ?? 'Update masjid failed');
      }

      // UPDATE SETTING (PENGURUS)
      final settingResponse = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/update-setting'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'pengurus': pengurusController.text.trim(),
        }),
      );

      if (settingResponse.statusCode != 200) {
        final data = json.decode(settingResponse.body);
        throw Exception(data['message'] ?? 'Update pengurus failed');
      }

      // UPDATE LOCAL DATA
      final masjidData = json.decode(masjidResponse.body)['data']['masjid'];
      masjidName.value = masjidData['name'];
      address.value = masjidData['address'];
      city.value = masjidData['city'];
      tahunBerdiri.value = masjidData['tahun_berdiri'].toString();

      final settingData = json.decode(settingResponse.body)['data']['setting'];
      pengurus.value = settingData['pengurus'];

      isEditMode.value = false;

      Get.snackbar(
        'Berhasil',
        'Data masjid dan pengurus berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Update error: $e');
      Get.snackbar(
        'Error',
        'Gagal update data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> refreshMasjidData() async {
    await loadMasjidData();
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

  bool get hasChanges {
    return nameController.text != masjidName.value ||
        addressController.text != address.value ||
        cityController.text != city.value ||
        tahunBerdiriController.text != tahunBerdiri.value ||
        pengurusController.text != pengurus.value;
  }
}
