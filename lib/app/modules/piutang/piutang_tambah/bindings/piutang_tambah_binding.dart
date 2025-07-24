import 'package:get/get.dart';

import '../controllers/piutang_tambah_controller.dart';

class PiutangTambahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PiutangTambahController>(
      () => PiutangTambahController(),
    );
  }
}
