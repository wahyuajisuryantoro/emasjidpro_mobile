import 'package:get/get.dart';

import '../controllers/aset_daftar_jual_controller.dart';

class AsetDaftarJualBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetDaftarJualController>(
      () => AsetDaftarJualController(),
    );
  }
}
