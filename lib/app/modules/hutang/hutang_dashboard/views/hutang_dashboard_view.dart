import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/hutang_dashboard_controller.dart';

class HutangDashboardView extends GetView<HutangDashboardController> {
  const HutangDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Hutang & Tagihan',
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
                _buildPeriodSummaryCards(),
                SizedBox(height: AppResponsive.h(4)),
                _buildActivityMenu(),
                 SizedBox(height: AppResponsive.h(4)),
                _buildKategoriHutang(),
                SizedBox(height: AppResponsive.h(4)),
                _buildHutangList(),
                SizedBox(height: AppResponsive.h(4)),
              ],
            ),
          ),
        );
      }),
     
    );
  }

  Widget _buildPeriodSummaryCards() {
    return Row(
      children: [
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
                        Remix.file_paper_2_line,
                        color: AppColors.white,
                        size: 23,
                      ),
                    ),
                     SizedBox(width: AppResponsive.w(1)),
                    Text(
                      'Total Hutang',
                      style: AppText.pSmall(
                          color: AppColors.white),
                    ),
                  ],
                ),
                Text(
                  controller.totalHutang.value,
                  style: AppText.h5(color: AppColors.white),
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
                      'Total Tagihan',
                      style: AppText.pSmall(
                          color: AppColors.white),
                    ),
                  ],
                ),
                Text(
                   controller.totalTagihan.value,
                  style: AppText.h5(color: AppColors.white),
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
            Get.toNamed(Routes.HUTANG_TAMBAH);
          },
        ),
        _buildActivityCard(
          icon: Remix.history_fill,
          title: "Riwayat",
          onTap: () {
            Get.toNamed(Routes.HUTANG_DAFTAR);
          },
        ),
        _buildActivityCard(
          icon: Remix.file_chart_line,
          title: "Laporan",
          onTap: () {
            Get.toNamed(Routes.HUTANG_LAPORAN);
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

  Widget _buildKategoriHutang() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Hutang',
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
            if (controller.kategoriHutang.isEmpty) {
              return Center(
                child: Text(
                  'Tidak ada data kategori',
                  style: AppText.p(color: AppColors.muted),
                ),
              );
            }

            return Column(
              children: controller.kategoriHutang.map((kategori) {
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

 // In your HutangDashboardView class:

Widget _buildHutangList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Daftar Hutang',
            style: AppText.h6(color: AppColors.dark),
          ),
          TextButton(
            onPressed: controller.navigateToDaftarHutang,
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
          final filteredHutang = controller.daftarHutang
              .where((hutang) => hutang['status'] != 'Lunas')
              .toList();
          
          if (filteredHutang.isEmpty) {
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
                      'Belum ada hutang aktif',
                      style: AppText.p(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: filteredHutang.map((hutang) {
              return _buildHutangItem(hutang);
            }).toList(),
          );
        }),
      ),
    ],
  );
}

Widget _buildHutangItem(Map<String, dynamic> hutang) {
  return InkWell(
    onTap: () => controller.navigateToDetailHutang(hutang['id'].toString()),
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
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                hutang['nama'].isNotEmpty
                    ? hutang['nama'].substring(0, 1)
                    : 'H',
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
                  hutang['nama'],
                  style: AppText.pSmallBold(color: AppColors.dark),
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  hutang['kategori'],
                  style:
                      AppText.small(color: AppColors.dark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hutang['sisa'],
                style: AppText.pSmallBold(color: AppColors.dark),
              ),    
            ],
          ),
        ],
      ),
    ),
  );
}
}
