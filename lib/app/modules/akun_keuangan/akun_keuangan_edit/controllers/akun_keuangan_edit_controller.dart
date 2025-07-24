import 'package:emasjid_pro/app/models/AkunKeuanganModel.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AkunKeuanganEditController extends GetxController {
  late AkunKeuanganModel originalAccount;

  final kodeController = TextEditingController();
  final namaController = TextEditingController();
  final saldoController = TextEditingController();

  final kategoriOptions = <String>[
    'Aktiva Lancar',
    'Aktiva Tetap',
    'Kewajiban',
  ];

  final selectedKategori = ''.obs;

  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments is AkunKeuanganModel) {
      originalAccount = Get.arguments as AkunKeuanganModel;

      kodeController.text = originalAccount.kode;
      namaController.text = originalAccount.nama;
      selectedKategori.value = originalAccount.kategori;
      saldoController.text = _formatCurrency(originalAccount.saldo);
    } else {
      Get.snackbar(
        'Error',
        'Data akun tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      Future.delayed(Duration(seconds: 1), () => Get.back());
    }
  }

  String _formatCurrency(double amount) {
    String formatted = currencyFormatter.format(amount);
    return formatted.replaceAll(currencyFormatter.currencySymbol, '').trim();
  }

  double _extractAmount(String amount) {
    String numericString = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return 0;
    return double.parse(numericString);
  }

  void updateAccount() {
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

    final saldo = _extractAmount(saldoController.text);

    final updatedAccount = AkunKeuanganModel(
      kode: kodeController.text,
      nama: namaController.text,
      kategori: selectedKategori.value,
      saldo: saldo,
    );

    Get.snackbar(
      'Berhasil',
      'Akun berhasil diperbarui',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );

    Future.delayed(const Duration(seconds: 1), () {
      Get.back(result: {
        'success': true,
        'action': 'update',
        'account': updatedAccount,
      });
    });
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah Anda yakin ingin menghapus akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: TextStyle(color: AppColors.dark),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();

              Get.snackbar(
                'Berhasil',
                'Akun berhasil dihapus',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );

              Future.delayed(const Duration(seconds: 1), () {
                Get.back(result: {
                  'success': true,
                  'action': 'delete',
                  'account': originalAccount,
                });
              });
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    kodeController.dispose();
    namaController.dispose();
    saldoController.dispose();
    super.onClose();
  }
}
