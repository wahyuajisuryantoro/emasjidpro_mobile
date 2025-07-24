import 'package:get/get.dart';

import '../controllers/profile_masjid_saya_controller.dart';

class ProfileMasjidSayaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileMasjidSayaController>(
      () => ProfileMasjidSayaController(),
    );
  }
}
