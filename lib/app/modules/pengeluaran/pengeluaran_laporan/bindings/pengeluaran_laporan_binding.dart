import 'package:get/get.dart';

import '../controllers/pengeluaran_laporan_controller.dart';

class PengeluaranLaporanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranLaporanController>(
      () => PengeluaranLaporanController(),
    );
  }
}
