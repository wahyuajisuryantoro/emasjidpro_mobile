import 'package:get/get.dart';

import '../controllers/hutang_laporan_controller.dart';

class HutangLaporanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HutangLaporanController>(
      () => HutangLaporanController(),
    );
  }
}
