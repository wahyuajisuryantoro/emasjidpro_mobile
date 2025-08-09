import 'package:get/get.dart';

import '../controllers/laporan_pendapatan_beban_controller.dart';

class LaporanPendapatanBebanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaporanPendapatanBebanController>(
      () => LaporanPendapatanBebanController(),
    );
  }
}
