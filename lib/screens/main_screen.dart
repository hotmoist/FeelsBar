import 'dart:math';

import 'package:emo_diary_project/models/diary_content_model.dart';
import 'package:emo_diary_project/models/gpt_response_model.dart';
import 'package:emo_diary_project/sqflite/db_helper.dart';
import 'package:emo_diary_project/widgets/first_survey_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/diary_list_widget.dart';
import '../widgets/writing_widget.dart';

bool isRetroMode = false;
late DiaryContent target;

class MainPage extends StatefulWidget {
  final String appUsage;
  final String stepCount;
  final String sleep;
  final Map profileData;

  const MainPage(
      {super.key,
      required this.appUsage,
      required this.stepCount,
      required this.sleep,
      required this.profileData});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<DiaryListState> _listKey = GlobalKey();
  late String journalingPrompt = "Prompt unimplemented";
  bool isLoaded = false;

  DiaryContent getRandomDiary(List<DiaryContent> list) {
    final random = Random();
    int index = random.nextInt(list.length);
    return list[index];
  }

  Future<DiaryContent> _loadRetrospectDiary(
      List<Map<String, dynamic>> dataList) async {
    // final dbHelper = DBHelper();
    // final dataList = await dbHelper.queryRetrospect();
    final retroDiaryList =
        dataList.map((e) => DiaryContent.fromMap(e)).toList();

    return getRandomDiary(retroDiaryList);
  }

  Future<void> _getJournalingPrompt() async {
    final dbHelper = DBHelper();
    final dataList = await dbHelper.queryRetrospect();
    print("retro target diary list: $dataList");

    if (dataList.isNotEmpty) {
      if (Random().nextInt(5) == 4) {
        // setState(() async {
        isRetroMode = true;
        target = await _loadRetrospectDiary(dataList);
        // });

        journalingPrompt = await GPTResponse()
            .fetchRetrospectPromptResponse(target.date, target.content);

        return;
      }
      // }
    }

    journalingPrompt = await GPTResponse().fetchSensorPromptResponse(
        widget.profileData, widget.stepCount, widget.appUsage, widget.sleep);
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        // bottom sheet
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return FractionallySizedBox(
              heightFactor: 0.95,
              child: FirstSurveySectionWidget(
                question: journalingPrompt,
                onRefreshRequested: () =>
                    _listKey.currentState?.refreshItemList(),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // DiaryPromptWidget(
                //   journalingPrompt: widget.journalingPrompt,
                // ),
                DiaryList(
                  key: _listKey,
                  onRefresh: () => _listKey.currentState?.refreshItemList(),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FutureBuilder(
          future: _getJournalingPrompt(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return FloatingActionButton(
                onPressed: null,
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              print(snapshot.error.toString());
              return FloatingActionButton(
                onPressed: () {
                  setState(() {});
                },
                child: Icon(Icons.refresh),
              );
            } else {
              return FloatingActionButton(
                onPressed: () {
                  _showBottomSheet(context);
                },
                child: Icon(Icons.edit),
              );
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
