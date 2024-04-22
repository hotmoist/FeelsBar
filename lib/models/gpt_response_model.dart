import 'dart:convert';

import 'package:http/http.dart' as http;

class GPTResponse {
  final apiKey = 'API KEY here';
  final url = Uri.parse("https://api.openai.com/v1/chat/completions");

  Future<String> fetchGPTPromptResponse(String sensorValue) async {
    String prompt = "사용자의 하루 평균 걸음 수: 1000보 / 사용자의 오늘 걸음 수: 340보"; // test
    // test
    String systemRole =
        "당신은 제공된 정보를 통해 사용자의 상태를 유추하고 일기 작성을 위한 작성 유도 문구를 제작하는 역할을 한다. 이때 문장은 2문장을 초과하지 않는다";
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
}
