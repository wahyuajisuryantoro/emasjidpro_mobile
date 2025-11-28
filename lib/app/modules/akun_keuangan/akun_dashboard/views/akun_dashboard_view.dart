import 'package:emasjid_pro/app/models/AkunKeuanganModel.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/akun_dashboard_controller.dart';

class AkunDashboardView extends GetView<AkunDashboardController> {
  const AkunDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Daftar Akun',
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
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.loadAccounts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: AppResponsive.padding(all: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccountSection(
                    title: 'Aktiva Lancar',
                    accounts: controller.aktivaLancar,
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                  _buildAccountSection(
                    title: 'Aktiva Tetap',
                    accounts: controller.aktivaTetap,
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                  _buildAccountSection(
                    title: 'Kewajiban',
                    accounts: controller.kewajiban,
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                  _buildAccountSection(
                    title: 'Saldo',
                    accounts: controller.saldo,
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                  _buildAccountSection(
                    title: 'Pendapatan',
                    accounts: controller.pendapatan,
                  ),
                  SizedBox(height: AppResponsive.h(3)),
                  _buildAccountSection(
                    title: 'Beban',
                    accounts: controller.beban,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.navigateToAddAccount,
        backgroundColor: AppColors.primary,
        child: Icon(Remix.add_line, color: AppColors.white),
      ),
    );
  }

  Widget _buildAccountSection({
    required String title,
    required RxList<AkunKeuanganModel> accounts,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dark.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppResponsive.padding(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppText.h5(color: AppColors.white),
                ),
              ],
            ),
          ),
          Obx(() {
            if (accounts.isEmpty) {
              return Container(
                padding: AppResponsive.padding(all: 3),
                child: Center(
                  child: Text(
                    'Belum ada data akun',
                    style: AppText.bodyMedium(color: AppColors.dark.withOpacity(0.6)),
                  ),
                ),
              );
            }
            
            return Column(
              children: accounts.map((account) {
                return _buildAccountItem(account);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccountItem(AkunKeuanganModel account) {
    return Container(
      padding: AppResponsive.padding(horizontal: 3, vertical: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dark.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${account.kode} - ${account.nama}',
                  style: AppText.bodyMedium(color: AppColors.dark),
                ),
                Text(
                  account.kategori,
                  style: AppText.small(color: AppColors.dark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Remix.edit_line,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => controller.navigateToEditAccount(account),
          ),
        ],
      ),
    );
  }
}