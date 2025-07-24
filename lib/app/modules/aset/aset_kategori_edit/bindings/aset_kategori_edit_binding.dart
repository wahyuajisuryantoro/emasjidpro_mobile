import 'package:get/get.dart';

import '../controllers/aset_kategori_edit_controller.dart';

class AsetKategoriEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AsetKategoriEditController>(
      () => AsetKategoriEditController(),
    );
  }
}
