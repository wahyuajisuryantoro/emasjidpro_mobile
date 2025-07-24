import 'package:get/get.dart';

import '../controllers/kas_dan_bank_tambah_controller.dart';

class KasDanBankTambahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KasDanBankTambahController>(
      () => KasDanBankTambahController(),
    );
  }
}
