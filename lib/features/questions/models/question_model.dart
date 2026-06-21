import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String? id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String category;
  final String difficulty;

  QuestionModel({
    this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.category,
    required this.difficulty,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QuestionModel(
      id: doc.id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: (data['correctAnswer'] ?? 0) as int,
      explanation: data['explanation'],
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? 'easy',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'category': category,
      'difficulty': difficulty,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}