import 'dart:convert';
import 'package:emasjid_pro/app/constant/base_url.dart';
import 'package:emasjid_pro/app/models/User.dart';
import 'package:emasjid_pro/app/routes/app_pages.dart';
import 'package:emasjid_pro/app/services/storage_services.dart';
import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  late final GlobalKey<FormState> formKey;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  final StorageService _storageService = Get.find<StorageService>();

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    return null;
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;

        final response = await http.post(
          Uri.parse('${BaseUrl.baseUrl}/login'),
          body: {
            'username': usernameController.text,
            'password': passwordController.text,
          },
        );
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (response.statusCode == 200 && responseData['status'] == 'success') {
          await _storageService.saveToken(responseData['token']);
          final user = User(
            userId: responseData['user_id'],
            username: responseData['username'],
            name: responseData['name'],
            category: responseData['category'],
            replika: responseData['replika'],
            referral: responseData['referral'],
            subdomain: responseData['subdomain'],
            link: responseData['link'],
            numberId: responseData['number_id'],
            birth: responseData['birth'],
            sex: responseData['sex'],
            address: responseData['address'],
            city: responseData['city'],
            phone: responseData['phone'],
            email: responseData['email'],
            bankName: responseData['bank_name'],
            bankBranch: responseData['bank_branch'],
            bankAccountNumber: responseData['bank_account_number'],
            bankAccountName: responseData['bank_account_name'],
            lastLogin: responseData['last_login'],
            lastIpaddress: responseData['last_ipaddress'],
            picture: responseData['picture'],
            date: responseData['date'],
            publish: responseData['publish'],
          );

          await _storageService.saveUserData(user);

          _clearForm();

          Get.offAllNamed(Routes.HOME);

          Get.snackbar(
            'Berhasil Login',
            'Selamat datang, ${user.name}!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.success,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Login gagal',
            responseData['message'] ?? 'Username or password is incorrect',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'An error occurred',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void _clearForm() {
    usernameController.clear();
    passwordController.clear();
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }
}
