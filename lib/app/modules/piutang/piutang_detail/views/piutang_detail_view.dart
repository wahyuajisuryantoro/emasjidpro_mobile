import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/piutang_detail_controller.dart';

class PiutangDetailView extends GetView<PiutangDetailController> {
  const PiutangDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Detail Piutang',
          style: AppText.h5(color: AppColors.dark),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Remix.arrow_left_s_line,
            color: AppColors.dark,
          ),
          onPressed: () {
            Get.back(result: true);
          },
        ),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _buildContent()),
      floatingActionButton:
          Obx(() => controller.status.value.toLowerCase() == 'lunas'
              ? Container()
              : FloatingActionButton.extended(
                  onPressed: () => controller.navigateToTambahCicilan(),
                  backgroundColor: AppColors.primary,
                  icon: Icon(Remix.add_line, color: AppColors.white),
                  label: Text(
                    'Tambah Cicilan',
                    style: AppText.button(color: AppColors.white),
                  ),
                )),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchDetailPiutang(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: AppResponsive.padding(all: 4),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIdentityCard(),
            SizedBox(height: AppResponsive.h(3)),
            _buildStatusInfo(),
            SizedBox(height: AppResponsive.h(3)),
            Text('Riwayat Cicilan', style: AppText.h5(color: AppColors.dark)),
            SizedBox(height: AppResponsive.h(1.5)),
            _buildRiwayatPiutang(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Container(
      width: double.infinity,
      padding: AppResponsive.padding(all: 3),
      decoration: BoxDecoration(
        color: controller.status.value.toLowerCase() == 'lunas'
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.status.value.toLowerCase() == 'lunas'
              ? AppColors.success
              : AppColors.warning,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                controller.status.value.toLowerCase() == 'lunas'
                    ? Remix.checkbox_circle_fill
                    : Remix.time_line,
                color: controller.status.value.toLowerCase() == 'lunas'
                    ? AppColors.success
                    : AppColors.warning,
                size: 20,
              ),
              SizedBox(width: AppResponsive.w(2)),
              Text(
                'Status Piutang: ${controller.status.value}',
                style: AppText.h6(
                  color: controller.status.value.toLowerCase() == 'lunas'
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.h(1.5)),
          Text(
            controller.status.value.toLowerCase() == 'lunas'
                ? 'Piutang ini telah lunas diterima.'
                : 'Piutang ini belum lunas. Segera lakukan penagihan.',
            style: AppText.bodyMedium(
              color: AppColors.dark.withOpacity(0.8),
            ),
          ),
          if (controller.tanggalJatuhTempo.value.isNotEmpty) ...[
            SizedBox(height: AppResponsive.h(0.5)),
            Text(
              'Jatuh tempo: ${controller.tanggalJatuhTempo.value}',
              style: AppText.bodyMedium(
                color: AppColors.dark.withOpacity(0.8),
              ),
            ),
          ],
          SizedBox(height: AppResponsive.h(1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Piutang',
                style: AppText.bodyMedium(color: AppColors.dark),
              ),
              Text(
                controller.formatCurrency(controller.totalPiutang.value),
                style: AppText.bodyMedium(
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.h(0.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Cicilan',
                style: AppText.bodyMedium(color: AppColors.dark),
              ),
              Text(
                controller.formatCurrency(controller.totalCicilan.value),
                style: AppText.bodyMedium(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.h(1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sisa Piutang',
                style: AppText.bodyMedium(color: AppColors.dark),
              ),
              Text(
                controller.formatCurrency(controller.sisaPiutang.value),
                style: AppText.bodyMedium(color: AppColors.dark)
              )
                ],
        ),
        ]
      )
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: AppResponsive.padding(vertical: 2, horizontal: 3),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              'Informasi Piutang',
              style: AppText.h6(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: AppResponsive.padding(all: 3),
            child: Column(
              children: [
                _buildInfoRow(
                  'Kode',
                  controller.kodePiutang.value,
                ),
                SizedBox(height: AppResponsive.h(1.5)),
                _buildInfoRow('Nama', controller.nama.value),
                SizedBox(height: AppResponsive.h(1.5)),
                _buildInfoRow('Kategori', controller.kategori.value),
                SizedBox(height: AppResponsive.h(1.5)),
                _buildInfoRow('Tanggal', controller.tanggalTransaksi.value),
                SizedBox(height: AppResponsive.h(1.5)),
                _buildInfoRow('Keterangan', controller.keterangan.value),
                SizedBox(height: AppResponsive.h(1.5)),
                _buildInfoRow(
                  'Total Piutang',
                  controller.formatCurrency(controller.totalPiutang.value),
                  valueColor: AppColors.danger,
                ),
                SizedBox(height: AppResponsive.h(1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppResponsive.w(25),
          child: Text(
            label,
            style: AppText.bodyMedium(color: AppColors.dark),
          ),
        ),
        Text(': ', style: AppText.bodyMedium(color: AppColors.dark)),
        Expanded(
          child: Text(
            value,
            style: AppText.bodyMedium(
              color: valueColor ?? AppColors.dark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiwayatPiutang() {
    final riwayat = controller.getRiwayatTransaksi().where((item) {
      return item['jenis'] != 'Piutang';
    }).toList();

    if (riwayat.isEmpty) {
      return Container(
        padding: AppResponsive.padding(vertical: 5),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Remix.history_line,
              size: 48,
              color: AppColors.muted,
            ),
            SizedBox(height: AppResponsive.h(2)),
            Text(
              'Belum ada riwayat pembayaran cicilan',
              style: AppText.caption(color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: riwayat.length,
      itemBuilder: (context, index) {
        final item = riwayat[index];
        final isPositive = (item['jumlah'] as num?) != null
            ? (item['jumlah'] as num) < 0
            : true;
        final jumlah = (item['jumlah'] as num?)?.abs() ?? 0;
        final jenis = item['jenis'] ?? 'Transaksi';
        final tanggal = item['tanggal'] ?? '';
        final keterangan = item['keterangan'] ?? '';

        return Card(
          color: AppColors.white,
          margin: AppResponsive.margin(bottom: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: AppResponsive.padding(all: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tanggal,
                      style: AppText.bodySmall(color: AppColors.dark),
                    ),
                    Container(
                      padding: AppResponsive.padding(
                        horizontal: 2,
                        vertical: 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        jenis,
                        style: AppText.smallBold(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppResponsive.h(1)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        keterangan,
                        style: AppText.bodyMedium(color: AppColors.dark),
                      ),
                    ),
                    Text(
                      controller.formatCurrency(jumlah.toInt()),
                      style: AppText.bodyMedium(
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}