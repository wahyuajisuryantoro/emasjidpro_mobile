import 'package:get/get.dart';

import '../controllers/akun_dashboard_controller.dart';

class AkunDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AkunDashboardController>(
      () => AkunDashboardController(),
    );
  }
}
