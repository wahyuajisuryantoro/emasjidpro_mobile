import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/buku_besar_controller.dart';

class BukuBesarView extends GetView<BukuBesarController> {
  const BukuBesarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Buku Besar',
          style: AppText.h5(color: AppColors.dark),
        ),
        backgroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Remix.arrow_left_s_line, color: AppColors.dark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 80,
            padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.dark.withOpacity(0.1),
                      ),
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: controller.onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari kode atau nama akun...',
                        hintStyle: AppText.bodyMedium(
                          color: AppColors.dark.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Remix.search_line,
                          color: AppColors.dark.withOpacity(0.5),
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: AppResponsive.padding(
                          horizontal: 3,
                          vertical: 2,
                        ),
                      ),
                      style: AppText.bodyMedium(color: AppColors.dark),
                    ),
                  ),
                ),
                Obx(() => controller.searchQuery.value.isNotEmpty
                    ? Container(
                        margin: AppResponsive.margin(left: 1.5),
                        child: IconButton(
                          onPressed: controller.clearSearch,
                          icon: Icon(
                            Remix.close_circle_line,
                            color: AppColors.dark.withOpacity(0.5),
                            size: 20,
                          ),
                        ),
                      )
                    : const SizedBox()),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: AppResponsive.h(2)),
                      Text(
                        'Memuat data akun...',
                        style: AppText.bodyMedium(
                          color: AppColors.dark.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Container(
                    margin: AppResponsive.margin(all: 4),
                    padding: AppResponsive.padding(all: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: AppResponsive.padding(all: 3),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Remix.error_warning_line,
                            size: 48,
                            color: AppColors.danger,
                          ),
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          'Terjadi Kesalahan',
                          style: AppText.h6(color: AppColors.dark),
                        ),
                        SizedBox(height: AppResponsive.h(1)),
                        Text(
                          controller.errorMessage.value,
                          style: AppText.bodyMedium(
                            color: AppColors.dark.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppResponsive.h(3)),
                        ElevatedButton(
                          onPressed: controller.refreshAccounts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: AppResponsive.padding(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Coba Lagi',
                            style: AppText.bodyMedium(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.filteredAccounts.isEmpty) {
                return Center(
                  child: Container(
                    margin: AppResponsive.margin(all: 2),
                    padding: AppResponsive.padding(all: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: AppResponsive.padding(all: 3),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            controller.searchQuery.value.isNotEmpty
                                ? Remix.search_line
                                : Remix.wallet_3_line,
                            size: 48,
                            color: AppColors.info,
                          ),
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'Tidak Ada Hasil'
                              : 'Tidak Ada Akun',
                          style: AppText.h6(color: AppColors.dark),
                        ),
                        SizedBox(height: AppResponsive.h(1)),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'Tidak ditemukan akun dengan kata kunci "${controller.searchQuery.value}"'
                              : 'Belum ada akun yang tersedia',
                          style: AppText.bodyMedium(
                            color: AppColors.dark.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (controller.searchQuery.value.isNotEmpty) ...[
                          SizedBox(height: AppResponsive.h(3)),
                          OutlinedButton(
                            onPressed: controller.clearSearch,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary),
                              padding: AppResponsive.padding(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Hapus Pencarian',
                              style:
                                  AppText.bodyMedium(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshAccounts,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
                  itemCount: controller.filteredAccounts.length,
                  itemBuilder: (context, index) {
                    final account = controller.filteredAccounts[index];

                    return Container(
                      margin: AppResponsive.margin(bottom: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            controller.navigateToAccountDetail(account['code']);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: AppResponsive.padding(
                              horizontal: 3,
                              vertical: 2.5,
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: AppResponsive.w(3)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: AppResponsive.padding(
                                          horizontal: 1.5,
                                          vertical: 0.3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          account['code'] ?? '',
                                          style: AppText.small(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: AppResponsive.h(0.8)),
                                      Text(
                                        account['name'] ?? '',
                                        style: AppText.bodyMedium(
                                          color: AppColors.dark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Remix.arrow_right_s_line,
                                  color: AppColors.dark,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
