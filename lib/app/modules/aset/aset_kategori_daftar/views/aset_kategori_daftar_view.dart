import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../controllers/aset_kategori_daftar_controller.dart';

class AsetKategoriDaftarView extends GetView<AsetKategoriDaftarController> {
  const AsetKategoriDaftarView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Kategori Aset',
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
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.loadCategories();
              },
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (controller.categories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Remix.inbox_line,
                          size: 64,
                          color: AppColors.dark.withOpacity(0.3),
                        ),
                        SizedBox(height: AppResponsive.h(2)),
                        Text(
                          'Belum ada kategori',
                          style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.7)),
                        ),
                        SizedBox(height: AppResponsive.h(1)),
                        Text(
                          'Tambahkan kategori pertama Anda',
                          style: AppText.small(color: AppColors.dark.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: AppResponsive.padding(all: 3),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return _buildCategoryCard(category);
                  },
                );
              }),
            ),
          ),
          Container(
            padding: AppResponsive.padding(all: 3),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.navigateToAddCategory,
                icon: Icon(
                  Remix.add_line,
                  size: 20,
                  color: AppColors.white,
                ),
                label: Text(
                  'Tambahkan Kategori Aset',
                  style: AppText.button(color: AppColors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: AppResponsive.padding(vertical: 2.5, horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      margin: AppResponsive.padding(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: AppResponsive.padding(horizontal: 3, vertical: 1),
        leading: Container(
          padding: AppResponsive.padding(all: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Remix.folder_line,
            color: AppColors.primary,
            size: 24,
          ),
        ),
        title: Text(
          category['name'],
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        subtitle: category['description'].isNotEmpty
            ? Text(
                category['description'],
                style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Remix.more_2_line,
            color: AppColors.dark.withOpacity(0.6),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                controller.navigateToEditCategory(category);
                break;
              case 'delete':
                controller.showDeleteConfirmation(category);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Remix.edit_line, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Edit', style: AppText.pSmall(color: AppColors.dark),),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Remix.delete_bin_line, size: 16, color: AppColors.danger),
                  SizedBox(width: 8),
                  Text('Hapus', style: AppText.pSmall(color: AppColors.dark)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Optional: Show category details or quick actions
          controller.showCategoryOptions(category);
        },
      ),
    );
  }
}
