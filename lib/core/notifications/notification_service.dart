import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/models.dart';

class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  Future<bool> requestPermission() async {
    final android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return android ?? ios ?? true;
  }

  Future<void> showColdChainAlert(SensorReading reading) async {
    final productTemperature = reading.productTemp;
    final battery = reading.battery;
    final temperatureRisk = (productTemperature ?? double.negativeInfinity) > 4;
    final batteryRisk = (battery ?? double.infinity) < 20;
    if (!temperatureRisk && !batteryRisk && !reading.doorOpen) return;
    final body = temperatureRisk
        ? 'Product temperature is ${productTemperature!.toStringAsFixed(1)} degrees Celsius.'
        : batteryRisk
        ? 'Sensor battery is ${battery!.toStringAsFixed(0)}%.'
        : 'The refrigerated vehicle door is open.';
    await _plugin.show(
      id: 4101,
      title: 'Cold-chain alert',
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'cold_chain_alerts',
          'Cold-chain alerts',
          channelDescription: 'Temperature, battery, and door warnings',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
