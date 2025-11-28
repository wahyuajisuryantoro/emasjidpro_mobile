import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:emasjid_pro/app/utils/app_responsive.dart';
import 'package:emasjid_pro/app/utils/app_text.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    AppResponsive().init(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/pattern.jpg'),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: AppResponsive.padding(horizontal: 5, vertical: 3),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Assalamualaikum',
                        style: AppText.h3(color: AppColors.dark),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppResponsive.h(1)),
                      Text(
                        'Silahkan masuk menggunakan username dan password anda',
                        style:
                            AppText.p(color: AppColors.dark.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppResponsive.h(5)),
                      _buildUsernameField(),
                      SizedBox(height: AppResponsive.h(2)),
                      _buildPasswordField(),
                      SizedBox(height: AppResponsive.h(1)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: AppText.pSmall(color: AppColors.primary),
                          ),
                        ),
                      ),
                      SizedBox(height: AppResponsive.h(3)),
                      _buildLoginButton(),
                      SizedBox(height: AppResponsive.h(4)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    final history = controller.getUsernameHistory();

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return history.take(5);
        }
        return history.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        }).take(5);
      },
      onSelected: (String selection) {
        controller.usernameController.text = selection;
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // Sync sekali saja, tanpa listener
        if (textEditingController.text != controller.usernameController.text) {
          textEditingController.text = controller.usernameController.text;
        }

        return TextFormField(
          controller:
              controller.usernameController, // Langsung pakai controller asli
          focusNode: focusNode,
          validator: controller.validateUsername,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'Masukkan Username',
            prefixIcon:
                const Icon(Icons.person_outline, color: AppColors.primary),
            suffixIcon: history.isNotEmpty
                ? Icon(Icons.history, color: Colors.grey[400], size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            contentPadding: AppResponsive.padding(horizontal: 4, vertical: 2),
          ),
          style: AppText.p(color: AppColors.dark),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => TextFormField(
          controller: controller.passwordController,
          validator: controller.validatePassword,
          obscureText: controller.obscurePassword.value,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Masukkan Password',
            prefixIcon:
                const Icon(Icons.lock_outline, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                controller.obscurePassword.value
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.primary,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            contentPadding: AppResponsive.padding(horizontal: 4, vertical: 2),
          ),
          style: AppText.p(color: AppColors.dark),
        ));
  }

  Widget _buildLoginButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: AppResponsive.h(7),
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              padding: AppResponsive.padding(vertical: 1.5),
            ),
            child: controller.isLoading.value
                ? const CircularProgressIndicator(
                    color: AppColors.white,
                  )
                : Text(
                    'Masuk',
                    style: AppText.button(color: AppColors.white),
                  ),
          ),
        ));
  }
}
