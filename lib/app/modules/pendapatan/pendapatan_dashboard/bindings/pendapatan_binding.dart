import 'package:get/get.dart';

import '../controllers/pendapatan_controller.dart';

class PendapatanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PendapatanController>(
      () => PendapatanController(),
    );
  }
}
