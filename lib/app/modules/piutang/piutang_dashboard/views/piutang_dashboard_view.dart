import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/piutang_dashboard_controller.dart';

class PiutangDashboardView extends GetView<PiutangDashboardController> {
  const PiutangDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Piutang & Terhutang',
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
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchDashboardData(),
          color: AppColors.primary,
          child: SingleChildScrollView(
            padding: AppResponsive.padding(horizontal: 5, vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(),
                SizedBox(height: AppResponsive.h(4)),
                _buildActivityMenu(),
                SizedBox(height: AppResponsive.h(4)),
                _buildKategoriPiutang(),
                SizedBox(height: AppResponsive.h(4)),
                _buildPiutangList(),
                SizedBox(height: AppResponsive.h(4)),
              ],
            ),
          ),
        );
      }),
      
    );
  }

  Widget _buildSummaryCards() {
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: AppResponsive.padding(all: 3),
          decoration: BoxDecoration(
            color: AppColors.info,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: AppResponsive.padding(all: 1),
                    child: Icon(
                      Remix.bill_line,
                      color: AppColors.white,
                      size: 23,
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(1)),
                  Text(
                    'Sisa Piutang', // Ubah label untuk kejelasan
                    style: AppText.pSmall(color: AppColors.white),
                  ),
                ],
              ),
              Text(
                controller.totalPiutang.value,
                style: AppText.h5(color: AppColors.white),
              ),
              SizedBox(height: AppResponsive.h(1)),
              Text(
                '${controller.piutangCount.value} penghutang', 
                style: AppText.small(color: AppColors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
      ),
      SizedBox(width: AppResponsive.w(3)),
      Expanded(
        child: Container(
          padding: AppResponsive.padding(all: 3),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: AppResponsive.padding(all: 1),
                    child: Icon(
                      Remix.money_dollar_box_line,
                      color: AppColors.white,
                      size: 23,
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(1)),
                  Text(
                    'Total Terhutang', 
                    style: AppText.pSmall(color: AppColors.white),
                  ),
                ],
              ),
              Text(
                controller.totalTerhutang.value,
                style: AppText.h5(color: AppColors.white),
              ),
              SizedBox(height: AppResponsive.h(1)),
              Text(
                '${controller.terhutangCount.value} rekanan',
                style: AppText.small(color: AppColors.white.withOpacity(0.9)),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildActivityMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActivityCard(
          icon: Remix.add_circle_fill,
          title: "Transaksi",
          onTap: () {
            Get.toNamed(Routes.PIUTANG_TAMBAH);
          },
        ),
        _buildActivityCard(
          icon: Remix.history_fill,
          title: "Riwayat",
          onTap: () {
            Get.toNamed(Routes.PIUTANG_DAFTAR);
          },
        ),
        _buildActivityCard(
          icon: Remix.file_chart_line,
          title: "Laporan",
          onTap: () {
            Get.toNamed(Routes.PIUTANG_LAPORAN);
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: AppResponsive.margin(horizontal: 1),
          padding: AppResponsive.padding(all: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: AppResponsive.w(10),
                height: AppResponsive.w(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.info,
                  size: 22,
                ),
              ),
              SizedBox(height: AppResponsive.h(1)),
              Text(
                title,
                style: AppText.pSmallBold(color: AppColors.dark),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriPiutang() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Piutang',
          style: AppText.h6(color: AppColors.dark),
        ),
        SizedBox(height: AppResponsive.h(2)),
        Container(
          padding: AppResponsive.padding(all: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            if (controller.kategoriPiutang.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada data kategori',
                  style: AppText.p(color: AppColors.muted),
                ),
              );
            }

            return Column(
              children: controller.kategoriPiutang.map((kategori) {
                return _buildKategoriItem(kategori);
              }).toList(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildKategoriItem(Map<String, dynamic> kategori) {
    return Container(
      padding: AppResponsive.padding(vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.muted.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kategori['nama_kategori'],
                  style: AppText.pSmallBold(color: AppColors.dark),
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  'Kode: ${kategori['kode_kategori']}',
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                kategori['formatted_sisa'],
                style: AppText.pSmallBold(color: AppColors.dark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPiutangList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Piutang',
              style: AppText.h6(color: AppColors.dark),
            ),
            TextButton(
              onPressed: controller.navigateToDaftarPiutang,
              child: Text(
                'Lihat Semua',
                style: AppText.pSmall(color: AppColors.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: AppResponsive.h(2)),
        Container(
          padding: AppResponsive.padding(all: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            // Filter out paid debts
            final filteredPiutang = controller.daftarPiutang
                .where((piutang) => piutang['status'] != 'Lunas')
                .toList();
            
            if (filteredPiutang.isEmpty) {
              return Container(
                padding: AppResponsive.padding(all: 3),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Remix.file_list_3_line,
                        color: AppColors.muted,
                        size: 32,
                      ),
                      SizedBox(height: AppResponsive.h(1)),
                      Text(
                        'Belum ada piutang aktif',
                        style: AppText.p(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: filteredPiutang.map((piutang) {
                return _buildPiutangItem(piutang);
              }).toList(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPiutangItem(Map<String, dynamic> piutang) {
  return InkWell(
    onTap: () => controller.navigateToDetailPiutang(piutang['id'].toString()),
    child: Container(
      padding: AppResponsive.padding(all: 3),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.muted.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: AppResponsive.w(10),
            height: AppResponsive.w(10),
            decoration: BoxDecoration(
              color: AppColors.info,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                piutang['nama'].isNotEmpty
                    ? piutang['nama'].substring(0, 1)
                    : 'P',
                style: AppText.h5(color: AppColors.white),
              ),
            ),
          ),
          SizedBox(width: AppResponsive.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  piutang['nama'],
                  style: AppText.pSmallBold(color: AppColors.dark),
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  piutang['kategori'],
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  'Jatuh tempo: ${piutang['tanggal']}',
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                piutang['sisa'], // Ubah dari jumlah menjadi sisa
                style: AppText.pSmallBold(color: AppColors.dark),
              ),
              SizedBox(height: AppResponsive.h(0.5)),
              Container(
                padding: AppResponsive.padding(horizontal: 1.5, vertical: 0.5),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  piutang['status'],
                  style: AppText.small(color: AppColors.warning),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}