import 'package:get/get.dart';

import '../controllers/kas_dan_bank_setor_controller.dart';

class KasDanBankSetorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KasDanBankSetorController>(
      () => KasDanBankSetorController(),
    );
  }
}
