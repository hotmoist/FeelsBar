import 'package:emo_diary_project/widgets/survey_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WritingSectionWidget extends StatefulWidget {
  final VoidCallback onRefreshRequested;
  final String question;

  const WritingSectionWidget(
      {super.key, required this.question, required this.onRefreshRequested});

  @override
  State<WritingSectionWidget> createState() => _WritingSectionWidgetState();
}

class _WritingSectionWidgetState extends State<WritingSectionWidget> {
  final contentEditController = TextEditingController();
  bool _isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = contentEditController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          // mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(DateFormat('yyyy/MM/dd').format(DateTime.now())),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                  child: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            ),
            Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(6, 4, 6, 4),
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  color: const Color(0xFFCAC4D0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: Align(
                    alignment: const AlignmentDirectional(-1, 0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(6),
                      child: Text(
                        widget.question,
                      ),
                    ),
                  ),
                )),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 4),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: contentEditController,
                    onChanged: (value) => _updateButtonState(),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: '당신이 겪은 일 또는 왜 그랬는지 작성 해 보세요',
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(-1, 0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 0, 18),
                child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return FractionallySizedBox(
                                      heightFactor: 0.95,
                                      child: SurveySectionWidget(
                                        diaryContent:
                                            contentEditController.text,
                                        diaryPrompt: widget.question,
                                        onRefreshRequested:
                                            widget.onRefreshRequested,
                                      ));
                                });
                          }
                        : null,
                    child: const Text("다음")),
              ),
            )
          ],
        ));
  }
}
