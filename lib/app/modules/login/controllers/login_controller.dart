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

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }

  List<String> getUsernameHistory() {
    return _storageService.getUsernameHistory();
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;

        final response = await http.post(
          Uri.parse('${BaseUrl.baseUrl}/login'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'username': usernameController.text.trim(),
            'password': passwordController.text.trim(),
          },
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);

          if (responseData['status'] == 'success') {
            await _storageService.saveToken(responseData['token']);
            final user = User.fromJson(responseData);
            await _storageService.saveUserData(user);
            await _storageService
                .saveUsernameToHistory(usernameController.text.trim());
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
            String message = responseData['message'] ?? 'Login gagal';
            String errorType = responseData['error_type'] ?? '';
            String title = errorType == 'username_not_found' ? 'Username Tidak Ditemukan' : errorType == 'wrong_password' ? 'Password Salah' : 'Login Gagal';
            
            Get.snackbar(
              title,
              message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.danger,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
              margin: EdgeInsets.all(10),
              borderRadius: 10,
              icon: Icon(
                errorType == 'username_not_found' ? Icons.person_off : Icons.lock,
                color: Colors.white,
              ),
            );
          }
        } else if (response.statusCode == 401) {
          try {
            final Map<String, dynamic> errorData = json.decode(response.body);
            String message = errorData['message'] ?? 'Login gagal';
            String errorType = errorData['error_type'] ?? '';
            String title = errorType == 'username_not_found' ? 'Username Tidak Ditemukan' : errorType == 'wrong_password' ? 'Password Salah' : 'Login Gagal';
            
            Get.snackbar(
              title,
              message,
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.danger,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
              margin: EdgeInsets.all(10),
              borderRadius: 10,
              icon: Icon(
                errorType == 'username_not_found' ? Icons.person_off : Icons.lock,
                color: Colors.white,
              ),
            );
          } catch (e) {
            Get.snackbar(
              'Login Gagal',
              'Username atau password salah',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.danger,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'Server error (${response.statusCode})',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.danger,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      } catch (e) {
        print('Login error: $e');
        Get.snackbar(
          'Error',
          'Terjadi kesalahan koneksi',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.danger,
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