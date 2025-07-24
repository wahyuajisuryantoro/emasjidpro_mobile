import 'package:get/get.dart';

import '../controllers/aset_penyusutan_edit_controller.dart';

class AsetPenyusutanEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetPenyusutanEditController>(
      () => AsetPenyusutanEditController(),
    );
  }
}
