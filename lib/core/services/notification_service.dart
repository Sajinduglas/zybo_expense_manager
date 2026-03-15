import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Android Initialization (Requires an app icon named @mipmap/ic_launcher in res/drawable)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // Handle notification tapped logic here if needed
      },
    );
  }

  Future<void> requestPermissions() async {
    print('[NOTIF] requestPermissions() called');
    // Request Android 13+ Notification Permissions reliably using permission_handler
    final status = await Permission.notification.status;
    print('[NOTIF] Current permission status: $status');
    if (status.isDenied || status.isProvisional) {
      final result = await Permission.notification.request();
      print('[NOTIF] Permission request result: $result');
    } else {
      print('[NOTIF] Permission already granted or permanently denied: $status');
    }
  }

  Future<void> showBudgetAlertNotification(
      double exceededAmount, double limit) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'budget_alerts', // Channel ID
      'Budget Alerts', // Channel Name
      channelDescription: 'Notifications for exceeding monthly budget limits',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF3B38D0), // matches App _activeBlue
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    print('[NOTIF] showBudgetAlertNotification called! amount=$exceededAmount limit=$limit');
    await _flutterLocalNotificationsPlugin.show(
      id: 0,
      title: 'Budget Limit Exceeded! ⚠️',
      body: 'You have exceeded your monthly limit of ₹${limit.toStringAsFixed(0)}. Current expenses: ₹${exceededAmount.toStringAsFixed(0)}',
      notificationDetails: platformChannelSpecifics,
    );
    print('[NOTIF] show() completed!');
  }
}
