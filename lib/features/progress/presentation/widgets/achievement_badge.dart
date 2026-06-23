import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String icon;
  final bool isUnlocked;
  final int points;
  final VoidCallback? onTap;

  const AchievementBadge({
    Key? key,
    required this.title,
    required this.icon,
    required this.isUnlocked,
    required this.points,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.amber[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked ? Colors.amber[300]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 28,
                    color: isUnlocked ? null : Colors.grey[400],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.grey[800] : Colors.grey[400],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked)
              Text(
                '+$points',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.amber[600],
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Icon(Icons.lock, size: 12, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}