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

class KasDanBankDaftarController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final searchController = TextEditingController();
  final isSearchVisible = false.obs;

  final isLoading = true.obs;

  final selectedPeriod = 'Bulan Ini'.obs;
  final sortKey = 'newest'.obs;
  final sortLabel = 'Terbaru'.obs;

  final selectedType = 'Semua'.obs;

  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;

  final allTransactions = <Map<String, dynamic>>[].obs;
  final filteredTransactions = <Map<String, dynamic>>[].obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  Future<void> fetchAllDataKasDanBank() async {
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

      final uri = Uri.parse('${BaseUrl.baseUrl}/all-kasdanbank');

      final response = await http.get(
        uri,
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
          allTransactions.value =
              List<Map<String, dynamic>>.from(data['transactions']);
          applyFilters();
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal memuat data kas dan bank');
        }
      } else {
        throw Exception(
            'Gagal memuat data kas dan bank. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi Kesalahan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      allTransactions.clear();
      filteredTransactions.clear();
    } finally {
      isLoading(false);
    }
  }

  void applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(allTransactions);

    // Filter by search text
    if (searchController.text.isNotEmpty) {
      final searchText = searchController.text.toLowerCase();
      filtered = filtered.where((transaction) {
        final description =
            (transaction['description'] ?? '').toString().toLowerCase();
        final fromAccount = (transaction['from_account']?['name'] ?? '')
            .toString()
            .toLowerCase();
        final toAccount =
            (transaction['to_account']?['name'] ?? '').toString().toLowerCase();
        final amount =
            (transaction['formatted_amount'] ?? '').toString().toLowerCase();

        return description.contains(searchText) ||
            fromAccount.contains(searchText) ||
            toAccount.contains(searchText) ||
            amount.contains(searchText);
      }).toList();
    }

    // Filter by period
    if (selectedPeriod.value != 'Semua Waktu') {
      DateTime now = DateTime.now();
      DateTime filterStart;
      DateTime filterEnd = now;

      switch (selectedPeriod.value) {
        case 'Hari Ini':
          filterStart = DateTime(now.year, now.month, now.day);
          filterEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'Minggu Ini':
          int daysFromMonday = now.weekday - 1;
          filterStart = DateTime(now.year, now.month, now.day - daysFromMonday);
          break;
        case 'Bulan Ini':
          filterStart = DateTime(now.year, now.month, 1);
          break;
        case 'Tahun Ini':
          filterStart = DateTime(now.year, 1, 1);
          break;
        default:
          if (selectedPeriod.value.contains('-')) {
            // Custom date range
            filterStart = startDate.value;
            filterEnd = endDate.value;
          } else {
            filterStart = DateTime(2000); // Very old date
          }
      }

      if (selectedPeriod.value != 'Semua Waktu') {
        filtered = filtered.where((transaction) {
          try {
            DateTime transactionDate =
                DateFormat('yyyy-MM-dd').parse(transaction['date']);
            return transactionDate
                    .isAfter(filterStart.subtract(Duration(days: 1))) &&
                transactionDate.isBefore(filterEnd.add(Duration(days: 1)));
          } catch (e) {
            return false;
          }
        }).toList();
      }

      if (selectedType.value != 'Semua') {
        filtered = filtered.where((transaction) {
          final type = transaction['type'] ?? '';
          return type == selectedType.value.toLowerCase();
        }).toList();
      }
    }

    // Apply sorting
    switch (sortKey.value) {
      case 'newest':
        filtered.sort((a, b) {
          try {
            DateTime dateA = DateFormat('yyyy-MM-dd').parse(a['date']);
            DateTime dateB = DateFormat('yyyy-MM-dd').parse(b['date']);
            return dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });
        break;
      case 'oldest':
        filtered.sort((a, b) {
          try {
            DateTime dateA = DateFormat('yyyy-MM-dd').parse(a['date']);
            DateTime dateB = DateFormat('yyyy-MM-dd').parse(b['date']);
            return dateA.compareTo(dateB);
          } catch (e) {
            return 0;
          }
        });
        break;
      case 'highest':
        filtered.sort((a, b) {
          double amountA = (a['amount'] ?? 0).toDouble();
          double amountB = (b['amount'] ?? 0).toDouble();
          return amountB.compareTo(amountA);
        });
        break;
      case 'lowest':
        filtered.sort((a, b) {
          double amountA = (a['amount'] ?? 0).toDouble();
          double amountB = (b['amount'] ?? 0).toDouble();
          return amountA.compareTo(amountB);
        });
        break;
      case 'code_asc':
        filtered.sort((a, b) {
          String codeA = (a['code'] ?? '').toString();
          String codeB = (b['code'] ?? '').toString();
          return codeA.compareTo(codeB);
        });
        break;
      case 'code_desc':
        filtered.sort((a, b) {
          String codeA = (a['code'] ?? '').toString();
          String codeB = (b['code'] ?? '').toString();
          return codeB.compareTo(codeA);
        });
        break;
    }

    filteredTransactions.value = filtered;
  }

  void toggleSearchBar() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      searchController.clear();
      applyFilters();
    }
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      applyFilters();
    });
  }

  Timer? _debounce;

  void setSelectedPeriod(String period) {
    selectedPeriod.value = period;
    applyFilters();
  }

  void setSortOption(String key, String label) {
    sortKey.value = key;
    sortLabel.value = label;
    applyFilters();
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

      applyFilters();
    }
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
              _buildDetailRow('Kode', transaction['code']),
              _buildDetailRow('Tanggal', transaction['date']),
              _buildDetailRow(
                  'Dari Akun', transaction['from_account']?['name'] ?? '-'),
              _buildDetailRow(
                  'Ke Akun', transaction['to_account']?['name'] ?? '-'),
              _buildDetailRow(
                  'Jumlah',
                  transaction['formatted_amount'] ??
                      transaction['amount'].toString()),
              _buildDetailRow('Deskripsi', transaction['description']),
              _buildDetailRow(
                  'Tipe', getTransactionTypeLabel(transaction['type'])),
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

  void setSelectedType(String type) {
    selectedType.value = type;
    applyFilters();
  }

  String getTransactionTypeLabel(String type) {
    switch (type) {
      case 'setor':
        return 'Setor Kas';
      case 'tarik':
        return 'Tarik Dana';
      case 'transfer':
        return 'Transfer';
      default:
        return 'Lainnya';
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAllDataKasDanBank();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
