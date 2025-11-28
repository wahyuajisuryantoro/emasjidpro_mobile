import 'dart:io';
import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/modules/home/controllers/home_controller.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class PengeluaranTransaksiController extends GetxController {
  final StorageService storage = Get.find<StorageService>();
  final ScrollController scrollController = ScrollController();

  final namaController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  Rx<File?> attachmentFile = Rx<File?>(null);

  final isLoading = false.obs;

  final sourceAccounts = <Map<String, dynamic>>[].obs;
  final destinationAccounts = <Map<String, dynamic>>[].obs;

  final selectedDate = DateTime.now().obs;
  final selectedSourceAccount = Rxn<Map<String, dynamic>>();
  final selectedDestinationAccount = Rxn<Map<String, dynamic>>();

  final hasAttachment = false.obs;
  final attachmentName = ''.obs;
  final attachmentSize = ''.obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  void resetFormAndScrollToTop() {
    namaController.clear();
    descriptionController.clear();
    amountController.clear();
    selectedDate.value = DateTime.now();
    if (sourceAccounts.isNotEmpty) {
      selectedSourceAccount.value = sourceAccounts[0];
    }
    if (destinationAccounts.isNotEmpty) {
      selectedDestinationAccount.value = destinationAccounts[0];
    }
    removeAttachment();
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> fetchAccounts() async {
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
        Uri.parse('${BaseUrl.baseUrl}/accounts-pengeluaran'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          sourceAccounts.value =
              List<Map<String, dynamic>>.from(data['source_accounts']);
          if (sourceAccounts.isNotEmpty) {
            selectedSourceAccount.value = sourceAccounts[0];
          }

          destinationAccounts.value =
              List<Map<String, dynamic>>.from(data['related_accounts']);
          if (destinationAccounts.isNotEmpty) {
            selectedDestinationAccount.value = destinationAccounts[0];
          }
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to load accounts data');
        }
      } else {
        throw Exception(
            'Failed to load accounts data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load accounts data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
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
            primaryColor: const Color(0xFFFF0000),
            colorScheme: const ColorScheme.light(
                primary: Color(0xFFFF0000)),
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

  Future<void> saveTransaction() async {
    try {
      if (namaController.text.isEmpty) {
        Get.snackbar(
          'Gagal',
          'Nama transaksi harus diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

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
          'Nominal transaksi harus diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedSourceAccount.value == null) {
        Get.snackbar(
          'Gagal',
          'Sumber dana harus dipilih',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedDestinationAccount.value == null) {
        Get.snackbar(
          'Gagal',
          'Kategori pengeluaran harus dipilih',
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

      final uri = Uri.parse('${BaseUrl.baseUrl}/transaksi-pengeluaran');

      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      final rawAmount = amountController.text
          .replaceAll('Rp ', '')
          .replaceAll('.', '')
          .trim();

      request.fields['date_transaction'] = formattedSelectedDateForApi;
      request.fields['name'] = namaController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['value'] = rawAmount;
      request.fields['account'] = selectedSourceAccount.value!['code'];
      request.fields['account_related'] =
          selectedDestinationAccount.value!['code'];

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
            'Transaksi berhasil disimpan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshNotificationCount();
          }

          Future.delayed(const Duration(milliseconds: 500), () {
            Get.offAndToNamed(Routes.PENGELUARAN_RIWAYAT, result: 'refresh');
          });
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal menyimpan transaksi');
        }
      } else {
        var errorMessage =
            'Gagal menyimpan transaksi. Status code: ${response.statusCode}';
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
        'Gagal menyimpan transaksi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  @override
  void onClose() {
    namaController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
