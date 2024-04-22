import 'package:emo_diary_project/models/diary_content_model.dart';
import 'package:emo_diary_project/models/gpt_response_model.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../sqflite/db_helper.dart';

class SurveySectionWidget extends StatefulWidget {
  final String diaryContent;
  final String diaryPrompt;
  final VoidCallback onRefreshRequested;

  const SurveySectionWidget(
      {super.key,
      required this.diaryContent,
      required this.diaryPrompt,
      required this.onRefreshRequested});

  @override
  State<SurveySectionWidget> createState() => _SurveySectionWidgetState();
}

class _SurveySectionWidgetState extends State<SurveySectionWidget> {
  var surveyOneValue = "-1";
  var surveyTwoValue = "-1";
  final dbHelper = DBHelper();
  bool isSending = false;

  Future<void> fetchData() async {
    setState(() {
      isSending = true;
    });

    DateTime date = DateTime.now();
    String diaryId = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    String refDir = 'users/test/$diaryId';
    String comment =
        await GPTResponse().fetchGPTCommentResponse(widget.diaryContent);
    // DB에 저장
    await dbHelper.insert(DiaryContent(
        id: diaryId,
        date: date.toString(),
        prompt: widget.diaryPrompt,
        showComment: 0,
        content: widget.diaryContent,
        comment: comment));

    // print(await GPTResponse()
    //     .fetchGPTCommentResponse(widget.diaryContent));
    widget.onRefreshRequested();

    DatabaseReference ref = FirebaseDatabase.instance.ref(refDir);
    await ref.set({
      'date': diaryId,
      'prompt': widget.diaryPrompt,
      'content': widget.diaryContent,
      'survey1': surveyOneValue,
      'survey2': surveyTwoValue,
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
    return Container(
      child: Center(
        child: CircularProgressIndicator(),
      ),
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
                      // 설문 1번: 오늘의 감정이 긍정적이었나요
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
                              child: Text("오늘의 감정은 긍정적인가요?"),
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
                                  groupValue: surveyOneValue,
                                  direction: Axis.horizontal,
                                  onChanged: (value) => setState(() {
                                        surveyOneValue = value.toString();
                                      }),
                                  items: const ['1', '2', '3', '4', '5'],
                                  itemBuilder: (item) => RadioButtonBuilder(
                                        item,
                                      )))
                        ],
                      ),
                    ),
                    Container(
                      // 설문 2번: 오늘의 질문이 사용자를 잘 이해...
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
                                  groupValue: surveyTwoValue,
                                  direction: Axis.horizontal,
                                  onChanged: (value) => setState(() {
                                        surveyTwoValue = value.toString();
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
                            onPressed: () async {
                              fetchData();
                              // Navigator.pop(context);
                            },
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
