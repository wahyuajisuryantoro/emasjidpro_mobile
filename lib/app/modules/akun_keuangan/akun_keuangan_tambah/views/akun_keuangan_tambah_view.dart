import 'package:emasjid_pro/app/helpers/currency_formatter.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/akun_keuangan_tambah_controller.dart';

class AkunKeuanganTambahView extends GetView<AkunKeuanganTambahController> {
  const AkunKeuanganTambahView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tambah Akun Keuangan',
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
          _buildTextField(
            label: 'Kode Akun',
            hint: 'Masukkan kode akun (contoh: 101)',
            controller: controller.kodeController,
            keyboardType: TextInputType.number,
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
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Saldo Awal',
            hint: 'Rp 0',
            controller: controller.saldoAwalController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ],
            prefixIcon: Padding(
              padding: AppResponsive.padding(left: 3, right: 1),
              child: Text(
                'Rp',
                style: AppText.bodyMedium(color: AppColors.dark),
              ),
            ),
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
    Widget? prefixIcon,
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
          style: AppText.bodyMedium(color: AppColors.dark),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            hintStyle: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
            contentPadding: AppResponsive.padding(all: 2),
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
      child: ElevatedButton(
        onPressed: controller.saveAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: AppResponsive.padding(vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Simpan Akun',
          style: AppText.button(color: Colors.white),
        ),
      ),
    );
  }
}