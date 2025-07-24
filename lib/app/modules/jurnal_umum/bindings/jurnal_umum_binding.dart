import 'package:get/get.dart';

import '../controllers/jurnal_umum_controller.dart';

class JurnalUmumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JurnalUmumController>(
      () => JurnalUmumController(),
    );
  }
}
