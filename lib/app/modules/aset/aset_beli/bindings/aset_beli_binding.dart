import 'package:get/get.dart';

import '../controllers/aset_beli_controller.dart';

class AsetBeliBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetBeliController>(
      () => AsetBeliController(),
    );
  }
}
