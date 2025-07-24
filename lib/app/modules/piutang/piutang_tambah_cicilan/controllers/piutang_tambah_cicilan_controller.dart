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
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:intl/intl.dart';
import 'package:emasjid_pro/app/helpers/currency_formatter.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class PiutangTambahCicilanController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final Map<String, dynamic> piutangData = Get.arguments;

  final RxString piutangId = ''.obs;
  final RxString piutangCode = ''.obs;
  final RxString namaPenerima = ''.obs;
  final RxInt totalPiutang = 0.obs;
  final RxInt sisaPiutang = 0.obs;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();

  final isLoading = false.obs;
  final isSaving = false.obs;

  final selectedDate = DateTime.now().obs;
  final formattedSelectedDate =
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()).obs;
  final sourceAccounts = <Map<String, dynamic>>[].obs;
  final selectedSourceAccount = Rxn<Map<String, dynamic>>();

  final jenisTransaksi = [
    'Penerimaan Cicilan',
    'Penerimaan Tunai',
    'Pelunasan',
  ];

  final selectedJenisTransaksi = 'Penerimaan Cicilan'.obs;

  final hasAttachment = false.obs;
  final attachmentName = ''.obs;
  final attachmentSize = ''.obs;
  Rx<File?> attachmentFile = Rx<File?>(null);

  final currencyFormatter = CurrencyInputFormatter();

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  Future<void> fetchSourceAccounts() async {
    try {
      isLoading(true);

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/accounts-cicilan-piutang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];

          final accountsList = (data['accounts'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
          sourceAccounts.value = accountsList;
          print(accountsList);
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memuat data akun');
        }
      } else {
        throw Exception(
            'Gagal memuat data akun. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching accounts: $e');
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

  void removeAttachment() {
    hasAttachment.value = false;
    attachmentName.value = '';
    attachmentSize.value = '';
    attachmentFile.value = null;
  }

  Future<void> saveCicilan() async {
    if (descriptionController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Keterangan cicilan harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (amountController.text.isEmpty) {
      Get.snackbar(
        'Gagal',
        'Nominal penerimaan harus diisi',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    final amount = _extractAmount(amountController.text);
    if (amount <= 0) {
      Get.snackbar(
        'Gagal',
        'Nominal penerimaan harus lebih dari 0',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
      );
      return;
    }

    if (amount > sisaPiutang.value) {
      Get.snackbar(
        'Gagal',
        'Nominal penerimaan tidak boleh melebihi sisa piutang (${formatCurrency(sisaPiutang.value)})',
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

    try {
      isSaving(true);

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final Uri url = Uri.parse('${BaseUrl.baseUrl}/tambah-cicilan-piutang');

      var request = http.MultipartRequest('POST', url);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['piutang_id'] = piutangId.value;
      request.fields['piutang_code'] = piutangCode.value;
      request.fields['description'] = descriptionController.text;
      request.fields['amount'] = amount.toString();
      request.fields['transaction_date'] =
          DateFormat('yyyy-MM-dd').format(selectedDate.value);
      request.fields['source_account'] = selectedSourceAccount.value!['code'];
      request.fields['name'] = nameController.text;
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
        print(response.body);
        if (responseData['success'] == true) {
          Get.snackbar(
            'Berhasil',
            'Cicilan piutang berhasil disimpan',
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
          throw Exception(responseData['message'] ?? 'Gagal menyimpan cicilan piutang');
        }
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        throw Exception(responseData['message'] ??
            'Gagal menyimpan cicilan piutang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Gagal menyimpan cicilan piutang',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(seconds: 1), () {
        Get.back(result: true);
      });
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

    try {
      if (piutangData.containsKey('id')) {
        piutangId.value = piutangData['id'].toString();
      }

      if (piutangData.containsKey('code')) {
        piutangCode.value = piutangData['code'].toString();
      }

      if (piutangData.containsKey('nama')) {
        namaPenerima.value = piutangData['nama'].toString();
      }

      if (piutangData.containsKey('jumlah')) {
        final jumlahStr = piutangData['jumlah'].toString();
        totalPiutang.value = int.tryParse(jumlahStr) ?? 0;
      }

      if (piutangData.containsKey('sisa')) {
        final sisaStr = piutangData['sisa'].toString();
        sisaPiutang.value = int.tryParse(sisaStr) ?? 0;
      }
    } catch (e) {
      print('Error parsing piutang data: $e');
    }

    fetchSourceAccounts();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    amountController.dispose();
    super.onClose();
  }
}

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