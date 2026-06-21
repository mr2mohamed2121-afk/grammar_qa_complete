import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard.dart';
import 'core/theme/app_theme.dart';
import 'splash_screen.dart';
import 'injection.dart';

class GrammarQAApp extends StatelessWidget {
  const GrammarQAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(AppStarted()),
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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          if (state.user.isAdmin) {
            return const AdminDashboard();
          }
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}