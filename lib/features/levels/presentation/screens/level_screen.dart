import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/levels_bloc.dart';
import '../../domain/entities/level_entity.dart';
import '../../../lessons/presentation/screens/lessons_screen.dart';
import '../../../../core/utils/app_colors.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LevelsBloc, LevelsState>(  // ✅ مع النوع
        builder: (context, state) {
          if (state is LevelsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LevelsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red[400]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // ✅ استخدم context.read<LevelsBloc>()
                      context.read<LevelsBloc>().add(const LoadLevels(userPoints: 0));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state is LevelsLoaded) {
            return _buildLevelsList(context, state.levels);
          }
          return const Center(child: Text('ابدأ رحلتك في تعلم النحو!'));
        },
      ),
    );
  }

  Widget _buildLevelsList(BuildContext context, List<LevelEntity> levels) {
    // ✅ إضافة: لو القائمة فاضية، اعرض رسالة
    if (levels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد مستويات متاحة حالياً',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'سيتم إضافة المحتوى قريباً',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Text(
                    'المستويات التعليمية',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${levels.where((l) => l.isUnlocked).length} / ${levels.length} مستويات متاحة',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildLevelCard(context, levels[index]),
              childCount: levels.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(BuildContext context, LevelEntity level) {
    final levelColor = _parseColor(level.color);

    return GestureDetector(
      onTap: level.isUnlocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LessonsScreen(level: level),
                ),
              );
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: level.isUnlocked ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: level.isUnlocked
                ? levelColor.withOpacity(0.3)
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: level.isUnlocked
              ? [
                  BoxShadow(
                    color: levelColor.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: level.isUnlocked
                        ? levelColor.withOpacity(0.1)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: level.isUnlocked
                            ? levelColor.withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          level.icon,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  level.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: level.isUnlocked
                                        ? Colors.grey[800]
                                        : Colors.grey[500],
                                  ),
                                ),
                              ),
                              if (!level.isUnlocked)
                                const Icon(Icons.lock, color: Colors.grey, size: 20)
                              else
                                Icon(Icons.arrow_forward_ios,
                                    color: levelColor, size: 16),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level.description,
                            style: TextStyle(
                              color: level.isUnlocked
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          if (level.isUnlocked)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${(level.progress * 100).toInt()}% مكتمل',
                                      style: TextStyle(
                                        color: levelColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${level.lessons.length} دروس',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: level.progress,
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        AlwaysStoppedAnimation(levelColor),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.lock_outline,
                                    color: Colors.grey[400], size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'يتطلب ${level.requiredPoints} نقطة',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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