import 'package:get/get.dart';

import '../controllers/aset_daftar_controller.dart';

class AsetDaftarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetDaftarController>(
      () => AsetDaftarController(),
    );
  }
}
