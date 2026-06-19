
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@lazySingleton
class AiTutorService {
  final String _geminiApiKey = 'YOUR_GEMINI_API_KEY';
  final String _geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  // Generate explanation for grammar question
  Future<String> explainGrammarQuestion({
    required String question,
    required String correctAnswer,
    required String userAnswer,
    required String category,
  }) async {
    final prompt = '''
    أنت مدرس نحو عربي متخصص. سؤال الطالب:
    "$question"

    الإجابة الصحيحة: $correctAnswer
    إجابة الطالب: $userAnswer

    اشرح بالعربية بشكل مبسط:
    1. لماذا الإجابة الصحيحة صحيحة
    2. الخطأ في إجابة الطالب (إذا كانت خاطئة)
    3. القاعدة النحوية المستخدمة
    4. مثال إضافي

    اجعل الشرح بسيطاً ومفهوماً للمبتدئين.
    ''';

    return await _generateContent(prompt);
  }

  // Generate new question based on topic
  Future<Map<String, dynamic>> generateQuestion(String topic, String difficulty) async {
    final prompt = '''
    أنشئ سؤال نحو عربي في موضوع: $topic
    المستوى: $difficulty

    اجعل السؤال في هذا التنسيق JSON:
    {
      "question": "نص السؤال",
      "options": ["خيار1", "خيار2", "خيار3", "خيار4"],
      "correctAnswer": 0,
      "explanation": "الشرح التفصيلي",
      "rule": "القاعدة النحوية"
    }
    ''';

    final response = await _generateContent(prompt);
    try {
      return jsonDecode(response);
    } catch (e) {
      return {
        'question': 'Failed to generate question',
        'options': ['A', 'B', 'C', 'D'],
        'correctAnswer': 0,
        'explanation': 'Error: $e',
        'rule': '',
      };
    }
  }

  // Answer student question
  Future<String> answerStudentQuestion(String question) async {
    final prompt = '''
    أنت مدرس نحو عربي متخصج. الطالب يسأل:
    "$question"

    اجب بشكل:
    1. مبسط ومفهوم
    2. مع أمثلة توضيحية
    3. مع ذكر القاعدة النحوية
    4. تشجيعي ومحفز
    ''';

    return await _generateContent(prompt);
  }

  // Generate study tips
  Future<String> generateStudyTips(String weakArea) async {
    final prompt = '''
    الطالب يواجه صعوبة في: $weakArea
    قدم 5 نصائح عملية للتحسن في هذا المجال.
    اجعل النصائح محددة وقابلة للتطبيق.
    ''';

    return await _generateContent(prompt);
  }

  // Generate daily challenge
  Future<Map<String, dynamic>> generateDailyChallenge() async {
    final prompt = '''
    أنشئ تحدي يومي في النحو العربي.
    التحدي يجب أن يكون:
    1. ممتع ومشوق
    2. قصير (5-10 دقائق)
    3. تدريجي الصعوبة
    4. مع مكافأة عند الإنجاز

    اجعل الرد في تنسيق JSON:
    {
      "title": "عنوان التحدي",
      "description": "وصف التحدي",
      "questions": [
        {
          "question": "السؤال",
          "options": ["أ", "ب", "ج", "د"],
          "correct": 0
        }
      ],
      "reward": "المكافأة",
      "timeLimit": 10
    }
    ''';

    final response = await _generateContent(prompt);
    try {
      return jsonDecode(response);
    } catch (e) {
      return {
        'title': 'Daily Challenge',
        'description': 'Practice Arabic Grammar',
        'questions': [],
        'reward': '50 Points',
        'timeLimit': 10,
      };
    }
  }

  // Core API call
  Future<String> _generateContent(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_geminiBaseUrl/models/gemini-pro:generateContent?key=$_geminiApiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      return 'عذراً، حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.';
    }
  }
}
