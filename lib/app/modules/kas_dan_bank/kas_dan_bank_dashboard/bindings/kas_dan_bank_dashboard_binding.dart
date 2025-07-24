import 'package:get/get.dart';

import '../controllers/kas_dan_bank_dashboard_controller.dart';

class KasDanBankDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KasDanBankDashboardController>(
      () => KasDanBankDashboardController(),
    );
  }
}
