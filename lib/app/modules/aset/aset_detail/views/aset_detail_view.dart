import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/aset_detail_controller.dart';

class AsetDetailView extends GetView<AsetDetailController> {
  const AsetDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : DefaultTabController(
                length: 3,
                child: RefreshIndicator(
                  onRefresh: controller.reloadData,
                  child: NestedScrollView(
                    headerSliverBuilder:
                        (BuildContext context, bool innerBoxIsScrolled) {
                      return <Widget>[
                        SliverAppBar(
                          expandedHeight: 250.0,
                          floating: false,
                          pinned: true,
                          backgroundColor: AppColors.primary,
                          leading: IconButton(
                            icon: Icon(
                              Remix.arrow_left_s_line,
                              color: Colors.white,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          actions: [
                            IconButton(
                              icon: Icon(
                                Remix.edit_line,
                                color: Colors.white,
                              ),
                              onPressed: controller.navigateToEditAsset,
                            ),
                          ],
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  color: AppColors.primary.withOpacity(0.8),
                                  child: Icon(
                                    Remix.archive_2_line,
                                    size: 64,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 50,
                                  left: 16,
                                  right: 16,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Obx(() => Text(
                                            controller
                                                    .assetData.value['name'] ??
                                                'Detail Aset',
                                            style: AppText.h4(
                                              color: Colors.white,
                                            ),
                                          )),
                                      SizedBox(height: AppResponsive.h(1)),
                                      Row(
                                        children: [
                                          Obx(() => Container(
                                                padding: AppResponsive.padding(
                                                    horizontal: 1,
                                                    vertical: 0.5),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  controller.assetData
                                                          .value['category'] ??
                                                      'Kategori',
                                                  style: AppText.small(
                                                      color: Colors.white),
                                                ),
                                              )),
                                          SizedBox(width: AppResponsive.w(2)),
                                          Obx(() => Container(
                                                padding: AppResponsive.padding(
                                                    horizontal: 1,
                                                    vertical: 0.5),
                                                decoration: BoxDecoration(
                                                  color: controller
                                                      .getStatusColor(controller
                                                                  .assetData
                                                                  .value[
                                                              'status'] ??
                                                          'Aktif'),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  controller.assetData
                                                          .value['status'] ??
                                                      'Aktif',
                                                  style: AppText.small(
                                                      color: Colors.white),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          bottom: TabBar(
                            indicatorColor: Colors.white,
                            indicatorWeight: 3,
                            labelStyle: AppText.bodyMedium(
                              color: Colors.white,
                            ),
                            unselectedLabelStyle: AppText.bodyMedium(
                              color: Colors.white.withOpacity(0.7),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white.withOpacity(0.7),
                            tabs: [
                              Tab(text: 'Informasi'),
                              Tab(text: 'Dokumen'),
                              Tab(text: 'Penyusutan'),
                            ],
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        _buildInfoTab(),
                        _buildDocumentsTab(),
                        _buildDepreciationTab(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: AppResponsive.padding(all: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: AppResponsive.padding(all: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Nilai Aset',
                  style: AppText.bodyMedium(color: Colors.white),
                ),
                SizedBox(height: AppResponsive.h(1)),
                Obx(() => Text(
                      controller.assetData.value['formatted_value'] ?? 'Rp 0',
                      style: AppText.h3(
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.h(3)),
          Text(
            'Deskripsi',
            style: AppText.h6(color: AppColors.dark),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Obx(() => Text(
                controller.assetData.value['description'] ??
                    'Tidak ada deskripsi',
                style:
                    AppText.bodyMedium(color: AppColors.dark.withOpacity(0.8)),
              )),
          SizedBox(height: AppResponsive.h(3)),
          Text(
            'Lokasi',
            style: AppText.h6(color: AppColors.dark),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Container(
            padding: AppResponsive.padding(all: 3),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Remix.map_pin_line,
                  color: AppColors.primary,
                ),
                SizedBox(width: AppResponsive.w(2)),
                Expanded(
                  child: Obx(() => Text(
                        controller.assetData.value['location'] ??
                            'Tidak ada informasi lokasi',
                        style: AppText.bodyMedium(color: AppColors.dark),
                      )),
                ),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.h(3)),
          Text(
            'Informasi Pembelian',
            style: AppText.h6(color: AppColors.dark),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Obx(() {
            Map<String, dynamic> purchaseInfo =
                controller.assetData.value['purchaseInfo'] ?? {};

            return Card(
              elevation: 0,
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: AppResponsive.padding(all: 3),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Tanggal Perolehan',
                      controller.formatDate(purchaseInfo['date']),
                    ),
                    Divider(),
                    _buildInfoRow(
                      'Harga Pembelian',
                      controller.assetData.value['formatted_value'] ?? '-',
                    ),
                    Divider(),
                    _buildInfoRow(
                      'Penjual/Vendor',
                      purchaseInfo['seller'] ?? '-',
                    ),
                    Divider(),
                    _buildInfoRow(
                      'Merek',
                      controller.assetData.value['brand'] ?? '-',
                    ),
                    Divider(),
                    _buildInfoRow(
                      'Dibeli Dengan',
                      purchaseInfo['purchased_with_account'] ?? '-',
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: AppResponsive.h(3)),
          Text(
            'Informasi Akun',
            style: AppText.h6(color: AppColors.dark),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Obx(() {
            Map<String, dynamic> accountInfo =
                controller.assetData.value['account_info'] ?? {};

            return Card(
              elevation: 0,
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: AppResponsive.padding(all: 3),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Kategori Akun',
                      accountInfo['account_category'] ?? '-',
                    ),
                    Divider(),
                    _buildInfoRow(
                      'Sumber Dana',
                      accountInfo['purchased_with'] ?? '-',
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(() {
            final pictureUrl = controller.assetData.value['picture'];

            if (pictureUrl != null && pictureUrl.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppResponsive.h(3)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Foto Aset',
                        style: AppText.h6(color: AppColors.dark),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: controller.pickAssetPicture,
                            child: Container(
                              padding: AppResponsive.padding(all: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Remix.image_edit_line,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                  SizedBox(width: AppResponsive.w(1)),
                                  Text(
                                    'Ganti',
                                    style:
                                        AppText.small(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppResponsive.w(2)),
                          InkWell(
                            onTap: controller.showDeletePictureConfirmation,
                            child: Container(
                              padding: AppResponsive.padding(all: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Remix.delete_bin_line,
                                    color: AppColors.danger,
                                    size: 16,
                                  ),
                                  SizedBox(width: AppResponsive.w(1)),
                                  Text(
                                    'Hapus',
                                    style:
                                        AppText.small(color: AppColors.danger),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showImageDialog(pictureUrl),
                        child: Container(
                          height: AppResponsive.h(25),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.dark.withOpacity(0.1),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              pictureUrl,
                              fit: BoxFit.cover,
                              key: ValueKey(pictureUrl),
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: AppColors.dark.withOpacity(0.05),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.dark.withOpacity(0.05),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Remix.image_line,
                                        size: 32,
                                        color: AppColors.dark.withOpacity(0.3),
                                      ),
                                      SizedBox(height: AppResponsive.h(1)),
                                      Text(
                                        'Gagal memuat foto',
                                        style: AppText.small(
                                          color:
                                              AppColors.dark.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (controller.isUpdatingPicture.value)
                        Container(
                          height: AppResponsive.h(25),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: AppResponsive.h(1)),
                                Text(
                                  'Memperbarui foto...',
                                  style: AppText.small(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Remix.eye_line,
                        size: 14,
                        color: AppColors.dark.withOpacity(0.6),
                      ),
                      SizedBox(width: AppResponsive.w(1)),
                      Text(
                        'Tap foto untuk memperbesar',
                        style: AppText.small(
                            color: AppColors.dark.withOpacity(0.6)),
                      ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppResponsive.h(3)),
                  Text(
                    'Foto Aset',
                    style: AppText.h6(color: AppColors.dark),
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  InkWell(
                    onTap: controller.uploadNewAssetPicture,
                    child: Container(
                      height: AppResponsive.h(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Remix.camera_line,
                            size: 32,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: AppResponsive.h(1)),
                          Text(
                            'Tambahkan Foto Aset',
                            style: AppText.bodyMedium(color: AppColors.primary),
                          ),
                          SizedBox(height: AppResponsive.h(0.5)),
                          Text(
                            'Tap untuk memilih foto',
                            style: AppText.small(
                                color: AppColors.dark.withOpacity(0.6)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                ],
              );
            }
          }),
          SizedBox(height: AppResponsive.h(3)),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(Routes.ASET_JUAL,
                    arguments: {'no': controller.assetData.value['id']});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: AppResponsive.padding(vertical: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return Obx(() {
      if (controller.isLoadingDocuments.value) {
        return Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: AppResponsive.padding(all: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dokumen Aset',
                  style: AppText.h6(color: AppColors.dark),
                ),
                if (controller.assetDocuments.isEmpty)
                  ElevatedButton.icon(
                    onPressed: controller.isUploadingDocument.value
                        ? null
                        : controller.uploadAssetDocument,
                    icon: controller.isUploadingDocument.value
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            Remix.upload_2_line,
                            size: 16,
                            color: Colors.white,
                          ),
                    label: Text(
                      controller.isUploadingDocument.value
                          ? 'Uploading...'
                          : 'Upload',
                      style: AppText.small(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding:
                          AppResponsive.padding(horizontal: 3, vertical: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppResponsive.h(2)),
            if (controller.assetDocuments.isEmpty) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Remix.file_list_line,
                        size: 64,
                        color: AppColors.dark.withOpacity(0.3),
                      ),
                      SizedBox(height: AppResponsive.h(2)),
                      Text(
                        'Belum ada dokumen',
                        style: AppText.bodyMedium(
                            color: AppColors.dark.withOpacity(0.7)),
                      ),
                      SizedBox(height: AppResponsive.h(1)),
                      Text(
                        'Tap tombol Upload untuk menambah dokumen',
                        style: AppText.small(
                            color: AppColors.dark.withOpacity(0.5)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: ListView.builder(
                  itemCount: controller.assetDocuments.length,
                  itemBuilder: (context, index) {
                    final document = controller.assetDocuments[index];
                    final extension = document['extension'] ?? '';
                    final name = document['name'] ?? 'Unknown';
                    final url = document['url'] ?? '';

                    return Container(
                      margin: AppResponsive.margin(bottom: 2),
                      padding: AppResponsive.padding(all: 3),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.dark.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: AppResponsive.padding(all: 2),
                                decoration: BoxDecoration(
                                  color: controller
                                      .getFileColor(extension)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  controller.getFileIcon(extension),
                                  color: controller.getFileColor(extension),
                                  size: 24,
                                ),
                              ),
                              SizedBox(width: AppResponsive.w(3)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppText.bodyMedium(
                                          color: AppColors.dark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: AppResponsive.h(0.5)),
                                    Container(
                                      padding: AppResponsive.padding(
                                          horizontal: 1.5, vertical: 0.5),
                                      decoration: BoxDecoration(
                                        color: controller
                                            .getFileColor(extension)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        extension.toUpperCase(),
                                        style: AppText.small(
                                          color: controller
                                              .getFileColor(extension),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        controller.openDocument(url, name),
                                    icon: Icon(
                                      Remix.eye_line,
                                      color: AppColors.info,
                                      size: 18,
                                    ),
                                    padding: AppResponsive.padding(all: 1),
                                    constraints: BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                    tooltip: 'Lihat',
                                  ),
                                  IconButton(
                                    onPressed: controller
                                            .isUploadingDocument.value
                                        ? null
                                        : () => controller.updateAssetDocument(
                                            index, name),
                                    icon: Icon(
                                      Remix.file_edit_line,
                                      color:
                                          controller.isUploadingDocument.value
                                              ? AppColors.dark.withOpacity(0.3)
                                              : AppColors.primary,
                                      size: 18,
                                    ),
                                    padding: AppResponsive.padding(all: 1),
                                    constraints: BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                    tooltip: 'Ganti',
                                  ),
                                  IconButton(
                                    onPressed:
                                        controller.isUploadingDocument.value
                                            ? null
                                            : () => controller
                                                .showDeleteDocumentConfirmation(
                                                    index, name),
                                    icon: Icon(
                                      Remix.delete_bin_line,
                                      color:
                                          controller.isUploadingDocument.value
                                              ? AppColors.dark.withOpacity(0.3)
                                              : AppColors.danger,
                                      size: 18,
                                    ),
                                    padding: AppResponsive.padding(all: 1),
                                    constraints: BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                    tooltip: 'Hapus',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (controller.isUploadingDocument.value) ...[
                            SizedBox(height: AppResponsive.h(2)),
                            Container(
                              width: double.infinity,
                              padding: AppResponsive.padding(all: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: AppResponsive.w(2)),
                                  Text(
                                    'Memproses dokumen...',
                                    style:
                                        AppText.small(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildDepreciationTab() {
    return Obx(() {
      if (controller.isLoadingDepreciation.value) {
        return Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: AppResponsive.padding(all: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: AppResponsive.padding(all: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Remix.line_chart_line,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: AppResponsive.w(2)),
                      Text(
                        'Total Penyusutan Aset',
                        style: AppText.bodyMedium(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Text(
                    controller.formattedTotalDepreciation.value,
                    style: AppText.h4(color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppResponsive.h(3)),
            Obx(() {
              final depInfo = controller.getDepreciationInfo();

              return Card(
                elevation: 0,
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.dark.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: AppResponsive.padding(all: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Remix.information_line,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: AppResponsive.w(2)),
                          Text(
                            'Informasi Penyusutan',
                            style: AppText.h6(color: AppColors.dark),
                          ),
                        ],
                      ),
                      SizedBox(height: AppResponsive.h(2)),
                      _buildInfoRow(
                        'Nilai Awal',
                        'Rp ${depInfo['initialValue'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      ),
                      Divider(),
                      _buildInfoRow(
                        'Nilai Saat Ini',
                        'Rp ${depInfo['currentValue'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      ),
                      Divider(),
                      _buildInfoRow(
                        'Penyusutan per Tahun',
                        'Rp ${controller.assetData.value['depreciation'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                      ),
                      Divider(),
                      _buildInfoRow(
                        'Total Penyusutan',
                        'Rp ${depInfo['depreciationAmount'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} (${depInfo['depreciationPercent'].toStringAsFixed(1)}%)',
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(height: AppResponsive.h(3)),
            if (controller.depreciationData.isEmpty) ...[
              Container(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Remix.file_list_line,
                        size: 64,
                        color: AppColors.dark.withOpacity(0.3),
                      ),
                      SizedBox(height: AppResponsive.h(2)),
                      Text(
                        'Belum ada data penyusutan',
                        style: AppText.bodyMedium(
                            color: AppColors.dark.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.navigateToAddDepreciation,
                  icon: Icon(
                    Remix.add_line,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Tambahkan Data Penyusutan',
                    style: AppText.button(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    padding:
                        AppResponsive.padding(vertical: 2.5, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Remix.history_line,
                    color: AppColors.dark,
                    size: 20,
                  ),
                  SizedBox(width: AppResponsive.w(2)),
                  Text(
                    'Riwayat Penyusutan',
                    style: AppText.h6(color: AppColors.dark),
                  ),
                ],
              ),
              SizedBox(height: AppResponsive.h(2)),
              ...controller.depreciationData.map<Widget>((depreciation) {
                return Container(
                  margin: AppResponsive.margin(bottom: 3),
                  padding: AppResponsive.padding(all: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.dark.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              depreciation['depreciation_name'] ?? 'Penyusutan',
                              style: AppText.h6(color: AppColors.dark),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.dark.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      controller.editDepreciation(depreciation),
                                  icon: Icon(Remix.edit_line,
                                      color: AppColors.primary, size: 18),
                                  padding: AppResponsive.padding(all: 1),
                                  constraints: BoxConstraints(
                                      minWidth: 36, minHeight: 36),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  onPressed: () => controller
                                      .showDeleteDepreciationConfirmation(
                                          depreciation['no'] ?? 0,
                                          depreciation['depreciation_name'] ??
                                              'Penyusutan'),
                                  icon: Icon(Remix.delete_bin_line,
                                      color: AppColors.danger, size: 18),
                                  padding: AppResponsive.padding(all: 1),
                                  constraints: BoxConstraints(
                                      minWidth: 36, minHeight: 36),
                                  tooltip: 'Hapus',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppResponsive.h(1),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: AppResponsive.padding(all: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Remix.money_dollar_circle_line,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: AppResponsive.w(1)),
                                      Text(
                                        'Nilai Penyusutan',
                                        style: AppText.small(
                                            color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppResponsive.h(0.5)),
                                  Text(
                                    depreciation['formatted_value'] ?? 'Rp 0',
                                    style: AppText.bodyMedium(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppResponsive.w(3)),
                          Expanded(
                            child: Container(
                              padding: AppResponsive.padding(all: 2.5),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Remix.calendar_line,
                                        size: 16,
                                        color: AppColors.info,
                                      ),
                                      SizedBox(width: AppResponsive.w(1)),
                                      Text(
                                        'Tanggal',
                                        style: AppText.small(
                                            color: AppColors.info),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppResponsive.h(0.5)),
                                  Text(
                                    depreciation['formatted_date'] ?? '-',
                                    style: AppText.bodyMedium(
                                      color: AppColors.info,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
              SizedBox(height: AppResponsive.h(2)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.navigateToAddDepreciation,
                  icon: Icon(
                    Remix.add_line,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Tambahkan Data Penyusutan',
                    style: AppText.button(color: AppColors.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary, width: 1.5),
                    padding:
                        AppResponsive.padding(vertical: 2.5, horizontal: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppText.bodyMedium(
            color: AppColors.dark.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppText.bodyMedium(
              color: AppColors.dark,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showImageDialog(String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white,
                      padding: AppResponsive.padding(all: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Remix.image_line,
                            size: 64,
                            color: AppColors.dark.withOpacity(0.3),
                          ),
                          Text(
                            'Gagal memuat gambar',
                            style: AppText.bodyMedium(color: AppColors.dark),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Container(
                  padding: AppResponsive.padding(all: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Remix.close_line,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
