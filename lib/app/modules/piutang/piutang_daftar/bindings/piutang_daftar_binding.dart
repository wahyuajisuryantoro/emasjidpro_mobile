import 'package:get/get.dart';

import '../controllers/piutang_daftar_controller.dart';

class PiutangDaftarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PiutangDaftarController>(
      () => PiutangDaftarController(),
    );
  }
}
