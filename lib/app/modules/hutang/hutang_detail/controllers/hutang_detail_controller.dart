import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HutangDetailController extends GetxController {
  final StorageService storage = Get.find<StorageService>();
  final dynamic arguments = Get.arguments;

  final RxString id = ''.obs;
  final RxString nama = ''.obs;
  final RxString keterangan = ''.obs;
  final RxString kategori = ''.obs;
  final RxString status = ''.obs;
  final RxString tanggalJatuhTempo = ''.obs;
  final RxString tanggalTransaksi = ''.obs;
  final RxString kodeHutang = ''.obs;
  final RxString tipeHutang = ''.obs;

  final RxInt totalHutang = 0.obs;
  final RxInt totalCicilan = 0.obs;
  final RxInt sisaHutang = 0.obs;

  final RxList<Map<String, dynamic>> daftarCicilan =
      <Map<String, dynamic>>[].obs;

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _extractArguments();
    fetchDetailHutang();
  }

  void _extractArguments() {
    if (arguments != null && arguments is Map) {
      id.value = arguments['id']?.toString() ?? '';
    }
  }

  Future<void> fetchDetailHutang() async {
    if (id.isEmpty) {
      Get.snackbar(
        'Error',
        'ID Hutang tidak valid',
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
        Uri.parse('${BaseUrl.baseUrl}/detail-hutang/${id.value}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];
          final detailHutang = data['detail_hutang'];

          id.value = _ensureString(detailHutang['id']);
          nama.value = _ensureString(detailHutang['nama']);
          keterangan.value = _ensureString(detailHutang['keterangan']);
          kategori.value = _ensureString(detailHutang['kategori']);
          status.value = _ensureString(detailHutang['status']);
          tanggalJatuhTempo.value =
              _ensureString(detailHutang['tanggal_jatuh_tempo']);
          tanggalTransaksi.value =
              _ensureString(detailHutang['tanggal_transaksi']);
          kodeHutang.value = _ensureString(detailHutang['code']);
          tipeHutang.value = _ensureString(detailHutang['tipe_hutang']);

          totalHutang.value = detailHutang['jumlah'] ?? 0;
          totalCicilan.value = detailHutang['total_cicilan'] ?? 0;
          sisaHutang.value = detailHutang['sisa_hutang'] ?? 0;

          if (data['daftar_cicilan'] != null &&
              data['daftar_cicilan'] is List) {
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
          throw Exception(
              responseData['message'] ?? 'Gagal memuat data detail hutang');
        }
      } else {
        throw Exception(
            'Gagal memuat data detail hutang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data detail hutang: $e',
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

  void navigateToTambahCicilan() async {
    final hutangData = {
      'id': id.value,
      'code': kodeHutang.value,
      'nama': nama.value,
      'jumlah': totalHutang.value.toString(),
      'sisa': sisaHutang.value.toString(),
    };

    final result =
        await Get.toNamed(Routes.HUTANG_TAMBAH_CICILAN, arguments: hutangData);

    if (result == 'refresh') {
      fetchDetailHutang();
    }
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
      'jenis': 'Hutang',
      'nama': nama.value,
      'jumlah': totalHutang.value,
      'formatted_jumlah': formatCurrency(totalHutang.value),
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
