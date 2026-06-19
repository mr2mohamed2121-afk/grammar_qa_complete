
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  String _selectedPeriod = 'all';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final data = await _firestoreService.getLeaderboard(limit: 10);
      setState(() {
        _leaderboard = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 لوحة المتصدرين'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Period Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text('يومي')),
                ButtonSegment(value: 'weekly', label: Text('أسبوعي')),
                ButtonSegment(value: 'all', label: Text('الكل')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (value) {
                setState(() => _selectedPeriod = value.first);
                _loadLeaderboard();
              },
            ),
          ),

          // Top 3 Podium
          if (_leaderboard.length >= 3) _buildPodium(),

          const SizedBox(height: 16),

          // Leaderboard List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _leaderboard.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _leaderboard.length,
                        itemBuilder: (context, index) {
                          final entry = _leaderboard[index];
                          return _buildLeaderboardItem(entry, index + 1);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top3 = _leaderboard.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd Place
          _buildPodiumItem(
            rank: 2,
            name: top3[1]['name'] ?? 'Unknown',
            score: top3[1]['totalScore'] ?? 0,
            color: const Color(0xFFC0C0C0), // Silver
            height: 120,
          ),
          const SizedBox(width: 16),

          // 1st Place
          _buildPodiumItem(
            rank: 1,
            name: top3[0]['name'] ?? 'Unknown',
            score: top3[0]['totalScore'] ?? 0,
            color: const Color(0xFFFFD700), // Gold
            height: 160,
            isFirst: true,
          ),
          const SizedBox(width: 16),

          // 3rd Place
          _buildPodiumItem(
            rank: 3,
            name: top3[2]['name'] ?? 'Unknown',
            score: top3[2]['totalScore'] ?? 0,
            color: const Color(0xFFCD7F32), // Bronze
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required int score,
    required Color color,
    required double height,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isFirst ? 4 : 2,
            ),
            image: DecorationImage(
              image: NetworkImage(
                'https://ui-avatars.com/api/?name=$name&background=random',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: isFirst
              ? const Align(
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontWeight: isFirst ? FontWeight.bold : FontWeight.normal,
            fontSize: isFirst ? 16 : 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$score نقطة',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isFirst ? 24 : 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> entry, int rank) {
    final bool isTop3 = rank <= 3;
    final Color rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: isTop3 ? rankColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rankColor.withOpacity(0.2),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
          ),
        ),
        title: Text(
          entry['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.local_fire_department, size: 14, color: Colors.orange[600]),
            const SizedBox(width: 4),
            Text('${entry['streakDays'] ?? 0} يوم'),
            const SizedBox(width: 16),
            Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
            const SizedBox(width: 4),
            Text('${entry['accuracy'] ?? 0}%'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry['totalScore'] ?? 0}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF6C63FF),
              ),
            ),
            Text(
              '${entry['totalQuizzes'] ?? 0} اختبار',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد متصدرين بعد',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'كن أول من يظهر في لوحة المتصدرين!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
