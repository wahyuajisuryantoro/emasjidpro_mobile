import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/aset_laporan_controller.dart';

class AsetLaporanView extends GetView<AsetLaporanController> {
  const AsetLaporanView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AsetLaporanView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AsetLaporanView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
