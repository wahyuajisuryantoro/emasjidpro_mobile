import 'package:get/get.dart';

import '../controllers/aset_edit_controller.dart';

class AsetEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetEditController>(
      () => AsetEditController(),
    );
  }
}
