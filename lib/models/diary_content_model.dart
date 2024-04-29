class DiaryContent {
  final String id;
  final String date;
  final String prompt;
  final String content;
  late final int showComment;
  late final int showSurvey;
  final String comment;
  final int isRetrospected;

  DiaryContent(
      {required this.id,
      required this.date,
      required this.prompt,
      required this.content,
      required this.showComment,
      required this.showSurvey,
      required this.comment,
      required this.isRetrospected});

  factory DiaryContent.fromMap(Map<String, dynamic> map) {
    return DiaryContent(
        id: map['id'],
        date: map['date'],
        prompt: map['prompt'],
        content: map['content'],
        showComment: map['show_comment'],
        showSurvey: map['show_survey'],
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
      'show_survey': showSurvey,
      'comment': comment,
      'is_retrospected': isRetrospected
    };
  }
}
