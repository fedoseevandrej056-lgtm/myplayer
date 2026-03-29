import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class LiquidAura extends StatefulWidget {
  final String? imageUrl;
  final Widget child;
  
  const LiquidAura({
    Key? key,
    this.imageUrl,
    required this.child,
  }) : super(key: key);

  @override
  State<LiquidAura> createState() => _LiquidAuraState();
}

class _LiquidAuraState extends State<LiquidAura> 
    with TickerProviderStateMixin {
  List<Color> _auraColors = [
    Colors.purple.shade900,
    Colors.blue.shade900,
    Colors.black,
  ];
  
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;
  
  final List<LiquidBlob> _blobs = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initializeBlobs();
    _initializeAnimations();
  }

  @override
  void didUpdateWidget(LiquidAura oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void _initializeBlobs() {
    for (int i = 0; i < 5; i++) {
      _blobs.add(LiquidBlob(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: 0.15 + _random.nextDouble() * 0.25,
        velocityX: (_random.nextDouble() - 0.5) * 0.0002,
        velocityY: (_random.nextDouble() - 0.5) * 0.0002,
        colorIndex: i % _auraColors.length,
      ));
    }
  }

  void _initializeAnimations() {
    _controllers = List.generate(5, (index) {
      return AnimationController(
        duration: Duration(seconds: 15 + index * 3),
        vsync: this,
      )..repeat();
    });

    _animations = _controllers
        .map((controller) => CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated liquid aura background
        AnimatedBuilder(
          animation: Listenable.merge(_controllers),
          builder: (context, child) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: LiquidAuraPainter(
                blobs: _blobs,
                colors: _auraColors,
                animations: _animations,
                time: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          },
        ),
        // Blur overlay for glass effect
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        // Child content
        widget.child,
      ],
    );
  }
}

class LiquidBlob {
  double x;
  double y;
  double radius;
  double velocityX;
  double velocityY;
  final int colorIndex;

  LiquidBlob({
    required this.x,
    required this.y,
    required this.radius,
    required this.velocityX,
    required this.velocityY,
    required this.colorIndex,
  });

  void update(double deltaTime) {
    x += velocityX * deltaTime;
    y += velocityY * deltaTime;

    // Bounce off edges
    if (x < 0 || x > 1) {
      velocityX = -velocityX;
      x = x.clamp(0.0, 1.0);
    }
    if (y < 0 || y > 1) {
      velocityY = -velocityY;
      y = y.clamp(0.0, 1.0);
    }
  }
}

class LiquidAuraPainter extends CustomPainter {
  final List<LiquidBlob> blobs;
  final List<Color> colors;
  final List<Animation<double>> animations;
  final int time;

  LiquidAuraPainter({
    required this.blobs,
    required this.colors,
    required this.animations,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80.0);

    // Update blob positions based on animations
    for (int i = 0; i < blobs.length; i++) {
      final blob = blobs[i];
      final animation = animations[i % animations.length];
      final animatedValue = animation.value;
      
      // Create metaball effect
      blob.update(16.0); // Assume 60 FPS
    
      // Apply animation transformations
      final animatedX = blob.x + math.sin(animatedValue * 2 * math.pi + i) * 0.1;
      final animatedY = blob.y + math.cos(animatedValue * 2 * math.pi + i) * 0.1;
      final animatedRadius = blob.radius * (0.8 + animatedValue * 0.4);
      
      final center = Offset(
        animatedX * size.width,
        animatedY * size.height,
      );
      
      // Draw blob with gradient
      final gradient = RadialGradient(
        colors: [
          colors[blob.colorIndex].withOpacity(0.6),
          colors[blob.colorIndex].withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      );
      
      paint.shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: animatedRadius * size.width),
      );
      
      canvas.drawCircle(center, animatedRadius * size.width, paint);
    }

    // Create metaball connections between nearby blobs
    paint.shader = null;
    paint.color = colors.first.withOpacity(0.3);
    
    for (int i = 0; i < blobs.length; i++) {
      for (int j = i + 1; j < blobs.length; j++) {
        final blob1 = blobs[i];
        final blob2 = blobs[j];
        
        final x1 = blob1.x + blob1.radius * math.sin(time * 0.01 + blob1.colorIndex);
        final y1 = blob1.y + blob1.radius * math.cos(time * 0.01 + blob1.colorIndex);
        final x2 = blob2.x + blob2.radius * math.sin(time * 0.01 + blob2.colorIndex);
        final y2 = blob2.y + blob2.radius * math.cos(time * 0.01 + blob2.colorIndex);
        
        final center1 = Offset(x1 * size.width, y1 * size.height);
        final center2 = Offset(x2 * size.width, y2 * size.height);
        final distance = (center1 - center2).distance;
        const maxDistance = 200.0;
        
        if (distance < maxDistance) {
          final opacity = 1.0 - (distance / maxDistance);
          paint.color = colors[blob1.colorIndex].withOpacity(opacity * 0.2);
          
          final path = Path();
          final controlPoint1 = Offset(
            center1.dx + (center2.dx - center1.dx) * 0.25,
            center1.dy - 50,
          );
          final controlPoint2 = Offset(
            center1.dx + (center2.dx - center1.dx) * 0.75,
            center2.dy - 50,
          );
          
          path.moveTo(center1.dx, center1.dy);
          path.cubicTo(
            controlPoint1.dx, controlPoint1.dy,
            controlPoint2.dx, controlPoint2.dy,
            center2.dx, center2.dy,
          );
          
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(LiquidAuraPainter oldDelegate) {
    return true; // Always repaint for smooth animation
  }
}
