import 'package:emasjid_pro/app/helpers/input_currency_formatter.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/aset_beli_controller.dart';

class AsetBeliView extends GetView<AsetBeliController> {
  const AsetBeliView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Beli Aset',
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
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Remix.shopping_cart_2_line,
                      color: AppColors.success,
                      size: 34,
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(2)),
                  Text(
                    'Masukkan Detail Aset',
                    style: AppText.h6(color: AppColors.dark),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Text(
                    'Isi semua informasi yang diperlukan untuk membeli aset',
                    style:
                        AppText.pSmall(color: AppColors.dark.withOpacity(0.6)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: AppResponsive.h(3)),

              // Nama Aset
              _buildTextField(
                label: 'Nama Aset',
                hint: 'Masukkan nama aset',
                controller: controller.nameController,
              ),
              SizedBox(height: AppResponsive.h(3)),

              // PERBAIKAN: Dropdown Akun Aset (Aktiva Tetap)
              _buildAssetAccountDropdown(),
              SizedBox(height: AppResponsive.h(3)),
              _buildCategoryDropdown(), // Tambah ini
              SizedBox(height: AppResponsive.h(3)),
              // PERBAIKAN: Dropdown Akun Pembayaran (Kas/Bank)
              _buildPaymentAccountDropdown(),
              SizedBox(height: AppResponsive.h(3)),

              // Brand
              _buildTextField(
                label: 'Brand/Merek (Opsional)',
                hint: 'Masukkan brand/merek aset',
                controller: controller.brandController,
              ),
              SizedBox(height: AppResponsive.h(3)),

              // Vendor/Penjual
              _buildTextField(
                label: 'Vendor/Penjual (Opsional)',
                hint: 'Masukkan nama vendor/penjual',
                controller: controller.vendorController,
              ),
              SizedBox(height: AppResponsive.h(3)),

              // Lokasi
              _buildTextField(
                label: 'Lokasi (Opsional)',
                hint: 'Masukkan lokasi aset',
                controller: controller.locationController,
              ),
              SizedBox(height: AppResponsive.h(3)),

              // Deskripsi
              _buildTextField(
                label: 'Deskripsi',
                hint: 'Masukkan deskripsi aset',
                controller: controller.descriptionController,
                maxLines: 3,
              ),
              SizedBox(height: AppResponsive.h(3)),

              // Tanggal Pembelian
              _buildDateField(
                label: 'Tanggal Pembelian',
                value: controller.purchaseDate,
                onTap: controller.selectPurchaseDate,
              ),
              SizedBox(height: AppResponsive.h(3)),

              // Harga Pembelian
              _buildTextField(
                label: 'Harga Pembelian',
                hint: 'Masukkan harga pembelian',
                controller: controller.purchasePriceController,
                keyboardType: TextInputType.number,
                inputFormatters: [IndonesiaCurrencyFormatter()],
                prefixText: 'Rp ',
              ),
              SizedBox(height: AppResponsive.h(3)),

              // PERBAIKAN: Masa Ekonomis
              _buildTextField(
                label: 'Masa Ekonomis (Tahun)',
                hint: 'Masukkan masa ekonomis dalam tahun',
                controller: controller.economicLifeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: AppResponsive.h(3)),

              // PERBAIKAN: Attachment (bukan hanya picture)
              _buildAttachmentField(),
              SizedBox(height: AppResponsive.h(3)),
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
                  controller.isLoading.value ? null : controller.buyAsset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
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
                          Remix.shopping_cart_2_line,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: AppResponsive.w(2)),
                        Text(
                          'Beli Aset',
                          style: AppText.bodyMedium(color: Colors.white),
                        ),
                      ],
                    ),
            )),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Aset',
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(0.5)),
        Text(
          'Pilih kategori untuk klasifikasi aset',
          style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
        ),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
              value: controller.selectedCategory.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: AppResponsive.padding(all: 2),
              ),
              hint: controller.isLoadingCategories.value
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Memuat kategori...'),
                      ],
                    )
                  : Text('Pilih kategori aset'),
              items: controller.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category['name']),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedCategory.value = value;
              },
            )),
      ],
    );
  }

  Widget _buildAssetAccountDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akun Aset',
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(0.5)),
        Text(
          'Pilih jenis akun aset (Tanah, Bangunan, Kendaraan, Peralatan, Perlengkapan)',
          style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
        ),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
              value: controller.selectedAssetAccount.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: AppResponsive.padding(all: 2),
              ),
              hint: controller.isLoadingAssetAccounts.value
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Memuat akun aset...'),
                      ],
                    )
                  : Text('Pilih akun aset'),
              items: controller.assetAccounts.map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account['name']),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedAssetAccount.value = value;
              },
            )),
      ],
    );
  }

  // PERBAIKAN: Dropdown untuk Akun Pembayaran (Kas/Bank 1xx)
  Widget _buildPaymentAccountDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akun Pembayaran',
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(0.5)),
        Text(
          'Pilih akun kas atau bank yang digunakan untuk membayar',
          style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
        ),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() => DropdownButtonFormField<Map<String, dynamic>>(
              value: controller.selectedPaymentAccount.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: AppResponsive.padding(all: 2),
              ),
              hint: controller.isLoadingPaymentAccounts.value
                  ? Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Memuat akun pembayaran...'),
                      ],
                    )
                  : Text('Pilih akun pembayaran'),
              items: controller.paymentAccounts.map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account['name']),
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedPaymentAccount.value = value;
              },
            )),
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

  Widget _buildAttachmentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lampiran (Opsional)',
          style: AppText.bodyMedium(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(0.5)),
        Text(
          'Foto aset, dokumen pembelian, atau file lainnya',
          style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
        ),
        SizedBox(height: AppResponsive.h(1)),
        Obx(() => controller.hasAttachment.value
            ? _buildAttachmentPreview()
            : _buildAttachmentPicker()),
      ],
    );
  }

  Widget _buildAttachmentPicker() {
    return InkWell(
      onTap: controller.pickAttachment,
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
              Remix.attachment_line,
              color: AppColors.primary,
              size: 32,
            ),
            SizedBox(height: AppResponsive.h(1)),
            Text(
              'Pilih file lampiran',
              style: AppText.pSmall(color: AppColors.primary),
            ),
            SizedBox(height: AppResponsive.h(0.5)),
            Text(
              'JPG, PNG, PDF, DOC (max. 5MB)',
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
              _getFileIcon(controller.attachmentName.value),
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

  IconData _getFileIcon(String fileName) {
    String extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Remix.image_fill;
      case 'pdf':
        return Remix.file_text_fill;
      case 'doc':
      case 'docx':
        return Remix.file_word_fill;
      default:
        return Remix.file_fill;
    }
  }
}
