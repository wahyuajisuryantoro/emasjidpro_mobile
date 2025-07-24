import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_responsive.dart';
import '../../../../utils/app_text.dart';
import '../../../../helpers/currency_formatter.dart';
import '../controllers/kas_dan_bank_tambah_controller.dart';

class KasDanBankTambahView extends GetView<KasDanBankTambahController> {
  const KasDanBankTambahView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tambah Transaksi',
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
          _buildDateSelector(
            label: 'Tanggal Transaksi',
            value: controller.selectedDate,
            onTap: () => controller.selectDate(Get.context!),
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildDropdownField(
            label: 'Sumber Dana',
            value: controller.selectedSourceAccount,
            items: controller.sourceAccounts,
            onChanged: (value) {
              if (value != null) {
                controller.selectedSourceAccount.value = value;
              }
            },
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildDropdownField(
            label: 'Tujuan Dana',
            value: controller.selectedDestinationAccount,
            items: controller.destinationAccounts,
            onChanged: (value) {
              if (value != null) {
                controller.selectedDestinationAccount.value = value;
              }
            },
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildDropdownField(
            label: 'Jenis Transaksi',
            value: controller.selectedTransactionType,
            items: controller.transactionTypes,
            onChanged: (value) {
              if (value != null) {
                controller.selectedTransactionType.value = value;
              }
            },
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Keterangan',
            hint: 'Masukkan keterangan transaksi',
            controller: controller.descriptionController,
            maxLines: 3,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Nominal Transaksi',
            hint: 'Rp 0',
            controller: controller.amountController,
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
          SizedBox(height: AppResponsive.h(3)),
          _buildAttachmentField(),
        ],
      ),
    );
  }
  
  Widget _buildDateSelector({
    required String label,
    required RxString value,
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
                  size: 20,
                  color: AppColors.dark,
                ),
                SizedBox(width: AppResponsive.w(2)),
                Obx(() => Text(
                  value.value,
                  style: AppText.bodyMedium(color: AppColors.dark),
                )),
                const Spacer(),
                Icon(
                  Remix.arrow_down_s_line,
                  size: 20,
                  color: AppColors.dark,
                ),
              ],
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
  
  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti Transaksi',
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() {
          if (controller.hasAttachment.value) {
            return Container(
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
                    Remix.file_line,
                    color: AppColors.info,
                  ),
                  SizedBox(width: AppResponsive.w(2)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.attachmentName.value,
                          style: AppText.bodyMedium(color: AppColors.dark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          controller.attachmentSize.value,
                          style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Remix.close_line,
                      color: AppColors.danger,
                    ),
                    onPressed: controller.removeAttachment,
                  ),
                ],
              ),
            );
          } else {
            return InkWell(
              onTap: controller.pickFile,
              child: Container(
                padding: AppResponsive.padding(vertical: 3, horizontal: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.dark.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Remix.upload_cloud_line,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppResponsive.w(2)),
                    Text(
                      'Unggah Bukti Transaksi',
                      style: AppText.bodyMedium(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            );
          }
        }),
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
        onPressed: controller.saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: AppResponsive.padding(vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Simpan Transaksi',
          style: AppText.button(color: Colors.white),
        ),
      ),
    );
  }
}