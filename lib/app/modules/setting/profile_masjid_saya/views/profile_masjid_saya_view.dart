import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/profile_masjid_saya_controller.dart';

class ProfileMasjidSayaView extends GetView<ProfileMasjidSayaController> {
  const ProfileMasjidSayaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        }

        if (!controller.hasMasjidData.value) {
          return _buildNoDataState();
        }

        return _buildContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      title: Text(
        'Masjid Saya',
        style: AppText.h5(color: AppColors.dark),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Remix.arrow_left_s_line, color: AppColors.dark),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() => controller.hasMasjidData.value
            ? _buildAppBarActions()
            : const SizedBox()),
      ],
    );
  }

  Widget _buildAppBarActions() {
    return Obx(() {
      if (controller.isEditMode.value) {
        return Row(
          children: [
            IconButton(
              icon: Icon(Remix.close_line, color: AppColors.danger),
              onPressed: controller.cancelEdit,
              tooltip: 'Batal',
            ),
            IconButton(
              icon: controller.isUpdating.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.success,
                      ),
                    )
                  : Icon(Remix.check_line, color: AppColors.success),
              onPressed: controller.isUpdating.value
                  ? null
                  : controller.updateMasjidData,
              tooltip: 'Simpan',
            ),
          ],
        );
      } else {
        return IconButton(
          icon: Icon(Remix.edit_line, color: AppColors.primary),
          onPressed: controller.toggleEditMode,
          tooltip: 'Edit',
        );
      }
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppResponsive.h(2)),
          Text(
            'Memuat data masjid...',
            style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return RefreshIndicator(
      onRefresh: controller.refreshMasjidData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(Get.context!).size.height * 0.8,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Remix.building_4_line,
                  size: 80,
                  color: AppColors.dark.withOpacity(0.3),
                ),
                SizedBox(height: AppResponsive.h(2)),
                Text(
                  'Data Masjid Tidak Ditemukan',
                  style: AppText.h6(color: AppColors.dark),
                ),
                SizedBox(height: AppResponsive.h(1)),
                Text(
                  'Hubungi administrator untuk menambahkan\ndata masjid Anda',
                  textAlign: TextAlign.center,
                  style: AppText.bodyMedium(
                      color: AppColors.dark.withOpacity(0.7)),
                ),
                SizedBox(height: AppResponsive.h(3)),
                ElevatedButton.icon(
                  onPressed: controller.refreshMasjidData,
                  icon: Icon(Remix.refresh_line, color: Colors.white),
                  label: Text(
                    'Muat Ulang',
                    style: AppText.button(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: AppResponsive.padding(horizontal: 6, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: controller.refreshMasjidData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppResponsive.padding(all: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            SizedBox(height: AppResponsive.h(3)),
            _buildMasjidInfoSection(),
            SizedBox(height: AppResponsive.h(3)),
            if (controller.pengurus.value.isNotEmpty)
              _buildPengurusSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Remix.building_4_line,
              size: 120,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: AppResponsive.padding(all: 4),
            child: Row(
              children: [
                // Logo dengan tombol edit simple
                Stack(
                  children: [
                    Container(
                      width: AppResponsive.w(20),
                      height: AppResponsive.w(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: controller.logoUrl.value.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                controller.logoUrl.value,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Remix.building_4_fill,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            )
                          : Icon(
                              Remix.building_4_fill,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Obx(() => GestureDetector(
                        onTap: controller.isUploadingLogo.value
                            ? null
                            : controller.pickLogoFromGallery,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: controller.isUploadingLogo.value
                              ? SizedBox(
                                  width: 15,
                                  height: 15,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Remix.edit_2_line,
                                  color: Colors.white,
                                  size: 16,
                                ),
                        ),
                      )),
                    ),
                  ],
                ),
                SizedBox(width: AppResponsive.w(4)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            controller.masjidName.value.isEmpty
                                ? 'Nama Masjid'
                                : controller.masjidName.value,
                            style: AppText.h5(color: Colors.white),
                          )),
                      SizedBox(height: AppResponsive.h(0.5)),
                      Obx(() => Text(
                            controller.city.value.isEmpty
                                ? 'Kota'
                                : controller.city.value,
                            style: AppText.bodyMedium(
                                color: Colors.white.withOpacity(0.9)),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasjidInfoSection() {
    return _buildSectionCard(
      title: 'Informasi Masjid',
      icon: Remix.information_line,
      children: [
        Obx(() => controller.isEditMode.value
            ? _buildEditForm()
            : _buildViewInfo()),
      ],
    );
  }

  Widget _buildViewInfo() {
    return Column(
      children: [
        _buildInfoRow('Nama Masjid', controller.masjidName.value),
        _buildInfoRow('Alamat', controller.address.value),
        _buildInfoRow('Kota', controller.city.value),
        _buildInfoRow('Tahun Berdiri', controller.tahunBerdiri.value),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildTextField(
          controller: controller.nameController,
          label: 'Nama Masjid',
          icon: Remix.building_4_line,
        ),
        SizedBox(height: AppResponsive.h(2)),
        _buildTextField(
          controller: controller.addressController,
          label: 'Alamat',
          icon: Remix.map_pin_line,
          maxLines: 3,
        ),
        SizedBox(height: AppResponsive.h(2)),
        _buildTextField(
          controller: controller.cityController,
          label: 'Kota',
          icon: Remix.building_line,
        ),
        SizedBox(height: AppResponsive.h(2)),
        _buildTextField(
          controller: controller.tahunBerdiriController,
          label: 'Tahun Berdiri',
          icon: Remix.calendar_line,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: AppText.bodyMedium(color: AppColors.dark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: AppColors.primary),
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
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }

  Widget _buildPengurusSection() {
  return _buildSectionCard(
    title: 'Pengurus',
    icon: Remix.group_line,
    children: [
      Obx(() => controller.isEditMode.value
          ? _buildTextField(
              controller: controller.pengurusController,
              label: 'Nama Pengurus',
              icon: Remix.user_line,
            )
          : _buildInfoRow('Pengurus', controller.pengurus.value)),
    ],
  );
}

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.dark.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppResponsive.padding(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                SizedBox(width: AppResponsive.w(2)),
                Text(title, style: AppText.h6(color: AppColors.primary)),
              ],
            ),
          ),
          Padding(
            padding: AppResponsive.padding(horizontal: 4, vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: AppResponsive.padding(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppResponsive.w(30),
            child: Text(
              label,
              style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.7)),
            ),
          ),
          SizedBox(width: AppResponsive.w(2)),
          Text(
            ':',
            style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.7)),
          ),
          SizedBox(width: AppResponsive.w(2)),
          Expanded(
            child: Text(
              value.isEmpty ? 'Tidak ada data' : value,
              style: AppText.bodyMedium(
                color: value.isEmpty
                    ? AppColors.dark.withOpacity(0.4)
                    : AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}