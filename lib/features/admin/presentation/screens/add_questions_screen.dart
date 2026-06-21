import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionsScreen extends StatelessWidget {
  const AddQuestionsScreen({super.key});

  Future<void> _addSampleQuestions() async {
    final firestore = FirebaseFirestore.instance;
    
    final questions = [
      {
        'question': 'ما هو الاسم في الجملة: "جاء محمد إلى المدرسة"؟',
        'options': ['جاء', 'محمد', 'إلى', 'المدرسة'],
        'correctAnswer': 1,
        'category': 'النحو',
        'difficulty': 'easy',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'question': 'ما هو الفعل في الجملة: "كتب الطالب الدرس"؟',
        'options': ['كتب', 'الطالب', 'الدرس', 'في'],
        'correctAnswer': 0,
        'category': 'النحو',
        'difficulty': 'easy',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'question': 'ما هو الحرف في الجملة: "ذهب الولد إلى السوق"؟',
        'options': ['ذهب', 'الولد', 'إلى', 'السوق'],
        'correctAnswer': 2,
        'category': 'النحو',
        'difficulty': 'easy',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'question': 'ما هي الكلمة المضافة في: "كتاب الطالب"؟',
        'options': ['كتاب', 'الطالب', 'مفيد', 'جديد'],
        'correctAnswer': 1,
        'category': 'الإضافة',
        'difficulty': 'medium',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'question': 'ما هو المبتدأ في: "العلم نور"؟',
        'options': ['العلم', 'نور', 'الجملة', 'لا يوجد'],
        'correctAnswer': 0,
        'category': 'الجملة الاسمية',
        'difficulty': 'medium',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final question in questions) {
      await firestore.collection('questions').add(question);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة أسئلة'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            await _addSampleQuestions();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إضافة 5 أسئلة بنجاح!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          icon: const Icon(Icons.add_circle),
          label: const Text('إضافة 5 أسئلة تجريبية'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ),
    );
  }
}