import 'package:get/get.dart';

import '../controllers/pengeluaran_transaksi_controller.dart';

class PengeluaranTransaksiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PengeluaranTransaksiController>(
      () => PengeluaranTransaksiController(),
    );
  }
}
