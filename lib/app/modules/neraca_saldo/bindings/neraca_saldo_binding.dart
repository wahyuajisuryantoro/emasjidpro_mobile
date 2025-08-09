import 'package:get/get.dart';

import '../controllers/neraca_saldo_controller.dart';

class NeracaSaldoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NeracaSaldoController>(
      () => NeracaSaldoController(),
    );
  }
}
