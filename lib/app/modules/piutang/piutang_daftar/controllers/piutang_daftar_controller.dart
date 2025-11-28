import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class PiutangDaftarController extends GetxController {
  final StorageService storage = Get.find<StorageService>();
  
  // Search functionality
  final searchController = TextEditingController();
  final isSearchVisible = false.obs;
  
  // Loading state
  final isLoading = true.obs;
  
  // Filter and sort state
  final selectedPeriod = 'Semua'.obs;
  final selectedStatus = 'Semua'.obs;
  final sortKey = 'newest'.obs;
  final sortLabel = 'Terbaru'.obs;
  
  // Custom date range
  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;
  
  // Piutang data
  final allPiutang = <Map<String, dynamic>>[].obs;
  final filteredPiutang = <Map<String, dynamic>>[].obs;
  
  // Initialize AppResponsive
  void initResponsive(BuildContext context) {
    AppResponsive().init(context);
  }
  
  // Toggle search bar visibility
  void toggleSearchBar() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      searchController.clear();
      applyFilters();
    }
  }
  
  // Handle search input changes
  void onSearchChanged(String value) {
    applyFilters();
  }
  
  // Set the selected period
  void setSelectedPeriod(String period) {
    selectedPeriod.value = period;
    
    if (period == 'Kustom...') {
      showCustomDateRangePicker();
    } else {
      applyFilters();
    }
  }
  
  // Set the selected status
  void setSelectedStatus(String status) {
    selectedStatus.value = status;
    applyFilters();
  }
  
  // Set sorting option
  void setSortOption(String key, String label) {
    sortKey.value = key;
    sortLabel.value = label;
    applyFilters();
  }
  
  // Show custom date range picker
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
            primaryColor: const Color(0xFF3D68DF),
            colorScheme: const ColorScheme.light(primary: Color(0xFF3D68DF)),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
      
      // Update selected period text to show date range
      final startFormatted = DateFormat('dd/MM/yyyy').format(picked.start);
      final endFormatted = DateFormat('dd/MM/yyyy').format(picked.end);
      selectedPeriod.value = '$startFormatted - $endFormatted';
      
      applyFilters();
    }
  }
  
  // Apply filters and update UI
  void applyFilters() {
    if (allPiutang.isEmpty) return;
    
    isLoading(true);
    
    List<Map<String, dynamic>> result = List.from(allPiutang);
    
    // Apply search filter
    if (searchController.text.isNotEmpty) {
      final searchQuery = searchController.text.toLowerCase();
      result = result.where((piutang) {
        final nama = _ensureString(piutang['nama']).toLowerCase();
        final kategori = _ensureString(piutang['kategori']).toLowerCase();
        final keterangan = _ensureString(piutang['keterangan']).toLowerCase();
        
        return nama.contains(searchQuery) || 
               kategori.contains(searchQuery) || 
               keterangan.contains(searchQuery);
      }).toList();
    }
    
    // Apply status filter
    if (selectedStatus.value != 'Semua') {
      result = result.where((piutang) {
        final status = _ensureString(piutang['status']);
        return status == selectedStatus.value;
      }).toList();
    }
    
    // Apply period filter
    if (selectedPeriod.value != 'Semua') {
      switch (selectedPeriod.value) {
        case 'Hari Ini':
          final today = DateTime.now();
          final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
          result = result.where((piutang) {
            DateTime? tanggal;
            try {
              if (piutang['tanggal_jatuh_tempo'] != null) {
                tanggal = DateTime.parse(piutang['tanggal_jatuh_tempo'].toString());
              } else if (piutang['tanggal'] != null) {
                tanggal = _parseDate(piutang['tanggal'].toString());
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
          result = result.where((piutang) {
            DateTime? tanggal;
            try {
              if (piutang['tanggal_jatuh_tempo'] != null) {
                tanggal = DateTime.parse(piutang['tanggal_jatuh_tempo'].toString());
              } else if (piutang['tanggal'] != null) {
                tanggal = _parseDate(piutang['tanggal'].toString());
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
          result = result.where((piutang) {
            DateTime? tanggal;
            try {
              if (piutang['tanggal_jatuh_tempo'] != null) {
                tanggal = DateTime.parse(piutang['tanggal_jatuh_tempo'].toString());
              } else if (piutang['tanggal'] != null) {
                tanggal = _parseDate(piutang['tanggal'].toString());
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
          result = result.where((piutang) {
            DateTime? tanggal;
            try {
              if (piutang['tanggal_jatuh_tempo'] != null) {
                tanggal = DateTime.parse(piutang['tanggal_jatuh_tempo'].toString());
              } else if (piutang['tanggal'] != null) {
                tanggal = _parseDate(piutang['tanggal'].toString());
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
            result = result.where((piutang) {
              DateTime? tanggal;
              try {
                if (piutang['tanggal_jatuh_tempo'] != null) {
                  tanggal = DateTime.parse(piutang['tanggal_jatuh_tempo'].toString());
                } else if (piutang['tanggal'] != null) {
                  tanggal = _parseDate(piutang['tanggal'].toString());
                }
              } catch (e) {
                return false;
              }
              
              if (tanggal == null) return false;
              return tanggal.isAfter(startDate.value.subtract(Duration(days: 1))) && 
                     tanggal.isBefore(endDate.value.add(Duration(days: 1)));
            }).toList();
          }
          break;
      }
    }
    
    // Apply sorting
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
        result.sort((a, b) => _ensureString(a['nama']).compareTo(_ensureString(b['nama'])));
        break;
        
      case 'nama_desc':
        result.sort((a, b) => _ensureString(b['nama']).compareTo(_ensureString(a['nama'])));
        break;
    }
    
    filteredPiutang.value = result;
    
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
  
  Future<void> fetchDaftarPiutang() async {
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
      
      final uri = Uri.parse('${BaseUrl.baseUrl}/daftar-piutang')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          
          if (data['daftar_piutang'] != null && data['daftar_piutang'] is List) {
            final List<dynamic> piutangList = data['daftar_piutang'];
            allPiutang.value = List<Map<String, dynamic>>.from(piutangList);
            applyFilters();
          } else {
            allPiutang.clear();
            filteredPiutang.clear();
          }
        } else {
          throw Exception(
              responseData['message'] ?? 'Gagal memuat data piutang');
        }
      } else {
        throw Exception(
            'Gagal memuat data piutang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data piutang: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
  
  // Navigate to detail piutang
  void navigateToDetailPiutang(String id) {
    Get.toNamed(Routes.PIUTANG_DETAIL, arguments: {'id': id})?.then((result) {
      if (result == 'refresh') {
        fetchDaftarPiutang();
      }
    });
  }
  
  // Navigate to tambah piutang
  void navigateToTambahPiutang() {
    Get.toNamed(Routes.PIUTANG_TAMBAH)?.then((result) {
      if (result == 'refresh') {
        fetchDaftarPiutang();
      }
    });
  }
  
  @override
  void onInit() {
    super.onInit();
    fetchDaftarPiutang();
  }
  
  @override
  void onReady() {
    super.onReady();
    if (filteredPiutang.isEmpty) {
      fetchDaftarPiutang();
    }
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}