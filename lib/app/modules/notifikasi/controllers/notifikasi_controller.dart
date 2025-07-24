import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/modules/home/controllers/home_controller.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:remixicon/remixicon.dart';

class NotifikasiController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Observable variables
  final isLoading = false.obs;
  final selectedFilter = 'all'.obs;
  final expandedItems = <int>{}.obs;
  final notifications = <Map<String, dynamic>>[].obs;
  
  // Pagination
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;
  
  // Counts
  final totalCount = 0.obs;
  final unreadCount = 0.obs;
  final urgentCount = 0.obs;
  final highCount = 0.obs;
  final normalCount = 0.obs;
  final lowCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchNotificationCounts();
  }

  // Fetch notifications from API
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
        notifications.clear();
      }

      isLoading.value = true;

      final token = _storageService.getToken();
      if (token == null) {
        Get.snackbar('Error', 'Token tidak ditemukan, silahkan login ulang');
        return;
      }
      Map<String, String> queryParams = {
        'page': currentPage.value.toString(),
        'limit': '20',
      };

      if (selectedFilter.value != 'all') {
        if (selectedFilter.value == 'unread') {
          queryParams['filter'] = 'unread';
        } else {
          if (['urgent', 'high', 'normal', 'low'].contains(selectedFilter.value)) {
            queryParams['priority'] = selectedFilter.value;
          }
        }
      }

      final uri = Uri.parse('${BaseUrl.baseUrl}/notifications').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final newNotifications = List<Map<String, dynamic>>.from(
            data['data']['notifications'].map((item) => {
              'id': item['id'],
              'title': item['title'],
              'message': item['message'],
              'icon': item['icon'] ?? 'ri-notification-line',
              'priority': item['priority'] ?? 'normal',
              'isRead': item['is_read'] == true,
              'date': DateTime.parse(item['date']),
              'formattedDate': item['formatted_date'] ?? '',
              'type': item['type'] ?? 'general',
              'messageData': item['message_data'],
            })
          );

          if (isRefresh) {
            notifications.value = newNotifications;
          } else {
            notifications.addAll(newNotifications);
          }
          final pagination = data['data']['pagination'];
          hasMore.value = pagination['has_more'] ?? false;
          final counts = data['data']['counts'];
          totalCount.value = counts['total'] ?? 0;
          unreadCount.value = counts['unread'] ?? 0;
        }
      } else {
        Get.snackbar('Error', 'Gagal memuat notifikasi');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Fetch notification counts
  Future<void> fetchNotificationCounts() async {
    try {
      final token = _storageService.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${BaseUrl.baseUrl}/notifications/counts'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final counts = data['data'];
          totalCount.value = counts['total'] ?? 0;
          unreadCount.value = counts['unread'] ?? 0;
          urgentCount.value = counts['urgent'] ?? 0;
          highCount.value = counts['high'] ?? 0;
          normalCount.value = counts['normal'] ?? 0;
          lowCount.value = counts['low'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  // Load more notifications for pagination
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    
    isLoadingMore.value = true;
    currentPage.value++;
    await fetchNotifications();
  }

  // Mark notification as read
   Future<void> markAsRead(int id) async {
    try {
      final token = _storageService.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/notifications/$id/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final index = notifications.indexWhere((item) => item['id'] == id);
          if (index != -1) {
            notifications[index]['isRead'] = true;
            notifications.refresh();
            if (unreadCount.value > 0) {
              unreadCount.value--;
            }
          }
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshNotificationCount();
          }
        }
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  // Mark all notifications as read
 Future<void> markAllAsRead() async {
    try {
      final token = _storageService.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/notifications/read-all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Update all local notifications as read
          for (var notification in notifications) {
            notification['isRead'] = true;
          }
          notifications.refresh();
          unreadCount.value = 0;  
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshNotificationCount();
          }
          
          Get.snackbar('Sukses', data['message'] ?? 'Semua notifikasi ditandai sebagai dibaca');
        }
      }
    } catch (e) {
      print('Error marking all as read: $e');
      Get.snackbar('Error', 'Gagal menandai semua notifikasi');
    }
  }

  // Delete notification
  Future<void> deleteNotification(int id) async {
    try {
      final token = _storageService.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${BaseUrl.baseUrl}/notifications/$id/delete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          notifications.removeWhere((item) => item['id'] == id);
        }
        if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshNotificationCount();
          }
      }
    } catch (e) {
      print('Error deleting notification: $e');
      Get.snackbar('Error', 'Gagal menghapus notifikasi');
    }
  }

  // Toggle expand/collapse for long text
  void toggleExpand(int id) {
    if (expandedItems.contains(id)) {
      expandedItems.remove(id);
    } else {
      expandedItems.add(id);
    }
  }

  // Check if item is expanded
  bool isExpanded(int id) {
    return expandedItems.contains(id);
  }

  // Filter notifications
  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter.value == 'all') {
      return notifications;
    } else if (selectedFilter.value == 'unread') {
      return notifications.where((item) => !item['isRead']).toList();
    }
    return notifications;
  }

  // Change filter and refresh data
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    // Untuk local filtering saja, tidak perlu refresh dari server
    // karena hanya ada 2 filter: all dan unread
  }

  // Get priority color
  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return const Color(0xFFFF0000); // AppColors.danger
      case 'high':
        return const Color(0xFFFFDE00); // AppColors.warning
      case 'normal':
        return const Color(0xFF3674B5); // AppColors.info
      case 'low':
        return const Color(0xFF9DDE8B); // AppColors.success
      default:
        return const Color(0xFFF5F5F7); // AppColors.muted
    }
  }

  // Get Remix Icon by name
  IconData getRemixIconByName(String iconName) {
    // Langsung mapping nama icon dari database ke Remix Icons
    switch (iconName) {
      case 'money_dollar_circle_line':
        return Remix.money_dollar_circle_line;
      case 'coins_line':
        return Remix.coins_line;
      case 'bank_card_line':
        return Remix.bank_card_line;
      case 'wallet_3_line':
        return Remix.wallet_3_line;
      case 'hand_coin_line':
        return Remix.hand_coin_line;
      case 'cash_line':
        return Remix.cash_line;
      case 'heart_line':
        return Remix.heart_line;
      case 'mail_line':
        return Remix.mail_line;
      case 'tools_line':
        return Remix.tools_line;
      case 'article_line':
        return Remix.article_line;
      case 'notification_line':
        return Remix.notification_line;
      case 'settings_3_line':
        return Remix.settings_3_line;
      case 'user_line':
        return Remix.user_line;
      case 'error_warning_line':
        return Remix.error_warning_line;
      case 'information_line':
        return Remix.information_line;
      case 'calendar_line':
        return Remix.calendar_line;
      case 'time_line':
        return Remix.time_line;
      case 'database_line':
        return Remix.database_line;
      case 'server_line':
        return Remix.server_line;
      default:
        return Remix.notification_line; // fallback
    }
  }

   String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}j';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}h';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await fetchNotifications(isRefresh: true);
    await fetchNotificationCounts();
  }
}