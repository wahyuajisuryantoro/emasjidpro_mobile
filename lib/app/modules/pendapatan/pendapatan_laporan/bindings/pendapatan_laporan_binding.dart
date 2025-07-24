import 'package:get/get.dart';

import '../controllers/pendapatan_laporan_controller.dart';

class PendapatanLaporanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PendapatanLaporanController>(
      () => PendapatanLaporanController(),
    );
  }
}
