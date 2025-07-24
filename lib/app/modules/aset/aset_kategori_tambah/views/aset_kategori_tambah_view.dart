import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/aset_kategori_tambah_controller.dart';

class AsetKategoriTambahView extends GetView<AsetKategoriTambahController> {
  const AsetKategoriTambahView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Tambah Kategori',
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
      body: Form(
        key: controller.formKey,
        child: Padding(
          padding: AppResponsive.padding(all: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                padding: AppResponsive.padding(all: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Remix.information_line,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: AppResponsive.w(2)),
                    Expanded(
                      child: Text(
                        'Buat kategori untuk mengelompokkan aset berdasarkan jenisnya',
                        style: AppText.small(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppResponsive.h(4)),

              // Name Field
              Text(
                'Nama Kategori *',
                style: AppText.bodyMedium(color: AppColors.dark),
              ),
              SizedBox(height: AppResponsive.h(1)),
              TextFormField(
                controller: controller.nameController,
                validator: controller.validateName,
                decoration: InputDecoration(
                  hintText: 'Contoh: Peralatan Elektronik',
                  hintStyle: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dark.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dark.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.danger),
                  ),
                  contentPadding: AppResponsive.padding(horizontal: 3, vertical: 2),
                ),
              ),

              SizedBox(height: AppResponsive.h(3)),

              // Description Field
              Text(
                'Deskripsi (Opsional)',
                style: AppText.bodyMedium(color: AppColors.dark),
              ),
              SizedBox(height: AppResponsive.h(1)),
              TextFormField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Jelaskan lebih detail tentang kategori ini...',
                  hintStyle: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dark.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.dark.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: AppResponsive.padding(horizontal: 3, vertical: 2),
                ),
              ),

              Spacer(),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton.icon(
                  onPressed: controller.isLoading.value ? null : controller.addCategory,
                  icon: controller.isLoading.value
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : Icon(
                          Remix.save_line,
                          size: 20,
                          color: AppColors.white,
                        ),
                  label: Text(
                    controller.isLoading.value ? 'Menyimpan...' : 'Simpan Kategori',
                    style: AppText.button(color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: AppResponsive.padding(vertical: 2.5, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                )),
              ),

              SizedBox(height: AppResponsive.h(2)),
            ],
          ),
        ),
      ),
    );
  }
}