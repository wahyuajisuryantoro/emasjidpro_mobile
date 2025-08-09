import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_responsive.dart';
import '../../../../utils/app_text.dart';
import '../controllers/kas_dan_bank_dashboard_controller.dart';

class KasDanBankDashboardView extends GetView<KasDanBankDashboardController> {
  const KasDanBankDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Kas & Bank',
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
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  controller.loadAccountsAndTransactions();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActivityCard(
                              icon: Remix.download_line,
                              title: "Setor",
                              color: AppColors.primary,
                              onTap: () {
                                Get.toNamed(Routes.KAS_DAN_BANK_SETOR);
                              },
                            ),
                            _buildActivityCard(
                              icon: Remix.upload_line,
                              title: "Tarik",
                              color: AppColors.warning,
                              onTap: () {
                                Get.toNamed(Routes.KAS_DAN_BANK_TARIK);
                              },
                            ),
                            _buildActivityCard(
                              icon: Remix.exchange_line,
                              title: "Transfer",
                              color: AppColors.info,
                              onTap: () {
                                Get.toNamed(Routes.KAS_DAN_BANK_TRANSFER);
                              },
                            ),
                            _buildActivityCard(
                              icon: Remix.file_chart_line,
                              title: "Laporan",
                              color: AppColors.danger,
                              onTap: () {
                                Get.toNamed(Routes.KAS_DAN_BANK_LAPORAN);
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            AppResponsive.padding(horizontal: 4, vertical: 2),
                        child: Text(
                          'Rincian Saldo',
                          style: AppText.h5(color: AppColors.dark),
                        ),
                      ),
                      _buildAccountsList(),
                      Padding(
                        padding:
                            AppResponsive.padding(horizontal: 4, vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Riwayat Mutasi',
                              style: AppText.h5(color: AppColors.dark),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.KAS_DAN_BANK_DAFTAR);
                              },
                              child: Text(
                                'Lihat Semua',
                                style: AppText.pSmall(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildTransactionsList(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required Color color,
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              SizedBox(height: AppResponsive.h(0.5)),
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

  Widget _buildAccountsList() {
    return Obx(() => Padding(
          padding: AppResponsive.padding(horizontal: 4),
          child: Column(
            children: controller.accounts.map((account) {
              return _buildAccountItem(account);
            }).toList(),
          ),
        ));
  }

  Widget _buildAccountItem(dynamic account) {
    return Container(
      margin: AppResponsive.margin(bottom: 2),
      padding: AppResponsive.padding(all: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.dark.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                account['type'] == 'kas'
                    ? Remix.wallet_line
                    : Remix.bank_card_line,
                color: AppColors.primary.withOpacity(0.7),
              ),
              SizedBox(width: AppResponsive.w(2)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account['name'],
                    style: AppText.bodyMedium(color: AppColors.dark),
                  ),
                  Text(
                    account['type'].toUpperCase(),
                    style:
                        AppText.small(color: AppColors.dark.withOpacity(0.6)),
                  ),
                ],
              ),
            ],
          ),
          Text(
            controller.formatCurrency(account['balance']),
            style: AppText.bodyMedium(color: AppColors.dark),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Obx(() => Padding(
          padding: AppResponsive.padding(horizontal: 4),
          child: controller.transactions.isEmpty
              ? Center(
                  child: Padding(
                    padding: AppResponsive.padding(vertical: 4),
                    child: Text(
                      'Belum ada data transaksi',
                      style: AppText.bodyMedium(
                          color: AppColors.dark.withOpacity(0.6)),
                    ),
                  ),
                )
              : Column(
                  children: controller.transactions.map((transaction) {
                    return _buildTransactionItem(transaction);
                  }).toList(),
                ),
        ));
  }

  Widget _buildTransactionItem(dynamic transaction) {
    final formatDate = DateFormat('dd MMM yyyy');

    final String fromAccount =
        transaction['fromAccount'].toString().toLowerCase();
    final String toAccount = transaction['toAccount'].toString().toLowerCase();

    bool isKasIncoming = toAccount.contains('kas');
    bool isKasOutgoing = fromAccount.contains('kas');

    Color transactionColor;
    IconData transactionIcon;
    String transactionType;

    if (isKasIncoming && !isKasOutgoing) {
      transactionColor = AppColors.success;
      transactionIcon = Remix.arrow_down_line;
      transactionType = "Tarik";
    } else if (isKasOutgoing && !isKasIncoming) {
      transactionColor = AppColors.warning;
      transactionIcon = Remix.arrow_up_line;
      transactionType = "Setor";
    } else {
      transactionColor = AppColors.info;
      transactionIcon = Remix.exchange_line;
      transactionType = "Transfer";
    }

    return Container(
      margin: AppResponsive.margin(bottom: 2),
      padding: AppResponsive.padding(all: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.dark.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: AppResponsive.padding(all: 1),
            decoration: BoxDecoration(
              color: transactionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              transactionIcon,
              color: transactionColor,
              size: 20,
            ),
          ),
          SizedBox(width: AppResponsive.w(2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          AppResponsive.padding(horizontal: 1, vertical: 0.5),
                      decoration: BoxDecoration(
                        color: transactionColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transactionType,
                        style: AppText.small(color: AppColors.white),
                      ),
                    ),
                    SizedBox(width: AppResponsive.w(1)),
                    Expanded(
                      child: Text(
                        transaction['description'] ?? 'Tidak ada keterangan',
                        style: AppText.bodyMedium(color: AppColors.dark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppResponsive.h(0.5)),
                Text(
                  '${transaction['fromAccount']} → ${transaction['toAccount']}',
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppResponsive.h(1)),
                Text(
                  controller.formatDate(transaction['date']),
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.formatCurrency(transaction['amount']),
                style: AppText.bodyMedium(color: transactionColor),
              ),
              Text(
                '#${transaction['code']}',
                style: AppText.small(color: AppColors.dark.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
