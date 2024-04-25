class DiaryContent {
  final String id;
  final String date;
  final String prompt;
  final String content;
  late final int showComment;
  final String comment;
  final int isRetrospected;

  DiaryContent(
      {required this.id,
      required this.date,
      required this.prompt,
      required this.content,
      required this.showComment,
      required this.comment,
      required this.isRetrospected});

  factory DiaryContent.fromMap(Map<String, dynamic> map) {
    return DiaryContent(
        id: map['id'],
        date: map['date'],
        prompt: map['prompt'],
        content: map['content'],
        showComment: map['show_comment'],
        comment: map['comment'],
        isRetrospected: map['is_retrospected']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'prompt': prompt,
      'content': content,
      'show_comment': showComment,
      'comment': comment,
      'is_retrospected': isRetrospected
    };
  }
}
