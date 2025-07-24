import 'package:get/get.dart';

import '../controllers/pengeluaran_dashboard_controller.dart';

class PengeluaranDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranDashboardController>(
      () => PengeluaranDashboardController(),
    );
  }
}
