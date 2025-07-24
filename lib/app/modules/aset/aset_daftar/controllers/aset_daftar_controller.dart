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

class AsetDaftarController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final isLoading = true.obs;

  final isFilterVisible = false.obs;

  final searchController = TextEditingController();
  final isSearchVisible = false.obs;

  final categories = <String>['Semua'].obs;

  final priceRanges = [
    '0',
    '1000000',
    '5000000',
    '10000000',
    '50000000',
    '100000000',
    '500000000',
    '1000000000',
  ];

  final selectedCategories = <String>[].obs;
  final selectedMinPrice = '0'.obs;
  final selectedMaxPrice = '0'.obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  final searchQuery = ''.obs;

  final assets = <Map<String, dynamic>>[].obs;
  final filteredAssets = <Map<String, dynamic>>[].obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadAssets();
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

  Future<void> loadAssets() async {
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
        Uri.parse('${BaseUrl.baseUrl}/aset-all'),
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

          assets.value = (data as List).map((asset) {
            return {
              'no': asset['no'],
              'name': asset['name'],
              'category': asset['category'] ?? 'Tidak Ada Kategori',
              'value': asset['value'] ?? 0,
              'acquisitionDate': _formatDate(asset['date_purchase']),
              'status': 'Aktif',
              'location': 'Lokasi Aset',
              'description': asset['name'],
              'imageUrl':
                  'https://via.placeholder.com/800x600?text=${Uri.encodeComponent(asset['category'] ?? 'Aset')}',
              'purchased_with': asset['purchased_with'] ?? 'Tidak Diketahui',
              'current_value': asset['current_value'] ?? asset['value'] ?? 0,
              'formatted_value': asset['formatted_value'] ?? 'Rp 0',
              'formatted_current_value': asset['formatted_current_value'] ??
                  asset['formatted_value'] ??
                  'Rp 0',
            };
          }).toList();

          final assetCategories = assets
              .map((asset) => asset['category'].toString())
              .where((category) =>
                  category.isNotEmpty && category != 'Tidak Ada Kategori')
              .toSet()
              .toList();

          categories.value = ['Semua', ...assetCategories];

          filteredAssets.value = List.from(assets);
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memuat data aset');
        }
      } else {
        throw Exception(
            'Gagal memuat data aset. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );

      assets.clear();
      filteredAssets.clear();
    } finally {
      isLoading.value = false;
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
    filteredAssets.value = assets.where((asset) {
      bool categoryMatch = true;
      if (selectedCategories.isNotEmpty) {
        categoryMatch = selectedCategories.contains(asset['category']);
      }

      bool priceMatch = true;
      double assetValue = (asset['value'] is int)
          ? asset['value'].toDouble()
          : (asset['value'] is double ? asset['value'] : 0.0);
      double minPrice = selectedMinPrice.value != '0'
          ? double.parse(selectedMinPrice.value)
          : 0;
      double maxPrice = selectedMaxPrice.value != '0'
          ? double.parse(selectedMaxPrice.value)
          : double.infinity;

      priceMatch = assetValue >= minPrice && assetValue <= maxPrice;

      bool dateMatch = true;
      if (startDate.value != null || endDate.value != null) {
        try {
          String acqDateStr = asset['acquisitionDate'];
          if (acqDateStr != 'Tanggal tidak diketahui') {
            DateTime acqDate =
                DateFormat('dd MMMM yyyy', 'id_ID').parse(acqDateStr);

            if (startDate.value != null) {
              dateMatch = dateMatch &&
                  (acqDate.isAfter(startDate.value!) ||
                      acqDate.isAtSameMomentAs(startDate.value!));
            }

            if (endDate.value != null) {
              dateMatch = dateMatch &&
                  (acqDate.isBefore(endDate.value!) ||
                      acqDate.isAtSameMomentAs(endDate.value!));
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
            asset['category'].toString().toLowerCase().contains(query) ||
            asset['purchased_with'].toString().toLowerCase().contains(query);
      }

      return categoryMatch && priceMatch && dateMatch && searchMatch;
    }).toList();

    isFilterVisible.value = false;
  }

  void resetFilters() {
    selectedCategories.clear();
    selectedMinPrice.value = '0';
    selectedMaxPrice.value = '0';
    startDate.value = null;
    endDate.value = null;
    searchQuery.value = '';
    searchController.clear();

    filteredAssets.value = List.from(assets);
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

  void setMinPrice(String price) {
    selectedMinPrice.value = price;
  }

  void setMaxPrice(String price) {
    selectedMaxPrice.value = price;
  }

  void resetPriceFilter() {
    selectedMinPrice.value = '0';
    selectedMaxPrice.value = '0';
  }

  void resetDateFilter() {
    startDate.value = null;
    endDate.value = null;
  }

  void showDateRangeDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Pilih Rentang Tanggal'),
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

  void showSearchDialog() {
    final searchController = TextEditingController(text: searchQuery.value);

    Get.dialog(
      AlertDialog(
        title: Text('Cari Aset'),
        content: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Masukkan kata kunci',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            searchQuery.value = value;
            if (value.isNotEmpty) {
              applyFilters();
            } else {
              filteredAssets.value = List.from(assets);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              searchQuery.value = '';
              filteredAssets.value = List.from(assets);
              Get.back();
            },
            child: Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              applyFilters();
            },
            child: Text('Cari'),
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

  String getPriceRangeText() {
    String minText = selectedMinPrice.value == '0'
        ? 'Min'
        : formatCurrency(double.parse(selectedMinPrice.value));

    String maxText = selectedMaxPrice.value == '0'
        ? 'Max'
        : formatCurrency(double.parse(selectedMaxPrice.value));

    return '$minText - $maxText';
  }

  String getDateRangeText() {
    if (startDate.value == null && endDate.value == null) {
      return 'Pilih rentang tanggal';
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
        selectedMinPrice.value != '0' ||
        selectedMaxPrice.value != '0' ||
        hasDateFilter() ||
        searchQuery.value.isNotEmpty;
  }

  void navigateToAssetDetail(Map<String, dynamic> asset) {
    Get.toNamed(Routes.ASET_DETAIL, arguments: asset['no']);
  }

  void navigateToAddAsset() {
    Get.toNamed(Routes.ASET_TAMBAH);
  }
}
