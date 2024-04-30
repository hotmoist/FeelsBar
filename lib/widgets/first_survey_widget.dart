import 'package:emo_diary_project/widgets/writing_widget.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';

class FirstSurveySectionWidget extends StatefulWidget {
  final VoidCallback onRefreshRequested;
  final String question;
  const FirstSurveySectionWidget(
      {super.key, required this.onRefreshRequested, required this.question});

  @override
  State<FirstSurveySectionWidget> createState() =>
      _FirstSurveySectionWidgetState();
}

class _FirstSurveySectionWidgetState extends State<FirstSurveySectionWidget> {
  var surveyOneValue = "-1";
  bool _isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = surveyOneValue != "-1";
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return FractionallySizedBox(
              heightFactor: 0.95,
              child: WritingSectionWidget(
                question: widget.question,
                onRefreshRequested: widget.onRefreshRequested,
                surveyOne: surveyOneValue,
              ));
        });
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
          child: Column(
            children: [
              Row(
                // bottom sheet의 상단
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child:
                        Text(DateFormat('yyyy/MM/dd').format(DateTime.now())),
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
                // 설문 1번: 감정 평가
                width: double.infinity,
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF7FF), border: Border.all()),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Align(
                      alignment: AlignmentDirectional(-1, 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                        child: Text("현재(\'일기 작성 전\') 감정이 쓸쓸한가요?"),
                      ),
                    ),
                    const Align(
                      alignment: AlignmentDirectional(-1, 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 4),
                        child: Text('(1: 전혀 아니다, 5: 매우 그렇다)'),
                      ),
                    ),
                    Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 4),
                        child: RadioGroup<String>.builder(
                            groupValue: surveyOneValue,
                            direction: Axis.horizontal,
                            onChanged: (value) => setState(() {
                                  surveyOneValue = value.toString();
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
                child: Container(),
              ),
              Align(
                alignment: const AlignmentDirectional(-1, 0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 0, 18),
                  child: ElevatedButton(
                      // 작성 완료시 작동하는 버튼
                      onPressed: _isButtonEnabled
                          ? () async {
                              Navigator.pop(context);
                              _showBottomSheet(context);
                            }
                          : null,
                      child: const Text("다음")),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
