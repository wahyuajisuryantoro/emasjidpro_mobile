import 'package:get/get.dart';

import '../controllers/piutang_dashboard_controller.dart';

class PiutangDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PiutangDashboardController>(
      () => PiutangDashboardController(),
    );
  }
}
