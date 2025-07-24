import 'package:get/get.dart';

import '../controllers/piutang_tambah_cicilan_controller.dart';

class PiutangTambahCicilanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PiutangTambahCicilanController>(
      () => PiutangTambahCicilanController(),
    );
  }
}
