import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/aset_penyusutan_edit_controller.dart';

class AsetPenyusutanEditView extends GetView<AsetPenyusutanEditController> {
  const AsetPenyusutanEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Penyusutan',
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
        if (controller.isLoadingData.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          child: Padding(
            padding: AppResponsive.padding(horizontal: 5, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [            
                // Nama Penyusutan
                _buildTextField(
                  label: 'Nama Penyusutan',
                  hint: 'Contoh: Penyusutan Januari 2025',
                  controller: controller.nameController,
                ),
                SizedBox(height: AppResponsive.h(3)),
                
                // Nilai Penyusutan
                _buildTextField(
                  label: 'Nilai Penyusutan',
                  hint: 'Masukkan nilai penyusutan',
                  controller: controller.valueController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixText: 'Rp ',
                ),
                SizedBox(height: AppResponsive.h(3)),
                
                // Tanggal Transaksi
                _buildDateField(
                  label: 'Tanggal Transaksi',
                  value: controller.transactionDate,
                  onTap: controller.selectTransactionDate,
                ),
                SizedBox(height: AppResponsive.h(3)),
                
                // Deskripsi
                _buildTextField(
                  label: 'Deskripsi (Opsional)',
                  hint: 'Masukkan deskripsi atau keterangan penyusutan',
                  controller: controller.descriptionController,
                  maxLines: 3,
                ),
                SizedBox(height: AppResponsive.h(4)),
                
                // Info Card - Data Asli
                Container(
                  width: double.infinity,
                  padding: AppResponsive.padding(all: 3),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Remix.information_line,
                            color: AppColors.info,
                            size: 16,
                          ),
                          SizedBox(width: AppResponsive.w(1)),
                          Text(
                            'Data Asli',
                            style: AppText.small(color: AppColors.info),
                          ),
                        ],
                      ),
                      SizedBox(height: AppResponsive.h(1)),
                      Obx(() => Text(
                        'Nilai sebelumnya: ${controller.depreciationData['formatted_value'] ?? 'Rp 0'}',
                        style: AppText.small(color: AppColors.dark.withOpacity(0.7)),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: AppResponsive.padding(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.updateDepreciation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
                padding: AppResponsive.padding(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Remix.save_line,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: AppResponsive.w(2)),
                        Text(
                          'Simpan Perubahan',
                          style: AppText.bodyMedium(color: Colors.white),
                        ),
                      ],
                    ),
            )),
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
    String? prefixText,
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
            prefixText: prefixText,
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
                color: AppColors.warning,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required Rx<DateTime?> value,
    required Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(1)),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: AppResponsive.padding(all: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.dark.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Remix.calendar_line,
                  color: AppColors.dark.withOpacity(0.7),
                ),
                SizedBox(width: AppResponsive.w(2)),
                Expanded(
                  child: Obx(() => Text(
                        value.value != null
                            ? controller.formatDate(value.value!)
                            : 'Pilih Tanggal',
                        style: AppText.bodyMedium(
                          color: value.value != null
                              ? AppColors.dark
                              : AppColors.dark.withOpacity(0.5),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}