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
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart' as share_plus;

class HutangLaporanController extends GetxController {
  final RxBool isDialogOpen = false.obs;
  final RxBool isLoading = false.obs;

  final RxMap laporanData = {}.obs;
  final StorageService storageService = StorageService();

  final RxString masjidName = 'Masjid'.obs;

  @override
  void onInit() {
    super.onInit();
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

  // ===================== DATA LOADING METHODS =====================
  Future<void> _loadMasjidData() async {
    try {
      String? token = storageService.getToken();
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

  Future<void> _loadSettingData() async {
    try {
      String? token = storageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/setting'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        laporanData['setting'] = data['setting'] ?? {};
      } else {
        laporanData['setting'] = {'pengurus': '', 'logo': ''};
      }
    } catch (e) {
      laporanData['setting'] = {'pengurus': '', 'logo': ''};
    }
  }

  Future<void> loadLaporanData() async {
    try {
      String? token = storageService.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/laporan-hutang'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          laporanData.assignAll(data['data'] ?? {});
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat data laporan');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
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

  void _setDefaultMasjidData() {
    masjidName.value = 'No Data Masjid';
    laporanData['masjid'] = {
      'name': 'No Data Masjid',
      'address': 'Alamat tidak tersedia'
    };
    laporanData['setting'] = {
      'pengurus': 'Pengurus tidak tersedia',
      'logo': null
    };
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
      await _loadSettingData();

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
    final daftarHutang = laporanData['daftar_hutang'] as List<dynamic>? ?? [];
    
    return [
      _buildKopSurat(ttfBold, ttf, masjidName.value, _getReportTitle(),
          _getReportSubtitle(), logoImage),
      _buildSummarySection(ttfBold, ttf),
      pw.SizedBox(height: 25),
      pw.Text(
        'Daftar Hutang',
        style: pw.TextStyle(font: ttfBold, fontSize: 11, color: PdfColors.black),
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
        },
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
        },
        columnWidths: {
          0: pw.FlexColumnWidth(1.5),
          1: pw.FlexColumnWidth(3),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1),
          4: pw.FlexColumnWidth(1),
        },
        headers: ['Nama', 'Deskripsi', 'Total Hutang', 'Total Cicilan', 'Sisa Hutang'],
        data: daftarHutang
            .map<List<dynamic>>((item) => [
                  item['nama_penghutang']?.toString() ?? '',
                  '${item['deskripsi']?.toString() ?? ''}\nTanggal Hutang: ${item['tanggal_hutang']?.toString() ?? ''}\nJatuh Tempo: ${item['tanggal_jatuh_tempo']?.toString() ?? ''}',
                  item['total_hutang']?.toString() ?? '',
                  item['total_cicilan']?.toString() ?? '',
                  item['sisa_hutang']?.toString() ?? '',
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
                          'No Data',
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
                      laporanData['masjid']?['address'] ?? 'No Data',
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
              // pw.SizedBox(height: 10),
              // pw.Text(
              //   subtitle.toUpperCase(),
              //   style: pw.TextStyle(
              //     font: ttfBold,
              //     fontSize: 13,
              //     color: PdfColors.black,
              //   ),
              //   textAlign: pw.TextAlign.center,
              // ),
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

   pw.Widget _buildSummarySection(pw.Font ttfBold, pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Ringkasan',
            style: pw.TextStyle(
                font: ttfBold, fontSize: 11, color: PdfColors.black)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black),
          columnWidths: {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(0.5),
          },
          children: [
            pw.TableRow(children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'Total Hutang',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  laporanData['total_hutang']?.toString() ?? 'Rp 0',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
            ]),
          ],
        ),
      ],
    );
  }

  String _getReportTitle() {
    return 'LAPORAN HUTANG';
  }

  String _getReportSubtitle() {
    return DateFormat('dd MMMM yyyy', 'id').format(DateTime.now());
  }

  String _generateFileName() {
    final dateStr = DateFormat('ddMMyyyy').format(DateTime.now());
    return 'Laporan_Hutang_$dateStr.pdf';
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
      String shareText = 'Laporan Hutang - ${_getReportSubtitle()}';

      await share_plus.Share.shareXFiles([file],
          text: shareText, subject: shareText);
    } catch (e) {
      _showErrorSnackbar('Terjadi kesalahan saat berbagi: $e');
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
                Text('Laporan hutang telah berhasil diekspor ke PDF',
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

  void _showErrorSnackbar(String message) {
    Get.snackbar('Error', message,
        backgroundColor: AppColors.danger,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP);
  }
}