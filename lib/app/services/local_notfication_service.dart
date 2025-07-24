import 'package:emasjid_pro/app/utils/app_colors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null) {
          OpenFile.open(payload);
        }
      },
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String filePath,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'export_channel',
          'Ekspor Data',
          channelDescription: 'Menampilkan notifikasi saat data berhasil diekspor',
          importance: Importance.max,
          priority: Priority.high,
          color: AppColors.primary,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: filePath,
    );
  }
}