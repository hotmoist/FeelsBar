import 'package:emo_diary_project/sqflite/db_helper.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../models/diary_content_model.dart';

class DiaryWidget extends StatefulWidget {
  final DiaryContent diaryContent;
  final VoidCallback onRefreshRequested;
  const DiaryWidget(
      {super.key,
      required this.diaryContent,
      required this.onRefreshRequested});

  @override
  State<DiaryWidget> createState() => _DiaryWidgetState();
}

class _DiaryWidgetState extends State<DiaryWidget> {
  // "Written diary:${widget.diaryContent.content}}\nmax 4 lines\nif over 4 lines\nthan use \'...\' instead\nyeah";
  final dbHelper = DBHelper();
  String surveyFiveVal = "-1";
  String afterPHQ_1 = "-1";
  String afterPHQ_2 = "-1";
  bool isCommented = false;
  bool isSurveyed = false;
  bool isButtenEnabled = false;

  @override
  void initState() {
    super.initState();
    isCommented = widget.diaryContent.showComment == 1 ? true : false;
    isSurveyed = widget.diaryContent.showSurvey == 1 ? true : false;

    if (!isCommented) {
      // 코멘트가 표시되지 않은 경우
      DateTime wroteTime = DateTime.parse(
          widget.diaryContent.id.replaceAll(" ", "T")); // 일기 작성 시간
      DateTime commentShowTime = wroteTime.add(Duration(seconds: 0)); // test!!!
      // DateTime commentShowTime = wroteTime.add(const Duration(minutes: 30));
      final now = DateTime.now();

      if (!isCommented) {
        Timer(const Duration(seconds: 0), () async {
          if (now.isAfter(commentShowTime)) {
            setState(() {
              isCommented = true;
            });

            String userName =
                (await SharedPreferences.getInstance()).getString('name') ??
                    "tester";
            await dbHelper.updateShowCommentById(widget.diaryContent.id, 1);
            DatabaseReference ref = FirebaseDatabase.instance
                .ref('pilot_test/$userName/${widget.diaryContent.id}');
            await ref.update({
              'isCommented': true,
            });
          }
        });
      }
    }
  }

  void _updateButtonState() {
    setState(() {
      isButtenEnabled = (surveyFiveVal != "-1") &&
          (afterPHQ_1 != "-1") &&
          (afterPHQ_2 != "-1");
    });
  }

  void refreshWidget() {
    setState(() {});
  }

  Future<void> sendSurveyData() async {
    isSurveyed = true;
    String? userName =
        (await SharedPreferences.getInstance()).getString('name') ?? "tester";
    String refDir = 'pilot_test/$userName/${widget.diaryContent.id}';
    DatabaseReference ref = FirebaseDatabase.instance.ref(refDir);
    await dbHelper.updateShowSurveyById(widget.diaryContent.id, 1);
    await ref.update({
      'survey_5': surveyFiveVal,
      'afterPHQ_1': afterPHQ_1,
      'afterPHQ_2': afterPHQ_2
    });
  }

  Widget surveyCard() {
    return Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Color(0xFFFEF7FF),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                children: [
                  const Align(
                    alignment: AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                      child: Text('나는 현재(답글을 읽은 후) 감정은'),
                    ),
                  ),
                  const Align(
                    alignment: AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
                      child: Text('(1: 전혀 외롭지 않다, 4: 매우 외롭다)'),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
                      child: RadioGroup<String>.builder(
                          groupValue: surveyFiveVal,
                          direction: Axis.horizontal,
                          onChanged: (value) => setState(() {
                                surveyFiveVal = value.toString();
                                _updateButtonState();
                              }),
                          items: const ['1', '2', '3', '4'],
                          itemBuilder: (item) => RadioButtonBuilder(item))),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                children: [
                  const Align(
                    alignment: AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                      child:
                          Text('나는 현재(답글을 읽은 후) 일을 함에 있어 거의 흥미가 없거나 즐거움이 없다'),
                    ),
                  ),
                  const Align(
                    alignment: AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
                      child: Text('(1: 전혀 아니다, 4: 매우 그렇다)'),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
                      child: RadioGroup<String>.builder(
                          groupValue: afterPHQ_1,
                          direction: Axis.horizontal,
                          onChanged: (value) => setState(() {
                                afterPHQ_1 = value.toString();
                                _updateButtonState();
                              }),
                          items: const ['1', '2', '3', '4'],
                          itemBuilder: (item) => RadioButtonBuilder(item))),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(border: Border.all()),
              child: Column(
                children: [
                  const Align(
                    alignment: AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                      child: Text('나는 현재(답글을 읽은 후) 기분이 가라앉거나 우울하거나 희망이 없다'),
                    ),
                  ),
                  const Align(
                    alignment: AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
                      child: Text('(1: 전혀 아니다, 4: 매우 그렇다)'),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 2, 0, 2),
                      child: RadioGroup<String>.builder(
                          groupValue: afterPHQ_2,
                          direction: Axis.horizontal,
                          onChanged: (value) => setState(() {
                                afterPHQ_2 = value.toString();
                                _updateButtonState();
                              }),
                          items: const ['1', '2', '3', '4'],
                          itemBuilder: (item) => RadioButtonBuilder(item))),
                ],
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: isButtenEnabled
                    ? () async {
                        sendSurveyData();
                        refreshWidget();
                      }
                    : null,
                child: const Text('제출'),
              ),
            )
          ],
        ));
  }

  void _deleteDiary(DiaryContent diaryContent) async {
    String userName =
        (await SharedPreferences.getInstance()).getString('name') ?? "tester";
    String refDir = 'pilot_test/$userName/${widget.diaryContent.id}';
    DatabaseReference ref = FirebaseDatabase.instance.ref(refDir);
    await dbHelper.delete(diaryContent.id);
    await ref.update({'status': 'deleted'});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('일기가 삭제되었습니다'),
      duration: Duration(seconds: 2),
    ));

    dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 14, 6),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFFFEF7FF),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 0, 6),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(6),
                          child: Text(widget.diaryContent.prompt),
                        ),
                      ),
                    ),
                    if (!isCommented)
                      const Align(
                        alignment: AlignmentDirectional(0, -1),
                        child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(6, 0, 6, 0),
                            child: Icon(Icons.access_time)),
                      )
                    else
                      (const Align(
                        alignment: AlignmentDirectional(0, -1),
                        child: Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(6, 0, 6, 0),
                            child: Icon(Icons.mark_chat_read_outlined)),
                      ))
                  ],
                ),
              ),
              Padding(
                // 사용자가 작성한 부분
                padding: const EdgeInsetsDirectional.fromSTEB(6, 4, 6, 4),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Color(0xFFFEF7FF), shape: BoxShape.rectangle),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Flexible(
                        child: Align(
                          alignment: const AlignmentDirectional(-1, 0),
                          child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  12, 4, 0, 4),
                              child: ExpandableText(
                                widget.diaryContent.content,
                                expandText: "",
                                collapseOnTextTap: true,
                                expandOnTextTap: true,
                                maxLines: 4,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isCommented)
                // LLM의 답글 부분
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(6, 4, 6, 4),
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: const Color(0xFFCAC4D0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                            child: Align(
                          alignment: AlignmentDirectional(-1, 0),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(12, 4, 0, 4),
                            child: ExpandableText(
                              widget.diaryContent.comment,
                              expandText: "",
                              collapseOnTextTap: true,
                              expandOnTextTap: true,
                              maxLines: 2,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              Container(
                child: isSurveyed ? null : surveyCard(),
              ),
              Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(6, 0, 6, 0),
                        child: Text(DateFormat('yyyy년 MM월 dd일')
                            .format(DateTime.parse(widget.diaryContent.date))),
                      ),
                      PopupMenuButton(
                        onSelected: (String result) {
                          if (result == 'delete') {
                            _deleteDiary(widget.diaryContent);
                            widget.onRefreshRequested();
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                              value: 'delete', child: Text("삭제"))
                        ],
                        icon: const Icon(Icons.more_horiz),
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
