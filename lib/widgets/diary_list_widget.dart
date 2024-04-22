import 'package:flutter/material.dart';

import '../models/diary_content_model.dart';
import '../sqflite/db_helper.dart';
import 'diary_widget.dart';

class DiaryList extends StatefulWidget {
  final VoidCallback onRefresh;

  const DiaryList({super.key, required this.onRefresh});

  @override
  State<DiaryList> createState() => DiaryListState();
}

class DiaryListState extends State<DiaryList> {
  void refreshItemList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Future<List<DiaryContent>> loadDiarys() async {
      final dbHelper = DBHelper();
      final dataList = await dbHelper.queryAll();
      return dataList.map((e) => DiaryContent.fromMap(e)).toList();
    }

    return Expanded(
      flex: 1,
      child: FutureBuilder(
          future: loadDiarys(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data!.isEmpty) {
                return const Center(child: Text('일기를 작성 해보아요 :)'));
              } else {
                return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, idx) {
                      final int reverseIdx = snapshot.data!.length - 1 - idx;
                      final item = snapshot.data![reverseIdx];
                      return DiaryWidget(
                        diaryContent: item,
                        onRefreshRequested: widget.onRefresh,
                      );
                    });
              }
            } else {
              return const Center(
                child: Text('No data Found'),
              );
            }
          }),
    );
  }
}
