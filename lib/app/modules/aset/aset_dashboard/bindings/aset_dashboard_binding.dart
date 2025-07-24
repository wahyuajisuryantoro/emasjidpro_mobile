import 'package:get/get.dart';

import '../controllers/aset_dashboard_controller.dart';

class AsetDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetDashboardController>(
      () => AsetDashboardController(),
    );
  }
}
