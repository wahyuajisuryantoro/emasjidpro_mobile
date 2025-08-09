import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

class NeracaSaldoController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;

  // Neraca Saldo data
  final RxList neracaLeft = [].obs;
  final RxList neracaRight = [].obs;
  final RxNum totalLeft = RxNum(0);
  final RxNum totalRight = RxNum(0);
  final RxString formattedTotalLeft = ''.obs;
  final RxString formattedTotalRight = ''.obs;
  final RxNum selisih = RxNum(0);
  final RxString formattedSelisih = ''.obs;
  final RxBool neracaBalanced = false.obs;
  final RxInt totalAccountsLeft = 0.obs;
  final RxInt totalAccountsRight = 0.obs;
  final RxList aktivaLancar = [].obs;
  final RxList aktivaTetap = [].obs;
  final RxList kewajiban = [].obs;
  final RxList saldo = [].obs;
  // Filter - hanya month dan year (tidak ada range untuk neraca saldo)
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  // Export filter
  final RxInt exportFromMonth = DateTime.now().month.obs;
  final RxInt exportFromYear = DateTime.now().year.obs;
  final RxInt exportToMonth = DateTime.now().month.obs;
  final RxInt exportToYear = DateTime.now().year.obs;
  final RxBool exportAllData = false.obs;

  final List<Map<String, dynamic>> monthOptions = [
    {'value': 1, 'label': 'Januari'},
    {'value': 2, 'label': 'Februari'},
    {'value': 3, 'label': 'Maret'},
    {'value': 4, 'label': 'April'},
    {'value': 5, 'label': 'Mei'},
    {'value': 6, 'label': 'Juni'},
    {'value': 7, 'label': 'Juli'},
    {'value': 8, 'label': 'Agustus'},
    {'value': 9, 'label': 'September'},
    {'value': 10, 'label': 'Oktober'},
    {'value': 11, 'label': 'November'},
    {'value': 12, 'label': 'Desember'},
  ];

  final RxString masjidName = 'Masjid'.obs;
  final RxMap laporanData = {}.obs;
  final RxBool isDialogOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMasjidData();
    fetchNeracaSaldo();
  }

  @override
  void onClose() {
    try {
      _forceCloseDialog();
      isLoading.value = false;
      isDialogOpen.value = false;
    } catch (e) {
    } finally {
      super.onClose();
    }
  }

  @override
  void onReady() {
    super.onReady();
    _forceCloseDialog();
  }

  // ===================== DATA LOADING METHODS =====================
  Future<void> _loadMasjidData() async {
    try {
      String? token = _storageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/setting-masjid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          masjidName.value = data['data']['masjid']?['name'] ?? 'Masjid';
          laporanData['masjid'] = {
            'name': data['data']['masjid']?['name'] ?? 'Masjid',
            'address':
                data['data']['masjid']?['address'] ?? 'Alamat tidak tersedia'
          };
          var settingData = data['data']['setting'];
          if (settingData != null) {
            laporanData['setting'] = {
              'pengurus': settingData['pengurus'] ?? '',
              'logo': settingData['logo'],
              'logo_path': settingData['logo_path'],
              'username': settingData['username'],
              'name': settingData['name'],
              'publish': settingData['publish'],
              'active': settingData['active']
            };
          } else {
            laporanData['setting'] = {'pengurus': '', 'logo': null};
          }
        } else {
          _setDefaultMasjidData();
        }
      } else {
        _setDefaultMasjidData();
      }
    } catch (e) {
      _setDefaultMasjidData();
    }
  }

  void _setDefaultMasjidData() {
    masjidName.value = 'Masjid';
    laporanData['masjid'] = {
      'name': 'Masjid',
      'address': 'Alamat tidak tersedia'
    };
    laporanData['setting'] = {'pengurus': '', 'logo': null};
  }

  Future<void> loadLaporanData() async {
    try {
      final exportData = await fetchExportData();
      laporanData['neraca_saldo'] = exportData;
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> fetchNeracaSaldo() async {
    try {
      isLoading.value = true;
      isError.value = false;

      String? token = _storageService.getToken();

      if (token == null) {
        isError.value = true;
        errorMessage.value = 'Token tidak tersedia, silakan login kembali';
        return;
      }

      Map<String, String> queryParams = {
        'month': selectedMonth.value.toString(),
        'year': selectedYear.value.toString(),
      };

      final uri = Uri.parse(BaseUrl.baseUrl + '/neraca-saldo').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print(response.body);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          totalLeft.value = data['data']['total_left'] ?? 0;
          totalRight.value = data['data']['total_right'] ?? 0;
          formattedTotalLeft.value =
              data['data']['formatted_total_left'] ?? 'Rp 0';
          formattedTotalRight.value =
              data['data']['formatted_total_right'] ?? 'Rp 0';
          totalAccountsLeft.value = data['data']['total_accounts_left'] ?? 0;
          totalAccountsRight.value = data['data']['total_accounts_right'] ?? 0;
          aktivaLancar.value = data['data']['aktiva_lancar'] ?? [];
          aktivaTetap.value = data['data']['aktiva_tetap'] ?? [];
          kewajiban.value = data['data']['kewajiban'] ?? [];
          saldo.value = data['data']['saldo'] ?? [];
        } else {
          isError.value = true;
          errorMessage.value = data['message'] ?? 'Terjadi kesalahan';
        }
      } else {
        isError.value = true;
        errorMessage.value = 'Terjadi kesalahan: HTTP ${response.statusCode}';
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void showExportModal() {
    // Set default export values sama dengan filter yang sedang aktif
    exportFromMonth.value = selectedMonth.value;
    exportFromYear.value = selectedYear.value;
    exportToMonth.value = selectedMonth.value;
    exportToYear.value = selectedYear.value;
    exportAllData.value = false;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: AppResponsive.padding(all: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Export PDF', style: AppText.h5(color: AppColors.dark)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: AppResponsive.h(1)),

              // Checkbox untuk export semua data
              Obx(() => CheckboxListTile(
                    title: Text('Export Semua Data', style: AppText.p()),
                    subtitle: Text(
                        'Export seluruh data neraca saldo tanpa filter periode',
                        style: AppText.small(color: Colors.grey[600])),
                    value: exportAllData.value,
                    onChanged: (value) {
                      exportAllData.value = value ?? false;
                    },
                    activeColor: AppColors.primary,
                  )),

              SizedBox(height: AppResponsive.h(1)),

              // Filter periode tunggal
              Obx(() => exportAllData.value
                  ? SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Periode Export',
                            style: AppText.pSmallBold(color: AppColors.dark)),
                        SizedBox(height: AppResponsive.h(1.5)),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey[200]!, width: 1),
                          ),
                          padding: AppResponsive.padding(all: 2),
                          child: Row(
                            children: [
                              // Month dropdown
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: exportFromMonth.value,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: AppColors.primary),
                                    ),
                                    contentPadding: AppResponsive.padding(
                                        horizontal: 1.5, vertical: 1),
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Bulan',
                                  ),
                                  items: monthOptions.map((month) {
                                    return DropdownMenuItem<int>(
                                      value: month['value'],
                                      child: Text(month['label'],
                                          style: AppText.pSmall()),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      exportFromMonth.value = value;
                                      exportToMonth.value = value;
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: AppResponsive.w(2)),
                              // Year input
                              SizedBox(
                                width: 120,
                                child: TextFormField(
                                  initialValue: exportFromYear.value.toString(),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: AppColors.primary),
                                    ),
                                    contentPadding: AppResponsive.padding(
                                        horizontal: 1.5, vertical: 1),
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'Tahun',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      int? year = int.tryParse(value);
                                      if (year != null) {
                                        exportFromYear.value = year;
                                        exportToYear.value = year;
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppResponsive.h(1)),
                        // Info text untuk periode tunggal
                        Container(
                          padding: AppResponsive.padding(all: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16, color: AppColors.info),
                              SizedBox(width: AppResponsive.w(1)),
                              Expanded(
                                child: Text(
                                  'Export untuk periode tunggal yang dipilih',
                                  style: AppText.small(color: AppColors.info),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),

              SizedBox(height: AppResponsive.h(3)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: AppColors.dark,
                        padding: AppResponsive.padding(vertical: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text('Batal',
                          style: AppText.p(color: AppColors.dark)),
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(2)),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        generateReport();
                      },
                      icon:
                          const Icon(Icons.picture_as_pdf, color: Colors.white),
                      label:
                          Text('Export', style: AppText.p(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: AppResponsive.padding(vertical: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchExportData() async {
    try {
      String? token = _storageService.getToken();
      if (token == null) return {};

      Map<String, String> queryParams = {};

      if (exportAllData.value) {
        queryParams['all_data'] = 'true';
      } else {
        queryParams['month'] = exportFromMonth.value.toString();
        queryParams['year'] = exportFromYear.value.toString();
      }

      final uri = Uri.parse(BaseUrl.baseUrl + '/neraca-saldo').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? {};
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // ===================== PDF GENERATION METHODS =====================
  Future<void> generateReport() async {
    if (isLoading.value) {
      print('Report generation already in progress');
      return;
    }

    try {
      isLoading.value = true;

      _showLoadingDialog('Memproses data...');

      await loadLaporanData();
      await _loadMasjidData();

      if (laporanData.isEmpty) {
        throw Exception('Data laporan tidak tersedia');
      }

      if (isDialogOpen.value) {
        _closeLoadingDialog();
        await Future.delayed(Duration(milliseconds: 200));
        _showLoadingDialog('Membuat PDF...');
      }

      final pdf = await _createPDF();
      final fileName = _generateFileName();

      if (isDialogOpen.value) {
        _closeLoadingDialog();
        await Future.delayed(Duration(milliseconds: 200));
        _showLoadingDialog('Menyimpan file...');
      }

      final filePath = await _savePDFToAppDirectory(pdf, fileName);
      _closeLoadingDialog();
      await Future.delayed(Duration(milliseconds: 300));

      _showExportSuccessDialog(filePath, fileName);
    } catch (e) {
      _closeLoadingDialog();
      await Future.delayed(Duration(milliseconds: 200));

      _showErrorSnackbar('Gagal membuat PDF');
    } finally {
      isLoading.value = false;
    }
  }

  Future<pw.Document> _createPDF() async {
    try {
      final pdf = pw.Document();

      late pw.Font ttf;
      late pw.Font ttfBold;
      pw.ImageProvider? logoImage;

      try {
        ttf = await PdfGoogleFonts.robotoRegular();
        ttfBold = await PdfGoogleFonts.robotoBold();
      } catch (e) {
        ttf = pw.Font.courier();
        ttfBold = pw.Font.courierBold();
      }

      try {
        logoImage = await _loadLogo();
      } catch (e) {
        logoImage = null;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return _buildFlatWidgetList(ttf, ttfBold, logoImage);
          },
        ),
      );

      return pdf;
    } catch (e) {
      print('Error in _createPDF: $e');
      rethrow;
    }
  }

  List<pw.Widget> _buildFlatWidgetList(
      pw.Font ttf, pw.Font ttfBold, pw.ImageProvider? logoImage) {
    final neracaSaldoData =
        laporanData['neraca_saldo'] as Map<String, dynamic>? ?? {};
    final aktivaLancar =
        neracaSaldoData['aktiva_lancar'] as List<dynamic>? ?? [];
    final aktivaTetap = neracaSaldoData['aktiva_tetap'] as List<dynamic>? ?? [];
    final kewajiban = neracaSaldoData['kewajiban'] as List<dynamic>? ?? [];
    final saldo = neracaSaldoData['saldo'] as List<dynamic>? ?? [];

    List<List<dynamic>> tableData = [];

    // Add section header for Aktiva Lancar
    if (aktivaLancar.isNotEmpty) {
      tableData.add(['', 'AKTIVA LANCAR', '', '']);
      for (var item in aktivaLancar) {
        tableData.add([
          item['account_code'] ?? '',
          item['account_name'] ?? '',
          _formatCurrency(item['saldo_akhir']),
          ''
        ]);
      }
    }

    // Add section header for Aktiva Tetap
    if (aktivaTetap.isNotEmpty) {
      tableData.add(['', 'AKTIVA TETAP', '', '']);
      for (var item in aktivaTetap) {
        tableData.add([
          item['account_code'] ?? '',
          item['account_name'] ?? '',
          _formatCurrency(item['saldo_akhir']),
          ''
        ]);
      }
    }

    // Add section header for Kewajiban
    if (kewajiban.isNotEmpty) {
      tableData.add(['', 'KEWAJIBAN', '', '']);
      for (var item in kewajiban) {
        tableData.add([
          item['account_code'] ?? '',
          item['account_name'] ?? '',
          '',
          _formatCurrency(item['saldo_akhir'])
        ]);
      }
    }

    // Add section header for Saldo
    if (saldo.isNotEmpty) {
      tableData.add(['', 'SALDO', '', '']);
      for (var item in saldo) {
        tableData.add([
          item['account_code'] ?? '',
          item['account_name'] ?? '',
          '',
          _formatCurrency(item['saldo_akhir'])
        ]);
      }
    }

    // Add totals
    tableData.add([
      '',
      'TOTAL',
      _formatCurrency(neracaSaldoData['total_left'] ?? 0),
      _formatCurrency(neracaSaldoData['total_right'] ?? 0)
    ]);

    return [
      _buildKopSurat(ttfBold, ttf, masjidName.value, _getReportTitle(),
          _getReportSubtitle(), logoImage),
      pw.SizedBox(height: 25),
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.black),
        columnWidths: {
          0: pw.FlexColumnWidth(1),
          1: pw.FlexColumnWidth(2.5),
          2: pw.FlexColumnWidth(1.5),
          3: pw.FlexColumnWidth(1.5),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#D6DBDF')),
            children: [
              pw.Container(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('No. Akun',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10),
                    textAlign: pw.TextAlign.center),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('Nama Akun',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10),
                    textAlign: pw.TextAlign.center),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('Debit (Rp)',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10),
                    textAlign: pw.TextAlign.center),
              ),
              pw.Container(
                padding: pw.EdgeInsets.all(6),
                child: pw.Text('Kredit (Rp)',
                    style: pw.TextStyle(font: ttfBold, fontSize: 10),
                    textAlign: pw.TextAlign.center),
              ),
            ],
          ),
          // Data rows
          ...tableData.map((row) {
            bool isTotal = row[1] == 'TOTAL';
            bool isSectionHeader = row[1] == 'AKTIVA LANCAR' ||
                row[1] == 'AKTIVA TETAP' ||
                row[1] == 'KEWAJIBAN' ||
                row[1] == 'SALDO';

            return pw.TableRow(
              decoration: isTotal
                  ? pw.BoxDecoration(color: PdfColor.fromHex('#FFEB3B'))
                  : isSectionHeader
                      ? pw.BoxDecoration(color: PdfColor.fromHex('#E8F5E8'))
                      : null,
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    row[0],
                    style: pw.TextStyle(
                      font: (isTotal || isSectionHeader) ? ttfBold : ttf,
                      fontSize: 9,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Container(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    row[1],
                    style: pw.TextStyle(
                      font: (isTotal || isSectionHeader) ? ttfBold : ttf,
                      fontSize: 9,
                    ),
                  ),
                ),
                pw.Container(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    row[2],
                    style: pw.TextStyle(
                      font: (isTotal || isSectionHeader) ? ttfBold : ttf,
                      fontSize: 9,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.Container(
                  padding: pw.EdgeInsets.all(4),
                  child: pw.Text(
                    row[3],
                    style: pw.TextStyle(
                      font: (isTotal || isSectionHeader) ? ttfBold : ttf,
                      fontSize: 9,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    ];
  }

  // Helper methods (sama seperti JurnalUmum)
  pw.Widget _buildKopSurat(pw.Font ttfBold, pw.Font ttf, String masjidName,
      String title, String subtitle, pw.ImageProvider? logoImage) {
    return pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          child: pw.Stack(
            children: [
              pw.Positioned(
                left: -30,
                top: -30,
                child: pw.Container(
                  width: 120,
                  height: 120,
                  child: logoImage != null
                      ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                      : pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.black),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              'LOGO',
                              style: pw.TextStyle(font: ttf, fontSize: 8),
                            ),
                          ),
                        ),
                ),
              ),
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.only(top: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      laporanData['setting']?['pengurus']
                              ?.toString()
                              .toUpperCase() ??
                          'PENGURUS MASJID',
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 15,
                        color: PdfColors.black,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      '"${masjidName.toUpperCase()}"',
                      style: pw.TextStyle(
                        font: ttfBold,
                        fontSize: 13,
                        color: PdfColors.black,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      laporanData['masjid']?['address'] ??
                          'Alamat tidak tersedia',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          height: 1.5,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 25),
        pw.Container(
          width: double.infinity,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 13,
                  color: PdfColors.black,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                subtitle.toUpperCase(),
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 13,
                  color: PdfColors.black,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Dicetak pada: ${DateFormat('dd MMMM yyyy', 'id').format(DateTime.now())}',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 9,
                  color: PdfColors.black,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0';
    String valueStr = value.toString();
    if (valueStr.startsWith('Rp ')) {
      valueStr = valueStr.substring(3);
    }
    if (value is num) {
      return value.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.',
          );
    }
    return valueStr;
  }

  String _getReportTitle() {
    return 'LAPORAN NERACA SALDO';
  }

  String _getReportSubtitle() {
    if (exportAllData.value) {
      return 'Semua Data';
    } else {
      final fromMonthName = monthOptions
          .firstWhere((m) => m['value'] == exportFromMonth.value)['label'];
      return '${fromMonthName} ${exportFromYear.value}';
    }
  }

  String _generateFileName() {
    final dateStr = DateFormat('ddMMyyyy').format(DateTime.now());
    return 'Laporan_NeracaSaldo_$dateStr.pdf';
  }

  Future<String> _savePDFToAppDirectory(
      pw.Document pdf, String fileName) async {
    try {
      final Uint8List bytes = await pdf.save();
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory reportsDir = Directory('${appDocDir.path}/Reports');

      if (!await reportsDir.exists()) {
        await reportsDir.create(recursive: true);
      }

      final String filePath = '${reportsDir.path}/$fileName';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  Future<pw.ImageProvider> _loadLogo() async {
    try {
      var logoData = laporanData['setting'];
      String? logoUrl;
      if (logoData != null) {
        logoUrl = logoData['logo']?.toString();

        if (logoUrl != null && !logoUrl.startsWith('http')) {
          logoUrl =
              'https://storage.googleapis.com/emasjid-storage/emasjidpro/$logoUrl';
        }
      }
      String? cleanUrl = _cleanAndValidateUrl(logoUrl);

      if (cleanUrl != null) {
        try {
          final response = await http
              .get(Uri.parse(cleanUrl))
              .timeout(Duration(seconds: 15));
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            return pw.MemoryImage(response.bodyBytes);
          } else {
            return await _loadDefaultLogo();
          }
        } catch (e) {
          return await _loadDefaultLogo();
        }
      } else {
        return await _loadDefaultLogo();
      }
    } catch (e) {
      return await _loadDefaultLogo();
    }
  }

  Future<pw.MemoryImage> _loadDefaultLogo() async {
    final ByteData data = await rootBundle.load('assets/images/no_logo.png');
    final Uint8List bytes = data.buffer.asUint8List();
    return pw.MemoryImage(bytes);
  }

  String? _cleanAndValidateUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') {
      return null;
    }
    String cleanUrl = url.replaceAll('\\/', '/');
    Uri? uri = Uri.tryParse(cleanUrl);
    if (uri != null &&
        (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://'))) {
      return cleanUrl;
    }
    return null;
  }

  Future<void> _openPDF(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        _showFileLocationDialog(filePath);
      }
    } catch (e) {
      _showFileLocationDialog(filePath);
    }
  }

  Future<void> _sharePDF(String filePath) async {
    try {
      final share_plus.XFile file = share_plus.XFile(filePath);
      String shareText = 'Laporan Neraca Saldo - ${_getReportSubtitle()}';

      await share_plus.Share.shareXFiles([file],
          text: shareText, subject: shareText);
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan saat berbagi: $e');
    }
  }

  void _closeLoadingDialog() {
    try {
      if (isDialogOpen.value && Get.isDialogOpen == true) {
        isDialogOpen.value = false;
        Get.back();
      } else {
        isDialogOpen.value = false;
      }
    } catch (e) {
      print('Error closing dialog: $e');
      isDialogOpen.value = false;
    }
  }

  void _forceCloseDialog() {
    try {
      isDialogOpen.value = false;
      int maxAttempts = 5;
      int attempts = 0;

      while (Get.isDialogOpen == true && attempts < maxAttempts) {
        Get.back();
        attempts++;
      }

      if (attempts >= maxAttempts) {
        print('Warning: Maximum dialog close attempts reached');
      }
    } catch (e) {
      print('Error in _forceCloseDialog: $e');
      isDialogOpen.value = false;
    }
  }

  void _showLoadingDialog(String message) {
    try {
      _forceCloseDialog();
      Future.delayed(Duration(milliseconds: 100), () {
        if (!isDialogOpen.value) {
          isDialogOpen.value = true;

          Get.dialog(
            WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppResponsive.w(4)),
                ),
                child: Container(
                  padding: AppResponsive.padding(all: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: AppResponsive.h(3)),
                      Text(
                        message,
                        style: AppText.p(color: AppColors.dark),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            barrierDismissible: false,
          ).then((_) {
            isDialogOpen.value = false;
          });
        }
      });
    } catch (e) {
      isDialogOpen.value = false;
    }
  }

  void _showExportSuccessDialog(String filePath, String fileName) {
    try {
      _forceCloseDialog();
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppResponsive.w(4))),
          child: Container(
            padding: AppResponsive.padding(all: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: AppResponsive.padding(all: 3),
                  decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(Icons.check_circle,
                      color: AppColors.success, size: AppResponsive.w(15)),
                ),
                SizedBox(height: AppResponsive.h(2)),
                Text('PDF Berhasil Dibuat!',
                    style: AppText.h6(color: AppColors.dark),
                    textAlign: TextAlign.center),
                SizedBox(height: AppResponsive.h(1)),
                Text('Laporan neraca saldo telah berhasil diekspor ke PDF',
                    style:
                        AppText.pSmall(color: AppColors.dark.withOpacity(0.7)),
                    textAlign: TextAlign.center),
                SizedBox(height: AppResponsive.h(1)),
                Container(
                  padding: AppResponsive.padding(all: 2),
                  decoration: BoxDecoration(
                      color: AppColors.muted,
                      borderRadius: BorderRadius.circular(AppResponsive.w(2))),
                  child: Text(fileName,
                      style: AppText.small(color: AppColors.dark),
                      textAlign: TextAlign.center),
                ),
                SizedBox(height: AppResponsive.h(3)),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            Get.back();
                            await _openPDF(filePath);
                          } catch (e) {
                            print('Error opening PDF: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: AppResponsive.padding(vertical: 2.5),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppResponsive.w(2)),
                          ),
                        ),
                        child: Text(
                          'Buka File',
                          style: AppText.pSmallBold(color: AppColors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: AppResponsive.h(1.5)),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                Get.back();
                                await _sharePDF(filePath);
                              } catch (e) {
                                print('Error sharing PDF: $e');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: AppResponsive.padding(vertical: 2.5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppResponsive.w(2)),
                              ),
                            ),
                            child: Text(
                              'Bagikan',
                              style: AppText.pSmallBold(color: AppColors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: AppResponsive.w(3)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              try {
                                Get.back();
                              } catch (e) {}
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              padding: AppResponsive.padding(vertical: 2.5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppResponsive.w(2)),
                              ),
                            ),
                            child: Text(
                              'Tutup',
                              style: AppText.pSmallBold(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    } catch (e) {}
  }

  void _showFileLocationDialog(String filePath) {
    _forceCloseDialog();

    Future.delayed(Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          title: Text('File Tersimpan', style: AppText.h6()),
          content: Text(
              'File PDF berhasil disimpan di aplikasi. Anda dapat mengakses file melalui file manager.'),
          actions: [
            TextButton(
                onPressed: () => Get.back(),
                child:
                    Text('OK', style: AppText.button(color: AppColors.primary)))
          ],
        ),
      );
    });
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar('Error', message,
        backgroundColor: AppColors.danger,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP);
  }

  String getMonthName(int month) {
    return monthOptions.firstWhere((m) => m['value'] == month)['label'];
  }

  String getCurrentPeriodText() {
    return '${getMonthName(selectedMonth.value)} ${selectedYear.value}';
  }
}
