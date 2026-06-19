
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particlesController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _particlesOpacity;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    _logoRotation = Tween<double>(begin: -0.5, end: 0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Particles animation
    _particlesController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particlesOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _particlesController, curve: Curves.easeIn),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _particlesController.forward();

    await Future.delayed(const Duration(milliseconds: 2500));
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Animated particles background
            AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return Opacity(
                  opacity: _particlesOpacity.value,
                  child: CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: ParticlesPainter(),
                  ),
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animation
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE94560), Color(0xFFFF6B6B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE94560).withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.menu_book,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // App name with animation
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: SlideTransition(
                          position: _textSlide,
                          child: Column(
                            children: [
                              // Main title
                              const Text(
                                'أستاذ النحو العربي',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Color(0xFFE94560),
                                      blurRadius: 20,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Subtitle
                              Text(
                                'مع أستاذ محمد أحمد الوهيدي',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Description
                              Text(
                                'تعلم النحو العربي بطريقة احترافية',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // Loading indicator
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            const SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE94560),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'جاري التحميل...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom signature
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value * 0.5,
                    child: const Center(
                      child: Text(
                        '© 2024 أستاذ النحو العربي',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Particles Background Painter
class ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (var i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw connecting lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (var i = 0; i < 20; i++) {
      final x1 = random.nextDouble() * size.width;
      final y1 = random.nextDouble() * size.height;
      final x2 = random.nextDouble() * size.width;
      final y2 = random.nextDouble() * size.height;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
