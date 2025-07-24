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

  final RxString userName = "".obs;
  final RxString name = "".obs;
  final RxString picture = "".obs;
  final RxString email = "".obs;
  final RxString masjidName = "".obs;
  final RxString masjidAlamat = "".obs;
  final RxInt unreadNotificationCount = 0.obs;
  final RxBool isLoadingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
    fetchMasjidName();
    fetchUnreadNotificationCount();
  }

  Future<void> fetchMasjidName() async {
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
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success' && data['masjid'] != null) {
          masjidName.value = data['masjid']['name'] ?? 'Tidak ada nama';
          masjidAlamat.value = data['masjid']['address'] ?? 'Tidak ada alamat';
        }
      }
    } catch (e) {
      print('Error: $e');
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

  void refreshNotificationCount() {
    fetchUnreadNotificationCount();
  }

  final pendapatan = 'Rp 25.750.000'.obs;
  final pengeluaran = 'Rp 12.345.000'.obs;
  final saldo = 'Rp 13.405.000'.obs;

  final periode = 'Maret 2025'.obs;

  final selectedTabIndex = 0.obs;

  final currencyRate = 'Rp 405.800.900'.obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  void updateFinancialData({String? newPendapatan, String? newPengeluaran}) {
    if (newPendapatan != null) {
      pendapatan.value = newPendapatan;
    }

    if (newPengeluaran != null) {
      pengeluaran.value = newPengeluaran;
    }

    calculateSaldo();
  }

  void calculateSaldo() {
    final pendapatanValue =
        int.parse(pendapatan.value.replaceAll('Rp ', '').replaceAll('.', ''));

    final pengeluaranValue =
        int.parse(pengeluaran.value.replaceAll('Rp ', '').replaceAll('.', ''));

    final saldoValue = pendapatanValue - pengeluaranValue;

    saldo.value =
        'Rp ${saldoValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void changePeriode(String newPeriode) {
    periode.value = newPeriode;
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void fetchFinancialData() {
    Future.delayed(Duration(seconds: 1), () {
      pendapatan.value = 'Rp 25.750.000';
      pengeluaran.value = 'Rp 12.345.000';
      calculateSaldo();
    });
  }
}
