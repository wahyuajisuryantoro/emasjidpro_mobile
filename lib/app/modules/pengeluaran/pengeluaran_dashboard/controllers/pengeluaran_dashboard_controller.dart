import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:intl/intl.dart';

class PengeluaranDashboardController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final yearlyExpense = 'Rp 0'.obs;
  final monthlyExpense = 'Rp 0'.obs;
  final totalPengeluaran = 'Rp 0'.obs;

  final isLoading = false.obs;

  final expenseCategories = <Map<String, dynamic>>[].obs;
  final recentTransactions = <Map<String, dynamic>>[].obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  String formatCurrency(int amount) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(amount);
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> fetchDashboardData() async {
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

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/dashboard-pengeluaran'),
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

          monthlyExpense.value =
              data['pengeluaran']['formatted_bulanan'] ?? 'Rp 0';
          yearlyExpense.value =
              data['pengeluaran']['formatted_tahunan'] ?? 'Rp 0';

          final categories = <Map<String, dynamic>>[];
          if (data['ringkasan_transaksi']['kategori_transaksi'] != null) {
            for (var category in data['ringkasan_transaksi']
                ['kategori_transaksi']) {
              categories.add({
                'title': category['nama_kategori'],
                'amount': formatCurrency(
                    int.parse(category['total_value'].toString())),
                'total_value': int.parse(category['total_value'].toString()),
              });
            }
          }
          expenseCategories.value = categories;

          totalPengeluaran.value = data['ringkasan_transaksi']
                  ['formatted_total_pengeluaran'] ??
              'Rp 0';

          final transactions = <Map<String, dynamic>>[];
          if (data['riwayat_transaksi'] != null) {
            for (var transaction in data['riwayat_transaksi']) {
              transactions.add({
                'date': transaction['tanggal'],
                'title': transaction['judul_transaksi'],
                'amount': transaction['formatted_amount'] ??
                    formatCurrency(transaction['amount']),
                'isIncome': transaction['isIncome'] ?? false,
              });
            }
          }
          recentTransactions.value = transactions;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to load dashboard data');
        }
      } else {
        throw Exception(
            'Failed to load dashboard data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      monthlyExpense.value = 'Rp 0';
      yearlyExpense.value = 'Rp 0';
      totalPengeluaran.value = 'Rp 0';
      expenseCategories.clear();
      recentTransactions.clear();
    } finally {
      isLoading(false);
    }
  }

  void refreshData() {
    fetchDashboardData();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  @override
  void onReady() {
    super.onReady();
    if (expenseCategories.isEmpty || recentTransactions.isEmpty) {
      fetchDashboardData();
    }
  }
}
