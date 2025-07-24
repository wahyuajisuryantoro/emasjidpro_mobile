import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/profile_detail_akun_controller.dart';

class ProfileDetailAkunView extends GetView<ProfileDetailAkunController> {
  const ProfileDetailAkunView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Profile',
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
      body: Obx(() {
        if (controller.isLoadingProfile.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }
        
        return _buildContent();
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppResponsive.padding(all: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap',
            controller: controller.nameController,
            icon: Remix.user_line,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Email',
            hint: 'Masukkan email',
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            icon: Remix.mail_line,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Nomor Telepon',
            hint: 'Masukkan nomor telepon',
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            icon: Remix.phone_line,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Alamat',
            hint: 'Masukkan alamat lengkap',
            controller: controller.addressController,
            maxLines: 3,
            icon: Remix.map_pin_line,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Kota',
            hint: 'Masukkan nama kota',
            controller: controller.cityController,
            icon: Remix.building_line,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildDateField(
            label: 'Tanggal Lahir',
            hint: 'Pilih tanggal lahir',
            controller: controller.birthController,
            onTap: controller.selectBirthDate,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildDropdownField(
            label: 'Jenis Kelamin',
            value: controller.selectedGender,
            items: controller.genderOptions,
            onChanged: (value) {
              if (value != null) {
                controller.selectedGender.value = value;
              }
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    IconData? icon,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(1)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          style: AppText.bodyMedium(color: AppColors.dark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
            prefixIcon: icon != null ? Icon(
              icon,
              color: AppColors.dark.withOpacity(0.6),
              size: 20,
            ) : null,
            contentPadding: AppResponsive.padding(
              horizontal: icon != null ? 0 : 3,
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
        ),
      ],
    );
  }
  
  Widget _buildDateField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(1)),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          style: AppText.bodyMedium(color: AppColors.dark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
            prefixIcon: Icon(
              Remix.calendar_line,
              color: AppColors.dark.withOpacity(0.6),
              size: 20,
            ),
            suffixIcon: Icon(
              Remix.arrow_down_s_line,
              color: AppColors.dark.withOpacity(0.6),
              size: 20,
            ),
            contentPadding: AppResponsive.padding(vertical: 2),
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
        ),
      ],
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required RxString value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(1)),
        Container(
          padding: AppResponsive.padding(horizontal: 3),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.dark.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Remix.user_3_line,
                color: AppColors.dark.withOpacity(0.6),
                size: 20,
              ),
              SizedBox(width: AppResponsive.w(3)),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: Obx(() => DropdownButton<String>(
                    value: value.value.isEmpty ? null : value.value,
                    hint: Text(
                      'Pilih jenis kelamin',
                      style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
                    ),
                    icon: Icon(
                      Remix.arrow_down_s_line,
                      color: AppColors.dark.withOpacity(0.6),
                    ),
                    isExpanded: true,
                    style: AppText.bodyMedium(color: AppColors.dark),
                    onChanged: onChanged,
                    items: items.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value == 'L' ? 'Laki-laki' : 'Perempuan',
                          style: AppText.bodyMedium(color: AppColors.dark),
                        ),
                      );
                    }).toList(),
                  )),
                ),
              ),
            ],
          ),
        ),
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
        onPressed: controller.isLoading.value ? null : controller.updateProfile,
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
                    'Menyimpan...',
                    style: AppText.button(color: Colors.white),
                  ),
                ],
              )
            : Text(
                'Simpan Perubahan',
                style: AppText.button(color: Colors.white),
              ),
      )),
    );
  }
}