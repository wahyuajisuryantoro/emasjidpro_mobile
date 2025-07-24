import 'package:get/get.dart';

import '../controllers/hutang_tambah_controller.dart';

class HutangTambahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HutangTambahController>(
      () => HutangTambahController(),
    );
  }
}
