import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MorphingPlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;
  final Color color;

  const MorphingPlayButton({
    Key? key,
    required this.isPlaying,
    required this.onPressed,
    this.size = 80.0,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  State<MorphingPlayButton> createState() => _MorphingPlayButtonState();
}

class _MorphingPlayButtonState extends State<MorphingPlayButton>
    with TickerProviderStateMixin {
  late final AnimationController _morphController;
  late final AnimationController _pulseController;
  late final Animation<double> _morphAnimation;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Set initial animation state
    if (widget.isPlaying) {
      _morphController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MorphingPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _morphController.forward();
      } else {
        _morphController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Fallback - ignore if sound fails
    }
    _rippleController.forward().then((_) {
      _rippleController.reverse();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effect
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return Container(
                  width: widget.size * (1.0 + _rippleController.value * 0.3),
                  height: widget.size * (1.0 + _rippleController.value * 0.3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withOpacity(
                        (1.0 - _rippleController.value) * 0.3,
                      ),
                      width: 2.0,
                    ),
                  ),
                );
              },
            ),
            // Main morphing button
            AnimatedBuilder(
              animation: Listenable.merge([_morphAnimation, _pulseAnimation]),
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: MorphingPlayPainter(
                    progress: _morphAnimation.value,
                    pulseScale: 1.0 + _pulseAnimation.value * 0.05,
                    color: widget.color,
                    isPlaying: widget.isPlaying,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MorphingPlayPainter extends CustomPainter {
  final double progress;
  final double pulseScale;
  final Color color;
  final bool isPlaying;

  MorphingPlayPainter({
    required this.progress,
    required this.pulseScale,
    required this.color,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseSize = math.min(size.width, size.height) * pulseScale;
    
    // Draw liquid mercury background with glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);
    
    canvas.drawCircle(center, baseSize / 2, glowPaint);
    
    // Draw main button background
    final bgPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, baseSize / 2.2, bgPaint);
    
    // Draw morphing play/pause icon
    final iconPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;
    
    _drawMorphingIcon(canvas, center, baseSize * 0.35, iconPaint);
  }

  void _drawMorphingIcon(Canvas canvas, Offset center, double size, Paint paint) {
    if (progress == 0.0) {
      // Draw play triangle
      _drawPlayTriangle(canvas, center, size, paint);
    } else if (progress == 1.0) {
      // Draw pause bars
      _drawPauseBars(canvas, center, size, paint);
    } else {
      // Morph between triangle and bars
      _drawMorphingShape(canvas, center, size, paint);
    }
  }

  void _drawPlayTriangle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final triangleSize = size * 0.6;
    
    path.moveTo(center.dx - triangleSize / 2, center.dy - triangleSize / 2);
    path.lineTo(center.dx - triangleSize / 2, center.dy + triangleSize / 2);
    path.lineTo(center.dx + triangleSize / 2, center.dy);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawPauseBars(Canvas canvas, Offset center, double size, Paint paint) {
    final barWidth = size * 0.25;
    final barHeight = size * 0.8;
    final spacing = size * 0.15;
    
    // Left bar
    final leftRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - spacing / 2, center.dy),
        width: barWidth,
        height: barHeight,
      ),
      const Radius.circular(4.0),
    );
    
    // Right bar
    final rightRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx + spacing / 2, center.dy),
        width: barWidth,
        height: barHeight,
      ),
      const Radius.circular(4.0),
    );
    
    canvas.drawRRect(leftRect, paint);
    canvas.drawRRect(rightRect, paint);
  }

  void _drawMorphingShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final triangleSize = size * 0.6;
    final barWidth = size * 0.25;
    final barHeight = size * 0.8;
    final spacing = size * 0.15;
    
    // Liquid morphing using bezier curves
    final t = progress;
    
    // Start with triangle points
    final p1 = Offset(center.dx - triangleSize / 2, center.dy - triangleSize / 2);
    final p2 = Offset(center.dx - triangleSize / 2, center.dy + triangleSize / 2);
    final p3 = Offset(center.dx + triangleSize / 2, center.dy);
    
    // Target pause bar positions
    final leftTop = Offset(center.dx - spacing / 2 - barWidth / 2, center.dy - barHeight / 2);
    final leftBottom = Offset(center.dx - spacing / 2 - barWidth / 2, center.dy + barHeight / 2);
    
    // Interpolate positions with liquid effect
    final cp1 = Offset.lerp(p1, leftTop, t)!;
    final cp2 = Offset.lerp(p2, leftBottom, t)!;
    final cp3 = Offset.lerp(p3, Offset(center.dx, center.dy), t)!;
    
    // Add liquid waviness
    final waveOffset = math.sin(t * math.pi) * 5.0;
    
    path.moveTo(cp1.dx, cp1.dy + waveOffset);
    
    // Liquid curve to second point
    final control1 = Offset(
      cp1.dx + (cp2.dx - cp1.dx) * 0.3 + waveOffset,
      cp1.dy + (cp2.dy - cp1.dy) * 0.3,
    );
    final control2 = Offset(
      cp1.dx + (cp2.dx - cp1.dx) * 0.7 - waveOffset,
      cp1.dy + (cp2.dy - cp1.dy) * 0.7,
    );
    path.cubicTo(control1.dx, control1.dy, control2.dx, control2.dy, cp2.dx, cp2.dy - waveOffset);
    
    // Liquid curve to third point
    final control3 = Offset(
      cp2.dx + (cp3.dx - cp2.dx) * 0.3 + waveOffset,
      cp2.dy + (cp3.dy - cp2.dy) * 0.3,
    );
    final control4 = Offset(
      cp2.dx + (cp3.dx - cp2.dx) * 0.7 - waveOffset,
      cp2.dy + (cp3.dy - cp2.dy) * 0.7,
    );
    path.cubicTo(control3.dx, control3.dy, control4.dx, control4.dy, cp3.dx, cp3.dy);
    
    // Close the liquid shape
    path.close();
    
    // Draw the morphing shape
    canvas.drawPath(path, paint);
    
    // Add liquid mercury highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    final highlightPath = Path();
    highlightPath.addOval(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.1, center.dy - size * 0.2),
        width: size * 0.3,
        height: size * 0.2,
      ),
    );
    
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(MorphingPlayPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.pulseScale != pulseScale ||
           oldDelegate.isPlaying != isPlaying;
  }
}
