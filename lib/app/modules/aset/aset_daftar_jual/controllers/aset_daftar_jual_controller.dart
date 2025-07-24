import 'dart:async';
import 'dart:convert';

import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AsetDaftarJualController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final isLoading = true.obs;

  final isFilterVisible = false.obs;

  final searchController = TextEditingController();
  final isSearchVisible = false.obs;

  final categories = <String>['Semua'].obs;

  final selectedCategories = <String>[].obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  final searchQuery = ''.obs;

  final soldAssets = <Map<String, dynamic>>[].obs;
  final filteredSoldAssets = <Map<String, dynamic>>[].obs;

  final totalSoldAssets = 0.obs;
  final totalSellValue = 0.0.obs;
  final formattedTotalSellValue = 'Rp 0'.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadSoldAssets();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void toggleFilterPanel() {
    isFilterVisible.value = !isFilterVisible.value;
  }

  void toggleSearchBar() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      searchController.clear();
      searchQuery.value = '';
      applyFilters();
    }
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      applyFilters();
    });
  }

  Future<void> loadSoldAssets() async {
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
        Uri.parse('${BaseUrl.baseUrl}/aset/sold'),
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
          final summary = responseData['summary'];

          soldAssets.value = (data as List).map((asset) {
            return {
              'no': asset['no'],
              'code': asset['code'],
              'code_asset': asset['code_asset'],
              'name': asset['name'],
              'description': asset['description'],
              'sell_value': asset['sell_value'] ?? 0,
              'formatted_sell_value': asset['formatted_sell_value'] ?? 'Rp 0',
              'sell_to': asset['sell_to'] ?? 'Tidak Diketahui',
              'date_sell': _formatDate(asset['date_sell']),
              'date_transaction': asset['date_transaction'],
              'account_name': asset['account_name'] ?? 'Tidak Diketahui',
              'status': 'Terjual',
            };
          }).toList();

          totalSoldAssets.value = summary['total_sold_assets'] ?? 0;
          totalSellValue.value = (summary['total_sell_value'] ?? 0).toDouble();
          formattedTotalSellValue.value =
              summary['formatted_total_sell_value'] ?? 'Rp 0';

          final assetCategories = soldAssets
              .map(
                  (asset) => _extractCategoryFromName(asset['name'].toString()))
              .where((category) => category.isNotEmpty)
              .toSet()
              .toList();

          categories.value = ['Semua', ...assetCategories];

          filteredSoldAssets.value = List.from(soldAssets);
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal memuat data aset terjual');
        }
      } else {
        throw Exception(
            'Gagal memuat data aset terjual. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi Kesalahan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );

      soldAssets.clear();
      filteredSoldAssets.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String _extractCategoryFromName(String name) {
    name = name.toLowerCase();
    if (name.contains('motor') ||
        name.contains('mobil') ||
        name.contains('kendaraan')) {
      return 'Kendaraan';
    } else if (name.contains('ac') ||
        name.contains('sound') ||
        name.contains('lampu') ||
        name.contains('cctv')) {
      return 'Peralatan Elektronik';
    } else if (name.contains('kursi') ||
        name.contains('meja') ||
        name.contains('karpet') ||
        name.contains('rak')) {
      return 'Furniture';
    } else if (name.contains('quran') ||
        name.contains('mimbar') ||
        name.contains('jam')) {
      return 'Peralatan Ibadah';
    } else {
      return 'Lainnya';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Tanggal tidak diketahui';
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void applyFilters() {
    filteredSoldAssets.value = soldAssets.where((asset) {
      bool categoryMatch = true;
      if (selectedCategories.isNotEmpty) {
        String assetCategory =
            _extractCategoryFromName(asset['name'].toString());
        categoryMatch = selectedCategories.contains(assetCategory);
      }

      bool dateMatch = true;
      if (startDate.value != null || endDate.value != null) {
        try {
          String sellDateStr = asset['date_sell'];
          if (sellDateStr != 'Tanggal tidak diketahui') {
            DateTime sellDate =
                DateFormat('dd MMMM yyyy', 'id_ID').parse(sellDateStr);

            if (startDate.value != null) {
              dateMatch = dateMatch &&
                  (sellDate.isAfter(startDate.value!) ||
                      sellDate.isAtSameMomentAs(startDate.value!));
            }

            if (endDate.value != null) {
              dateMatch = dateMatch &&
                  (sellDate.isBefore(endDate.value!) ||
                      sellDate.isAtSameMomentAs(endDate.value!));
            }
          }
        } catch (e) {
          if (startDate.value != null || endDate.value != null) {
            dateMatch = false;
          }
        }
      }

      bool searchMatch = true;
      if (searchQuery.value.isNotEmpty) {
        String query = searchQuery.value.toLowerCase();
        searchMatch = asset['name'].toString().toLowerCase().contains(query) ||
            asset['description'].toString().toLowerCase().contains(query) ||
            asset['sell_to'].toString().toLowerCase().contains(query) ||
            asset['account_name'].toString().toLowerCase().contains(query);
      }

      return categoryMatch && dateMatch && searchMatch;
    }).toList();

    isFilterVisible.value = false;
  }

  void resetFilters() {
    selectedCategories.clear();
    startDate.value = null;
    endDate.value = null;
    searchQuery.value = '';
    searchController.clear();

    applyFilters();
  }

  void resetCategoryFilter() {
    selectedCategories.clear();
    applyFilters();
  }

  void resetSearchFilter() {
    searchQuery.value = '';
    searchController.clear();
    applyFilters();
  }

  void toggleCategoryFilter(String category) {
    if (category == 'Semua') {
      selectedCategories.clear();
    } else {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    }

    applyFilters();
  }

  void resetDateFilter() {
    startDate.value = null;
    endDate.value = null;
    applyFilters();
  }

  void showDateRangeDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Pilih Rentang Tanggal Penjualan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Dari Tanggal'),
              subtitle: Obx(() => Text(startDate.value != null
                  ? DateFormat('dd MMMM yyyy', 'id_ID').format(startDate.value!)
                  : 'Belum dipilih')),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: Get.context!,
                  initialDate: startDate.value ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  startDate.value = pickedDate;
                }
              },
            ),
            ListTile(
              title: Text('Sampai Tanggal'),
              subtitle: Obx(() => Text(endDate.value != null
                  ? DateFormat('dd MMMM yyyy', 'id_ID').format(endDate.value!)
                  : 'Belum dipilih')),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: Get.context!,
                  initialDate: endDate.value ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  endDate.value = pickedDate;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              resetDateFilter();
              Get.back();
            },
            child: Text('Reset'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('Terapkan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String formatCurrency(dynamic amount) {
    if (amount is int) {
      amount = amount.toDouble();
    }

    if (amount is! double) {
      return 'Rp 0';
    }

    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  String getDateRangeText() {
    if (startDate.value == null && endDate.value == null) {
      return 'Pilih rentang tanggal penjualan';
    }

    String startText = startDate.value != null
        ? DateFormat('dd/MM/yyyy').format(startDate.value!)
        : '';

    String endText = endDate.value != null
        ? DateFormat('dd/MM/yyyy').format(endDate.value!)
        : '';

    if (startDate.value != null && endDate.value != null) {
      return '$startText - $endText';
    } else if (startDate.value != null) {
      return 'Dari $startText';
    } else {
      return 'Sampai $endText';
    }
  }

  bool hasDateFilter() {
    return startDate.value != null || endDate.value != null;
  }

  bool hasActiveFilters() {
    return selectedCategories.isNotEmpty ||
        hasDateFilter() ||
        searchQuery.value.isNotEmpty;
  }

  void showSoldAssetDetails(Map<String, dynamic> asset) {
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
                'Detail Aset Terjual',
                style: AppText.h6(color: AppColors.dark),
              ),
              SizedBox(height: 20),
              _buildDetailRow('Kode Aset', asset['code_asset']),
              _buildDetailRow('Nama Aset', asset['name']),
              _buildDetailRow('Dijual Kepada', asset['sell_to']),
              _buildDetailRow('Tanggal Penjualan', asset['date_sell']),
              _buildDetailRow('Harga Jual', asset['formatted_sell_value']),
              _buildDetailRow('Akun Pembayaran', asset['account_name']),
              _buildDetailRow('Deskripsi', asset['description']),
              _buildDetailRow('Status', asset['status']),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
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
            width: 120,
            child: Text(
              label,
              style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: label.contains('Harga') || label.contains('Nilai')
                  ? AppText.small(color: AppColors.success)
                  : AppText.small(color: AppColors.dark),
            ),
          ),
        ],
      ),
    );
  }
}
