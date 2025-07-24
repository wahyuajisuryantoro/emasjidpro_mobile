import 'package:get/get.dart';

import '../controllers/hutang_daftar_controller.dart';

class HutangDaftarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HutangDaftarController>(
      () => HutangDaftarController(),
    );
  }
}
