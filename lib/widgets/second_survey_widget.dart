import 'package:emo_diary_project/models/diary_content_model.dart';
import 'package:emo_diary_project/models/gpt_response_model.dart';
import 'package:emo_diary_project/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sqflite/db_helper.dart';

class SecondSurveySectionWidget extends StatefulWidget {
  final String diaryContent;
  final String diaryPrompt;
  final String surveyOne;
  final VoidCallback onRefreshRequested;

  const SecondSurveySectionWidget(
      {super.key,
      required this.diaryContent,
      required this.diaryPrompt,
      required this.onRefreshRequested,
      required this.surveyOne});

  @override
  State<SecondSurveySectionWidget> createState() =>
      _SecondSurveySectionWidgetState();
}

class _SecondSurveySectionWidgetState extends State<SecondSurveySectionWidget> {
  var surveyTwoValue = "-1";
  var surveyThreeValue = "-1";
  var surveyFourValue = "-1";
  final dbHelper = DBHelper();
  bool isSending = false;
  bool _isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = (surveyTwoValue != "-1") &&
          (surveyThreeValue != "-1") &&
          (surveyFourValue != '-1');
    });
  }

  int _countWords(String content) {
    List<String> list = content.split(" ");
    return list.length;
  }

  Future<void> fetchData() async {
    setState(() {
      isSending = true;
    });

    DateTime date = DateTime.now();
    String? userName =
        (await SharedPreferences.getInstance()).getString('name') ?? "tester";
    String diaryId = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String refDir = 'pilot_test/$userName/$diaryId';
    final prefs = await SharedPreferences.getInstance();
    String comment =
        await GPTResponse().fetchGPTCommentResponse(widget.diaryContent);
    String? userPrompt = prefs.getString("userPrompt");
    String? systemPrompt = prefs.getString("systemPrompt");
    // DB에 저장
    await dbHelper.insert(DiaryContent(
        id: diaryId,
        date: date.toString(),
        prompt: widget.diaryPrompt,
        showComment: 0,
        showSurvey: 0,
        content: widget.diaryContent,
        comment: comment,
        isRetrospected: 0));

    // print(await GPTResponse()
    //     .fetchGPTCommentResponse(widget.diaryContent));
    widget.onRefreshRequested();

    if (isRetroMode) {
      await dbHelper.updateRetrospectById(target.id, 1);
      setState(() {
        isRetroMode = false;
      });
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref(refDir);
    await ref.set({
      'date': diaryId,
      'system_prompt': systemPrompt,
      'user_prompt': userPrompt,
      'diary_prompt': widget.diaryPrompt,
      'content': _countWords(widget.diaryContent),
      'survey_1': widget.surveyOne,
      'survey_2': surveyTwoValue,
      'survey_3': surveyThreeValue,
      'survey_4': surveyFourValue,
      'survey_5': "-1",
      'isCommented': false,
      'status': 'onView',
      'comment': comment,
    });

    setState(() {
      isSending = false;
    });

    Navigator.pop(context);
  }

  Widget _sendingScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
              color: Color(0xFFFEF7FF),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24))),
          child: isSending
              ? _sendingScreen()
              : Column(
                  children: [
                    Row(
                      // bottom sheet의 상단
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                              DateFormat('yyyy/MM/dd').format(DateTime.now())),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.all(4),
                          child: IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    ),
                    Container(
                      // 설문 2: 일기 작성 후 감정 평가
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEF7FF), border: Border.all()),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                              child: Text("현재 ('일기 작성 후') 감정이 쓸쓸한가요?"),
                            ),
                          ),
                          const Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
                              child: Text('(1: 전혀 아니다, 5: 매우 그렇다)'),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 4, 0, 4),
                              child: RadioGroup<String>.builder(
                                  groupValue: surveyTwoValue,
                                  direction: Axis.horizontal,
                                  onChanged: (value) => setState(() {
                                        surveyTwoValue = value.toString();
                                        _updateButtonState();
                                      }),
                                  items: const ['1', '2', '3', '4', '5'],
                                  itemBuilder: (item) => RadioButtonBuilder(
                                        item,
                                      )))
                        ],
                      ),
                    ),
                    Container(
                      // 설문 3: AI의 사용자 이해도 평가 (일기 prompt 기반)
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEF7FF), border: Border.all()),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                              child: Text("오늘의 질문이 사용자를 잘 이해했다고 생각하시나요?"),
                            ),
                          ),
                          const Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
                              child: Text('(1: 전혀 아니다, 5: 매우 그렇다)'),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 4, 0, 4),
                              child: RadioGroup<String>.builder(
                                  groupValue: surveyThreeValue,
                                  direction: Axis.horizontal,
                                  onChanged: (value) => setState(() {
                                        surveyThreeValue = value.toString();
                                        _updateButtonState();
                                      }),
                                  items: const ['1', '2', '3', '4', '5'],
                                  itemBuilder: (item) => RadioButtonBuilder(
                                        item,
                                      )))
                        ],
                      ),
                    ),
                    Container(
                      // 설문 4: 사용자의 일기 작성 시 self-disclosure 평가
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEF7FF), border: Border.all()),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                              child:
                                  Text("오늘 작성한 일기에서 개인적인 문제나 고민을 자세히 서술하셨나요?"),
                            ),
                          ),
                          const Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
                              child: Text('(1: 전혀 아니다, 5: 매우 그렇다)'),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 4, 0, 4),
                              child: RadioGroup<String>.builder(
                                  groupValue: surveyFourValue,
                                  direction: Axis.horizontal,
                                  onChanged: (value) => setState(() {
                                        surveyFourValue = value.toString();
                                        _updateButtonState();
                                      }),
                                  items: const ['1', '2', '3', '4', '5'],
                                  itemBuilder: (item) => RadioButtonBuilder(
                                        item,
                                      )))
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            // child: isSending ? _sendingScreen() : SizedBox.shrink()
                            )),
                    Align(
                      alignment: const AlignmentDirectional(-1, 0),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(12, 12, 0, 18),
                        child: ElevatedButton(
                            // 작성 완료시 작동하는 버튼
                            onPressed: _isButtonEnabled
                                ? () async {
                                    fetchData();
                                    // Navigator.pop(context);
                                  }
                                : null,
                            child: const Text("작성 완료")),
                      ),
                    )
                  ],
                ),
        ),
      ],
    );
  }
}
