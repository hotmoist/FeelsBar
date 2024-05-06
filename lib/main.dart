import 'package:emo_diary_project/screens/profile_setting_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/loading_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHanlder(RemoteMessage message) async {
  print("Background message handling...${message.notification!.body}");
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

// Future<void> _initNotification() async {
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHanlder);

//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true, badge: true, sound: true);
// }

Future<void> _initFirebaseMessaging() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: '', appId: '', messagingSenderId: '', projectId: ''));

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHanlder); // allow message when on background
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // allow message when on foreground
    print('Got message whilst in the foreground');
  });

  channel = const AndroidNotificationChannel(
      'diary_channel', 'Test Notification',
      description: 'test', importance: Importance.max);

  var initSettingsAndorid =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  var initSettings = InitializationSettings(android: initSettingsAndorid);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  print(await FirebaseMessaging.instance.getToken());
}

void main() async {
  _initFirebaseMessaging();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static const platform = MethodChannel("com.example.emo_diary_project/data");

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDataSaved = false;

  Future<void> _checkPermission() async {
    try {
      await MyApp.platform.invokeMethod("checkPermission");
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void initFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      var androidNotiDetails = AndroidNotificationDetails(
          channel.id, channel.name,
          channelDescription: channel.description);
      var details = NotificationDetails(android: androidNotiDetails);

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(notification.hashCode,
            notification.title, notification.body, details);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print(event);
    });
  }

  @override
  void initState() {
    initFCM();
    super.initState();

    _checkPermission();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isDataSaved') ?? false) {
      setState(() {
        isDataSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text("Diary")),
            backgroundColor: const Color(0xFFFEF7FF),
          ),
          body: isDataSaved
              ? const LoadingScreen()
              : const ProfileSettingScreen()),
    );
  }
}
