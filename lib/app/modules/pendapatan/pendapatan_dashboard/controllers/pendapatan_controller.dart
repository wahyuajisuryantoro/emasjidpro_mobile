import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/modules/pendapatan/pendapatan_dashboard/models/dashboard_pendapatan_model.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:intl/intl.dart';

class PendapatanController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final isLoading = false.obs;
  final monthlyIncome = "Rp 0".obs;
  final yearlyIncome = "Rp 0".obs;
  final totalIncome = "Rp 0".obs;

  final dashboardData = Rxn<DashboardPendapatanModel>();
  final incomeCategories = <KategoriTransaksi>[].obs;
  final recentTransactions = <TransaksiItem>[].obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
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
        Uri.parse('${BaseUrl.baseUrl}/dashboard-pendapatan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];
          dashboardData.value = DashboardPendapatanModel.fromJson(data);
          monthlyIncome.value =
              dashboardData.value?.saldo.formattedBulanan ?? "Rp 0";
          yearlyIncome.value =
              dashboardData.value?.saldo.formattedTahunan ?? "Rp 0";
          totalIncome.value = dashboardData
                  .value?.ringkasanTransaksi.formattedTotalPendapatan ??
              "Rp 0";
          incomeCategories.value = dashboardData
                  .value?.ringkasanTransaksi.kategoriTransaksi
                  .where((category) => category.status == 'debit')
                  .toList() ??
              [];

          if (incomeCategories.isEmpty) {}

          recentTransactions.value =
              dashboardData.value?.riwayatTransaksi ?? [];
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
        'Terjadi Kesalahan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    await fetchDashboardData();
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
}
