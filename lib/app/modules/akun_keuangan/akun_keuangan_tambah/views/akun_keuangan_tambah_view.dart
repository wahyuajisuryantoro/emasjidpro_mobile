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
      body: Obx(() {
        if (controller.isLoadingCategories.value) {
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
          // Info card
          Container(
            padding: AppResponsive.padding(all: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Remix.information_line, color: AppColors.primary),
                SizedBox(width: AppResponsive.w(2)),
                Expanded(
                  child: Text(
                    'Kode akun akan digenerate otomatis sesuai kategori. Anda bisa mengubahnya jika diperlukan.',
                    style: AppText.small(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.h(3)),
          
          _buildDropdownField(
            label: 'Kategori Akun',
            value: controller.selectedKategoriCode,
            items: controller.kategoriOptions,
            onChanged: controller.onKategoriChanged,
          ),
          SizedBox(height: AppResponsive.h(3)),
          
          _buildTextField(
            label: 'Kode Akun',
            hint: 'Otomatis digenerate (bisa diubah)',
            controller: controller.kodeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            suffixIcon: IconButton(
              icon: Icon(Remix.refresh_line, color: AppColors.primary),
              onPressed: () {
                if (controller.selectedKategoriCode.value.isNotEmpty) {
                  controller.generateNextCode(controller.selectedKategoriCode.value);
                }
              },
            ),
          ),
          SizedBox(height: AppResponsive.h(3)),
          
          _buildTextField(
            label: 'Nama Akun',
            hint: 'Contoh: Kas di Tangan, Bank BCA, dll',
            controller: controller.namaController,
          ),
          SizedBox(height: AppResponsive.h(3)),
          
          _buildTextField(
            label: 'Saldo Awal',
            hint: '0',
            controller: controller.saldoAwalController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            prefixIcon: Padding(
              padding: AppResponsive.padding(left: 3, right: 1),
              child: Align(
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Text(
                  'Rp',
                  style: AppText.bodyMedium(color: AppColors.dark),
                ),
              ),
            ),
          ),
          SizedBox(height: AppResponsive.h(3)),
          
          // Cash and Bank checkbox (hanya untuk Aktiva Lancar)
          Obx(() {
            if (controller.selectedKategoriCode.value == '1') {
              return Column(
                children: [
                  Container(
                    padding: AppResponsive.padding(all: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.success.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Obx(() => Checkbox(
                          value: controller.isCashAndBank.value,
                          onChanged: (value) {
                            controller.isCashAndBank.value = value ?? false;
                          },
                          activeColor: AppColors.success,
                        )),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Akun Kas atau Bank',
                                style: AppText.bodyMedium(color: AppColors.dark),
                              ),
                              Text(
                                'Centang jika akun ini adalah kas atau rekening bank',
                                style: AppText.small(color: AppColors.dark.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                ],
              );
            }
            return SizedBox.shrink();
          }),
          
          _buildTextField(
            label: 'Deskripsi (Opsional)',
            hint: 'Keterangan tambahan tentang akun ini',
            controller: controller.deskripsiController,
            maxLines: 3,
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
    Widget? suffixIcon,
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
            suffixIcon: suffixIcon,
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
    required RxList<Map<String, dynamic>> items,
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
              value: value.value.isEmpty ? null : value.value,
              hint: Text(
                'Pilih kategori akun',
                style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
              ),
              icon: Icon(
                Remix.arrow_down_s_line,
                color: AppColors.dark,
              ),
              isExpanded: true,
              style: AppText.bodyMedium(color: AppColors.dark),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
                return DropdownMenuItem<String>(
                  value: item['code'],
                  child: Text('${item['code']} - ${item['name']}'),
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
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: AppResponsive.padding(vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isLoading.value
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Simpan Akun',
                style: AppText.button(color: Colors.white),
              ),
      )),
    );
  }
}