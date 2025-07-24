import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/jurnal_umum_detail_controller.dart';

class JurnalUmumDetailView extends GetView<JurnalUmumDetailController> {
  const JurnalUmumDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JurnalUmumDetailView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'JurnalUmumDetailView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
