import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:emasjid_pro/app/widgets/custom_navbar_bottom.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../controllers/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
  const ProfilView({super.key});
  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: AppText.h5(color: AppColors.dark),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshProfile,
        child: SingleChildScrollView(
          child: Column(
            children: [
              
              Container(
                width: double.infinity,
                color: AppColors.white,
                padding: AppResponsive.padding(horizontal: 3),
                child: Column(
                  children: [
                    
                    Obx(() => Stack(
                          children: [
                            Container(
                              width: AppResponsive.w(25),
                              height: AppResponsive.w(25),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                  width: 3,
                                ),
                                image: controller.picture.value.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            controller.picture.value),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {},
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: controller.picture.value.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: AppResponsive.w(12),
                                      color: AppColors.primary.withOpacity(0.5),
                                    )
                                  : null,
                            ),
                            if (controller.isLoading.value)
                              Container(
                                width: AppResponsive.w(25),
                                height: AppResponsive.w(25),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              ),
                            
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: InkWell(
                                onTap: () {
                                  controller.showPhotoOptions();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Remix.camera_3_line,
                                    color: AppColors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                    SizedBox(height: AppResponsive.h(1.5)),
                    
                    Obx(
                      () => controller.isLoadingProfile.value
                          ? Column(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Text(
                                  controller.name.value.isEmpty
                                      ? 'No Data'
                                      : controller.name.value,
                                  style: AppText.h5(color: AppColors.dark),
                                ),
                                SizedBox(height: AppResponsive.h(0.5)),
                                Text(
                                  controller.email.value.isEmpty
                                      ? 'No Data'
                                      : controller.email.value,
                                  style: AppText.bodyMedium(
                                      color: AppColors.dark.withOpacity(0.7)),
                                ),
                              ],
                            ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: AppResponsive.padding(horizontal: 3),
                child: Column(
                  children: [
                    _buildCategoryCard(
                      title: 'Akun',
                      items: [
                        _MenuItem(
                          icon: Remix.user_3_line,
                          title: 'Akun Saya',
                          onTap: () {
                            Get.toNamed(Routes.PROFILE_DETAIL_AKUN);
                          },
                        ),
                        _MenuItem(
                          icon: Remix.lock_2_line,
                          title: 'Ubah Password',
                          onTap: () {
                            Get.toNamed(Routes.PROFILE_UBAH_PASSWORD);
                          },
                        ),
                        _MenuItem(
                          icon: Remix.building_4_line,
                          title: 'Masjid Saya',
                          onTap: () {
                            Get.toNamed(Routes.PROFILE_MASJID_SAYA);
                          },
                        ),
                      ],
                    ),

                    
                    _buildCategoryCard(
                      title: 'Pengaturan',
                      items: [
                        _MenuItem(
                          icon: Remix.wallet_3_line,
                          title: 'Akun Keuangan',
                          onTap: () {
                            Get.toNamed(Routes.AKUN_DASHBOARD);
                          },
                        ),
                       
                        _MenuItem(
                          icon: Remix.file_text_line,
                          title: 'Format Kwitansi',
                          onTap: () {
                            
                          },
                        ),
                      ],
                    ),

                    
                    _buildCategoryCard(
                      title: 'Bantuan',
                      items: [
                        _MenuItem(
                          icon: Remix.question_line,
                          title: 'Pusat Bantuan',
                          onTap: () {
                            
                          },
                        ),
                        _MenuItem(
                          icon: Remix.shield_line,
                          title: 'Kebijakan Privasi',
                          onTap: () {
                            
                          },
                        ),
                        _MenuItem(
                          icon: Remix.file_list_line,
                          title: 'Syarat dan Ketentuan',
                          onTap: () {
                            
                          },
                        ),
                        _MenuItem(
                          icon: Remix.star_line,
                          title: 'Rating Kami!!',
                          onTap: () {
                            
                          },
                        ),
                        _MenuItem(
                          icon: Remix.delete_bin_line,
                          title: 'Ajukan Hapus Akun',
                          titleColor: AppColors.danger,
                          onTap: () {
                            
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: AppResponsive.h(3)),

                    
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: AppResponsive.h(6),
                          child: OutlinedButton.icon(
                            onPressed: controller.isLogoutLoading.value
                                ? null
                                : () {
                                    controller.showLogoutDialog();
                                  },
                            icon: controller.isLogoutLoading.value
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.danger),
                                    ),
                                  )
                                : const Icon(Icons.logout_rounded,
                                    color: AppColors.danger),
                            label: Text(
                              controller.isLogoutLoading.value
                                  ? 'Logout...'
                                  : 'Keluar',
                              style: AppText.button(color: AppColors.danger),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: controller.isLogoutLoading.value
                                      ? AppColors.danger.withOpacity(0.5)
                                      : AppColors.danger),
                              backgroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )),

                    SizedBox(height: AppResponsive.h(2)),
                    Text(
                      'Emasjid v1.0.0',
                      style: AppText.bodySmall(
                          color: AppColors.dark.withOpacity(0.5)),
                    ),
                    SizedBox(height: AppResponsive.h(2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Card(
      color: AppColors.white,
      elevation: 3,
      shadowColor: AppColors.dark.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: AppResponsive.padding(all: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppResponsive.padding(horizontal: 2, vertical: 1),
              child: Text(
                title,
                style: AppText.h6(color: AppColors.dark),
              ),
            ),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  _buildMenuItem(item),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: AppColors.dark.withOpacity(0.1),
                      indent: AppResponsive.w(15),
                      endIndent: AppResponsive.w(5),
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: AppResponsive.padding(horizontal: 2, vertical: 1.5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: AppColors.primary,
                size: AppResponsive.sp(16),
              ),
            ),
            SizedBox(width: AppResponsive.w(4)),
            Expanded(
              child: Text(
                item.title,
                style: AppText.pSmall(
                  color: item.titleColor ?? AppColors.dark,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.dark.withOpacity(0.4),
              size: AppResponsive.sp(14),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.titleColor,
  });
}
