import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  static Future<void> showHelpAlert() async {
    const androidDetails = AndroidNotificationDetails(
      'moodmirror_help_channel',
      'MoodMirror Alerts',
      channelDescription: 'Alertas de ayuda cuando hay varios días difíciles.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      101,
      '💙 ¿Necesitas apoyo?',
      'Detectamos varios días difíciles seguidos. Contactos: 911 • 102 • 988',
      details,
    );
  }
}
