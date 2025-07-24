import 'package:get/get.dart';

import '../controllers/jurnal_umum_detail_controller.dart';

class JurnalUmumDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JurnalUmumDetailController>(
      () => JurnalUmumDetailController(),
    );
  }
}
