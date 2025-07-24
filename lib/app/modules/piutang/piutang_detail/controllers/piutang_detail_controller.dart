import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PiutangDetailController extends GetxController {
  final StorageService storage = Get.find<StorageService>();
  final dynamic arguments = Get.arguments;

  final RxString id = ''.obs;
  final RxString nama = ''.obs;
  final RxString keterangan = ''.obs;
  final RxString kategori = ''.obs;
  final RxString status = ''.obs;
  final RxString tanggalJatuhTempo = ''.obs;
  final RxString tanggalTransaksi = ''.obs;
  final RxString kodePiutang = ''.obs;
  final RxString tipePiutang = ''.obs;

  final RxInt totalPiutang = 0.obs;
  final RxInt totalCicilan = 0.obs;
  final RxInt sisaPiutang = 0.obs;

  final RxList<Map<String, dynamic>> daftarCicilan = <Map<String, dynamic>>[].obs;

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    fetchDetailPiutang();
  }

  void _extractArguments() {
    if (arguments != null && arguments is Map) {
      id.value = arguments['id']?.toString() ?? '';
    }
  }

  Future<void> fetchDetailPiutang() async {
    if (id.isEmpty) {
      Get.snackbar(
        'Error',
        'ID Piutang tidak valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
      return;
    }

    try {
      isLoading(true);
      
      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }
      
      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/detail-piutang/${id.value}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final detailPiutang = data['detail_piutang'];
          
          id.value = _ensureString(detailPiutang['id']);
          nama.value = _ensureString(detailPiutang['nama']);
          keterangan.value = _ensureString(detailPiutang['keterangan']);
          kategori.value = _ensureString(detailPiutang['kategori']);
          status.value = _ensureString(detailPiutang['status']);
          tanggalJatuhTempo.value = _ensureString(detailPiutang['tanggal_jatuh_tempo']);
          tanggalTransaksi.value = _ensureString(detailPiutang['tanggal_transaksi']);
          kodePiutang.value = _ensureString(detailPiutang['code']);
          tipePiutang.value = _ensureString(detailPiutang['tipe_piutang']);
          
          totalPiutang.value = detailPiutang['jumlah'] ?? 0;
          totalCicilan.value = detailPiutang['total_cicilan'] ?? 0;
          sisaPiutang.value = detailPiutang['sisa_piutang'] ?? 0;
          
          if (data['daftar_cicilan'] != null && data['daftar_cicilan'] is List) {
            final List<dynamic> cicilanList = data['daftar_cicilan'];
            final List<Map<String, dynamic>> processedCicilan = [];
            
            for (var item in cicilanList) {
              final Map<String, dynamic> cicilanItem = {
                'id': _ensureString(item['id']),
                'nama': _ensureString(item['nama']),
                'jumlah': item['jumlah'] ?? 0,
                'formatted_jumlah': _ensureString(item['formatted_jumlah']),
                'tanggal': _ensureString(item['tanggal']),
                'tanggal_raw': _ensureString(item['tanggal_raw']),
                'keterangan': _ensureString(item['keterangan']),
              };
              processedCicilan.add(cicilanItem);
            }
            
            daftarCicilan.assignAll(processedCicilan);
          } else {
            daftarCicilan.clear();
          }
          
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memuat data detail piutang');
        }
      } else {
        throw Exception('Gagal memuat data detail piutang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data detail piutang: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  String _ensureString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  void navigateToTambahCicilan() {
    final piutangData = {
      'id': id.value,
      'code': kodePiutang.value,
      'nama': nama.value,
      'jumlah': totalPiutang.value.toString(),
      'sisa': sisaPiutang.value.toString(),
    };

    Get.toNamed(Routes.PIUTANG_TAMBAH_CICILAN, arguments: piutangData)
      ?.then((_) => fetchDetailPiutang()); 
  }

  String formatCurrency(int amount) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  List<Map<String, dynamic>> getRiwayatTransaksi() {
    final List<Map<String, dynamic>> riwayat = [];
    
    riwayat.add({
      'id': id.value,
      'tanggal': tanggalTransaksi.value,
      'tanggal_raw': tanggalTransaksi.value,
      'jenis': 'Piutang',
      'nama': nama.value,
      'jumlah': totalPiutang.value,
      'formatted_jumlah': formatCurrency(totalPiutang.value),
      'keterangan': keterangan.value,
    });
    
    for (var cicilan in daftarCicilan) {
      riwayat.add({
        'id': cicilan['id'],
        'tanggal': cicilan['tanggal'],
        'tanggal_raw': cicilan['tanggal_raw'],
        'jenis': 'Pembayaran',
        'nama': cicilan['nama'],
        'jumlah': -cicilan['jumlah'],
        'formatted_jumlah': cicilan['formatted_jumlah'],
        'keterangan': cicilan['keterangan'],
      });
    }
    
    riwayat.sort((a, b) {
      DateTime? dateA, dateB;
      try {
        dateA = DateFormat('dd MMM yyyy', 'id').parse(a['tanggal'] ?? '');
        dateB = DateFormat('dd MMM yyyy', 'id').parse(b['tanggal'] ?? '');
      } catch (e) {
        try {
          dateA = DateTime.parse(a['tanggal_raw'] ?? '');
          dateB = DateTime.parse(b['tanggal_raw'] ?? '');
        } catch (e) {
          return 0;
        }
      }
      return dateB.compareTo(dateA);
    });
    
    return riwayat;
  }
}