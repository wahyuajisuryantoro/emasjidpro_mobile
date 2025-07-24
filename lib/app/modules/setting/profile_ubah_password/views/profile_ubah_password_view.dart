import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/profile_ubah_password_controller.dart';

class ProfileUbahPasswordView extends GetView<ProfileUbahPasswordController> {
  const ProfileUbahPasswordView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Ubah Password',
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
      body: _buildContent(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppResponsive.padding(all: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            width: double.infinity,
            padding: AppResponsive.padding(all: 3),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Remix.information_line,
                  color: AppColors.info,
                  size: 20,
                ),
                SizedBox(width: AppResponsive.w(3)),
                Expanded(
                  child: Text(
                    'Setelah password berhasil diubah, Anda akan otomatis logout dan perlu login ulang.',
                    style: AppText.bodySmall(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppResponsive.h(4)),
          
          _buildPasswordField(
            label: 'Password Saat Ini',
            hint: 'Masukkan password saat ini',
            controller: controller.currentPasswordController,
            isHidden: controller.isCurrentPasswordHidden,
            onToggleVisibility: controller.toggleCurrentPasswordVisibility,
          ),
          
          SizedBox(height: AppResponsive.h(3)),
          
          _buildPasswordField(
            label: 'Password Baru',
            hint: 'Masukkan password baru (min. 8 karakter)',
            controller: controller.newPasswordController,
            isHidden: controller.isNewPasswordHidden,
            onToggleVisibility: controller.toggleNewPasswordVisibility,
          ),
          
          SizedBox(height: AppResponsive.h(3)),
          
          _buildPasswordField(
            label: 'Konfirmasi Password Baru',
            hint: 'Masukkan ulang password baru',
            controller: controller.confirmPasswordController,
            isHidden: controller.isConfirmPasswordHidden,
            onToggleVisibility: controller.toggleConfirmPasswordVisibility,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required RxBool isHidden,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() => TextField(
          controller: controller,
          obscureText: isHidden.value,
          style: AppText.bodyMedium(color: AppColors.dark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
            prefixIcon: Icon(
              Remix.lock_line,
              color: AppColors.dark.withOpacity(0.6),
              size: 20,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                isHidden.value ? Remix.eye_off_line : Remix.eye_line,
                color: AppColors.dark.withOpacity(0.6),
                size: 20,
              ),
            ),
            contentPadding: AppResponsive.padding(
              horizontal: 0,
              vertical: 2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.dark.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.dark.withOpacity(0.2),
              ),
            ),
          ),
        )),
      ],
    );
  }
  
  Widget _buildBottomBar() {
    return Container(
      padding: AppResponsive.padding(all: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.updatePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          padding: AppResponsive.padding(vertical: 2.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isLoading.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(2)),
                  Text(
                    'Mengubah Password...',
                    style: AppText.button(color: Colors.white),
                  ),
                ],
              )
            : Text(
                'Ubah Password',
                style: AppText.button(color: Colors.white),
              ),
      )),
    );
  }
}