import 'package:get/get.dart';

import '../controllers/aset_detail_controller.dart';

class AsetDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetDetailController>(
      () => AsetDetailController(),
    );
  }
}
