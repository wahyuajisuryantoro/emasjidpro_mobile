import 'package:get/get.dart';

import '../controllers/pendapatan_transaksi_controller.dart';

class PendapatanTransaksiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PendapatanTransaksiController>(
      () => PendapatanTransaksiController(),
    );
  }
}
