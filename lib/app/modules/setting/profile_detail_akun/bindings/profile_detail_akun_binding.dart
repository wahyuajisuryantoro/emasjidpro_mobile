import 'package:get/get.dart';

import '../controllers/profile_detail_akun_controller.dart';

class ProfileDetailAkunBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileDetailAkunController>(
      () => ProfileDetailAkunController(),
    );
  }
}
