import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard.dart';
import 'features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'features/leaderboard/presentation/bloc/leaderboard_bloc.dart';
import 'features/levels/presentation/screens/level_screen.dart';
import 'features/levels/presentation/bloc/levels_bloc.dart';
import 'core/theme/app_theme.dart';
import 'splash_screen.dart';
import 'injection.dart';

class GrammarQAApp extends StatelessWidget {
  const GrammarQAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ✅ AuthBloc مع النوع الصحيح
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AppStarted()),
        ),
        // ✅ LevelsBloc مع النوع الصحيح
        BlocProvider<LevelsBloc>(
          create: (_) => getIt<LevelsBloc>()..add(const LoadLevels(userPoints: 0)),
        ),
      ],
      child: MaterialApp(
        title: 'أستاذ النحو العربي',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'EG'),
          Locale('en', 'US'),
        ],
        locale: const Locale('ar', 'EG'),
        home: const SplashScreenWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/levels': (context) => const LevelScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/leaderboard':
              return MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (_) => getIt<LeaderboardBloc>()..add(LoadLeaderboard()),
                  child: const LeaderboardScreen(),
                ),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(
        onComplete: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    // ✅ BlocBuilder<AuthBloc, AuthState> مع النوع
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          if (state.user.isAdmin) {
            return const AdminDashboard(); // ✅ const
          }
          return const HomeScreen();
        }
        if (state is AuthUnauthenticated) {
          return const LoginScreen();
        }
        // ✅ initial state - loading
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}