import 'package:emasjid_pro/app/helpers/input_currency_formatter.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/aset_jual_controller.dart';

class AsetJualView extends GetView<AsetJualController> {
  const AsetJualView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Jual Aset',
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
              Container(
                width: double.infinity,
                margin: AppResponsive.margin(bottom: 1),
                padding: AppResponsive.padding(all: 4),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(AppResponsive.w(4)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Remix.archive_2_line,
                      size: AppResponsive.w(12),
                      color: AppColors.white,
                    ),
                    SizedBox(height: AppResponsive.h(1)),
                    Text(
                      'Masukkan Detail Aset yang dijual',
                      style: AppText.pSmall(color: AppColors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppResponsive.h(2)),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed(Routes.ASET_DAFTAR_JUAL);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.danger,
                        padding:
                            AppResponsive.padding(horizontal: 6, vertical: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppResponsive.w(2)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lihat Daftar Aset Terjual',
                            style: AppText.button(color: AppColors.danger),
                          ),
                          SizedBox(width: AppResponsive.w(2)),
                          Icon(
                            Remix.arrow_right_s_line,
                            size: 18,
                            color: AppColors.danger,
                          ),
                        ],
                      ),
                    ),
                   
                  ],
                ),
              ),
              SizedBox(height: AppResponsive.h(2)),
              Text(
                'Aset yang Dijual',
                style: AppText.h6(color: AppColors.dark),
              ),
              SizedBox(height: AppResponsive.h(1)),
              Obx(() => controller.isAssetLocked.value
                  ? _buildAssetDisplay()
                  : _buildAssetDropdown()),
              SizedBox(height: AppResponsive.h(3)),
              _buildDateField(
                label: 'Tanggal Penjualan',
                value: controller.sellDate,
                onTap: controller.selectSellDate,
              ),
              SizedBox(height: AppResponsive.h(3)),
              _buildTextField(
                label: 'Harga Jual',
                hint: 'Masukkan harga jual',
                controller: controller.sellValueController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  IndonesiaCurrencyFormatter()
                ],
                prefixText: 'Rp ',
              ),
              SizedBox(height: AppResponsive.h(3)),
              _buildTextField(
                label: 'Dijual Kepada',
                hint: 'Nama pembeli',
                controller: controller.sellToController,
              ),
              SizedBox(height: AppResponsive.h(3)),
              _buildTextField(
                label: 'Keterangan',
                hint: 'Keterangan penjualan (opsional)',
                controller: controller.descriptionController,
                maxLines: 3,
              ),
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
              onPressed:
                  controller.isLoading.value ? null : controller.sellAsset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
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
                          Remix.money_dollar_circle_line,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: AppResponsive.w(2)),
                        Text(
                          'Jual Aset',
                          style: AppText.bodyMedium(color: Colors.white),
                        ),
                      ],
                    ),
            )),
      ),
    );
  }

  Widget _buildAssetDisplay() {
    return Container(
      padding: AppResponsive.padding(all: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Obx(() => Row(
            children: [
              Icon(Remix.lock_line, color: AppColors.primary, size: 20),
              SizedBox(width: AppResponsive.w(2)),
              Expanded(
                child: Text(
                  controller.selectedAssetData.value['name'] ?? 'Loading...',
                  style: AppText.bodyMedium(color: AppColors.primary),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildAssetDropdown() {
    return Obx(() => DropdownButtonFormField<String>(
          value: controller.selectedAssetNo.value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: AppResponsive.padding(all: 2),
          ),
          hint: Text('Pilih aset'),
          items: controller.availableAssets.map((asset) {
            return DropdownMenuItem(
              value: asset['id'].toString(),
              child: Text(asset['name']),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) controller.selectAsset(value);
          },
        ));
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
            hintStyle:
                AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
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
