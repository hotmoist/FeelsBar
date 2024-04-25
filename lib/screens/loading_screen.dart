import 'package:emo_diary_project/firebase_options.dart';
import 'package:emo_diary_project/models/gpt_response_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './main_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});
  static const platform = MethodChannel("com.example.emo_diary_project/data");

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late String stepcount;
  late String appUsage;
  late String sleep;
  late Map profileData;
  late String journalingPrompt = "no prompt";

  Future<void> _loadData() async {
    appUsage = await _getAppData();
    stepcount = (await _getStepData());
    sleep = (await _getSleepData());
    profileData = await _getProfileData();
    await _firebaseInit();

    print('---- app 사용 log 기록 ---');
    print(appUsage);
    print("step count: $stepcount");
    print("sleep data: $sleep");
    print("name: ${profileData['name']}");
    print("steps: ${profileData['steps']}");
    print("sleepTime: ${profileData['sleepTime']}");
    print("wakeTime: ${profileData['wakeTime']}");
    print("screenTime: ${profileData['screenTime']}");
    print("---------------------------");

    // journalingPrompt = await GPTResponse()
    //     .fetchGPTPromptResponse(profileData, stepcount, appUsage, sleep);
  }

  Future<void> _firebaseInit() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  Future<String> _getStepData() async {
    try {
      final String result =
          await LoadingScreen.platform.invokeMethod("getStepData");
      return result;
    } on PlatformException catch (e) {
      return "Failed to get step data '${e.message}'";
    }
  }

  Future<String> _getSleepData() async {
    try {
      final String result =
          await LoadingScreen.platform.invokeMethod("getSleepData");
      return result;
    } on PlatformException catch (e) {
      return "Failed to get sleep data '${e.message}";
    }
  }

  Future<String> _getAppData() async {
    try {
      final String result =
          await LoadingScreen.platform.invokeMethod("getUsageData");
      // print(result);
      return result;
    } on PlatformException catch (e) {
      return "Failed to get app data '${e.message}";
    }
  }

  Future<Map> _getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    Map data = {};
    data['name'] = prefs.get('name');
    data['steps'] = prefs.get('steps');
    data['sleepTime'] = prefs.get('sleepTime');
    data['wakeTime'] = prefs.get('wakeTime');
    data['screenTime'] = prefs.get('screenTime');
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MainPage(
              appUsage: appUsage,
              stepCount: stepcount,
              sleep: sleep,
              profileData: profileData,
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("에이전트가 당신을 스스슥슈슉..."))
                ],
              ),
            );
          }
        });
  }
}
