import 'package:emasjid_pro/app/helpers/currency_formatter.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/akun_keuangan_edit_controller.dart';

class AkunKeuanganEditView extends GetView<AkunKeuanganEditController> {
  const AkunKeuanganEditView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Akun Keuangan',
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
      body: SingleChildScrollView(
      padding: AppResponsive.padding(all: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Kode Akun',
            hint: 'Masukkan kode akun (contoh: 101)',
            controller: controller.kodeController,
            keyboardType: TextInputType.number,
            readOnly: true,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Nama Akun',
            hint: 'Masukkan nama akun',
            controller: controller.namaController,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildDropdownField(
            label: 'Kategori Akun',
            value: controller.selectedKategori,
            items: controller.kategoriOptions,
            onChanged: (value) {
              if (value != null) {
                controller.selectedKategori.value = value;
              }
            },
          ),
        ],
      ),
    ),
      bottomNavigationBar: Container(
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.deleteAccount,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.danger),
                padding: AppResponsive.padding(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Hapus',
                style: AppText.button(color: AppColors.danger),
              ),
            ),
          ),
          SizedBox(width: AppResponsive.w(3)),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: controller.updateAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: AppResponsive.padding(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Simpan Perubahan',
                style: AppText.button(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      )
    );
  }
  
  
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    Widget? prefixIcon,
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
          style: AppText.bodyMedium(color: readOnly ? AppColors.dark.withOpacity(0.7) : AppColors.dark),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            hintStyle: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
            contentPadding: AppResponsive.padding(all: 2),
            filled: readOnly,
            fillColor: readOnly ? AppColors.dark.withOpacity(0.05) : null,
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
          padding: AppResponsive.padding(horizontal: 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.dark.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() => DropdownButton<String>(
              value: value.value,
              icon: Icon(
                Remix.arrow_down_s_line,
                color: AppColors.dark,
              ),
              isExpanded: true,
              style: AppText.bodyMedium(color: AppColors.dark),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )),
          ),
        ),
      ],
    );
  }
}