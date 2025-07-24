import 'package:get/get.dart';

import '../controllers/piutang_detail_controller.dart';

class PiutangDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PiutangDetailController>(
      () => PiutangDetailController(),
    );
  }
}
