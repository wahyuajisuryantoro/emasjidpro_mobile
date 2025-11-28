import 'dart:convert';
import 'dart:io';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class HutangDaftarController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final searchController = TextEditingController();
  final isSearchVisible = false.obs;

  final isLoading = true.obs;

  final selectedPeriod = 'Semua'.obs;
  final selectedStatus = 'Semua'.obs;
  final sortKey = 'newest'.obs;
  final sortLabel = 'Terbaru'.obs;

  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;

  final allHutang = <Map<String, dynamic>>[].obs;
  final filteredHutang = <Map<String, dynamic>>[].obs;

  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }

  @override
  void onInit() {
    super.onInit();
    fetchDaftarHutang();
  }

  void toggleSearchBar() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      searchController.clear();
      applyFilters();
    }
  }

  void onSearchChanged(String value) {
    applyFilters();
  }

  void setSelectedPeriod(String period) {
    selectedPeriod.value = period;
    applyFilters();
  }

  void setSelectedStatus(String status) {
    selectedStatus.value = status;
    applyFilters();
  }

  void setSortOption(String key, String label) {
    sortKey.value = key;
    sortLabel.value = label;
    applyFilters();
  }

  void showCustomDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: startDate.value,
        end: endDate.value,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFFFDE00),
            colorScheme: const ColorScheme.light(primary: Color(0xFFFFDE00)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;

      final startFormatted = DateFormat('dd/MM/yyyy').format(picked.start);
      final endFormatted = DateFormat('dd/MM/yyyy').format(picked.end);
      selectedPeriod.value = '$startFormatted - $endFormatted';

      applyFilters();
    }
  }

  void applyFilters() {
    if (allHutang.isEmpty) return;

    isLoading.value = true;

    List<Map<String, dynamic>> result = List.from(allHutang);

    if (searchController.text.isNotEmpty) {
      final searchQuery = searchController.text.toLowerCase();
      result = result.where((hutang) {
        final nama = _ensureString(hutang['nama']).toLowerCase();
        final kategori = _ensureString(hutang['kategori']).toLowerCase();
        final keterangan = _ensureString(hutang['keterangan']).toLowerCase();

        return nama.contains(searchQuery) ||
            kategori.contains(searchQuery) ||
            keterangan.contains(searchQuery);
      }).toList();
    }

    if (selectedStatus.value != 'Semua') {
      result = result.where((hutang) {
        final status = _ensureString(hutang['status']);
        return status == selectedStatus.value;
      }).toList();
    }

    if (selectedPeriod.value != 'Semua') {
      switch (selectedPeriod.value) {
        case 'Hari Ini':
          final today = DateTime.now();
          final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
          result = result.where((hutang) {
            DateTime? tanggal;
            try {
              if (hutang['tanggal_jatuh_tempo'] != null) {
                tanggal =
                    DateTime.parse(hutang['tanggal_jatuh_tempo'].toString());
              } else if (hutang['tanggal'] != null) {
                tanggal = _parseDate(hutang['tanggal'].toString());
              }
            } catch (e) {
              return false;
            }

            if (tanggal == null) return false;
            final tanggalFormatted = DateFormat('yyyy-MM-dd').format(tanggal);
            return tanggalFormatted == todayFormatted;
          }).toList();
          break;

        case 'Minggu Ini':
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(Duration(days: 6));
          result = result.where((hutang) {
            DateTime? tanggal;
            try {
              if (hutang['tanggal_jatuh_tempo'] != null) {
                tanggal =
                    DateTime.parse(hutang['tanggal_jatuh_tempo'].toString());
              } else if (hutang['tanggal'] != null) {
                tanggal = _parseDate(hutang['tanggal'].toString());
              }
            } catch (e) {
              return false;
            }

            if (tanggal == null) return false;
            return tanggal.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                tanggal.isBefore(endOfWeek.add(Duration(days: 1)));
          }).toList();
          break;

        case 'Bulan Ini':
          final now = DateTime.now();
          final startOfMonth = DateTime(now.year, now.month, 1);
          final endOfMonth = DateTime(now.year, now.month + 1, 0);
          result = result.where((hutang) {
            DateTime? tanggal;
            try {
              if (hutang['tanggal_jatuh_tempo'] != null) {
                tanggal =
                    DateTime.parse(hutang['tanggal_jatuh_tempo'].toString());
              } else if (hutang['tanggal'] != null) {
                tanggal = _parseDate(hutang['tanggal'].toString());
              }
            } catch (e) {
              return false;
            }

            if (tanggal == null) return false;
            return tanggal.isAfter(startOfMonth.subtract(Duration(days: 1))) &&
                tanggal.isBefore(endOfMonth.add(Duration(days: 1)));
          }).toList();
          break;

        case 'Tahun Ini':
          final now = DateTime.now();
          final startOfYear = DateTime(now.year, 1, 1);
          final endOfYear = DateTime(now.year, 12, 31);
          result = result.where((hutang) {
            DateTime? tanggal;
            try {
              if (hutang['tanggal_jatuh_tempo'] != null) {
                tanggal =
                    DateTime.parse(hutang['tanggal_jatuh_tempo'].toString());
              } else if (hutang['tanggal'] != null) {
                tanggal = _parseDate(hutang['tanggal'].toString());
              }
            } catch (e) {
              return false;
            }

            if (tanggal == null) return false;
            return tanggal.isAfter(startOfYear.subtract(Duration(days: 1))) &&
                tanggal.isBefore(endOfYear.add(Duration(days: 1)));
          }).toList();
          break;
        default:
          if (selectedPeriod.value.contains('-')) {
            result = result.where((hutang) {
              DateTime? tanggal;
              try {
                if (hutang['tanggal_jatuh_tempo'] != null) {
                  tanggal =
                      DateTime.parse(hutang['tanggal_jatuh_tempo'].toString());
                } else if (hutang['tanggal'] != null) {
                  tanggal = _parseDate(hutang['tanggal'].toString());
                }
              } catch (e) {
                return false;
              }

              if (tanggal == null) return false;
              return tanggal
                      .isAfter(startDate.value.subtract(Duration(days: 1))) &&
                  tanggal.isBefore(endDate.value.add(Duration(days: 1)));
            }).toList();
          }
          break;
      }
    }

    switch (sortKey.value) {
      case 'newest':
        result.sort((a, b) {
          DateTime? dateA, dateB;
          try {
            if (a['tanggal_jatuh_tempo'] != null) {
              dateA = DateTime.parse(a['tanggal_jatuh_tempo'].toString());
            } else if (a['tanggal'] != null) {
              dateA = _parseDate(a['tanggal'].toString());
            }

            if (b['tanggal_jatuh_tempo'] != null) {
              dateB = DateTime.parse(b['tanggal_jatuh_tempo'].toString());
            } else if (b['tanggal'] != null) {
              dateB = _parseDate(b['tanggal'].toString());
            }
          } catch (e) {
            return 0;
          }

          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
        break;

      case 'oldest':
        result.sort((a, b) {
          DateTime? dateA, dateB;
          try {
            if (a['tanggal_jatuh_tempo'] != null) {
              dateA = DateTime.parse(a['tanggal_jatuh_tempo'].toString());
            } else if (a['tanggal'] != null) {
              dateA = _parseDate(a['tanggal'].toString());
            }

            if (b['tanggal_jatuh_tempo'] != null) {
              dateB = DateTime.parse(b['tanggal_jatuh_tempo'].toString());
            } else if (b['tanggal'] != null) {
              dateB = _parseDate(b['tanggal'].toString());
            }
          } catch (e) {
            return 0;
          }

          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });
        break;

      case 'highest':
        result.sort((a, b) {
          int amountA = 0, amountB = 0;

          if (a['jumlah'] != null) {
            if (a['jumlah'] is int) {
              amountA = a['jumlah'];
            } else if (a['jumlah'] is String) {
              amountA = _extractAmount(a['jumlah'].toString()).toInt();
            }
          }

          if (b['jumlah'] != null) {
            if (b['jumlah'] is int) {
              amountB = b['jumlah'];
            } else if (b['jumlah'] is String) {
              amountB = _extractAmount(b['jumlah'].toString()).toInt();
            }
          }

          return amountB.compareTo(amountA);
        });
        break;

      case 'lowest':
        result.sort((a, b) {
          int amountA = 0, amountB = 0;

          if (a['jumlah'] != null) {
            if (a['jumlah'] is int) {
              amountA = a['jumlah'];
            } else if (a['jumlah'] is String) {
              amountA = _extractAmount(a['jumlah'].toString()).toInt();
            }
          }

          if (b['jumlah'] != null) {
            if (b['jumlah'] is int) {
              amountB = b['jumlah'];
            } else if (b['jumlah'] is String) {
              amountB = _extractAmount(b['jumlah'].toString()).toInt();
            }
          }

          return amountA.compareTo(amountB);
        });
        break;

      case 'nama_asc':
        result.sort((a, b) =>
            _ensureString(a['nama']).compareTo(_ensureString(b['nama'])));
        break;

      case 'nama_desc':
        result.sort((a, b) =>
            _ensureString(b['nama']).compareTo(_ensureString(a['nama'])));
        break;
    }

    filteredHutang.value = result;

    Future.delayed(Duration(milliseconds: 300), () {
      isLoading.value = false;
    });
  }

  DateTime _parseDate(String dateString) {
    final formats = [
      'dd MMM yyyy',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'd MMM yyyy',
    ];

    for (var format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (e) {}
    }

    return DateTime.now();
  }

  double _extractAmount(String amount) {
    if (amount.isEmpty) return 0;

    try {
      return double.parse(amount);
    } catch (e) {
      String numericString = amount.replaceAll(RegExp(r'[^0-9]'), '');
      if (numericString.isEmpty) return 0;
      try {
        return double.parse(numericString);
      } catch (e) {
        return 0;
      }
    }
  }

  String _ensureString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  void navigateToDetailHutang(String id) {
    Get.toNamed(Routes.HUTANG_DETAIL, arguments: {'id': id})?.then((result) {
      if (result != null) {
        fetchDaftarHutang();
      }
    });
  }

  void navigateToTambahHutang() {
    Get.toNamed(Routes.HUTANG_TAMBAH)?.then((result) {
      if (result != null) {
        fetchDaftarHutang();
      }
    });
  }

  Future<void> fetchDaftarHutang() async {
    try {
      isLoading(true);

      final token = storage.getToken();
      if (token == null) {
        throw Exception('No authentication token');
      }

      Map<String, String> queryParams = {};

      if (selectedStatus.value != 'Semua') {
        queryParams['status'] =
            selectedStatus.value == 'Lunas' ? 'paid' : 'unpaid';
      }

      if (selectedPeriod.value == 'Hari Ini') {
        queryParams['period'] = 'today';
      } else if (selectedPeriod.value == 'Minggu Ini') {
        queryParams['period'] = 'week';
      } else if (selectedPeriod.value == 'Bulan Ini') {
        queryParams['period'] = 'month';
      } else if (selectedPeriod.value == 'Tahun Ini') {
        queryParams['period'] = 'year';
      } else if (selectedPeriod.value.contains('-')) {
        queryParams['period'] = 'custom';
        queryParams['start_date'] =
            DateFormat('yyyy-MM-dd').format(startDate.value);
        queryParams['end_date'] =
            DateFormat('yyyy-MM-dd').format(endDate.value);
      }

      if (searchController.text.isNotEmpty) {
        queryParams['search'] = searchController.text;
      }

      queryParams['sort'] = sortKey.value;

      final uri = Uri.parse('${BaseUrl.baseUrl}/daftar-hutang')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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

          if (data['daftar_hutang'] != null && data['daftar_hutang'] is List) {
            final List<dynamic> hutangList = data['daftar_hutang'];
            allHutang.value = List<Map<String, dynamic>>.from(hutangList);
            applyFilters();
          } else {
            allHutang.clear();
            filteredHutang.clear();
          }
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal memuat data hutang');
        }
      } else {
        throw Exception(
            'Gagal memuat data hutang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data hutang',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    await fetchDaftarHutang();
  }

  @override
  void onReady() {
    super.onReady();
    if (filteredHutang.isEmpty) {
      fetchDaftarHutang();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
