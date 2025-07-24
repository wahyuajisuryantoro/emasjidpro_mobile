import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:emasjid_pro/app/widgets/custom_navbar_bottom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/pendapatan_controller.dart';

class PendapatanView extends GetView<PendapatanController> {
  const PendapatanView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Pendapatan',
          style: AppText.h5(color: AppColors.dark),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Remix.refresh_line,
              color: AppColors.dark,
            ),
            onPressed: () {
              controller.fetchDashboardData();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSummaryCards(),
              const SizedBox(height: 20),
              _buildActivityMenu(),
              const SizedBox(height: 20),
              _buildIncomeCategoriesSummary(),
              const SizedBox(height: 20),
              _buildTransactionHistory(),
            ],
          ),
        );
      }),
      bottomNavigationBar: CustomBottomNavigationBar(),
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
                        Remix.calendar_event_line,
                        color: AppColors.white,
                        size: 23,
                      ),
                    ),
                    Text(
                      'Tahunan',
                      style: AppText.pSmall(
                          color: AppColors.white),
                    ),
                  ],
                ),
                Text(
                  controller.yearlyIncome.value,
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
                      style: AppText.pSmall(
                          color: AppColors.white),
                    ),
                  ],
                ),
                Text(
                  controller.monthlyIncome.value,
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
            Get.toNamed(Routes.PENDAPATAN_TRANSAKSI);
          },
        ),
        _buildActivityCard(
          icon: Remix.history_fill,
          title: "Riwayat",
          onTap: () {
            Get.toNamed(Routes.PENDAPATAN_RIWAYAT);
          },
        ),
        _buildActivityCard(
          icon: Remix.file_chart_line,
          title: "Laporan",
          onTap: () {
            Get.toNamed(Routes.PENDAPATAN_LAPORAN);
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
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
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

  Widget _buildIncomeCategoriesSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Jenis Pendapatan',
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
          child: Column(
            children: [
              ...controller.incomeCategories
                  .map((category) => Column(
                        children: [
                          _buildIncomeCategoryItem(
                            title: category.name,
                            amount: controller.formatCurrency(category.total),
                          ),
                          const Divider(),
                        ],
                      ))
                  .toList(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Pendapatan',
                    style: AppText.pSmallBold(color: AppColors.dark),
                  ),
                  Text(
                    controller.totalIncome.value,
                    style: AppText.h6(color: AppColors.dark),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeCategoryItem({
    required String title,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          width: AppResponsive.w(2),
          height: AppResponsive.h(4),
        ),
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
                Get.toNamed(Routes.PENDAPATAN_RIWAYAT);
              },
              child: Text(
                'Lihat Semua',
                style: AppText.pSmall(color: AppColors.primary),
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
          child: Column(
            children: [
              ...controller.recentTransactions
                  .map((transaction) => Column(
                        children: [
                          _buildTransactionItem(
                            date: transaction.date,
                            title: transaction.title,
                            description: transaction.description,
                            amount:
                                controller.formatCurrency(transaction.amount),
                            isIncome: transaction.isIncome,
                          ),
                          const Divider(),
                        ],
                      ))
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required String date,
    required String title,
    required String description,
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
                      softWrap: true,
                    ),
                  ),
                  SizedBox(width: AppResponsive.w(2)),
                  Text(
                    description,
                    style: AppText.pSmall(color: AppColors.dark),
                  ),
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
