import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 浮遊するパーティクルを表現するデータ
class _Particle {
  double x;
  double y;
  double size;
  double opacity;
  double speed;
  Color color;
  double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.color,
    required this.phase,
  });
}

/// 夜空のパーティクル背景
/// デザインガイドの「光のパーティクル」を実装
class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final bool animate;

  const ParticleBackground({
    super.key,
    required this.child,
    this.particleCount = 15,
    this.animate = true,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  static const _particleColors = [
    AppTheme.particleWarm,
    AppTheme.particleCool,
    AppTheme.particlePink,
    AppTheme.accentPrimary,
  ];

  @override
  void initState() {
    super.initState();
    _initParticles();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  void _initParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 4.0 + _random.nextDouble() * 12.0,
        opacity: 0.1 + _random.nextDouble() * 0.25,
        speed: 0.2 + _random.nextDouble() * 0.5,
        color: _particleColors[_random.nextInt(_particleColors.length)],
        phase: _random.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.gradientBgMain,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              animationValue: _controller.value,
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // ゆっくり浮遊する動き
      final floatOffset = math.sin(
            animationValue * math.pi * 2 * particle.speed + particle.phase,
          ) *
          20;

      final x = particle.x * size.width;
      final y = particle.y * size.height + floatOffset;

      // フェードイン・アウト効果
      final fadePhase = (animationValue * particle.speed + particle.phase) %
          (math.pi * 2);
      final fadeFactor = 0.5 + 0.5 * math.sin(fadePhase);
      final opacity = particle.opacity * fadeFactor;

      // ぼかしたパーティクルを描画
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.8);

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
