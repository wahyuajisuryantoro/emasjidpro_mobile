import 'package:get/get.dart';

import '../controllers/hutang_dashboard_controller.dart';

class HutangDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HutangDashboardController>(
      () => HutangDashboardController(),
    );
  }
}
