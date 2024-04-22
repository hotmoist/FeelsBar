import 'package:emo_diary_project/screens/profile_setting_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/loading_screen.dart';

void main() {
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

  @override
  void initState() {
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
