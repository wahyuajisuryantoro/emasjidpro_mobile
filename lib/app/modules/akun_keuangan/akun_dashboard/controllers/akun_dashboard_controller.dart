import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/models/AkunKeuanganModel.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:http/http.dart' as http;

class AkunDashboardController extends GetxController {
  final RxList<AkunKeuanganModel> aktivaLancar = <AkunKeuanganModel>[].obs;
  final RxList<AkunKeuanganModel> aktivaTetap = <AkunKeuanganModel>[].obs;
  final RxList<AkunKeuanganModel> kewajiban = <AkunKeuanganModel>[].obs;
  final RxList<AkunKeuanganModel> saldo = <AkunKeuanganModel>[].obs;
  final RxList<AkunKeuanganModel> pendapatan = <AkunKeuanganModel>[].obs;
  final RxList<AkunKeuanganModel> beban = <AkunKeuanganModel>[].obs;

  final RxDouble totalAktivaLancar = 0.0.obs;
  final RxDouble totalAktivaTetap = 0.0.obs;
  final RxDouble totalKewajiban = 0.0.obs;
  final RxDouble totalSaldo = 0.0.obs;
  final RxDouble totalPendapatan = 0.0.obs;
  final RxDouble totalBeban = 0.0.obs;

  final RxBool isLoading = false.obs;
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  void loadAccounts() async {
    try {
      isLoading.value = true;
      
      final token = await _storageService.getToken();
      
      if (token == null) {
        Get.snackbar(
          'Error',
          'Token tidak ditemukan, silakan login ulang',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/akun-keuangan'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == 'success') {
          final data = responseData['data'];
          
          // Parse data akun
          aktivaLancar.value = _parseAccountList(data['accounts']['aktiva_lancar']);
          aktivaTetap.value = _parseAccountList(data['accounts']['aktiva_tetap']);
          kewajiban.value = _parseAccountList(data['accounts']['kewajiban']);
          saldo.value = _parseAccountList(data['accounts']['saldo']);
          pendapatan.value = _parseAccountList(data['accounts']['pendapatan']);
          beban.value = _parseAccountList(data['accounts']['beban']);

          // Set totals
          totalAktivaLancar.value = data['totals']['total_aktiva_lancar'].toDouble();
          totalAktivaTetap.value = data['totals']['total_aktiva_tetap'].toDouble();
          totalKewajiban.value = data['totals']['total_kewajiban'].toDouble();
          totalSaldo.value = data['totals']['total_saldo'].toDouble();
          totalPendapatan.value = data['totals']['total_pendapatan'].toDouble();
          totalBeban.value = data['totals']['total_beban'].toDouble();

        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Gagal mengambil data',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      } else if (response.statusCode == 401) {
        Get.snackbar(
          'Error',
          'Unauthorized - Token tidak valid',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Server error (${response.statusCode})',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('Error loading accounts: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data akun keuangan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<AkunKeuanganModel> _parseAccountList(List<dynamic> accountList) {
    return accountList.map((account) => AkunKeuanganModel(
      no: account['no'],
      kode: account['kode'],
      nama: account['nama'],
      kategori: account['kategori'],
      saldo: account['saldo'].toDouble(),
      type: account['type'],
      cashAndBank: account['cash_and_bank'] == '1',
    )).toList();
  }

  void navigateToAddAccount() {
    Get.toNamed(Routes.AKUN_KEUANGAN_TAMBAH);
  }

  void navigateToEditAccount(AkunKeuanganModel account) {
    Get.toNamed(Routes.AKUN_KEUANGAN_EDIT, arguments: account);
  }

  String formatCurrency(double amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }
}