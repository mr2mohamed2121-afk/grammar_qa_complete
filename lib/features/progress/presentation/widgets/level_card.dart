import 'package:flutter/material.dart';
import '../../domain/entities/level_entity.dart';
import '../../../../core/utils/app_colors.dart';

class LevelCard extends StatelessWidget {
  final LevelEntity level;
  final VoidCallback? onTap;

  const LevelCard({
    Key? key,
    required this.level,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levelColor = _parseColor(level.color);

    return GestureDetector(
      onTap: level.isUnlocked ? onTap : null,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        levelColor),
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