import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/modules/akun_keuangan/akun_dashboard/controllers/akun_dashboard_controller.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AkunKeuanganTambahController extends GetxController {
  final kodeController = TextEditingController();
  final namaController = TextEditingController();
  final saldoAwalController = TextEditingController();
  final deskripsiController = TextEditingController();

  final RxList<Map<String, dynamic>> kategoriOptions =
      <Map<String, dynamic>>[].obs;
  final RxString selectedKategoriCode = ''.obs;
  final RxString selectedKategoriName = ''.obs;
  final RxBool isCashAndBank = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingCategories = false.obs;

  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    loadCategories();

    // Auto-generate kode saat kategori berubah
    ever(selectedKategoriCode, (String code) {
      if (code.isNotEmpty) {
        generateNextCode(code);
      }
    });
  }

  void loadCategories() async {
    try {
      isLoadingCategories.value = true;

      final token = await _storageService.getToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Token tidak ditemukan, silakan login ulang',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
          colorText: Colors.white,
        );
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/akun-keuangan/categories'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          kategoriOptions.value = List<Map<String, dynamic>>.from(
              responseData['data'].map((item) => {
                    'code': item['code'],
                    'name': item['name'],
                    'type': item['type'],
                  }));

          // Set default kategori pertama
          if (kategoriOptions.isNotEmpty) {
            final firstCategory = kategoriOptions.first;
            selectedKategoriCode.value = firstCategory['code'];
            selectedKategoriName.value = firstCategory['name'];
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat kategori: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void generateNextCode(String categoryCode) async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return;

      // Ambil akun terakhir untuk kategori ini
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/akun-keuangan'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final accounts = responseData['data']['accounts'];

          // Cari akun dengan kategori yang sama
          List<String> existingCodes = [];

          switch (categoryCode) {
            case '1':
              existingCodes = List<String>.from(
                  accounts['aktiva_lancar'].map((acc) => acc['kode']));
              break;
            case '2':
              existingCodes = List<String>.from(
                  accounts['aktiva_tetap'].map((acc) => acc['kode']));
              break;
            case '3':
              existingCodes = List<String>.from(
                  accounts['kewajiban'].map((acc) => acc['kode']));
              break;
            case '4':
              existingCodes = List<String>.from(
                  accounts['saldo'].map((acc) => acc['kode']));
              break;
            case '5':
              existingCodes = List<String>.from(
                  accounts['pendapatan'].map((acc) => acc['kode']));
              break;
            case '6':
              existingCodes = List<String>.from(
                  accounts['beban'].map((acc) => acc['kode']));
              break;
          }

          // Generate kode berikutnya
          int nextNumber = 1;
          String nextCode = '';

          do {
            nextCode = '$categoryCode${nextNumber.toString().padLeft(2, '0')}';
            nextNumber++;
          } while (existingCodes.contains(nextCode) && nextNumber <= 99);

          kodeController.text = nextCode;
        }
      }
    } catch (e) {
      print('Error generating code: $e');
    }
  }

  void onKategoriChanged(String? value) {
    if (value != null) {
      final category =
          kategoriOptions.firstWhere((cat) => cat['code'] == value);
      selectedKategoriCode.value = category['code'];
      selectedKategoriName.value = category['name'];

      // Reset cash and bank jika bukan Aktiva Lancar
      if (value != '1') {
        isCashAndBank.value = false;
      }
    }
  }

  void saveAccount() async {
    // Validasi input
    if (selectedKategoriCode.value.isEmpty) {
      _showError('Kategori akun harus dipilih');
      return;
    }

    if (kodeController.text.isEmpty) {
      _showError('Kode akun harus diisi');
      return;
    }

    if (namaController.text.isEmpty) {
      _showError('Nama akun harus diisi');
      return;
    }

    // Validasi prefix kode
    if (!kodeController.text.startsWith(selectedKategoriCode.value)) {
      _showError(
          'Kode akun harus diawali dengan ${selectedKategoriCode.value}');
      return;
    }

    final saldoAwal = _extractAmount(saldoAwalController.text);

    try {
      isLoading.value = true;

      final token = await _storageService.getToken();
      if (token == null) {
        _showError('Token tidak ditemukan, silakan login ulang');
        return;
      }

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/akun-keuangan'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'code': kodeController.text,
          'code_account_category': selectedKategoriCode.value,
          'name': namaController.text,
          'balance': saldoAwal.toInt(),
          'cash_and_bank': isCashAndBank.value ? '1' : '0',
          'description': deskripsiController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          Get.snackbar(
            'Berhasil',
            'Akun keuangan berhasil ditambahkan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Get.until((route) =>
                route.settings.name?.contains('akun-dashboard') == true);
            if (Get.isRegistered<AkunDashboardController>()) {
              Get.find<AkunDashboardController>().loadAccounts();
            }
          });
        } else {
          _showError(responseData['message'] ?? 'Gagal menambahkan akun');
        }
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        String errorMessage = errorData['message'] ?? 'Data tidak valid';

        if (errorData['error_type'] == 'invalid_code_prefix') {
          errorMessage =
              'Kode akun harus diawali dengan ${selectedKategoriCode.value}';
        } else if (errorData['error_type'] == 'code_already_exists') {
          errorMessage = 'Kode akun sudah digunakan, silakan gunakan kode lain';
        } else if (errorData['error_type'] == 'invalid_cash_and_bank') {
          errorMessage = 'Cash and Bank hanya berlaku untuk Aktiva Lancar';
        }

        _showError(errorMessage);
      } else {
        _showError('Server error (${response.statusCode})');
      }
    } catch (e) {
      _showError('Gagal menambahkan akun');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Gagal',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  int _extractAmount(String amount) {
    String numericString = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return 0;
    return int.parse(numericString);
  }

  @override
  void onClose() {
    kodeController.dispose();
    namaController.dispose();
    saldoAwalController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }
}
