import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/leaderboard_model.dart';
import '../bloc/leaderboard_bloc.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF16213E),
            iconTheme: const IconThemeData(color: Colors.white), // ✅ أضف ده
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '🏆 لوحة المتصدرين',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white, // ✅ أبيض صريح
                ),
              ),
              background: Container(
                decoration: const BoxDecoration( // ✅ const
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0F3460),
                      Color(0xFF16213E),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.emoji_events,
                        size: 60,
                        color: Colors.amber[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'أفضل المتعلمين',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9), // ✅ أوضح
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE94560),
                    ),
                  ),
                );
              }

              if (state is LeaderboardError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ: ${state.message}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<LeaderboardBloc>().add(RefreshLeaderboard());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94560),
                          ),
                          child: const Text(
                            'إعادة المحاولة',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is LeaderboardLoaded) {
                if (state.entries.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'لا توجد نتائج بعد!\nكن أول من يصل للقمة 🚀',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = state.entries[index];
                        final isCurrentUser = state.currentUserRank == index + 1;

                        return _buildLeaderboardCard(
                          context,
                          entry: entry,
                          rank: index + 1,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                      childCount: state.entries.length,
                    ),
                  ),
                );
              }

              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(
    BuildContext context, {
    required LeaderboardEntry entry,
    required int rank,
    required bool isCurrentUser,
  }) {
    Color rankColor;
    IconData? rankIcon;
    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.looks_one;
    } else if (rank == 2) {
      rankColor = Colors.grey[400]!;
      rankIcon = Icons.looks_two;
    } else if (rank == 3) {
      rankColor = Colors.brown[300]!;
      rankIcon = Icons.looks_3;
    } else {
      rankColor = Colors.white54;
      rankIcon = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isCurrentUser
            ? const LinearGradient(
                colors: [Color(0xFFE94560), Color(0xFF0F3460)],
              )
            : null,
        color: isCurrentUser ? null : const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: const Color(0xFFE94560), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: 2),
              ),
              child: Center(
                child: rankIcon != null
                    ? Icon(rankIcon, color: rankColor, size: 24)
                    : Text(
                        '$rank',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF0F3460),
              backgroundImage: entry.userPhotoUrl != null
                  ? NetworkImage(entry.userPhotoUrl!)
                  : null,
              child: entry.userPhotoUrl == null
                  ? Text(
                      entry.userName[0].toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.userName,
                          style: const TextStyle( // ✅ const
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'أنت',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Color(0xFFE94560),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.totalQuizzes} اختبار | أفضل: ${entry.bestScore}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.totalScore}',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: rankColor,
                  ),
                ),
                Text(
                  'نقطة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}