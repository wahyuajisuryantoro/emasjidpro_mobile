import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/notifikasi_controller.dart';

class NotifikasiView extends GetView<NotifikasiController> {
  const NotifikasiView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize responsive
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: AppColors.muted,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: Text(
          'Notifikasi',
          style: AppText.h5(color: AppColors.dark),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Remix.arrow_left_s_line,
            color: AppColors.dark,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? Container(
                  margin: AppResponsive.margin(right: 2),
                  child: TextButton(
                    onPressed: controller.markAllAsRead,
                    child: Text(
                      'Baca Semua',
                      style: AppText.pSmall(color: AppColors.primary),
                    ),
                  ),
                )
              : const SizedBox()),
          IconButton(
            onPressed: controller.refreshNotifications,
            icon: const Icon(Icons.refresh, color: AppColors.dark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: AppColors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: AppResponsive.padding(horizontal: 4),
              child: Obx(() => Row(
                    children: [
                      _buildFilterChip(
                          'all', 'Semua (${controller.totalCount.value})'),
                      _buildFilterChip('unread',
                          'Belum Dibaca (${controller.unreadCount.value})'),
                      SizedBox(
                        width: AppResponsive.w(40),
                      )
                    ],
                  )),
            ),
          ),

          // Notification List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              final filteredNotifs = controller.filteredNotifications;

              if (filteredNotifs.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: AppResponsive.sp(64),
                        color: AppColors.muted,
                      ),
                      SizedBox(height: AppResponsive.h(2)),
                      Text(
                        'Tidak ada notifikasi',
                        style:
                            AppText.p(color: AppColors.dark.withOpacity(0.6)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                color: AppColors.primary,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        controller.hasMore.value &&
                        !controller.isLoadingMore.value) {
                      controller.loadMore();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: AppResponsive.padding(all: 4),
                    itemCount: filteredNotifs.length +
                        (controller.isLoadingMore.value ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: AppResponsive.h(1)),
                    itemBuilder: (context, index) {
                      if (index == filteredNotifs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                        );
                      }

                      final notification = filteredNotifs[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Container(
      margin: AppResponsive.margin(right: 2),
      child: FilterChip(
        selected: controller.selectedFilter.value == value,
        label: Text(
          label,
          style: AppText.pSmall(
            color: controller.selectedFilter.value == value
                ? AppColors.white
                : AppColors.dark,
          ),
        ),
        onSelected: (selected) {
          if (selected) {
            controller.changeFilter(value);
          }
        },
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.white,
        side: BorderSide(
          color: controller.selectedFilter.value == value
              ? AppColors.primary
              : AppColors.muted,
        ),
        padding: AppResponsive.padding(horizontal: 3, vertical: 1),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final priority = notification['priority'] as String;
    final message = notification['message'] as String;
    final isLongText = message.length > 100;
    final isExpanded = controller.isExpanded(notification['id']);

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: AppResponsive.padding(right: 4),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        controller.deleteNotification(notification['id']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.dark.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (!isRead) {
                controller.markAsRead(notification['id']);
              }
            },
            child: Padding(
              padding: AppResponsive.padding(all: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon with priority indicator
                      Stack(
                        children: [
                          Container(
                            width: AppResponsive.sp(40),
                            height: AppResponsive.sp(40),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              controller
                                  .getRemixIconByName(notification['icon']),
                              color: AppColors.primary,
                              size: AppResponsive.sp(20),
                            ),
                          ),
                          if (priority == 'urgent' || priority == 'high')
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: AppResponsive.sp(8),
                                height: AppResponsive.sp(8),
                                decoration: BoxDecoration(
                                  color: controller.getPriorityColor(priority),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(width: AppResponsive.w(3)),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and timestamp
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification['title'],
                                    style: AppText.pSmallBold(
                                      color: isRead
                                          ? AppColors.dark.withOpacity(0.7)
                                          : AppColors.dark,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppResponsive.w(2)),
                                Text(
                                  notification['formattedDate'] ??
                                      controller
                                          .formatDateTime(notification['date']),
                                  style: AppText.small(
                                    color: AppColors.dark.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: AppResponsive.h(1)),

                            // Message with expand functionality
                            Obx(() {
                              final isExpanded =
                                  controller.isExpanded(notification['id']);
                              final isLongText = message.length > 100;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLongText && !isExpanded
                                        ? '${message.substring(0, 100)}...'
                                        : message,
                                    style: AppText.pSmall(
                                      color: isRead
                                          ? AppColors.dark.withOpacity(0.6)
                                          : AppColors.dark.withOpacity(0.8),
                                    ),
                                    maxLines: isExpanded ? null : 3,
                                    overflow: isExpanded
                                        ? null
                                        : TextOverflow.ellipsis,
                                  ),

                                  // Show more/less button
                                  if (isLongText)
                                    GestureDetector(
                                      onTap: () => controller
                                          .toggleExpand(notification['id']),
                                      child: Padding(
                                        padding: AppResponsive.padding(top: 1),
                                        child: Text(
                                          isExpanded
                                              ? 'Tampilkan lebih sedikit'
                                              : 'Selengkapnya',
                                          style: AppText.small(
                                              color: AppColors.primary),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      // Unread indicator
                      if (!isRead)
                        Container(
                          width: AppResponsive.sp(8),
                          height: AppResponsive.sp(8),
                          margin: AppResponsive.margin(left: 2, top: 1),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
