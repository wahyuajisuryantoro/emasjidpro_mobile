import 'package:get/get.dart';

import '../controllers/kas_dan_bank_transfer_controller.dart';

class KasDanBankTransferBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KasDanBankTransferController>(
      () => KasDanBankTransferController(),
    );
  }
}
