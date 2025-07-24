import 'package:get/get.dart';

import '../controllers/pengeluaran_riwayat_controller.dart';

class PengeluaranRiwayatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranRiwayatController>(
      () => PengeluaranRiwayatController(),
    );
  }
}
