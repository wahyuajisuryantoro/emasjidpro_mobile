import 'package:get/get.dart';

import '../controllers/aset_penyusutan_tambah_controller.dart';

class AsetPenyusutanTambahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetPenyusutanTambahController>(
      () => AsetPenyusutanTambahController(),
    );
  }
}
