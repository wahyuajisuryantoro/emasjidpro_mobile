import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:emasjid_pro/app/widgets/custom_navbar_bottom.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';

import '../controllers/informasi_controller.dart';

class InformasiView extends GetView<InformasiController> {
  const InformasiView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('Informasi' ,style: AppText.h5(color: AppColors.dark),),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'InformasiView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
