import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../levels/presentation/screens/level_screen.dart';
import '../../../admin/presentation/screens/add_questions_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../../leaderboard/presentation/bloc/leaderboard_bloc.dart';
import '../../../live_sessions/presentation/screens/live_sessions_screen.dart';
import '../../../ai_tutor/presentation/screens/ai_tutor_screen.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/screens/account_settings_dialog.dart';
import '../../../auth/presentation/screens/privacy_settings_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الصفحة الرئيسية',
          style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E3A5F),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsMenu(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, size: 80, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'تطبيق قواعد اللغة العربية',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'اختبر معلوماتك في النحو والصرف',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // ✅ زر "اختبر نفسك" → يفتح LevelScreen
              _buildGradientButton(
                context: context,
                title: 'اختبر نفسك',
                icon: Icons.quiz,
                colors: [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LevelScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildGradientButton(
                context: context,
                title: 'إضافة أسئلة',
                icon: Icons.add_circle,
                colors: [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddQuestionsScreen()),
                ),
              ),
              const SizedBox(height: 16),

              _buildGradientButton(
                context: context,
                title: 'لوحة المتصدرين',
                icon: Icons.emoji_events,
                colors: [const Color(0xFFFFD700), const Color(0xFFFF8C00)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (_) => getIt<LeaderboardBloc>()..add(LoadLeaderboard()),
                      child: const LeaderboardScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildGradientButton(
                context: context,
                title: 'الجلسات المباشرة',
                icon: Icons.live_tv,
                colors: [const Color(0xFFE94560), const Color(0xFF0F3460)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LiveSessionsScreen()),
                ),
              ),
              const SizedBox(height: 16),

              _buildGradientButton(
                context: context,
                title: 'أستاذ النحو الذكي',
                icon: Icons.smart_toy,
                colors: [const Color(0xFF9C27B0), const Color(0xFF673AB7)],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiTutorScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'الإعدادات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'إعدادات الحساب',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const AccountSettingsDialog(),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.white),
              title: const Text(
                'الخصوصية',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const PrivacySettingsDialog(),
                );
              },
            ),

            const Divider(color: Colors.white24),

            // ✅✅✅ الحل الصحيح!
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                // ✅ استخدم context.read<AuthBloc>() مع النوع
                context.read<AuthBloc>().add(SignOutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}