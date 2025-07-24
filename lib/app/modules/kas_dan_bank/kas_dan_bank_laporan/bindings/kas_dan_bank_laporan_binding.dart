import 'package:get/get.dart';

import '../controllers/kas_dan_bank_laporan_controller.dart';

class KasDanBankLaporanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KasDanBankLaporanController>(
      () => KasDanBankLaporanController(),
    );
  }
}
