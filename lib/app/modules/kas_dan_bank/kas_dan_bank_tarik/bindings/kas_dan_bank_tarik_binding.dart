import 'package:get/get.dart';

import '../controllers/kas_dan_bank_tarik_controller.dart';

class KasDanBankTarikBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KasDanBankTarikController>(
      () => KasDanBankTarikController(),
    );
  }
}
