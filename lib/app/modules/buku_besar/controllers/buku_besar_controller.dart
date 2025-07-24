import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class BukuBesarController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> accounts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredAccounts =
      <Map<String, dynamic>>[].obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
    searchQuery.listen((query) {
      filterAccounts(query);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchAccounts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      String? token = _storageService.getToken();

      if (token == null) {
        errorMessage.value = 'Token tidak tersedia, silakan login kembali';
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/buku-besar/account'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          accounts.value =
              List<Map<String, dynamic>>.from(data['data']['accounts'] ?? []);
          filteredAccounts.value = accounts.value;
        } else {
          errorMessage.value = data['message'] ?? 'Terjadi kesalahan';
        }
      } else {
        errorMessage.value = 'Terjadi kesalahan: HTTP ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan';
    } finally {
      isLoading.value = false;
    }
  }

  void filterAccounts(String query) {
    if (query.isEmpty) {
      filteredAccounts.value = accounts.value;
    } else {
      filteredAccounts.value = accounts.where((account) {
        final code = account['code']?.toString().toLowerCase() ?? '';
        final name = account['name']?.toString().toLowerCase() ?? '';
        final searchTerm = query.toLowerCase();

        return code.contains(searchTerm) || name.contains(searchTerm);
      }).toList();
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  Future<void> refreshAccounts() async {
    await fetchAccounts();
  }

  void navigateToAccountDetail(String accountCode) {
    Get.toNamed(Routes.BUKU_BESAR_DETAIL, arguments: {
      'code_account': accountCode,
    });
  }
}
