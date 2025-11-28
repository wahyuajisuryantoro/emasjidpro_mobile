import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:emasjid_pro/app/widgets/custom_navbar_bottom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/pengeluaran_dashboard_controller.dart';

class PengeluaranDashboardView extends GetView<PengeluaranDashboardController> {
  const PengeluaranDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Pengeluaran',
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
              child: CircularProgressIndicator(color: AppColors.danger));
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchDashboardData();
          },
          color: AppColors.danger,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: AppResponsive.padding(horizontal: 5, vertical: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodSummaryCards(),
                SizedBox(height: AppResponsive.h(4)),
                _buildActivityMenu(),
                SizedBox(height: AppResponsive.h(4)),
                _buildExpenseCategoriesSummary(),
                SizedBox(height: AppResponsive.h(4)),
                _buildTransactionHistory(),
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
              color: AppColors.danger,
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
                        Remix.calendar_event_line,
                        color: AppColors.white,
                        size: 23,
                      ),
                    ),
                    Text(
                      'Tahunan',
                      style: AppText.pSmall(color: AppColors.white),
                    ),
                  ],
                ),
                Text(
                  controller.yearlyExpense.value,
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
                        Remix.calendar_check_line,
                        color: AppColors.white,
                        size: 23,
                      ),
                    ),
                    Text(
                      'Bulanan',
                      style: AppText.pSmall(color: AppColors.white),
                    ),
                  ],
                ),
                Text(
                  controller.monthlyExpense.value,
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
            onTap: () async {
              final result = await Get.toNamed(Routes.PENGELUARAN_TRANSAKSI);
              if (result == 'refresh') {
                controller.refreshData();
              }
            }),
        _buildActivityCard(
            icon: Remix.history_fill,
            title: "Riwayat",
            onTap: () async {
              final result = await Get.toNamed(Routes.PENGELUARAN_RIWAYAT);
              if (result == 'refresh') {
                controller.refreshData();
              }
            }),
        _buildActivityCard(
          icon: Remix.file_chart_line,
          title: "Laporan",
          onTap: () {
            Get.toNamed(Routes.PENGELUARAN_LAPORAN);
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
                  color: AppColors.danger.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.danger,
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

  Widget _buildExpenseCategoriesSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Jenis Pengeluaran',
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
          child: Obx(() => Column(
                children: [
                  if (controller.expenseCategories.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Belum ada data pengeluaran',
                          style:
                              AppText.p(color: AppColors.dark.withOpacity(0.6)),
                        ),
                      ),
                    )
                  else
                    ...controller.expenseCategories.map((category) {
                      return Column(
                        children: [
                          _buildExpenseCategoryItem(
                            title: category['title'],
                            amount: category['amount'],
                          ),
                          Divider(height: AppResponsive.h(3)),
                        ],
                      );
                    }).toList(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pengeluaran',
                        style: AppText.pSmallBold(color: AppColors.dark),
                      ),
                      Obx(() => Text(
                            controller.totalPengeluaran.value,
                            style: AppText.h6(color: AppColors.dark),
                          )),
                    ],
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildExpenseCategoryItem({
    required String title,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          width: AppResponsive.w(2),
          height: AppResponsive.h(4),
        ),
        SizedBox(width: AppResponsive.w(3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.pSmall(color: AppColors.dark),
              ),
              SizedBox(height: AppResponsive.h(0.5)),
              Row(
                children: [
                  Text(
                    amount,
                    style: AppText.pSmallBold(color: AppColors.dark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Transaksi',
              style: AppText.h6(color: AppColors.dark),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(Routes.PENGELUARAN_RIWAYAT);
              },
              child: Text(
                'Lihat Semua',
                style: AppText.pSmall(color: AppColors.danger),
              ),
            ),
          ],
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
          child: Obx(() => Column(
                children: [
                  if (controller.recentTransactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Belum ada data transaksi',
                          style:
                              AppText.p(color: AppColors.dark.withOpacity(0.6)),
                        ),
                      ),
                    )
                  else
                    ...controller.recentTransactions.map((transaction) {
                      return Column(
                        children: [
                          _buildTransactionItem(
                            date: transaction['date'],
                            title: transaction['title'],
                            amount: transaction['amount'],
                            isIncome: transaction['isIncome'],
                          ),
                          if (controller.recentTransactions.last != transaction)
                            Divider(height: AppResponsive.h(3)),
                        ],
                      );
                    }).toList(),
                ],
              )),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String date,
    required String title,
    required String amount,
    required bool isIncome,
  }) {
    return Row(
      children: [
        SizedBox(width: AppResponsive.w(3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppText.pSmall(color: AppColors.dark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              ),
              SizedBox(height: AppResponsive.h(2)),
              Text(
                controller.formatDate(date),
                style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: AppText.pSmallBold(
              color: isIncome ? AppColors.primary : AppColors.danger),
        ),
      ],
    );
  }
}
