import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:get/get.dart';

class BottomNavigationBarController extends GetxController {
  var currentIndex = 0.obs;

  final List<String> routes = [
    Routes.HOME,
    Routes.PENDAPATAN,
    Routes.LAPORAN,
    Routes.INFORMASI,
    Routes.PROFIL,
  ];

  @override
  void onInit() {
    super.onInit();

    updateIndexBasedOnRoute(Get.currentRoute);
  }

  @override
  void onReady() {
    super.onReady();

    updateIndexBasedOnRoute(Get.currentRoute);
  }

  void updateIndexBasedOnRoute(String currentRoute) {
    for (int i = 0; i < routes.length; i++) {
      if (currentRoute.startsWith(routes[i])) {
        currentIndex.value = i;
        break;
      }
    }
  }

  void changePage(int index) {
    if (currentIndex.value != index) {
      currentIndex.value = index;
      Get.offNamed(routes[index]);
    }
  }
}
