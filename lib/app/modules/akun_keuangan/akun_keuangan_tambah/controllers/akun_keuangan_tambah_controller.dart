import 'package:emasjid_pro/app/helpers/currency_formatter.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AkunKeuanganTambahController extends GetxController {
  final kodeController = TextEditingController();
  final namaController = TextEditingController();
  final saldoAwalController = TextEditingController();

  final kategoriOptions = <String>[
    'Aktiva Lancar',
    'Aktiva Tetap',
    'Kewajiban',
  ];

  final selectedKategori = 'Aktiva Lancar'.obs;

  final currencyFormatter = CurrencyInputFormatter();

  void saveAccount() {
    if (kodeController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Kode akun harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (namaController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nama akun harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    final saldoAwal = _extractAmount(saldoAwalController.text);

    Get.snackbar(
      'Berhasil',
      'Akun berhasil disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );

    Future.delayed(const Duration(seconds: 1), () {
      Get.back(result: {
        'success': true,
        'kode': kodeController.text,
        'nama': namaController.text,
        'kategori': selectedKategori.value,
        'saldo': saldoAwal,
      });
    });
  }

  double _extractAmount(String amount) {
    String numericString = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return 0;
    return double.parse(numericString);
  }

  @override
  void onClose() {
    kodeController.dispose();
    namaController.dispose();
    saldoAwalController.dispose();
    super.onClose();
  }
}
