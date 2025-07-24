import 'package:get/get.dart';

import '../controllers/aset_laporan_controller.dart';

class AsetLaporanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetLaporanController>(
      () => AsetLaporanController(),
    );
  }
}
