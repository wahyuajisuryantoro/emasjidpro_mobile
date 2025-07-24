import 'package:get/get.dart';

import '../controllers/aset_kategori_daftar_controller.dart';

class AsetKategoriDaftarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetKategoriDaftarController>(
      () => AsetKategoriDaftarController(),
    );
  }
}
