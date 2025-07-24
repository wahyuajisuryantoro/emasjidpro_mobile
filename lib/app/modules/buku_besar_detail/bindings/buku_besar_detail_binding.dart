import 'package:get/get.dart';

import '../controllers/buku_besar_detail_controller.dart';

class BukuBesarDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BukuBesarDetailController>(
      () => BukuBesarDetailController(),
    );
  }
}
