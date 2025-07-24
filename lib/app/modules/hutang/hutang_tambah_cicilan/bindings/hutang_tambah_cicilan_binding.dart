import 'package:get/get.dart';

import '../controllers/hutang_tambah_cicilan_controller.dart';

class HutangTambahCicilanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HutangTambahCicilanController>(
      () => HutangTambahCicilanController(),
    );
  }
}
