import 'dart:convert';

import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Profile data
  final RxString userName = "".obs;
  final RxString name = "".obs;
  final RxString picture = "".obs;
  final RxString email = "".obs;
  final RxBool isLoadingProfile = false.obs;

  // Masjid data
  final RxString masjidName = "".obs;
  final RxString masjidAlamat = "".obs;

  // Notification
  final RxInt unreadNotificationCount = 0.obs;

  // Home financial data - sesuai response backend
  final RxString pendapatanBulanIni = "Rp 0".obs;
  final RxString pendapatanBulanLalu = "Rp 0".obs;
  final RxString pengeluaranBulanIni = "Rp 0".obs;
  final RxString pengeluaranBulanLalu = "Rp 0".obs;
  final RxBool isLoadingHomeData = false.obs;

  // Tab control
  final RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
    fetchMasjidData();
    fetchUnreadNotificationCount();
    getHomeData();
  }

  void refreshNotificationCount() {
    fetchUnreadNotificationCount();
  }

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> fetchMasjidData() async {
    try {
      final token = _storageService.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/data-masjid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['masjid'] != null) {
          masjidName.value = data['masjid']['name'] ?? 'Tidak ada nama';
          masjidAlamat.value = data['masjid']['address'] ?? 'Tidak ada alamat';
        }
      }
    } catch (e) {
      print('Error fetching masjid data: $e');
    }
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      final token = _storageService.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/notifications/counts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          unreadNotificationCount.value = data['data']['unread'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  Future<void> loadProfileData() async {
    try {
      isLoadingProfile.value = true;
      final token = _storageService.getToken();

      if (token == null) {
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> getHomeData() async {
    try {
      isLoadingHomeData.value = true;
      final token = _storageService.getToken();

      if (token == null) {
        _handleNoToken();
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/home-data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          final homeData = data['data'];

          // Update data sesuai response backend
          pendapatanBulanIni.value =
              homeData['pendapatan']['bulan_ini'] ?? 'Rp 0';
          pendapatanBulanLalu.value =
              homeData['pendapatan']['bulan_lalu'] ?? 'Rp 0';
          pengeluaranBulanIni.value =
              homeData['pengeluaran']['bulan_ini'] ?? 'Rp 0';
          pengeluaranBulanLalu.value =
              homeData['pengeluaran']['bulan_lalu'] ?? 'Rp 0';
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat data home');
        }
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading home data: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data finansial',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoadingHomeData.value = false;
    }
  }

  void _handleNoToken() {
    Get.snackbar(
      'Session Expired',
      'Silakan login ulang',
      snackPosition: SnackPosition.TOP,
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
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
    );
    Get.offAllNamed(Routes.LOGIN);
  }
}
