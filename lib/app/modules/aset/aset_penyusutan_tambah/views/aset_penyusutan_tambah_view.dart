import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/aset_penyusutan_tambah_controller.dart';

class AsetPenyusutanTambahView extends GetView<AsetPenyusutanTambahController> {
  const AsetPenyusutanTambahView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tambah Penyusutan',
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
        child: Padding(
          padding: AppResponsive.padding(horizontal: 5, vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: AppResponsive.w(18),
                    height: AppResponsive.w(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Remix.line_chart_line,
                      color: AppColors.primary,
                      size: 34,
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(2)),
                  Text(
                    'Tambah Data Penyusutan',
                    style: AppText.h6(color: AppColors.dark),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Obx(() => Text(
                    'Untuk aset: ${controller.assetName.value}',
                    style: AppText.pSmall(color: AppColors.primary),
                    textAlign: TextAlign.center,
                  )),
                  SizedBox(height: AppResponsive.h(1)),
                  Text(
                    'Masukkan detail penyusutan aset untuk periode tertentu',
                    style: AppText.pSmall(color: AppColors.dark.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: AppResponsive.h(4)),
              
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
            ],
          ),
        ),
      ),
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
              onPressed: controller.isLoading.value ? null : controller.addDepreciation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
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
                          Remix.add_line,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: AppResponsive.w(2)),
                        Text(
                          'Tambah Penyusutan',
                          style: AppText.bodyMedium(color: Colors.white),
                        ),
                      ],
                    ),
            )),
      ),
    );
  }

  Widget _buildPaymentAccountDropdown() {
    // Method ini sudah tidak digunakan karena menggunakan nilai dari aset
    return Container();
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
                color: AppColors.primary,
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