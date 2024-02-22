import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:todo/Model/note.dart';

class LocalNotify {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initializeNotification() async {
    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) => null,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request Permissions for iOS
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

// Request Permissions for Android
  Future<void> requestAndroidPermissions() async {
    // Request the required permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.scheduleExactAlarm,
      // Add other permissions as needed
    ].request();

    // Check if the permissions are granted
    bool isNotificationPermissionGranted =
        statuses[Permission.notification]?.isGranted ?? false;
    bool isScheduleExactAlarmPermissionGranted =
        statuses[Permission.scheduleExactAlarm]?.isGranted ?? false;

    if (isNotificationPermissionGranted &&
        isScheduleExactAlarmPermissionGranted) {
    } else {
      if (await Permission.scheduleExactAlarm.isPermanentlyDenied) {
        openAppSettings();
      } else {
        await [
          Permission.notification,
          Permission.scheduleExactAlarm,
        ].request();
      }
    }
  }

  Future<void> displayNotification(
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: 'icon',
      largeIcon: DrawableResourceAndroidBitmap('icon'),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: "$title | $body |",
    );
  }

  //  Scheduled Notification
  Future<void> scheduledNotification(Note note) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    DateFormat format = DateFormat("dd-MM-yyyy");
    DateTime date = format.parse(note.date!);
    TimeOfDay? endTime =
        note.endTime != null ? _timeOfDayFromString(note.endTime!) : null;

    tz.Location location = tz.getLocation('Asia/Ho_Chi_Minh');

    tz.TZDateTime dueTime = tz.TZDateTime(location, date.year, date.month,
            date.day, endTime!.hour, endTime.minute)
        .subtract(Duration(minutes: 10));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      note.title,
      note.description,
      dueTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: "${note.title}|${note.description}|",
    );
  }

  TimeOfDay _timeOfDayFromString(String timeString) {
    final timeParts = timeString.split(':').map(int.parse).toList();
    return TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
  }
}
