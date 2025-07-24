import 'package:get/get.dart';

import '../controllers/akun_keuangan_tambah_controller.dart';

class AkunKeuanganTambahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AkunKeuanganTambahController>(
      () => AkunKeuanganTambahController(),
    );
  }
}
