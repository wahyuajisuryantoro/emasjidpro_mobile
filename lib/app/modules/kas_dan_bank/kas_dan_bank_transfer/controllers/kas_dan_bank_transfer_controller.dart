import 'dart:io';
import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/modules/home/controllers/home_controller.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class KasDanBankTransferController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  Rx<File?> attachmentFile = Rx<File?>(null);

  final isLoading = false.obs;

  final allBankAccounts = <Map<String, dynamic>>[].obs;
  final sourceBankAccounts = <Map<String, dynamic>>[].obs;
  final destinationBankAccounts = <Map<String, dynamic>>[].obs;

  final selectedDate = DateTime.now().obs;
  final selectedSourceBank = Rxn<Map<String, dynamic>>();
  final selectedDestinationBank = Rxn<Map<String, dynamic>>();

  final hasAttachment = false.obs;
  final attachmentName = ''.obs;
  final attachmentSize = ''.obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  Future<void> fetchBankAccounts() async {
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
        Uri.parse('${BaseUrl.baseUrl}/bank-accounts-transfer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          allBankAccounts.value =
              List<Map<String, dynamic>>.from(data['bank_accounts']);

          sourceBankAccounts.value = allBankAccounts
              .where((account) => (account['can_transfer_from'] == true))
              .toList();

          selectedSourceBank.value = null;
          selectedDestinationBank.value = null;
          destinationBankAccounts.clear();
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to load bank accounts data');
        }
      } else {
        throw Exception(
            'Failed to load bank accounts data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load bank accounts data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void onSourceBankChanged(Map<String, dynamic>? sourceBank) {
    selectedSourceBank.value = sourceBank;
    selectedDestinationBank.value = null;

    if (sourceBank != null) {
      destinationBankAccounts.value = allBankAccounts
          .where((account) => account['code'] != sourceBank['code'])
          .toList();
    } else {
      destinationBankAccounts.clear();
    }
  }

  double get maxTransferAmount {
    if (selectedSourceBank.value != null) {
      return selectedSourceBank.value!['balance']?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      selectedDate.value = picked;
    }
  }

  String get formattedSelectedDate =>
      DateFormat('dd MMMM yyyy').format(selectedDate.value);

  String get formattedSelectedDateForApi =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate.value);

  void pickFile() async {
    try {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        final documentsStatus =
            await Permission.manageExternalStorage.request();

        if (photosStatus.isDenied && documentsStatus.isDenied) {
          final storageStatus = await Permission.storage.request();
          if (storageStatus.isDenied) {
            Get.snackbar(
              'Permission Required',
              'Storage permission is required to select files. Please grant permission in app settings.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }
        }
      }
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);

        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          Get.snackbar(
            'File Size Limit',
            'File size exceeds 5MB limit',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        final allowedExtensions = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
        final fileExtension = file.path.split('.').last.toLowerCase();

        if (!allowedExtensions.contains(fileExtension)) {
          Get.snackbar(
            'Unsupported File Type',
            'File type not supported. Please select: ${allowedExtensions.join(", ")}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
        attachmentFile.value = file;
        hasAttachment.value = true;
        attachmentName.value = result.files.single.name;
        attachmentSize.value =
            '${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB';
      }
    } catch (e) {
      print('File picker error: $e');
      Get.snackbar(
        'Error',
        'An error occurred while picking the file.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeAttachment() {
    hasAttachment.value = false;
    attachmentName.value = '';
    attachmentSize.value = '';
    attachmentFile.value = null;
  }

  Future<void> saveTransfer() async {
    try {
      if (descriptionController.text.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Keterangan transaksi harus diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (amountController.text.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Nominal transfer harus diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedSourceBank.value == null) {
        Get.snackbar(
          'Gagal',
          'Bank sumber harus dipilih',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedDestinationBank.value == null) {
        Get.snackbar(
          'Gagal',
          'Bank tujuan harus dipilih',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final requestAmount = double.tryParse(amountController.text
              .replaceAll('Rp ', '')
              .replaceAll('.', '')
              .trim()) ??
          0;

      if (requestAmount > maxTransferAmount) {
        Get.snackbar(
          'Gagal',
          'Nominal transfer melebihi saldo bank sumber (Rp ${_formatCurrency(maxTransferAmount)})',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (requestAmount <= 0) {
        Get.snackbar(
          'Gagal',
          'Nominal transfer harus lebih dari 0',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading(true);

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final uri = Uri.parse('${BaseUrl.baseUrl}/transfer-kasdanbank');

      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      final rawAmount = amountController.text
          .replaceAll('Rp ', '')
          .replaceAll('.', '')
          .trim();

      request.fields['date_transaction'] = formattedSelectedDateForApi;
      request.fields['from_bank_code'] = selectedSourceBank.value!['code'];
      request.fields['to_bank_code'] = selectedDestinationBank.value!['code'];
      request.fields['description'] = descriptionController.text;
      request.fields['value'] = rawAmount;

      if (attachmentFile.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'picture',
            attachmentFile.value!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          Get.snackbar(
            'Berhasil',
            'Transfer berhasil disimpan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF40A578),
            colorText: Colors.white,
          );
           if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshNotificationCount();
          }
          Future.delayed(const Duration(seconds: 2), () {
            Get.back(result: true);
          });
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal menyimpan transfer');
        }
      } else {
        var errorMessage =
            'Gagal menyimpan transfer. Status code: ${response.statusCode}';
        try {
          final errorData = json.decode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan transfer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    final value =
        amount is String ? double.tryParse(amount) ?? 0 : amount.toDouble();
    return value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  void onInit() {
    super.onInit();
    fetchBankAccounts();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
