import 'dart:async';
import 'dart:convert';

import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class PendapatanRiwayatController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final searchController = TextEditingController();
  final isSearchVisible = false.obs;

  final isLoading = true.obs;

  final selectedPeriod = 'Bulan Ini'.obs;
  final selectedCategory = 'Semua'.obs;
  final sortKey = 'newest'.obs;
  final sortLabel = 'Terbaru'.obs;

  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;

  final allTransactions = <Map<String, dynamic>>[].obs;
  final filteredTransactions = <Map<String, dynamic>>[].obs;

  final availableCategories = <String>['Semua'].obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  Future<void> fetchRiwayatPendapatan() async {
    try {
      isLoading(true);

      final username = storage.getUsername();
      if (username == null) {
        throw Exception('User not logged in');
      }

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      Map<String, String> params = {
        'period': selectedPeriod.value,
        'category': selectedCategory.value,
        'sort_key': sortKey.value,
      };

      if (searchController.text.isNotEmpty) {
        params['search'] = searchController.text;
      }

      if (selectedPeriod.value.contains('-') ||
          selectedPeriod.value == 'Kustom...') {
        params['start_date'] = DateFormat('yyyy-MM-dd').format(startDate.value);
        params['end_date'] = DateFormat('yyyy-MM-dd').format(endDate.value);
      }

      final uri = Uri.parse('${BaseUrl.baseUrl}/riwayat-pendapatan')
          .replace(queryParameters: params);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          allTransactions.value =
              List<Map<String, dynamic>>.from(data['transactions']);
          filteredTransactions.value = allTransactions;

          if (data.containsKey('categories')) {
            availableCategories.value = List<String>.from(data['categories']);
          }
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal memuat data riwayat');
        }
      } else {
        throw Exception(
            'Gagal memuat data riwayat. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data riwayat: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      allTransactions.clear();
      filteredTransactions.clear();
    } finally {
      isLoading(false);
    }
  }

  void toggleSearchBar() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      searchController.clear();
      fetchRiwayatPendapatan();
    }
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchRiwayatPendapatan();
    });
  }

  Timer? _debounce;

  void setSelectedPeriod(String period) {
    selectedPeriod.value = period;
    fetchRiwayatPendapatan();
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    fetchRiwayatPendapatan();
  }

  void setSortOption(String key, String label) {
    sortKey.value = key;
    sortLabel.value = label;
    fetchRiwayatPendapatan();
  }

  void showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: startDate.value,
        end: endDate.value,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF40A578),
            colorScheme: const ColorScheme.light(primary: Color(0xFF40A578)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;

      final startFormatted = DateFormat('dd/MM/yyyy').format(picked.start);
      final endFormatted = DateFormat('dd/MM/yyyy').format(picked.end);
      selectedPeriod.value = '$startFormatted - $endFormatted';

      fetchRiwayatPendapatan();
    }
  }

  double _extractAmount(String amount) {
    String numericString = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return 0;
    return double.parse(numericString);
  }

  void showTransactionDetails(Map<String, dynamic> transaction) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildDetailRow('Judul', transaction['title']),
              _buildDetailRow('Tanggal', transaction['date']),
              _buildDetailRow('Kategori', transaction['category']),
              _buildDetailRow('Jumlah',
                  transaction['formatted_amount'] ?? transaction['amount']),
              _buildDetailRow('Deskripsi', transaction['description']),
              _buildDetailRow(
                  'Status',
                  transaction['status'] == 'debit'
                      ? 'Debit (Masuk)'
                      : 'Credit (Keluar)'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.dark,
                      padding:
                          AppResponsive.padding(horizontal: 3, vertical: 1.5),
                    ),
                    child: Text(
                      'Tutup',
                      style: AppText.button(color: AppColors.dark),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppText.pSmall(color: AppColors.dark.withOpacity(0.6)),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: label == 'Jumlah'
                  ? AppText.pSmallBold(color: AppColors.primary)
                  : AppText.pSmall(color: AppColors.dark),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onInit() {
    super.onInit();
    fetchRiwayatPendapatan();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
