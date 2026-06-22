import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../questions/models/question_model.dart';

class AddQuestionsScreen extends StatefulWidget {
  const AddQuestionsScreen({super.key});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  int _correctAnswerIndex = 0;
  String _category = 'عام';
  String _difficulty = 'easy';
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final options = _optionControllers.map((c) => c.text.trim()).toList();
      
      final question = QuestionModel(
        question: _questionController.text.trim(),
        options: options,
        correctAnswer: _correctAnswerIndex,
        explanation: null,
        category: _category,
        difficulty: _difficulty,
      );

      await FirebaseFirestore.instance
          .collection('questions')
          .add(question.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ تم إضافة السؤال بنجاح!',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
            ),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ خطأ: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _questionController.clear();
    for (var controller in _optionControllers) {
      controller.clear();
    }
    setState(() {
      _correctAnswerIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة أسئلة',
          style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ✅ خلفية داكنة للشاشة كلها
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ✅ عنوان أبيض واضح
                    const Text(
                      'أضف سؤال جديد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ أبيض
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ✅ السؤال - نص أبيض + خلفية أزرق
                    _buildTextField(
                      controller: _questionController,
                      label: 'السؤال',
                      hint: 'اكتب السؤال هنا...',
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء كتابة السؤال';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ الخيارات - عنوان أبيض
                    const Text(
                      'الخيارات:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ أبيض
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (int i = 0; i < 4; i++) ...[
                      Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: _correctAnswerIndex,
                            onChanged: (value) {
                              setState(() => _correctAnswerIndex = value!);
                            },
                            activeColor: const Color(0xFF2E7D32),
                          ),
                          Expanded(
                            child: _buildTextField(
                              controller: _optionControllers[i],
                              label: 'الخيار ${i + 1}',
                              hint: 'اكتب الخيار ${i + 1}...',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء كتابة الخيار';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ✅ التصنيف
                    const Text(
                      'التصنيف:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ أبيض
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _category,
                      dropdownColor: const Color(0xFF16213E), // ✅ خلفية داكنة
                      style: const TextStyle(
                        color: Colors.white, // ✅ أبيض
                        fontFamily: 'Cairo',
                      ),
                      decoration: _buildInputDecoration('اختر التصنيف'),
                      items: const [
                        DropdownMenuItem(value: 'عام', child: Text('عام', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'نحو', child: Text('نحو', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'صرف', child: Text('صرف', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'بلاغة', child: Text('بلاغة', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (value) {
                        setState(() => _category = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✅ الصعوبة
                    const Text(
                      'الصعوبة:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ أبيض
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _difficulty,
                      dropdownColor: const Color(0xFF16213E), // ✅ خلفية داكنة
                      style: const TextStyle(
                        color: Colors.white, // ✅ أبيض
                        fontFamily: 'Cairo',
                      ),
                      decoration: _buildInputDecoration('اختر الصعوبة'),
                      items: const [
                        DropdownMenuItem(value: 'easy', child: Text('سهل', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'medium', child: Text('متوسط', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'hard', child: Text('صعب', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (value) {
                        setState(() => _difficulty = value!);
                      },
                    ),
                    const SizedBox(height: 24),

                    // ✅ زر الإضافة - أخضر واضح + نص أبيض
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _addQuestion,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add, color: Colors.white, size: 28),
                      label: Text(
                        _isLoading ? 'جاري الإضافة...' : 'إضافة السؤال',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // ✅ أبيض
                          fontFamily: 'Cairo',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ TextField موحد - نص أبيض + خلفية أزرق داكن
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        color: Colors.white, // ✅ أبيض
        fontFamily: 'Cairo',
        fontSize: 16,
      ),
      decoration: _buildInputDecoration(label, hint: hint),
    );
  }

  // ✅ InputDecoration موحد - خلفية أزرق داكن + نص أبيض
  InputDecoration _buildInputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: Colors.white70, // ✅ أبيض فاتح
        fontFamily: 'Cairo',
      ),
      hintStyle: const TextStyle(
        color: Colors.white38, // ✅ أبيض شفاف
        fontFamily: 'Cairo',
      ),
      filled: true,
      fillColor: const Color(0xFF0F3460), // ✅ خلفية أزرق داكن
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontFamily: 'Cairo',
      ),
    );
  }
}