import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:emasjid_pro/app/widgets/custom_navbar_bottom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Profile Avatar with NetworkImage
            Obx(() {
              if (controller.picture.value.isNotEmpty) {
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: NetworkImage(controller.picture.value),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle image loading error
                    print('Error loading profile image: $exception');
                  },
                  child: controller.picture.value.isEmpty
                      ? Icon(
                          Remix.user_3_fill,
                          color: AppColors.primary,
                          size: 20,
                        )
                      : null,
                );
              } else {
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  child: Icon(
                    Remix.user_3_fill,
                    color: AppColors.primary,
                    size: 20,
                  ),
                );
              }
            }),
            SizedBox(width: AppResponsive.w(3)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assalamualaikum',
                  style: AppText.pSmall(color: AppColors.dark.withOpacity(0.6)),
                ),
                Obx(() => Text(
                      controller.name.value.isEmpty
                          ? (controller.userName.value.isEmpty
                              ? 'User'
                              : controller.userName.value)
                          : controller.name.value,
                      style: AppText.h6(color: AppColors.dark),
                    )),
              ],
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.toNamed(Routes.PROFILE);
                },
                icon: Icon(Remix.settings_3_line, color: AppColors.dark),
              ),
              Obx(() => Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.toNamed(Routes.NOTIFIKASI);
                        },
                        icon: Icon(Remix.notification_3_line,
                            color: AppColors.dark),
                      ),
                      if (controller.unreadNotificationCount.value > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              controller.unreadNotificationCount.value > 99
                                  ? '99+'
                                  : controller.unreadNotificationCount.value
                                      .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  )),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppResponsive.padding(horizontal: 5, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabCard(),
            SizedBox(height: AppResponsive.h(4)),
            Text(
              'Menu Utama',
              style: AppText.h5(color: AppColors.dark),
            ),
            SizedBox(height: AppResponsive.h(3)),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 0.9,
              crossAxisSpacing: AppResponsive.w(2),
              mainAxisSpacing: AppResponsive.h(2),
              children: _buildMenuItems(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }

  Widget _buildTabCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppResponsive.padding(horizontal: 5, top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        return Text(
                          controller.masjidName.value.isNotEmpty
                              ? controller.masjidName.value
                              : 'No Data',
                          style: AppText.h5(color: Colors.white),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          maxLines: null,
                        );
                      }),
                      SizedBox(height: AppResponsive.h(1)),
                      Obx(() => Text(
                            controller.masjidAlamat.value.isNotEmpty
                                ? controller.masjidAlamat.value
                                : 'No Data',
                            style: AppText.pSmall(
                                color: Colors.white.withOpacity(0.8)),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            maxLines: null,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Obx(() => Container(
                margin: AppResponsive.margin(horizontal: 5),
                padding: AppResponsive.padding(vertical: 0.5, horizontal: 0.5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Pendapatan', 0),
                    _buildTabButton('Pengeluaran', 1),
                    _buildTabButton('Saldo', 2),
                  ],
                ),
              )),
          Obx(() => _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = controller.selectedTabIndex.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTabIndex.value = index,
        child: Container(
          padding: AppResponsive.padding(vertical: 1.2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title,
            style: AppText.pSmall(
              color: isSelected ? AppColors.secondary : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (controller.selectedTabIndex.value) {
      case 0:
        return _buildPendapatanTab();
      case 1:
        return _buildPengeluaranTab();
      case 2:
        return _buildSaldoTab();
      default:
        return _buildPendapatanTab();
    }
  }

  Widget _buildPendapatanTab() {
    return Padding(
      padding: AppResponsive.padding(all: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Pendapatan',
            style: AppText.pSmall(color: Colors.white.withOpacity(0.8)),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Text(
            controller.pendapatan.value,
            style: AppText.h2(color: Colors.white),
          ),
          SizedBox(height: AppResponsive.h(2)),
          _buildInfoRow('Bulan Lalu', 'Rp 20.750.000'),
          SizedBox(height: AppResponsive.h(1)),
          _buildInfoRow('Bulan Ini', 'Rp 25.750.000'),
          SizedBox(height: AppResponsive.h(1)),
          _buildInfoRow('Peningkatan', '24%', suffixIcon: Remix.arrow_up_fill),
          SizedBox(height: AppResponsive.h(3)),
          _buildViewDetailButton('Lihat Detail Pendapatan'),
        ],
      ),
    );
  }

  Widget _buildPengeluaranTab() {
    return Padding(
      padding: AppResponsive.padding(all: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Pengeluaran',
            style: AppText.pSmall(color: Colors.white.withOpacity(0.8)),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Text(
            controller.pengeluaran.value,
            style: AppText.h2(color: Colors.white),
          ),
          SizedBox(height: AppResponsive.h(2)),
          _buildInfoRow('Bulan Lalu', 'Rp 10.500.000'),
          SizedBox(height: AppResponsive.h(1)),
          _buildInfoRow('Bulan Ini', 'Rp 12.345.000'),
          SizedBox(height: AppResponsive.h(1)),
          _buildInfoRow('Peningkatan', '17%', suffixIcon: Remix.arrow_up_fill),
          SizedBox(height: AppResponsive.h(3)),
          _buildViewDetailButton('Lihat Detail Pengeluaran'),
        ],
      ),
    );
  }

  Widget _buildSaldoTab() {
    return Padding(
      padding: AppResponsive.padding(all: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Kas',
            style: AppText.pSmall(color: Colors.white.withOpacity(0.8)),
          ),
          SizedBox(height: AppResponsive.h(1)),
          Text(
            controller.saldo.value,
            style: AppText.h2(color: Colors.white),
          ),
          SizedBox(height: AppResponsive.h(2)),
          _buildInfoRow('Pendapatan', controller.pendapatan.value,
              prefixIcon: Remix.funds_box_fill),
          SizedBox(height: AppResponsive.h(1)),
          _buildInfoRow('Pengeluaran', controller.pengeluaran.value,
              prefixIcon: Remix.hand_coin_fill),
          SizedBox(height: AppResponsive.h(1)),
          Divider(
              color: Colors.white.withOpacity(0.2), height: AppResponsive.h(2)),
          SizedBox(height: AppResponsive.h(1)),
          _buildInfoRow('Periode', controller.periode.value,
              prefixIcon: Remix.calendar_check_fill),
          SizedBox(height: AppResponsive.h(3)),
          _buildViewDetailButton('Lihat Detail Kas'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {IconData? prefixIcon, IconData? suffixIcon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (prefixIcon != null) ...[
              Icon(
                prefixIcon,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              SizedBox(width: AppResponsive.w(1)),
            ],
            Text(
              label,
              style: AppText.pSmall(color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              value,
              style: AppText.pSmall(color: Colors.white),
            ),
            if (suffixIcon != null) ...[
              SizedBox(width: AppResponsive.w(1)),
              Icon(
                suffixIcon,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildViewDetailButton(String label) {
    return Container(
      width: double.infinity,
      padding: AppResponsive.padding(vertical: 1.5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Remix.file_list_3_line,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: AppResponsive.w(1)),
          Text(
            label,
            style: AppText.pSmall(color: Colors.white),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    final menuItems = [
      {
        'title': 'Pendapatan',
        'icon': Remix.funds_box_fill,
        'color1': Color(0xFF53E88B),
        'color2': Color(0xFF15BE77),
        'onTap': () {
          Get.toNamed(Routes.PENDAPATAN);
        }
      },
      {
        'title': 'Pengeluaran',
        'icon': Remix.hand_coin_fill,
        'color1': Color(0xFFFF8C48),
        'color2': Color(0xFFFF5757),
        'onTap': () {
          Get.toNamed(Routes.PENGELUARAN_DASHBOARD);
        }
      },
      {
        'title': 'Hutang',
        'icon': Remix.refund_2_fill,
        'color1': Color(0xFF62CDFF),
        'color2': Color(0xFF3674B5),
        'onTap': () {
          Get.toNamed(Routes.HUTANG_DASHBOARD);
        }
      },
      {
        'title': 'Piutang',
        'icon': Remix.refund_fill,
        'color1': Color(0xFF9DDE8B),
        'color2': Color(0xFF40A578),
        'onTap': () {
          Get.toNamed(Routes.PIUTANG_DASHBOARD);
        }
      },
      {
        'title': 'Kas & Bank',
        'icon': Remix.bank_fill,
        'color1': Color(0xFFD47AE8),
        'color2': Color(0xFFA84DC9),
        'onTap': () {
          Get.toNamed(Routes.KAS_DAN_BANK_DASHBOARD);
        }
      },
      {
        'title': 'Aset',
        'icon': Remix.home_gear_fill,
        'color1': Color(0xFF896BFF),
        'color2': Color(0xFF6045E6),
        'onTap': () {
          Get.toNamed(Routes.ASET_DASHBOARD);
        }
      },
      {
        'title': 'Laporan',
        'icon': Remix.file_chart_fill,
        'color1': Color(0xFF00C2CB),
        'color2': Color(0xFF006769),
        'onTap': () {
          Get.toNamed(Routes.LAPORAN);
        }
      },
      {
        'title': 'Akun',
        'icon': Remix.wallet_3_fill,
        'color1': Color(0xFFFFCF71),
        'color2': Color(0xFFFFB836),
        'onTap': () {
          Get.toNamed(Routes.AKUN_DASHBOARD);
        }
      },
    ];

    return menuItems.map((item) {
      return GestureDetector(
        onTap: item['onTap'] as void Function(),
        child: Column(
          children: [
            Container(
              width: AppResponsive.w(14),
              height: AppResponsive.w(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item['color1'] as Color,
                    item['color2'] as Color,
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: (item['color2'] as Color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                item['icon'] as IconData,
                color: Colors.white,
                size: 26,
              ),
            ),
            SizedBox(height: AppResponsive.h(1)),
            Text(
              item['title'] as String,
              style: AppText.small(color: AppColors.dark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }).toList();
  }
}
