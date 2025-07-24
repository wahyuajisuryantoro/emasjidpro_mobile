import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/pendapatan_transaksi_controller.dart';

class PendapatanTransaksiView extends GetView<PendapatanTransaksiController> {
  const PendapatanTransaksiView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initResponsive(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tambah Pendapatan',
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
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: AppResponsive.padding(horizontal: 5, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form header
                _buildFormHeader(),

                SizedBox(height: AppResponsive.h(4)),

                // Form fields
                _buildDateField(),
                SizedBox(height: AppResponsive.h(3)),

                _buildSourceAccountField(),
                SizedBox(height: AppResponsive.h(3)),

                _buildDestinationAccountField(),
                SizedBox(height: AppResponsive.h(3)),

                _buildNameField(),
                SizedBox(height: AppResponsive.h(3)),

                _buildDescriptionField(),
                SizedBox(height: AppResponsive.h(3)),

                _buildAmountField(),
                SizedBox(height: AppResponsive.h(3)),

                _buildAttachmentField(),
                SizedBox(height: AppResponsive.h(4)),

                // Save button
                _buildSaveButton(),
                SizedBox(height: AppResponsive.h(4)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormHeader() {
    return Column(
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
            Remix.funds_box_fill,
            color: AppColors.primary,
            size: 34,
          ),
        ),
        SizedBox(height: AppResponsive.h(2)),
        Text(
          'Masukkan Detail Transaksi',
          style: AppText.h6(color: AppColors.dark),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppResponsive.h(1)),
        Text(
          'Isi semua informasi yang diperlukan untuk mencatat pendapatan baru',
          style: AppText.pSmall(color: AppColors.dark.withOpacity(0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Tanggal Transaksi'),
        SizedBox(height: AppResponsive.h(1)),
        InkWell(
          onTap: () => controller.selectDate(Get.context!),
          child: Container(
            padding: AppResponsive.padding(vertical: 2, horizontal: 3),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.dark.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Remix.calendar_event_line,
                  color: AppColors.dark.withOpacity(0.5),
                  size: 20,
                ),
                SizedBox(width: AppResponsive.w(2)),
                Obx(() => Text(
                      controller.formattedSelectedDate,
                      style: AppText.p(color: AppColors.dark),
                    )),
                Spacer(),
                Icon(
                  Remix.arrow_down_s_line,
                  color: AppColors.dark.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Nama Transaksi'),
        SizedBox(height: AppResponsive.h(1)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dark.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller.namaController,
            decoration: InputDecoration(
              hintText: 'Masukkan nama transaksi...',
              hintStyle: AppText.p(color: AppColors.dark.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding: AppResponsive.padding(all: 3),
            ),
            style: AppText.p(color: AppColors.dark),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Sumber Dana'),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() {
          if (controller.sourceAccounts.isEmpty) {
            return Container(
              padding: AppResponsive.padding(vertical: 2, horizontal: 3),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dark.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tidak ada data akun sumber',
                style: AppText.p(color: AppColors.dark.withOpacity(0.4)),
              ),
            );
          }

          return Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.dark.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: controller.selectedSourceAccount.value,
                isExpanded: true,
                icon: Padding(
                  padding: AppResponsive.padding(right: 2),
                  child: Icon(
                    Remix.arrow_down_s_line,
                    color: AppColors.dark.withOpacity(0.5),
                  ),
                ),
                iconSize: 20,
                elevation: 16,
                padding: AppResponsive.padding(horizontal: 3),
                onChanged: (Map<String, dynamic>? newValue) {
                  if (newValue != null) {
                    controller.selectedSourceAccount.value = newValue;
                  }
                },
                items: controller.sourceAccounts
                    .map<DropdownMenuItem<Map<String, dynamic>>>(
                        (Map<String, dynamic> account) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: account,
                    child: Text(
                      account['name'],
                      style: AppText.p(color: AppColors.dark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDestinationAccountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Tujuan Dana'),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() {
          if (controller.destinationAccounts.isEmpty) {
            return Container(
              padding: AppResponsive.padding(vertical: 2, horizontal: 3),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.dark.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Tidak ada data akun tujuan',
                style: AppText.p(color: AppColors.dark.withOpacity(0.4)),
              ),
            );
          }

          return Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.dark.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Map<String, dynamic>>(
                value: controller.selectedDestinationAccount.value,
                isExpanded: true,
                icon: Padding(
                  padding: AppResponsive.padding(right: 2),
                  child: Icon(
                    Remix.arrow_down_s_line,
                    color: AppColors.dark.withOpacity(0.5),
                  ),
                ),
                iconSize: 20,
                elevation: 16,
                padding: AppResponsive.padding(horizontal: 3),
                onChanged: (Map<String, dynamic>? newValue) {
                  if (newValue != null) {
                    controller.selectedDestinationAccount.value = newValue;
                  }
                },
                items: controller.destinationAccounts
                    .map<DropdownMenuItem<Map<String, dynamic>>>(
                        (Map<String, dynamic> account) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: account,
                    child: Text(
                      account['name'],
                      style: AppText.p(color: AppColors.dark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Keterangan'),
        SizedBox(height: AppResponsive.h(1)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dark.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller.descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Masukkan keterangan transaksi...',
              hintStyle: AppText.p(color: AppColors.dark.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding: AppResponsive.padding(all: 3),
            ),
            style: AppText.p(color: AppColors.dark),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Nominal Transaksi'),
        SizedBox(height: AppResponsive.h(1)),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dark.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              controller.currencyFormatter,
            ],
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: AppText.p(color: AppColors.dark.withOpacity(0.4)),
              border: InputBorder.none,
              contentPadding: AppResponsive.padding(all: 3),
              prefixIcon: Padding(
                padding: AppResponsive.padding(left: 3, vertical: 3),
                child: Text(
                  'Rp ',
                  style: AppText.p(color: AppColors.dark),
                ),
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
            style: AppText.p(color: AppColors.dark),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel('Lampiran (Opsional)'),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() => controller.hasAttachment.value
            ? _buildAttachmentPreview()
            : _buildAttachmentPicker()),
      ],
    );
  }

  Widget _buildAttachmentPicker() {
    return InkWell(
      onTap: controller.pickFile,
      child: Container(
        width: double.infinity,
        padding: AppResponsive.padding(vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primary.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Remix.upload_cloud_2_line,
              color: AppColors.primary,
              size: 32,
            ),
            SizedBox(height: AppResponsive.h(1)),
            Text(
              'Pilih atau tarik file ke sini',
              style: AppText.pSmall(color: AppColors.primary),
            ),
            SizedBox(height: AppResponsive.h(0.5)),
            Text(
              'JPG, PNG, atau PDF (max. 5MB)',
              style: AppText.small(color: AppColors.dark.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      padding: AppResponsive.padding(all: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.dark.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: AppResponsive.w(10),
            height: AppResponsive.w(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(),
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppResponsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.attachmentName.value,
                  style: AppText.pSmall(color: AppColors.dark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  controller.attachmentSize.value,
                  style: AppText.small(color: AppColors.dark.withOpacity(0.5)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: controller.removeAttachment,
            icon: Icon(
              Remix.close_circle_fill,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    if (controller.attachmentName.value.isEmpty) return Remix.file_line;

    final extension =
        controller.attachmentName.value.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
      return Remix.image_fill;
    } else if (extension == 'pdf') {
      return Remix.file_pdf_fill;
    } else if (['doc', 'docx'].contains(extension)) {
      return Remix.file_word_fill;
    }

    return Remix.file_fill;
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            controller.isLoading.value ? null : controller.saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: AppResponsive.padding(vertical: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Obx(() => controller.isLoading.value
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Simpan Transaksi',
                style: AppText.button(color: Colors.white),
              )),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: AppText.pSmallBold(color: AppColors.dark),
    );
  }
}
