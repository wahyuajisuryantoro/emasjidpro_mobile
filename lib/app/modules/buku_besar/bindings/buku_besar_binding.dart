import 'package:get/get.dart';

import '../controllers/buku_besar_controller.dart';

class BukuBesarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BukuBesarController>(
      () => BukuBesarController(),
    );
  }
}
