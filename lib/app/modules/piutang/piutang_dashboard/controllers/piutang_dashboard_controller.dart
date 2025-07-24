import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:http/http.dart' as http;

class PiutangDashboardController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final isLoading = false.obs;

  // Ringkasan piutang
  final totalPiutang = 'Rp 0'.obs;
  final totalTerhutang = 'Rp 0'.obs;

  // Counter
  final piutangCount = 0.obs;
  final terhutangCount = 0.obs;

  // Data
  final daftarPiutang = <Map<String, dynamic>>[].obs;
  final daftarTerhutang = <Map<String, dynamic>>[].obs;
  final kategoriPiutang = <Map<String, dynamic>>[].obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/dashboard-piutang'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];
          final ringkasan = data['ringkasan'];

          totalPiutang.value =
              _ensureString(ringkasan['formatted_totalPiutang'] ?? 'Rp 0');
          totalTerhutang.value =
              _ensureString(ringkasan['formatted_totalTagihan'] ?? 'Rp 0');

          piutangCount.value = ringkasan['piutangCount'] ?? 0;
          terhutangCount.value = ringkasan['penghutangCount'] ?? 0;
          
          if (data['daftarPiutang'] != null && data['daftarPiutang'] is List) {
            final List<dynamic> piutangList = data['daftarPiutang'];
            final List<Map<String, dynamic>> processedPiutang = [];

            for (var item in piutangList) {
              final Map<String, dynamic> piutangItem = {
                'id': _ensureString(item['id']),
                'nama': _ensureString(item['nama']),
                'jumlah': _ensureString(item['formatted_jumlah'] ?? 'Rp 0'),
                'sisa': _ensureString(item['formatted_sisa'] ?? 'Rp 0'),
                'tanggal': _ensureString(item['tanggal']),
                'kategori': _ensureString(item['kategori']),
                'status': _ensureString(item['status']),
                'keterangan': _ensureString(item['keterangan'] ?? ''),
              };
              processedPiutang.add(piutangItem);
            }

            daftarPiutang.assignAll(processedPiutang);
          } else {
            daftarPiutang.clear();
          }

          // Proses daftar terhutang (cicilan piutang)
          if (data['daftarCicilanPiutang'] != null &&
              data['daftarCicilanPiutang'] is List) {
            final List<dynamic> terhutangList = data['daftarCicilanPiutang'];
            final List<Map<String, dynamic>> processedTerhutang = [];

            for (var item in terhutangList) {
              final Map<String, dynamic> terhutangItem = {
                'id': _ensureString(item['id']),
                'nama': _ensureString(item['nama']),
                'jumlah': _ensureString(item['jumlah']),
                'sisa': _ensureString(item['sisa'] ?? 'Rp 0'),
                'tanggal': _ensureString(item['tanggal']),
                'kategori': _ensureString(item['kategori']),
                'status': _ensureString(item['status']),
                'keterangan': _ensureString(item['keterangan'] ?? ''),
              };
              processedTerhutang.add(terhutangItem);
            }

            daftarTerhutang.assignAll(processedTerhutang);
          } else {
            daftarTerhutang.clear();
          }

          // Proses kategori piutang
          if (data['ringkasan_kategori'] != null &&
              data['ringkasan_kategori']['kategori_piutang'] != null &&
              data['ringkasan_kategori']['kategori_piutang'] is List) {
            final List<dynamic> kategoriList =
                data['ringkasan_kategori']['kategori_piutang'];
            final List<Map<String, dynamic>> processedKategori = [];

            for (var item in kategoriList) {
              final Map<String, dynamic> kategoriItem = {
                'nama_kategori': _ensureString(item['nama_kategori']),
                'kode_kategori': _ensureString(item['kode_kategori']),
                'status': _ensureString(item['status']),
                'total_value': item['total_value'] ?? 0,
                'total_dibayar': item['total_dibayar'] ?? 0,
                'sisa': item['sisa'] ?? 0,
                'formatted_total': _ensureString(item['formatted_total']),
                'formatted_sisa': _ensureString(item['formatted_sisa']),
              };
              processedKategori.add(kategoriItem);
            }

            kategoriPiutang.assignAll(processedKategori);
          } else {
            kategoriPiutang.clear();
          }
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to load dashboard data');
        }
      } else {
        throw Exception(
            'Failed to load dashboard data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _setDefaultValues();
    } finally {
      isLoading(false);
    }
  }

  String _ensureString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  void navigateToDetailPiutang(String id) {
    Get.toNamed(Routes.PIUTANG_DETAIL, arguments: {'id': id})?.then((result) {
      if (result != null) {
        fetchDashboardData();
      }
    });
  }

  void navigateToDaftarPiutang() {
    Get.toNamed(Routes.PIUTANG_DAFTAR);
  }

  void _setDefaultValues() {
    totalPiutang.value = 'Rp 0';
    totalTerhutang.value = 'Rp 0';

    piutangCount.value = 0;
    terhutangCount.value = 0;

    daftarPiutang.clear();
    daftarTerhutang.clear();
    kategoriPiutang.clear();
  }

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
