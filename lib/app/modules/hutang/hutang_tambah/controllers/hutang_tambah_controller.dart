import 'dart:convert';
import 'dart:io';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/modules/home/controllers/home_controller.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:http/http.dart' as http;

class HutangTambahController extends GetxController {
  final StorageService storage = Get.find<StorageService>();
  final ScrollController scrollController = ScrollController();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  Rx<File?> attachmentFile = Rx<File?>(null);

  final isLoading = false.obs;
  final isSaving = false.obs;

  final sourceAccounts = <Map<String, dynamic>>[].obs;
  final destinationAccounts = <Map<String, dynamic>>[].obs;

  final selectedDate = DateTime.now().obs;
  final selectedDueDate = DateTime.now().add(const Duration(days: 30)).obs;

  final formattedSelectedDate =
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()).obs;
  final formattedSelectedDueDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID')
      .format(DateTime.now().add(const Duration(days: 30)))
      .obs;

  final selectedSourceAccount = Rxn<Map<String, dynamic>>();
  final selectedDestinationAccount = Rxn<Map<String, dynamic>>();

  final hasAttachment = false.obs;
  final attachmentName = ''.obs;
  final attachmentSize = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  void resetFormAndScrollToTop() {
    nameController.clear();
    descriptionController.clear();
    amountController.clear();
    selectedDate.value = DateTime.now();
    selectedDueDate.value = DateTime.now().add(const Duration(days: 30));
    formattedSelectedDate.value =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());
    formattedSelectedDueDate.value = DateFormat('EEEE, d MMMM yyyy', 'id_ID')
        .format(DateTime.now().add(const Duration(days: 30)));
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

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/accounts-hutang'),
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
        'Terjadi Kesalahan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

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
                  child: SfDateRangePicker(
                    initialSelectedDate: selectedDate.value,
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: AppColors.white,
                      textStyle: AppText.bodyMedium(color: AppColors.dark),
                    ),
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                        textStyle: AppText.bodySmall(
                            color: AppColors.dark.withOpacity(0.7)),
                      ),
                      dayFormat: 'EEE',
                      firstDayOfWeek: 1,
                    ),
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      textStyle: AppText.bodyMedium(color: AppColors.dark),
                      todayTextStyle:
                          AppText.bodyMedium(color: AppColors.primary),
                      leadingDatesTextStyle: AppText.bodyMedium(
                          color: AppColors.dark.withOpacity(0.4)),
                      trailingDatesTextStyle: AppText.bodyMedium(
                          color: AppColors.dark.withOpacity(0.4)),
                    ),
                    selectionColor: AppColors.primary,
                    todayHighlightColor: AppColors.primary,
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      if (args.value is DateTime) {
                        selectedDate.value = args.value;
                        formattedSelectedDate.value =
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                .format(args.value);
                        Navigator.pop(context);
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

  Future<void> selectDueDate(BuildContext context) async {
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
                  child: SfDateRangePicker(
                    initialSelectedDate: selectedDueDate.value,
                    minDate: DateTime.now(),
                    maxDate: DateTime(2030),
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: AppColors.white,
                      textStyle: AppText.bodyMedium(color: AppColors.dark),
                    ),
                    monthViewSettings: DateRangePickerMonthViewSettings(
                      viewHeaderStyle: DateRangePickerViewHeaderStyle(
                        textStyle: AppText.bodySmall(
                            color: AppColors.dark.withOpacity(0.7)),
                      ),
                      dayFormat: 'EEE',
                      firstDayOfWeek: 1,
                    ),
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      textStyle: AppText.bodyMedium(color: AppColors.dark),
                      todayTextStyle:
                          AppText.bodyMedium(color: AppColors.primary),
                      leadingDatesTextStyle: AppText.bodyMedium(
                          color: AppColors.dark.withOpacity(0.4)),
                      trailingDatesTextStyle: AppText.bodyMedium(
                          color: AppColors.dark.withOpacity(0.4)),
                    ),
                    selectionColor: AppColors.primary,
                    todayHighlightColor: AppColors.primary,
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      if (args.value is DateTime) {
                        selectedDueDate.value = args.value;
                        formattedSelectedDueDate.value =
                            DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                                .format(args.value);
                        Navigator.pop(context);
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
      Get.snackbar(
        'Error',
        'An error occurred while picking the file.',
        snackPosition: SnackPosition.TOP,
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

  Future<void> saveHutang() async {
    if (nameController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nama penghutang harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (descriptionController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Keterangan hutang harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (amountController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nominal hutang harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedSourceAccount.value == null) {
      Get.snackbar(
        'Gagal',
        'Akun sumber harus dipilih',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedDestinationAccount.value == null) {
      Get.snackbar(
        'Gagal',
        'Akun tujuan harus dipilih',
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
      final Uri url = Uri.parse('${BaseUrl.baseUrl}/tambah-hutang');
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      request.fields['name'] = nameController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['amount'] =
          _extractAmount(amountController.text).toString();
      request.fields['transaction_date'] =
          DateFormat('yyyy-MM-dd').format(selectedDate.value);
      request.fields['due_date'] =
          DateFormat('yyyy-MM-dd').format(selectedDueDate.value);
      request.fields['source_account'] = selectedSourceAccount.value!['code'];
      request.fields['destination_account'] =
          selectedDestinationAccount.value!['code'];
      if (hasAttachment.value && attachmentFile.value != null) {
        var file = await http.MultipartFile.fromPath(
            'attachment', attachmentFile.value!.path,
            filename: attachmentName.value);
        request.files.add(file);
      }
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          Get.snackbar(
            'Berhasil',
            'Hutang berhasil disimpan',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
          );
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshNotificationCount();
          }
          Future.delayed(const Duration(milliseconds: 500), () {
             Get.offAndToNamed(Routes.HUTANG_DAFTAR, result: 'refresh');
          });
        } else {
          throw Exception(responseData['message'] ?? 'Gagal menyimpan hutang');
        }
      } else {
        throw Exception(
            'Gagal menyimpan hutang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan hutang',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving(false);
    }
  }

  double _extractAmount(String amount) {
    String numericString = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericString.isEmpty) return 0;
    return double.parse(numericString);
  }
}
