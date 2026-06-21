import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';

import '../../controller/StartpageContrller.dart';
import '../../core/constant/imageassets.DART';
import '../../core/constant/routes.dart';
import '../../core/functions/CheckInternat.dart';
import '../../core/services/Services.dart';

class Sparkle {
  double x, y;
  double vx, vy;
  double size;
  double maxLife;
  double life;
  Color color;

  Sparkle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.maxLife,
    required this.color,
  }) : life = maxLife;
}

class SpaceParticlesPainter extends CustomPainter {
  final List<Sparkle> sparkles;
  final double animateProgress;

  SpaceParticlesPainter(this.sparkles, this.animateProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw background nebula glow
    final radialGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        const Color(0xFFF5E6FF).withOpacity(0.45 * (1.0 - animateProgress)), // soft violet aura
        Colors.white.withOpacity(1.0 - animateProgress), // pure white
      ],
    );
    paint.shader = radialGradient.createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);

    // Reset shader for drawing sparkles
    paint.shader = null;

    for (var s in sparkles) {
      final progress = s.life / s.maxLife;
      paint.color = s.color.withOpacity(progress * 0.6 * (1.0 - animateProgress));
      
      // Draw particle glow (shadow)
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, s.size * 0.9);
      canvas.drawCircle(Offset(s.x, s.y), s.size * 1.8, paint);

      // Draw particle core
      paint.maskFilter = null;
      paint.color = s.color.withOpacity(progress * 0.9 * (1.0 - animateProgress));
      canvas.drawCircle(Offset(s.x, s.y), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Startpagecontrller contrller = Get.put(Startpagecontrller());
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  late AnimationController _rotationController;
  late AnimationController _loadingProgressController;
  late Animation<double> _loadingProgressAnimation;
  
  late Ticker _particleTicker;
  final List<Sparkle> _sparkles = [];
  final Random _random = Random();

  final Myservices myServices = Get.find();
  bool animate = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.1)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _loadingProgressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _loadingProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingProgressController, curve: Curves.easeInOut),
    );

    _particleTicker = createTicker((elapsed) {
      _updateParticles();
    })..start();

    _startAnimationSequence();
  }

  void _updateParticles() {
    if (!mounted) return;
    
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width > 0 ? size.width : 1200.0;
    final screenHeight = size.height > 0 ? size.height : 800.0;

    setState(() {
      // Spawn slow ambient background particles
      if (_random.nextDouble() < 0.25 && _sparkles.length < 180) {
        _sparkles.add(Sparkle(
          x: _random.nextDouble() * screenWidth,
          y: screenHeight + 20,
          vx: (_random.nextDouble() - 0.5) * 0.4,
          vy: -_random.nextDouble() * 1.2 - 0.4,
          size: _random.nextDouble() * 2.5 + 1.0,
          maxLife: 250 + _random.nextDouble() * 150,
          color: _random.nextBool() 
              ? const Color(0xFF9333EA) // purple
              : const Color(0xFF0284C7), // cyan
        ));
      }

      // Update particle positions and lifespans
      for (int i = _sparkles.length - 1; i >= 0; i--) {
        var s = _sparkles[i];
        s.x += s.vx;
        s.y += s.vy;
        s.life -= 1.0;
        if (s.life <= 0) {
          _sparkles.removeAt(i);
        }
      }
    });
  }

  void _spawnMouseSparkles(Offset pos) {
    if (!mounted) return;
    for (int i = 0; i < 4; i++) {
      _sparkles.add(Sparkle(
        x: pos.dx,
        y: pos.dy,
        vx: (_random.nextDouble() - 0.5) * 2.5,
        vy: (_random.nextDouble() - 0.5) * 2.5,
        size: _random.nextDouble() * 3.5 + 1.5,
        maxLife: 45 + _random.nextDouble() * 25,
        color: _random.nextBool() 
            ? const Color(0xFFDB2777) // pink
            : const Color(0xFF0891B2), // neon cyan
      ));
    }
  }

  Future<void> _startAnimationSequence() async {
    String? token = myServices.sharedPreferences?.getString("token");

    if (token != null && token.isNotEmpty) {
      try {
        await Future.microtask(() async {
          if (await checkInternet()) {
            await contrller.getUser();
          }
        }).timeout(const Duration(seconds: 15));
      } catch (e) {
        print("Timeout or no internet in SplashScreen: $e");
      }
    }

    _controller.forward();
    _loadingProgressController.forward();

    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      setState(() => animate = true);
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (token != null && token.isNotEmpty) {
      String? experimentDateString =
          myServices.sharedPreferences?.getString("date_experiment");

      int status = myServices.sharedPreferences?.getInt("status") ?? 0;

      if (status == 1) {
        Get.offAllNamed(Approutes.HomeScreen);
        return;
      }

      if (status == 2 || status == 3) {
        if (experimentDateString != null && experimentDateString.isNotEmpty) {
          DateTime experimentDate = DateTime.parse(experimentDateString);
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);
          DateTime expireDate = DateTime(
            experimentDate.year,
            experimentDate.month,
            experimentDate.day,
          );

          bool isValid = today.isBefore(expireDate);

          if (isValid) {
            Get.offAllNamed(Approutes.HomeScreen);
          } else {
            Get.offAllNamed(Approutes.Login);
          }
        } else {
          Get.offAllNamed(Approutes.Login);
        }
        return;
      }

      Get.offAllNamed(Approutes.Login);
    } else {
      Get.offAllNamed(Approutes.Login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    _loadingProgressController.dispose();
    _particleTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final fadeOutProgress = animate ? 1.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: MouseRegion(
        onHover: (event) => _spawnMouseSparkles(event.localPosition),
        child: Stack(
          children: [
            // Ambient Particle Space
            Positioned.fill(
              child: CustomPaint(
                painter: SpaceParticlesPainter(_sparkles, fadeOutProgress),
              ),
            ),
            
            // Content
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1.0 - fadeOutProgress,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rotating Neon Halo & Pulsing Logo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: _rotationController,
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    const Color(0xFFC084FC).withOpacity(0.0),
                                    const Color(0xFFC084FC).withOpacity(0.35),
                                    const Color(0xFF38BDF8).withOpacity(0.35),
                                    const Color(0xFFC084FC).withOpacity(0.0),
                                  ],
                                  stops: const [0.0, 0.35, 0.65, 1.0],
                                ),
                              ),
                            ),
                          ),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC084FC).withOpacity(0.35),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF38BDF8).withOpacity(0.15),
                                    blurRadius: 15,
                                    spreadRadius: -2,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Image.asset(
                                Appimageassets.logo2,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      // Title Text
                      Text(
                        "ZEFFA",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8.0,
                          color: const Color(0xFF3B1578),
                          shadows: [
                            Shadow(
                              color: const Color(0xFFC084FC).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle Arabic Text
                      Text(
                        isArabic 
                            ? "المنصة الذكية لإدارة قاعات الحفلات والفعاليات"
                            : "Intelligent Platform for Event Halls Management",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5A527A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Glowing Progress Indicator
                      AnimatedBuilder(
                        animation: _loadingProgressAnimation,
                        builder: (context, child) {
                          final percentage = (_loadingProgressAnimation.value * 100).toInt();
                          return Column(
                            children: [
                              Container(
                                width: 280,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B1578).withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    widthFactor: _loadingProgressAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFC084FC),
                                            Color(0xFF38BDF8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF38BDF8).withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                isArabic
                                    ? "جاري تهيئة النظام... $percentage%"
                                    : "Initializing System... $percentage%",
                                style: const TextStyle(
                                  color: Color(0xFF7D759F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
