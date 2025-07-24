import 'package:get/get.dart';

import '../controllers/piutang_laporan_controller.dart';

class PiutangLaporanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PiutangLaporanController>(
      () => PiutangLaporanController(),
    );
  }
}
