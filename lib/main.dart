
import 'package:emasjid_pro/app/services/local_notfication_service.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  final storageService = Get.put(StorageService(), permanent: true);
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';
  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();
  final initialRoute = storageService.isLoggedIn() ? Routes.HOME : Routes.LOGIN;
  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    ),
  );
}
