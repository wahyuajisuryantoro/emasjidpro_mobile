import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:emasjid_pro/app/widgets/custom_navbar_bottom_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  CustomBottomNavigationBar({super.key});

  final BottomNavigationBarController navigationController =
      Get.put(BottomNavigationBarController());

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigationController.updateIndexBasedOnRoute(Get.currentRoute);
    });

    return Container(
      height: AppResponsive.h(8),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.secondary,
      ),
      child: Obx(
        () => BottomNavigationBar(
          currentIndex: navigationController.currentIndex.value,
          onTap: (index) {
            navigationController.changePage(index);
          },
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.white,
          unselectedItemColor: Colors.grey.shade300,
          showUnselectedLabels: false, 
          selectedLabelStyle: AppText.small(color: AppColors.white),
          unselectedLabelStyle: AppText.small(color: Colors.grey.shade300),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          items: [
            _buildNavItem(
              context,
              icon: Remix.home_2_line,
              label: "", 
              index: 0,
            ),
            _buildNavItem(
              context,
              icon: Remix.funds_box_line,
              label: "",  
              index: 1,
            ),
            _buildNavItem(
              context,
              icon: Remix.file_3_line,
              label: "",  
              index: 2,
            ),
            _buildNavItem(
              context,
              icon: Remix.newspaper_line,
              label: "",  
              index: 3,
            ),
            _buildNavItem(
              context,
              icon: Remix.user_2_line,
              label: "",  
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = navigationController.currentIndex.value == index;

    return BottomNavigationBarItem(
      icon: isSelected
          ? Container(
              padding: EdgeInsets.all(AppResponsive.w(2.5)),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: AppResponsive.w(5.5),
              ),
            )
          : Icon(
              icon,
              size: AppResponsive.w(5.5),
              color: Colors.grey.shade300,
            ),
      label: label, 
    );
  }
}