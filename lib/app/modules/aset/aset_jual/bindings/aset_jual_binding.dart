import 'package:get/get.dart';

import '../controllers/aset_jual_controller.dart';

class AsetJualBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetJualController>(
      () => AsetJualController(),
    );
  }
}
