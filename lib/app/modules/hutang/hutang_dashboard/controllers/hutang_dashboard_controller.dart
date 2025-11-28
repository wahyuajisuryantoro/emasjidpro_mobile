import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:http/http.dart' as http;

class HutangDashboardController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final isLoading = false.obs;

  // Ringkasan hutang
  final totalHutangBruto = 'Rp 0'.obs;
  final totalHutangTerbayar = 'Rp 0'.obs;
  final totalHutang = 'Rp 0'.obs;

  // Ringkasan tagihan/piutang
  final totalPiutangBruto = 'Rp 0'.obs;
  final totalPiutangTerbayar = 'Rp 0'.obs;
  final totalTagihan = 'Rp 0'.obs;

  // Counter
  final rekananCount = 0.obs;
  final penghutangCount = 0.obs;

  // Data
  final daftarHutang = <Map<String, dynamic>>[].obs;
  final daftarTagihan = <Map<String, dynamic>>[].obs;
  final kategoriHutang = <Map<String, dynamic>>[].obs;

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
        Uri.parse('${BaseUrl.baseUrl}/dashboard-hutang'),
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
          totalHutangBruto.value =
              _ensureString(ringkasan['formatted_totalHutangBruto'] ?? 'Rp 0');
          totalHutangTerbayar.value = _ensureString(
              ringkasan['formatted_totalHutangTerbayar'] ?? 'Rp 0');
          totalHutang.value =
              _ensureString(ringkasan['formatted_totalHutang'] ?? 'Rp 0');
          totalPiutangBruto.value =
              _ensureString(ringkasan['formatted_totalPiutangBruto'] ?? 'Rp 0');
          totalPiutangTerbayar.value = _ensureString(
              ringkasan['formatted_totalPiutangTerbayar'] ?? 'Rp 0');
          totalTagihan.value =
              _ensureString(ringkasan['formatted_totalTagihan'] ?? 'Rp 0');
          rekananCount.value = ringkasan['rekananCount'] ?? 0;
          penghutangCount.value = ringkasan['penghutangCount'] ?? 0;
          if (data['ringkasan_kategori'] != null &&
              data['ringkasan_kategori']['kategori_hutang'] != null &&
              data['ringkasan_kategori']['kategori_hutang'] is List) {
            final List<dynamic> kategoriList =
                data['ringkasan_kategori']['kategori_hutang'];
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

            kategoriHutang.assignAll(processedKategori);
          } else {
            kategoriHutang.clear();
          }
          if (data['daftarHutang'] != null && data['daftarHutang'] is List) {
            final List<dynamic> hutangList = data['daftarHutang'];
            final List<Map<String, dynamic>> processedHutang = [];

            for (var item in hutangList) {
              final Map<String, dynamic> hutangItem = {
                'id': _ensureString(item['id']),
                'nama': _ensureString(item['nama']),
                'jumlah': _ensureString(item['jumlah']),
                'sisa': _ensureString(item['sisa'] ?? 'Rp 0'),
                'tanggal': _ensureString(item['tanggal']),
                'kategori': _ensureString(item['kategori']),
                'status': _ensureString(item['status']),
                'keterangan': _ensureString(item['keterangan'] ?? ''),
              };
              processedHutang.add(hutangItem);
            }

            daftarHutang.assignAll(processedHutang);
          } else {
            daftarHutang.clear();
          }
          if (data['daftarTagihan'] != null && data['daftarTagihan'] is List) {
            final List<dynamic> tagihanList = data['daftarTagihan'];
            final List<Map<String, dynamic>> processedTagihan = [];

            for (var item in tagihanList) {
              final Map<String, dynamic> tagihanItem = {
                'id': _ensureString(item['id']),
                'nama': _ensureString(item['nama']),
                'jumlah': _ensureString(item['jumlah']),
                'sisa': _ensureString(item['sisa'] ?? 'Rp 0'),
                'tanggal': _ensureString(item['tanggal']),
                'kategori': _ensureString(item['kategori']),
                'status': _ensureString(item['status']),
                'keterangan': _ensureString(item['keterangan'] ?? ''),
              };
              processedTagihan.add(tagihanItem);
            }

            daftarTagihan.assignAll(processedTagihan);
          } else {
            daftarTagihan.clear();
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
        'Terjadi Kesalahan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _setDefaultValues();
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    await fetchDashboardData();
  }

  String _ensureString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  void navigateToDetailHutang(String id) {
    Get.toNamed(Routes.HUTANG_DETAIL, arguments: {'id': id})?.then((result) {
      if (result != null) {
        fetchDashboardData();
      }
    });
  }

  void navigateToDaftarHutang() {
    Get.toNamed(Routes.HUTANG_DAFTAR);
  }

  void navigateToDaftarTagihan() {}

  void _setDefaultValues() {
    totalHutangBruto.value = 'Rp 0';
    totalHutangTerbayar.value = 'Rp 0';
    totalHutang.value = 'Rp 0';

    totalPiutangBruto.value = 'Rp 0';
    totalPiutangTerbayar.value = 'Rp 0';
    totalTagihan.value = 'Rp 0';

    rekananCount.value = 0;
    penghutangCount.value = 0;

    daftarHutang.clear();
    daftarTagihan.clear();
    kategoriHutang.clear();
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
