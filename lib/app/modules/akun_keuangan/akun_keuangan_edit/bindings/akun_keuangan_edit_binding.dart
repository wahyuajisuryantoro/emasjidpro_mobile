import 'package:get/get.dart';

import '../controllers/akun_keuangan_edit_controller.dart';

class AkunKeuanganEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AkunKeuanganEditController>(
      () => AkunKeuanganEditController(),
    );
  }
}
