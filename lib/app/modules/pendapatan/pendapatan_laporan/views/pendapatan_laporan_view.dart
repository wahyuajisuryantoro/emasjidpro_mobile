import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import '../controllers/pendapatan_laporan_controller.dart';

class PendapatanLaporanView extends GetView<PendapatanLaporanController> {
  const PendapatanLaporanView({super.key});

  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Laporan Pendapatan',
          style: AppText.h5(color: AppColors.dark),
        ),
        leading: IconButton(
          icon: Icon(
            Remix.arrow_left_s_line,
            color: AppColors.dark,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: AppResponsive.padding(all: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              margin: AppResponsive.margin(bottom: 3),
              padding: AppResponsive.padding(all: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppResponsive.w(4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: AppResponsive.w(12),
                    color: AppColors.white,
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Text(
                    'Cetak Laporan Pendapatan',
                    style: AppText.h5(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppResponsive.h(0.5)),
                  Text(
                    'Pilih periode laporan yang ingin dicetak',
                    style:
                        AppText.pSmall(color: AppColors.white.withOpacity(0.9)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Report Options
            Obx(() => Column(
                  children: [
                    _buildRadioOption(
                      title: 'Hari Ini',
                      value: ReportPeriod.daily,
                      groupValue: controller.selectedPeriod.value,
                      onChanged: (value) => controller.selectPeriod(value!),
                    ),
                    SizedBox(height: AppResponsive.h(2)),

                    _buildRadioOption(
                      title: '7 Hari Terakhir',
                      value: ReportPeriod.weekly,
                      groupValue: controller.selectedPeriod.value,
                      onChanged: (value) => controller.selectPeriod(value!),
                    ),
                    SizedBox(height: AppResponsive.h(2)),

                    _buildExpandableOption(
                      title: 'Pilih Bulan',
                      value: ReportPeriod.monthly,
                      groupValue: controller.selectedPeriod.value,
                      onChanged: (value) => controller.selectPeriod(value!),
                      isExpanded: controller.selectedPeriod.value ==
                          ReportPeriod.monthly,
                      expandedContent: _buildMonthSelector(),
                    ),
                    SizedBox(height: AppResponsive.h(2)),

                    // Pilih Tanggal
                    _buildExpandableOption(
                      title: 'Pilih Tanggal',
                      value: ReportPeriod.custom,
                      groupValue: controller.selectedPeriod.value,
                      onChanged: (value) => controller.selectPeriod(value!),
                      isExpanded: controller.selectedPeriod.value ==
                          ReportPeriod.custom,
                      expandedContent: _buildDateRangeSelector(),
                    ),
                    SizedBox(height: AppResponsive.h(4)),

                    SizedBox(
                      width: double.infinity,
                      height: AppResponsive.h(7),
                      child: ElevatedButton(
                        onPressed: () => controller.generateReport(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppResponsive.w(3)),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: AppColors.white,
                              size: AppResponsive.w(6),
                            ),
                            SizedBox(width: AppResponsive.w(2)),
                            Text(
                              'Cetak Laporan',
                              style: AppText.button(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required ReportPeriod value,
    required ReportPeriod groupValue,
    required ValueChanged<ReportPeriod?> onChanged,
  }) {
    bool isSelected = value == groupValue;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.w(3)),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.muted,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RadioListTile<ReportPeriod>(
        title: Text(
          title,
          style: AppText.h6(
            color: isSelected ? AppColors.primary : AppColors.dark,
          ),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: AppResponsive.padding(
          horizontal: 4,
          vertical: 1,
        ),
      ),
    );
  }

  Widget _buildExpandableOption({
    required String title,
    required ReportPeriod value,
    required ReportPeriod groupValue,
    required ValueChanged<ReportPeriod?> onChanged,
    required bool isExpanded,
    required Widget expandedContent,
  }) {
    bool isSelected = value == groupValue;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppResponsive.w(3)),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.muted,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          RadioListTile<ReportPeriod>(
            title: Text(
              title,
              style: AppText.h6(
                color: isSelected ? AppColors.primary : AppColors.dark,
              ),
            ),
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            contentPadding: AppResponsive.padding(
              horizontal: 4,
              vertical: 1,
            ),
          ),
          if (isExpanded) ...[
            Divider(
              color: AppColors.muted,
              height: 1,
              indent: AppResponsive.w(4),
              endIndent: AppResponsive.w(4),
            ),
            Padding(
              padding: AppResponsive.padding(
                horizontal: 4,
                vertical: 3,
              ),
              child: expandedContent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Obx(() => Container(
          width: double.infinity,
          padding: AppResponsive.padding(all: 3),
          decoration: BoxDecoration(
            color: AppColors.muted.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppResponsive.w(2)),
            border: Border.all(color: AppColors.muted),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: controller.selectedMonth.value,
              hint: Text(
                'Pilih Bulan',
                style: AppText.p(color: AppColors.dark.withOpacity(0.6)),
              ),
              isExpanded: true,
              dropdownColor: AppColors.white,
              items: controller.months.map((month) {
                return DropdownMenuItem<int>(
                  value: month['value'],
                  child: Text(
                    month['label'],
                    style: AppText.p(color: AppColors.dark),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectMonth(value);
                }
              },
            ),
          ),
        ));
  }

  Widget _buildDateRangeSelector() {
    return Obx(() => Column(
          children: [
            // Tanggal Mulai
            Container(
              width: double.infinity,
              margin: AppResponsive.margin(bottom: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Mulai',
                    style:
                        AppText.pSmall(color: AppColors.dark.withOpacity(0.7)),
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Container(
                    width: double.infinity,
                    padding: AppResponsive.padding(all: 3),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppResponsive.w(2)),
                      border: Border.all(color: AppColors.muted),
                    ),
                    child: InkWell(
                      onTap: () => controller.selectStartDate(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                            size: AppResponsive.w(5),
                          ),
                          SizedBox(width: AppResponsive.w(3)),
                          Text(
                            controller.startDate.value != null
                                ? controller
                                    .formatDate(controller.startDate.value!)
                                : '19 Jun 2025',
                            style: AppText.p(color: AppColors.dark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tanggal Akhir
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal Akhir',
                    style:
                        AppText.pSmall(color: AppColors.dark.withOpacity(0.7)),
                  ),
                  SizedBox(height: AppResponsive.h(1)),
                  Container(
                    width: double.infinity,
                    padding: AppResponsive.padding(all: 3),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppResponsive.w(2)),
                      border: Border.all(color: AppColors.muted),
                    ),
                    child: InkWell(
                      onTap: () => controller.selectEndDate(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                            size: AppResponsive.w(5),
                          ),
                          SizedBox(width: AppResponsive.w(3)),
                          Text(
                            controller.endDate.value != null
                                ? controller
                                    .formatDate(controller.endDate.value!)
                                : '19 Jun 2025',
                            style: AppText.p(color: AppColors.dark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
