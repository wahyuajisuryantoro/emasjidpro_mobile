import 'package:get/get.dart';

import '../controllers/pendapatan_riwayat_controller.dart';

class PendapatanRiwayatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PendapatanRiwayatController>(
      () => PendapatanRiwayatController(),
    );
  }
}
