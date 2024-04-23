import 'dart:convert';

import 'package:http/http.dart' as http;

class GPTResponse {
  final apiKey = 'API_Key_HERE';
  final url = Uri.parse("https://api.openai.com/v1/chat/completions");

  Future<String> fetchGPTPromptResponse(
      Map profileData, String stepCount, String appUsage, String sleep) async {
    String loggedSleepTime =
        sleep.substring(sleep.indexOf('T') + 1, sleep.indexOf(' to'));
    String loggedWakeTime = sleep.substring(sleep.lastIndexOf('T') + 1);
    String prompt =
        "[데이터]\n데이터 1 : 평균 걸음 수 = ${profileData['steps']} | 오늘 걸음 수 = $stepCount\n데이터 2 : 평소 취침 시각 = ${profileData['sleepTime']} | 기록된 취침 시간: $loggedSleepTime\n데이터 3 : 평소 기상 시각 = ${profileData['wakeTime']} | 기록된 기상 시각: $loggedWakeTime\n데이터 4 : 금일 가장 많이 사용한 어플: \"Youtube\"(카테고리: \"VIDEO_PLAYER\", 사용시간: 3652초)"; // test
    // test
    String systemRole =
        "[역할]\n당신은 제공된 데이터 1, 데이터 2, 데이터 3, 데이터 4 중 하나를 선택해서 사용자의 심리 상태를 유추한다. 유추 후, 일기 작성을 위한 작성 유도 문구를 제작하는 역할을 한다.\n\n[출력 조건]\n유도 문구만 출력한다.\n이때 문장은 3문장을 초과하지 않는다\n\n[출력 예시]\n\"오늘은 평소보다 많이 잤네요. 개운한 하루를 보내었나요? 당신의 이야기를 들려주세요.\"";

    print(prompt);
    print(systemRole);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': systemRole,
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 1
        }),
      );
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        // var text = data['choices'][0]['message']['content'].trim();
        // print(text);
        return data['choices'][0]['message']['content']
            .trim()
            .replaceAll(RegExp(r'^"|"$'), '');
      } else {
        // print('Error: ${response.statusCode} ${response.body}');
        return "Failed to load data from OpenAI";
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }

  Future<String> fetchGPTCommentResponse(String content) async {
    String systemRole =
        "당신은 사용자가 제공한 일기 내용을 토대로 감정적 지지(emotional support)하는 댓글을 다는 역할이다. 이때 댓글 다는 입장은 자신의 경험을 짧게 이야기 한 후, 감정적 지지하는 말 한마디를 한다. 문장은 2문장을 초과하지 않는다.";
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey'
          },
          body: jsonEncode({
            'model': 'gpt-4',
            'messages': [
              {
                'role': 'system',
                'content': systemRole,
              },
              {
                'role': 'user',
                'content': content,
              },
            ],
            'temperature': 1
          }));
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        var text = data['choices'][0]['message']['content'].trim();
        print(text);
        return data['choices'][0]['message']['content']
            .trim()
            .replaceAll(RegExp(r'^"|"$'), '');
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        return "Failed to load data from OpenAI";
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}
