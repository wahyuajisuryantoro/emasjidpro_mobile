import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:emasjid_pro/app/helpers/currency_formatter.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class KasDanBankTambahController extends GetxController {
  // Form controllers
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  
  // Dropdown options
  final sourceAccounts = <String>[
    'Kas di Tangan',
    'Bank BCA',
    'Bank Syariah Indonesia',
    'Bank Mandiri',
    'Lainnya',
  ];
  
  final destinationAccounts = <String>[
    'Kas di Tangan',
    'Bank BCA',
    'Bank Syariah Indonesia',
    'Bank Mandiri',
    'Lainnya',
  ];
  
  final transactionTypes = <String>[
    'Transfer',
    'Setoran',
    'Penarikan',
    'Lainnya',
  ];
  
  // Selected values
  final selectedDate = DateFormat('dd MMMM yyyy').format(DateTime.now()).obs;
  final selectedSourceAccount = 'Kas di Tangan'.obs;
  final selectedDestinationAccount = 'Bank BCA'.obs;
  final selectedTransactionType = 'Transfer'.obs;
  
  // Attachment details
  final hasAttachment = false.obs;
  final attachmentName = ''.obs;
  final attachmentSize = ''.obs;
  File? attachmentFile;
  
  // Currency formatter
  final currencyFormatter = CurrencyInputFormatter();
  
  // Select date function
  void selectDate(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            height: 350,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: AppResponsive.padding(all: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Pilih Tanggal',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: SfDateRangePicker(
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: AppColors.white,
                      textStyle: TextStyle(color: AppColors.dark),
                    ),
                    selectionColor: AppColors.primary,
                    todayHighlightColor: AppColors.primary,
                    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                      if (args.value is DateTime) {
                        Navigator.pop(context);
                        final DateFormat formatter = DateFormat('dd MMMM yyyy', 'id_ID');
                        selectedDate.value = formatter.format(args.value);
                      }
                    },
                  ),
                ),
                Container(
                  padding: AppResponsive.padding(all: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Batal'),
                      ),
                      SizedBox(width: AppResponsive.w(2)),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text('Pilih', style: TextStyle(color: AppColors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Pick file function
  void pickFile() async {
    // Simulasi pemilihan file
    await Future.delayed(const Duration(seconds: 1));
    
    // Update detail lampiran
    hasAttachment.value = true;
    attachmentName.value = 'Bukti-Transaksi.pdf';
    attachmentSize.value = '2.3 MB';
  }
  
  // Remove attachment function
  void removeAttachment() {
    hasAttachment.value = false;
    attachmentName.value = '';
    attachmentSize.value = '';
    attachmentFile = null;
  }
  
  // Save transaction function
  void saveTransaction() {
    // Validasi input
    if (descriptionController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Keterangan transaksi harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    if (amountController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nominal transaksi harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }
    
    // Simulasi proses penyimpanan data
    Get.snackbar(
      'Berhasil',
      'Transaksi berhasil disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
    
    // Kembali ke halaman sebelumnya
    Future.delayed(const Duration(seconds: 1), () {
      Get.back(result: {
        'success': true,
        'amount': _extractAmount(amountController.text),
        'description': descriptionController.text,
        'date': selectedDate.value,
        'source': selectedSourceAccount.value,
        'destination': selectedDestinationAccount.value,
        'type': selectedTransactionType.value
      });
    });
  }
  
  // Ekstrak nilai numerik dari string mata uang
  double _extractAmount(String amount) {
    String numericString = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return 0;
    return double.parse(numericString);
  }
  
  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}