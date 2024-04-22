import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

///  일기 작성을 위한 위젯
/// 생성된 GPT의 context-aware question을 반영한다
class DiaryPromptWidget extends StatefulWidget {
  final String journalingPrompt;
  // final VoidCallback onRefreshRequested;

  const DiaryPromptWidget({
    super.key,
    required this.journalingPrompt,
    // required this.onRefreshRequested
  });

  @override
  State<StatefulWidget> createState() => _DiaryPromptWidget();
}

class _DiaryPromptWidget extends State<DiaryPromptWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 20, 14, 6),
      child: Card(
        // 일기 작성 card: question + 작성하기 버튼
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: const Color(0xFFFEF7FF),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.all(4),
                child: Text(DateFormat('yyyy년 MM월 dd일').format(DateTime.now())),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.all(8),
                child: Text(widget.journalingPrompt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
