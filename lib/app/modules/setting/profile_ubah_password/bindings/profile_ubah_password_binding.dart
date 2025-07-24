import 'package:get/get.dart';

import '../controllers/profile_ubah_password_controller.dart';

class ProfileUbahPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileUbahPasswordController>(
      () => ProfileUbahPasswordController(),
    );
  }
}
