// PiutangTambahController.dart
import 'dart:convert';
import 'dart:io';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/modules/home/controllers/home_controller.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emasjid_pro/app/helpers/currency_formatter.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class PiutangTambahController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  // State loading
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Selected values
  final selectedDate = DateTime.now().obs;
  final formattedSelectedDate =
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()).obs;
  final selectedDueDate = DateTime.now().add(const Duration(days: 30)).obs;
  final formattedSelectedDueDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID')
      .format(DateTime.now().add(const Duration(days: 30)))
      .obs;

  // Accounts
  final sourceAccounts = <Map<String, dynamic>>[].obs;
  final relatedAccounts = <Map<String, dynamic>>[].obs;
  final selectedSourceAccount = Rxn<Map<String, dynamic>>();
  final selectedRelatedAccount = Rxn<Map<String, dynamic>>();

  // Attachment details
  final hasAttachment = false.obs;
  final attachmentName = ''.obs;
  final attachmentSize = ''.obs;
  Rx<File?> attachmentFile = Rx<File?>(null);

  // Currency formatter
  final currencyFormatter = CurrencyInputFormatter();

  // Initialize AppResponsive
  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  // Fetch accounts data
  Future<void> fetchAccounts() async {
    try {
      isLoading(true);

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/accounts-piutang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];

          // Parse source accounts (akun piutang)
          sourceAccounts.value =
              List<Map<String, dynamic>>.from(data['source_accounts'] ?? []);
          if (sourceAccounts.isNotEmpty) {
            selectedSourceAccount.value = sourceAccounts[0];
          }

          // Parse related accounts (kas/bank tujuan)
          relatedAccounts.value =
              List<Map<String, dynamic>>.from(data['related_accounts'] ?? []);
          if (relatedAccounts.isNotEmpty) {
            selectedRelatedAccount.value = relatedAccounts[0];
          }
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memuat data akun');
        }
      } else {
        throw Exception(
            'Gagal memuat data akun. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching accounts: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data akun: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

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
                      style: AppText.h6(color: AppColors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                      ),
                    ),
                    child: Calendar(
                      initialSelectedDate: selectedDate.value,
                      onDateSelected: (date) {
                        selectedDate.value = date;
                        formattedSelectedDate.value =
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                .format(date);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Container(
                  padding: AppResponsive.padding(all: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text('Batal',
                            style: AppText.button(color: AppColors.dark)),
                      ),
                      SizedBox(width: AppResponsive.w(2)),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding:
                              AppResponsive.padding(horizontal: 3, vertical: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Pilih',
                            style: AppText.button(color: AppColors.white)),
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

  // Select due date function
  void selectDueDate(BuildContext context) {
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
                      'Pilih Tanggal Jatuh Tempo',
                      style: AppText.h6(color: AppColors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: Theme(
                    data: ThemeData.light().copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                      ),
                    ),
                    child: Calendar(
                      initialSelectedDate: selectedDueDate.value,
                      onDateSelected: (date) {
                        selectedDueDate.value = date;
                        formattedSelectedDueDate.value =
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                .format(date);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Container(
                  padding: AppResponsive.padding(all: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                        child: Text('Batal',
                            style: AppText.button(color: AppColors.dark)),
                      ),
                      SizedBox(width: AppResponsive.w(2)),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding:
                              AppResponsive.padding(horizontal: 3, vertical: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Pilih',
                            style: AppText.button(color: AppColors.white)),
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
  Future<void> pickFile() async {
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
              snackPosition: SnackPosition.TOP,
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
            snackPosition: SnackPosition.TOP,
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
            snackPosition: SnackPosition.TOP,
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Remove attachment function
  void removeAttachment() {
    hasAttachment.value = false;
    attachmentName.value = '';
    attachmentSize.value = '';
    attachmentFile.value = null;
  }

  // Save piutang function
  Future<void> savePiutang() async {
    // Validasi input
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nama penerima piutang harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (descriptionController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Keterangan piutang harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (amountController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nominal piutang harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    // Validasi jumlah cicilan
    final amount = _extractAmount(amountController.text);
    if (amount <= 0) {
      Get.snackbar(
        'Gagal',
        'Nominal piutang harus lebih dari 0',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedSourceAccount.value == null) {
      Get.snackbar(
        'Gagal',
        'Sumber dana harus dipilih',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedRelatedAccount.value == null) {
      Get.snackbar(
        'Gagal',
        'Tujuan akun harus dipilih',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving(true);

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      // Persiapkan data untuk dikirim ke API
      final Uri url = Uri.parse('${BaseUrl.baseUrl}/tambah-piutang');

      // Membuat request multipart
      var request = http.MultipartRequest('POST', url);

      // Tambahkan headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Tambahkan fields
      request.fields['name'] = nameController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['amount'] = amount.toString();
      request.fields['transaction_date'] =
          DateFormat('yyyy-MM-dd').format(selectedDate.value);
      request.fields['due_date'] =
          DateFormat('yyyy-MM-dd').format(selectedDueDate.value);
      request.fields['source_account'] = selectedSourceAccount.value!['code'];
      request.fields['destination_account'] =
          selectedRelatedAccount.value!['code'];
      if (hasAttachment.value && attachmentFile.value != null) {
        var file = await http.MultipartFile.fromPath(
            'attachment', attachmentFile.value!.path,
            filename: attachmentName.value);
        request.files.add(file);
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          Get.snackbar(
            'Berhasil',
            'Piutang berhasil disimpan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshNotificationCount();
          }
          Future.delayed(const Duration(seconds: 1), () {
            Get.back(result: true);
          });
        } else {
          throw Exception(responseData['message'] ?? 'Gagal menyimpan piutang');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ??
            'Gagal menyimpan piutang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan piutang: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving(false);
    }
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  int _extractAmount(String amount) {
    String numericString = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return 0;
    return int.parse(numericString);
  }

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}

// Custom calendar widget
class Calendar extends StatelessWidget {
  final DateTime initialSelectedDate;
  final Function(DateTime) onDateSelected;

  const Calendar(
      {Key? key,
      required this.initialSelectedDate,
      required this.onDateSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: initialSelectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      onDateChanged: onDateSelected,
    );
  }
}
