import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
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
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

class JurnalUmumController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList journalEntries = [].obs;
  final RxList accounts = [].obs;
  final RxInt totalCount = 0.obs;
  final RxNum totalDebit = RxNum(0);
  final RxNum totalCredit = RxNum(0);
  final RxString formattedTotalDebit = ''.obs;
  final RxString formattedTotalCredit = ''.obs;

  // Simplified filter - only month and year
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  // Export filter - for range selection
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

  final RxMap journalDetail = {}.obs;
  final RxBool isDetailLoading = false.obs;

  final RxString masjidName = 'Masjid'.obs;
  final RxMap laporanData = {}.obs;
  final RxBool isDialogOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMasjidData();
    fetchJournalEntries();
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

  // SAMA seperti loadLaporanData di hutang controller
  Future<void> loadLaporanData() async {
    try {
      final exportData = await fetchExportData();
      laporanData['daftar_jurnal'] = exportData; // Simpan ke laporanData
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> fetchJournalEntries() async {
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

      final uri = Uri.parse(BaseUrl.baseUrl + '/jurnal-umum').replace(
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
          journalEntries.value = data['data']['journal_entries'] ?? [];
          accounts.value = data['data']['accounts'] ?? [];
          totalCount.value = data['data']['total_count'] ?? 0;
          totalDebit.value = data['data']['total_debit'] ?? 0;
          totalCredit.value = data['data']['total_credit'] ?? 0;
          formattedTotalDebit.value =
              data['data']['formatted_total_debit'] ?? 'Rp 0';
          formattedTotalCredit.value =
              data['data']['formatted_total_credit'] ?? 'Rp 0';
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
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
              Obx(() => CheckboxListTile(
                    title: Text('Export Semua Data', style: AppText.p()),
                    subtitle: Text(
                        'Export seluruh data jurnal tanpa filter periode',
                        style: AppText.small(color: Colors.grey[600])),
                    value: exportAllData.value,
                    onChanged: (value) {
                      exportAllData.value = value ?? false;
                    },
                    activeColor: AppColors.primary,
                  )),
              SizedBox(height: AppResponsive.h(1)),
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode Export',
                        style: AppText.pSmallBold(
                            color: exportAllData.value
                                ? Colors.grey
                                : AppColors.dark),
                      ),
                      SizedBox(height: AppResponsive.h(1)),

                      // Container Dari
                      Container(
                        decoration: BoxDecoration(
                          color: exportAllData.value
                              ? Colors.grey[100]
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: exportAllData.value
                                ? Colors.grey[300]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        padding: AppResponsive.padding(all: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dari:',
                                style: AppText.small(
                                    color: exportAllData.value
                                        ? Colors.grey
                                        : AppColors.dark)),
                            SizedBox(height: AppResponsive.h(0.5)),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: exportFromMonth.value,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding: AppResponsive.padding(
                                          horizontal: 1.5, vertical: 1),
                                      enabled: !exportAllData.value,
                                      filled: true,
                                      fillColor: exportAllData.value
                                          ? Colors.grey[100]
                                          : Colors.white,
                                    ),
                                    items: monthOptions.map((month) {
                                      return DropdownMenuItem<int>(
                                        value: month['value'],
                                        child: Text(month['label'],
                                            style: AppText.pSmall()),
                                      );
                                    }).toList(),
                                    onChanged: exportAllData.value
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              exportFromMonth.value = value;
                                            }
                                          },
                                  ),
                                ),
                                SizedBox(width: AppResponsive.w(2)),
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    initialValue:
                                        exportFromYear.value.toString(),
                                    enabled: !exportAllData.value,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding: AppResponsive.padding(
                                          horizontal: 1.5, vertical: 1),
                                      hintText: 'Tahun',
                                      filled: true,
                                      fillColor: exportAllData.value
                                          ? Colors.grey[100]
                                          : Colors.white,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        exportFromYear.value =
                                            int.tryParse(value) ??
                                                DateTime.now().year;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: AppResponsive.h(1.5)),

                      // Container Sampai
                      Container(
                        decoration: BoxDecoration(
                          color: exportAllData.value
                              ? Colors.grey[100]
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: exportAllData.value
                                ? Colors.grey[300]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        padding: AppResponsive.padding(all: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sampai:',
                                style: AppText.small(
                                    color: exportAllData.value
                                        ? Colors.grey
                                        : AppColors.dark)),
                            SizedBox(height: AppResponsive.h(0.5)),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: exportToMonth.value,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding: AppResponsive.padding(
                                          horizontal: 1.5, vertical: 1),
                                      enabled: !exportAllData.value,
                                      filled: true,
                                      fillColor: exportAllData.value
                                          ? Colors.grey[100]
                                          : Colors.white,
                                    ),
                                    items: monthOptions.map((month) {
                                      return DropdownMenuItem<int>(
                                        value: month['value'],
                                        child: Text(month['label'],
                                            style: AppText.pSmall()),
                                      );
                                    }).toList(),
                                    onChanged: exportAllData.value
                                        ? null
                                        : (value) {
                                            if (value != null) {
                                              exportToMonth.value = value;
                                            }
                                          },
                                  ),
                                ),
                                SizedBox(width: AppResponsive.w(2)),
                                SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    initialValue: exportToYear.value.toString(),
                                    enabled: !exportAllData.value,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: AppColors.primary),
                                      ),
                                      contentPadding: AppResponsive.padding(
                                          horizontal: 1.5, vertical: 1),
                                      hintText: 'Tahun',
                                      filled: true,
                                      fillColor: exportAllData.value
                                          ? Colors.grey[100]
                                          : Colors.white,
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        exportToYear.value =
                                            int.tryParse(value) ??
                                                DateTime.now().year;
                                      }
                                    },
                                  ),
                                ),
                              ],
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

  Future<List> fetchExportData() async {
    try {
      String? token = _storageService.getToken();
      if (token == null) return [];

      Map<String, String> queryParams = {};

      if (exportAllData.value) {
        queryParams['all_data'] = 'true';
      } else {
        if (exportFromMonth.value == exportToMonth.value &&
            exportFromYear.value == exportToYear.value) {
          queryParams['month'] = exportFromMonth.value.toString();
          queryParams['year'] = exportFromYear.value.toString();
        } else {
          queryParams['from_month'] = exportFromMonth.value.toString();
          queryParams['from_year'] = exportFromYear.value.toString();
          queryParams['to_month'] = exportToMonth.value.toString();
          queryParams['to_year'] = exportToYear.value.toString();
        }
      }

      final uri = Uri.parse(BaseUrl.baseUrl + '/jurnal-umum').replace(
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
          return data['data']['journal_entries'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ===================== PDF GENERATION METHODS =====================

  // EXACT COPY dari hutang controller generateReport()
  Future<void> generateReport() async {
    if (isLoading.value) {
      print('Report generation already in progress');
      return;
    }

    try {
      isLoading.value = true;

      _showLoadingDialog('Memproses data...');

      await loadLaporanData(); // Load data seperti hutang controller
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

  // EXACT COPY dari hutang controller
  List<pw.Widget> _buildFlatWidgetList(
      pw.Font ttf, pw.Font ttfBold, pw.ImageProvider? logoImage) {
    final daftarJurnal = laporanData['daftar_jurnal'] as List<dynamic>? ?? [];

    return [
      _buildKopSurat(ttfBold, ttf, masjidName.value, _getReportTitle(),
          _getReportSubtitle(), logoImage),
      pw.SizedBox(height: 25),
      pw.Text(
        'Data Jurnal Umum',
        style:
            pw.TextStyle(font: ttfBold, fontSize: 11, color: PdfColors.black),
      ),
      pw.SizedBox(height: 10),
      pw.TableHelper.fromTextArray(
        border: pw.TableBorder.all(color: PdfColors.black),
        cellAlignment: pw.Alignment.centerLeft,
        headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#F8F9FA')),
        oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#FAFAFA')),
        headerStyle: pw.TextStyle(
          font: ttfBold,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#333333'),
        ),
        cellStyle: pw.TextStyle(
          font: ttf,
          fontSize: 9,
          color: PdfColors.black,
        ),
        cellPadding: pw.EdgeInsets.all(8),
        headerAlignment: pw.Alignment.centerLeft,
        headerAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.center,
          3: pw.Alignment.center,
          4: pw.Alignment.center,
          5: pw.Alignment.center,
        },
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.centerLeft,
          4: pw.Alignment.centerRight,
          5: pw.Alignment.centerRight,
        },
        columnWidths: {
          0: pw.FlexColumnWidth(1.2),
          1: pw.FlexColumnWidth(2.5),
          2: pw.FlexColumnWidth(0.8),
          3: pw.FlexColumnWidth(2.5),
          4: pw.FlexColumnWidth(1.5),
          5: pw.FlexColumnWidth(1.5),
        },
        headers: [
          'Tanggal',
          'Deskripsi',
          'Kode',
          'Nama Akun',
          'Debit',
          'Kredit'
        ],
        data: daftarJurnal
            .expand<Map<String, dynamic>>((journal) {
              if (journal['entries'] == null || journal['entries'].isEmpty) {
                return <Map<String, dynamic>>[];
              }

              final entries = journal['entries'] as List;
              String description =
                  entries.isNotEmpty ? (entries[0]['description'] ?? '') : '';
              String formattedDate = journal['formatted_date'] ?? '';

              return entries
                  .asMap()
                  .entries
                  .map<Map<String, dynamic>>((entryWithIndex) {
                int i = entryWithIndex.key;
                var entry = entryWithIndex.value;

                return {
                  'tanggal': i == 0 ? formattedDate : '',
                  'deskripsi': i == 0 ? description : '',
                  'kode': entry['account']?.toString() ?? '',
                  'nama_akun': entry['account_name']?.toString() ?? '',
                  'debit': entry['status'] == 'debit'
                      ? _formatCurrency(entry['value'])
                      : '',
                  'kredit': entry['status'] == 'credit'
                      ? _formatCurrency(entry['value'])
                      : '',
                };
              });
            })
            .map<List<dynamic>>((item) => [
                  item['tanggal'] ?? '',
                  item['deskripsi'] ?? '',
                  item['kode'] ?? '',
                  item['nama_akun'] ?? '',
                  item['debit'] ?? '',
                  item['kredit'] ?? '',
                ])
            .toList(),
      ),
    ];
  }

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
    return 'LAPORAN JURNAL UMUM';
  }

  String _getReportSubtitle() {
    if (exportAllData.value) {
      return 'Semua Data';
    } else {
      final fromMonthName = monthOptions
          .firstWhere((m) => m['value'] == exportFromMonth.value)['label'];
      final toMonthName = monthOptions
          .firstWhere((m) => m['value'] == exportToMonth.value)['label'];
      if (exportFromMonth.value == exportToMonth.value &&
          exportFromYear.value == exportToYear.value) {
        return '${fromMonthName} ${exportFromYear.value}';
      } else {
        return '${fromMonthName} ${exportFromYear.value} - ${toMonthName} ${exportToYear.value}';
      }
    }
  }

  String _generateFileName() {
    final dateStr = DateFormat('ddMMyyyy').format(DateTime.now());
    return 'Laporan_JurnalUmum_$dateStr.pdf';
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
      String shareText = 'Laporan Jurnal Umum - ${_getReportSubtitle()}';

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
                Text('Laporan jurnal umum telah berhasil diekspor ke PDF',
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
                              } catch (e) {
                                print('Error closing dialog: $e');
                              }
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

  Future<void> fetchJournalDetail(String code) async {
    try {
      isDetailLoading.value = true;

      String? token = _storageService.getToken();
      if (token == null) {
        Get.snackbar('Error', 'Token tidak tersedia');
        return;
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/jurnal-umum/$code'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          journalDetail.value = data['data'] ?? {};
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  String getMonthName(int month) {
    return monthOptions.firstWhere((m) => m['value'] == month)['label'];
  }

  String getCurrentPeriodText() {
    return '${getMonthName(selectedMonth.value)} ${selectedYear.value}';
  }
}
