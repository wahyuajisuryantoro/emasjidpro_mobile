import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PermissionHelper {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
        
        return statuses[Permission.photos]?.isGranted == true;
      }

      else if (androidInfo.version.sdkInt >= 30) {
        final status = await Permission.storage.request();
        return status.isGranted;
      }

      else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
    return true;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      
      if (androidInfo.version.sdkInt >= 33) {
        return await Permission.photos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return true;
  }

  static void showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Permission Required'),
        content: Text(
          'This app needs storage permission to access files. Please grant permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}