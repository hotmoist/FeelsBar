import 'package:flutter/material.dart';

import '../widgets/diary_list_widget.dart';
import '../widgets/writing_widget.dart';

class MainPage extends StatefulWidget {
  final String journalingPrompt;
  const MainPage({super.key, required this.journalingPrompt});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<DiaryListState> _listKey = GlobalKey();

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        // bottom sheet ����
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return FractionallySizedBox(
              heightFactor: 0.95,
              child: WritingSectionWidget(
                question: widget.journalingPrompt,
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
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.edit),
          onPressed: () {
            _showBottomSheet(context);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
