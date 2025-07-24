import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class KasDanBankDashboardController extends GetxController {
  final RxList accounts = [].obs;

  final RxList transactions = [].obs;

  RxDouble totalBalance = 0.0.obs;

  final StorageService storageService = StorageService();

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccountsAndTransactions();
  }

  void loadAccountsAndTransactions() async {
    isLoading.value = true;

    try {
      String? token = storageService.getToken();

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/dashboard-kasdanbank'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          accounts.value = data['data']['accounts'];
          totalBalance.value = data['data']['totalBalance'].toDouble();
          transactions.value = data['data']['transactions'];
        } else {
          Get.snackbar('Error', 'Gagal memuat data');
        }
      } else {
        Get.snackbar('Error', 'Gagal terhubung ke server');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToAddTransaction() {
    Get.toNamed(Routes.KAS_DAN_BANK_TAMBAH);
  }

  String formatCurrency(dynamic amount) {
    double value = 0.0;

    if (amount is double) {
      value = amount;
    } else if (amount is int) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    }

    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
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
