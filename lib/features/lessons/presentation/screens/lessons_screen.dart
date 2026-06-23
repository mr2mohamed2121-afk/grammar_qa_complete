import 'package:flutter/material.dart';
import '../../../levels/domain/entities/level_entity.dart';      // ✅ تعديل
import '../../../levels/domain/entities/lesson_entity.dart';      // ✅ تعديل
import 'lesson_detail_screen.dart';
import '../../../quiz/presentation/screens/quiz_screen.dart';
import '../../../../core/utils/app_colors.dart';

class LessonsScreen extends StatelessWidget {
  final LevelEntity level;

  const LessonsScreen({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levelColor = _parseColor(level.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(level.title),
        backgroundColor: levelColor,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    level.icon,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    level.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    level.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: level.progress,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(level.progress * 100).toInt()}% مكتمل',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildLessonCard(
                  context,
                  level.lessons[index],
                  index,
                  levelColor,
                ),
                childCount: level.lessons.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        quiz: level.quiz,
                        levelColor: levelColor,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.quiz),
                label: const Text('بدء الاختبار النهائي'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: levelColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    LessonEntity lesson,
    int index,
    Color levelColor,
  ) {
    final isCompleted = lesson.isCompleted;
    final isLocked = !isCompleted && index > 0 && !lesson.isCompleted;

    return GestureDetector(
      onTap: isLocked
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonDetailScreen(
                    lesson: lesson,
                    levelColor: levelColor,
                  ),
                ),
              ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? Colors.green.withOpacity(0.3)
                : isLocked
                    ? Colors.grey[300]!
                    : levelColor.withOpacity(0.2),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : isLocked
                      ? Colors.grey[200]
                      : levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                  : isLocked
                      ? const Icon(Icons.lock, color: Colors.grey, size: 24)
                      : Icon(Icons.play_circle_outline,
                          color: levelColor, size: 24),
            ),
          ),
          title: Text(
            lesson.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey[400] : Colors.grey[800],
            ),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.timer, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                '${lesson.duration} دقيقة',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(Icons.star, size: 14, color: Colors.amber[400]),
              const SizedBox(width: 4),
              Text(
                '${lesson.points} نقطة',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          trailing: isCompleted
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'مكتمل',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : isLocked
                  ? null
                  : const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}