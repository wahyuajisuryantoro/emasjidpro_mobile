import 'package:emasjid_pro/app/helpers/input_currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/piutang_tambah_cicilan_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_responsive.dart';
import '../../../../utils/app_text.dart';

class PiutangTambahCicilanView extends GetView<PiutangTambahCicilanController> {
  const PiutangTambahCicilanView({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Initialize responsive
    controller.initResponsive(context);
    
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Terima Cicilan Piutang',
          style: AppText.h5(color: AppColors.dark),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Remix.arrow_left_s_line,
            color: AppColors.dark,
          ),
          onPressed: () => Get.back(result: false),
        ),
      ),
      body: Obx(() => controller.isLoading.value
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _buildContent()),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: AppResponsive.padding(all: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: AppResponsive.h(3)),
          _buildDateSelector(),
          SizedBox(height: AppResponsive.h(3)),
          _buildSourceAccountField(),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Nama Penerimaan',
            hint: 'Masukkan nama penerimaan',
            controller: controller.nameController,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Keterangan',
            hint: 'Masukkan keterangan penerimaan',
            controller: controller.descriptionController,
            maxLines: 3,
          ),
          SizedBox(height: AppResponsive.h(3)),
          _buildTextField(
            label: 'Jumlah Penerimaan',
            hint: 'Rp 0',
            controller: controller.amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              IndonesiaCurrencyFormatter()
            ],
            prefixIcon: Icon(
              Remix.money_dollar_circle_line,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Obx(() => Text(
            'Sisa piutang: ${controller.formatCurrency(controller.sisaPiutang.value)}',
            style: AppText.small(color: AppColors.primary),
          )),
          SizedBox(height: AppResponsive.h(3)),
          _buildAttachmentField(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: AppResponsive.padding(all: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
            "Nama Penerima: ${controller.namaPenerima.value}",
            style: AppText.h6(color: AppColors.dark),
          )),
          SizedBox(height: AppResponsive.h(1)),
          Obx(() => Text(
            "Total Piutang: ${controller.formatCurrency(controller.totalPiutang.value)}",
            style: AppText.bodyMedium(color: AppColors.dark),
          )),
          SizedBox(height: AppResponsive.h(0.5)),
          Obx(() => Text(
            "Sisa Piutang: ${controller.formatCurrency(controller.sisaPiutang.value)}",
            style: AppText.bodyMedium(color: AppColors.success),
          )),
        ],
      ),
    );
  }
  
 Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal Transaksi',
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(1)),
        InkWell(
          onTap: () => controller.selectDate(Get.context!),
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
                Expanded(
                  child: Obx(() => Text(
                    controller.formattedSelectedDate.value,
                    style: AppText.bodyMedium(color: AppColors.dark),
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
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
  
 Widget _buildSourceAccountField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Sumber Dana',
        style: AppText.bodyMedium(color: AppColors.dark),
      ),
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
        if (controller.selectedSourceAccount.value == null) {
          controller.selectedSourceAccount.value = controller.sourceAccounts.first;
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.dark.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Map<String, dynamic>>(
              value: controller.selectedSourceAccount.value ?? controller.sourceAccounts.first,
              isExpanded: true,
              hint: Padding(
                padding: AppResponsive.padding(horizontal: 3),
                child: Text(
                  'Pilih Sumber Dana',
                  style: AppText.p(color: AppColors.dark.withOpacity(0.5)),
                ),
              ),
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
          'Lampiran',
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
                      'Unggah Bukti Penerimaan (Opsional)',
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
      child: Obx(() => ElevatedButton(
        onPressed: controller.isSaving.value ? null : controller.saveCicilan,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          padding: AppResponsive.padding(vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: controller.isSaving.value 
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
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
              'Simpan Penerimaan',
              style: AppText.button(color: Colors.white),
            ),
      )),
    );
  }
}