import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ParticleShiftTransition extends StatefulWidget {
  final Widget child;
  final String? imageUrl;
  final bool isTransitioning;
  final Duration duration;

  const ParticleShiftTransition({
    Key? key,
    required this.child,
    this.imageUrl,
    this.isTransitioning = false,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ParticleShiftTransition> createState() => _ParticleShiftTransitionState();
}

class _ParticleShiftTransitionState extends State<ParticleShiftTransition>
    with TickerProviderStateMixin {
  late final AnimationController _particleController;
  late final Animation<double> _particleAnimation;
  
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  bool _hasTransitioned = false;

  @override
  void initState() {
    super.initState();
    
    _particleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(ParticleShiftTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isTransitioning && !oldWidget.isTransitioning && !_hasTransitioned) {
      _startTransition();
    }
  }

  void _startTransition() {
    _hasTransitioned = true;
    _generateParticles();
    _particleController.forward().then((_) {
      if (mounted) {
        setState(() {
          _hasTransitioned = false;
          _particles.clear();
        });
        _particleController.reset();
      }
    });
  }

  void _generateParticles() {
    const particleCount = 1000;
    _particles.clear();
    
    for (int i = 0; i < particleCount; i++) {
      _particles.add(Particle(
        startX: _random.nextDouble(),
        startY: _random.nextDouble(),
        endX: _random.nextDouble() * 2.0 - 0.5, // Particles fly off screen
        endY: _random.nextDouble() * 2.0 - 0.5,
        size: 1.0 + _random.nextDouble() * 3.0,
        color: _getRandomParticleColor(),
        delay: _random.nextDouble() * 0.3, // Staggered animation
        speed: 0.5 + _random.nextDouble() * 0.5,
      ));
    }
  }

  Color _getRandomParticleColor() {
    final colors = [
      Colors.white,
      Colors.blue.shade300,
      Colors.purple.shade300,
      Colors.cyan.shade300,
      Colors.indigo.shade300,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        AnimatedOpacity(
          opacity: _hasTransitioned ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: widget.child,
        ),
        
        // Particle effect
        if (_hasTransitioned)
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: ParticlePainter(
                  particles: _particles,
                  progress: _particleAnimation.value,
                  imageUrl: widget.imageUrl,
                ),
              );
            },
          ),
      ],
    );
  }
}

class Particle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final Color color;
  final double delay;
  final double speed;

  Particle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.color,
    required this.delay,
    required this.speed,
  });

  Offset getPositionAt(double progress) {
    final adjustedProgress = ((progress - delay) / speed).clamp(0.0, 1.0);
    if (adjustedProgress <= 0.0) return Offset(startX, startY);
    
    // Use cubic easing for more natural movement
    final t = _cubicEaseInOut(adjustedProgress);
    
    return Offset(
      startX + (endX - startX) * t,
      startY + (endY - startY) * t,
    );
  }

  double getOpacityAt(double progress) {
    final adjustedProgress = ((progress - delay) / speed).clamp(0.0, 1.0);
    if (adjustedProgress <= 0.0) return 0.0;
    if (adjustedProgress >= 0.8) return (1.0 - (adjustedProgress - 0.8) / 0.2);
    return 1.0;
  }

  double _cubicEaseInOut(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - math.pow(-2 * t + 2, 3) / 2;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;
  final String? imageUrl;

  ParticlePainter({
    required this.particles,
    required this.progress,
    this.imageUrl,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw particles
    for (final particle in particles) {
      final position = particle.getPositionAt(progress);
      final opacity = particle.getOpacityAt(progress);
      
      if (opacity > 0.0) {
        final paint = Paint()
          ..color = particle.color.withOpacity(opacity * 0.8)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size * 0.5);
        
        final particlePosition = Offset(
          position.dx * size.width,
          position.dy * size.height,
        );
        
        canvas.drawCircle(particlePosition, particle.size, paint);
        
        // Add glow effect for larger particles
        if (particle.size > 2.0) {
          final glowPaint = Paint()
            ..color = particle.color.withOpacity(opacity * 0.3)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
          
          canvas.drawCircle(particlePosition, particle.size * 2, glowPaint);
        }
      }
    }
    
    // Draw assembling particles for new image
    if (progress > 0.3 && imageUrl != null) {
      final assembleProgress = (progress - 0.3) / 0.7;
      _drawAssemblingImage(canvas, size, assembleProgress);
    }
  }

  void _drawAssemblingImage(Canvas canvas, Size size, double progress) {
    // Create a particle-based image assembly effect
    const gridSize = 20;
    final particleSize = size.width / gridSize;
    
    for (int x = 0; x < gridSize; x++) {
      for (int y = 0; y < gridSize; y++) {
        final particleProgress = ((x + y) / (gridSize * 2.0) + progress * 0.5).clamp(0.0, 1.0);
        final opacity = _cubicEaseInOut(particleProgress);
        
        if (opacity > 0.0) {
          final paint = Paint()
            ..color = Colors.white.withOpacity(opacity * 0.6)
            ..style = PaintingStyle.fill;
          
          final targetX = (x + 0.5) * particleSize;
          final targetY = (y + 0.5) * particleSize;
          
          // Particles come from random positions
          final randomX = math.Random(x * y + 42).nextDouble() * size.width;
          final randomY = math.Random(y * x + 24).nextDouble() * size.height;
          
          final currentX = randomX + (targetX - randomX) * progress;
          final currentY = randomY + (targetY - randomY) * progress;
          
          canvas.drawCircle(
            Offset(currentX, currentY),
            particleSize * 0.3 * opacity,
            paint,
          );
        }
      }
    }
  }

  double _cubicEaseInOut(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Helper widget for seamless track transitions
class ArtworkTransition extends StatefulWidget {
  final String? currentArtwork;
  final String? nextArtwork;
  final Widget child;
  final bool isChanging;

  const ArtworkTransition({
    Key? key,
    this.currentArtwork,
    this.nextArtwork,
    required this.child,
    this.isChanging = false,
  }) : super(key: key);

  @override
  State<ArtworkTransition> createState() => _ArtworkTransitionState();
}

class _ArtworkTransitionState extends State<ArtworkTransition>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(ArtworkTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isChanging && !oldWidget.isChanging) {
      _fadeController.forward().then((_) {
        if (mounted) {
          _fadeController.reset();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParticleShiftTransition(
      imageUrl: widget.currentArtwork,
      isTransitioning: widget.isChanging,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: widget.isChanging ? (1.0 - _fadeAnimation.value) : 1.0,
            child: widget.child,
          );
        },
      ),
    );
  }
}
