import 'package:get/get.dart';

import '../controllers/aset_kategori_tambah_controller.dart';

class AsetKategoriTambahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetKategoriTambahController>(
      () => AsetKategoriTambahController(),
    );
  }
}
