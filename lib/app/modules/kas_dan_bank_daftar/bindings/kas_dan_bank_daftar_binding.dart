import 'package:get/get.dart';

import '../controllers/kas_dan_bank_daftar_controller.dart';

class KasDanBankDaftarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KasDanBankDaftarController>(
      () => KasDanBankDaftarController(),
    );
  }
}
