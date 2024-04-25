import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GPTResponse {
  final apiKey = 'API key HERE';
  final url = Uri.parse("https://api.openai.com/v1/chat/completions");

  Future<String> fetchRetrospectPromptResponse(
      String date, String content) async {
    String systemRole =
        "[역할]\n너는 사용자의 [데이터] 기반으로 일기를 작성 할 수 있도록 일기 작성 유도 문구를 제작하는 역할이다.\n일기 작성 유도 문구는 3문장을 초과하지 않는다.\n[할 일]$date에 작성되었던 일기를 사용자에게 상기 시켜 이때의 일에 대해서 회고하도록 한다.\n$date 일기에 대해 언급하며, 심리학에서의 '재구성 기법'을 통해 사용자가 회고할 수 있도록 일기 작성 유도 문구를 생성한다.\n일기 언급 시, 일기의 모든 내용을 언급하지 않고 날짜와 일기 내용을 요약하여 언급한다.\n'재구성 기법'이라는 단어를 사용하지 않는다.\n사용자를 지칭할 때, '여러분'과 같은 복수가 아닌 단수로 언급한다.";
    String prompt = "[데이터]\n<작성된 일기 일자>\n$date\n<작성된 일기 내용>\n$content";

    print(prompt);
    print(systemRole);
    return await fetchPromptResponse(systemRole, prompt);
  }

  Future<String> fetchSensorPromptResponse(
      Map profileData, String stepCount, String appUsage, String sleep) async {
    // String loggedSleepTime = "no record";
    // String loggedWakeTime = "no record";
    String loggedSleep = "no record";
    String loggedStepCount = "no record";
    if (sleep != "none") {
      loggedSleep = sleep;
    }
    //   loggedSleepTime =
    //       sleep.substring(sleep.indexOf('T') + 1, sleep.indexOf(' to'));
    //   loggedWakeTime = sleep.substring(sleep.lastIndexOf('T') + 1);
    // }

    if (stepCount != "none") {
      loggedStepCount = stepCount;
    }

    List<String> lines = appUsage.trim().split('\n');
    String screenTime = lines.removeLast();
    String appUseTime = lines.join('\n');

    int randomNumber = Random().nextInt(4) + 1;
    // test
    String systemRole =
        "[역할]\n당신은 제공된 '데이터 1', '데이터 2', '데이터 3', '데이터 4' 중 오직 '데이터 $randomNumber'에 대해서만 분석한 후, 사용자의 심리 상태를 유추한다.\n심리 상태 유추 후, 일기 작성을 위한 작성 유도 문구를 제작하는 역할을 한다.\n\n[출력 조건]\n유도 문구만 출력하며, 이외의 것은 출력하지 않는다.\유도 문구 문장은 3문장을 초과하지 않는다.\n선택한 데이터 중 \'no record\'가 있는 경우, 해당 데이터를 제외하고 다른 데이터 중 하나를 선택하여 유도 문구를 다시 작성한다.\n\n[출력 예시]\n\"오늘은 평소보다 많이 잤네요. 개운한 하루를 보내었나요? 당신의 이야기를 들려주세요.\"";
    // String prompt =
    //     "[데이터]\n데이터 1 : {평균 걸음 수 = ${profileData['steps']} | 오늘 걸음 수 = $loggedStepCount}\n데이터 2 : {평소 취침 시각 = ${profileData['sleepTime']} | 기록된 취침 시간 = $loggedSleepTime}\n데이터 3 : {평소 기상 시각 = ${profileData['wakeTime']} | 기록된 기상 시각 = $loggedWakeTime}\n데이터 4 : {금일 가장 많이 사용한 어플 Top 3=\n$appUseTime}\n데이터 5 : {평소 스마트폰 사용 시간 = ${profileData['screenTime']} | 기록된 사용 시간 = $screenTime}"; // test
    String prompt =
        "[데이터]\n'데이터 1' : {평균 걸음 수 = {${profileData['steps']}} | 오늘 걸음 수 = {$loggedStepCount}}\n'데이터 2' : {평소 취침 시각 = {${profileData['sleepTime']}} | 평소 기상 시각 = {${profileData['wakeTime']}} | 오늘 수면 기록 = {\n$loggedSleep\n}\n}\n'데이터 3' : {금일 가장 많이 사용한 어플 Top 3=\n$appUseTime}\n'데이터 4' : {평소 스마트폰 사용 시간 = {${profileData['screenTime']}} | 기록된 사용 시간 = {$screenTime}}"; // test

    print(prompt);
    print(systemRole);

    return await fetchPromptResponse(systemRole, prompt);
  }

  Future<String> fetchPromptResponse(String systemRole, String prompt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPrompt', prompt);
    await prefs.setString('systemPrompt', systemRole);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo',
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
