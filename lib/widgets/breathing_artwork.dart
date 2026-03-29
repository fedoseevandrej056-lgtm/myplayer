import 'dart:math' as math;
import 'package:flutter/material.dart';

class BreathingArtwork extends StatefulWidget {
  final String? imageUrl;
  final double size;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;

  const BreathingArtwork({
    super.key,
    this.imageUrl,
    this.size = 300.0,
    this.isPlaying = false,
    this.duration,
    this.position,
  });

  @override
  State<BreathingArtwork> createState() => _BreathingArtworkState();
}

class _BreathingArtworkState extends State<BreathingArtwork>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController;
  late final AnimationController _parallaxController;
  late final Animation<double> _breathingAnimation;
  late final Animation<Offset> _parallaxAnimation;
  
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  final double _maxTilt = 0.15;

  @override
  void initState() {
    super.initState();
    
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _breathingAnimation = CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    );

    _parallaxAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeOut,
    ));

    _startListening();
    _startBreathing();
  }

  void _startListening() {
    // Simulated sensor data for demo purposes
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _tiltX = (math.Random().nextDouble() - 0.5) * _maxTilt;
          _tiltY = (math.Random().nextDouble() - 0.5) * _maxTilt;
        });
        
        _parallaxController.reset();
        _parallaxController.forward();
      }
    });
  }

  void _startBreathing() {
    if (widget.isPlaying) {
      _breathingController.repeat(reverse: true);
    } else {
      _breathingController.stop();
      _breathingController.reset();
    }
  }

  @override
  void didUpdateWidget(BreathingArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isPlaying != widget.isPlaying) {
      _startBreathing();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  double _getBPM() {
    if (widget.duration != null) {
      return 60.0 + (widget.duration!.inSeconds % 60);
    }
    return 80.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingAnimation, _parallaxAnimation]),
      builder: (context, child) {
        final bpm = _getBPM();
        final breathingScale = 1.0 + 
            (_breathingAnimation.value * 0.05) * 
            (bpm / 80.0);
        
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_tiltX * 0.3)
            ..rotateX(-_tiltY * 0.3)
            ..scale(breathingScale),
          alignment: Alignment.center,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30.0,
                  offset: Offset(_tiltX * 15, _tiltY * 15 + 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 20.0,
                  spreadRadius: -5.0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                children: [
                  // Main artwork
                  if (widget.imageUrl != null)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.shade900,
                              Colors.blue.shade900,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.music_note,
                          color: Colors.white54,
                          size: 80,
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple.shade900,
                            Colors.blue.shade900,
                            Colors.black,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  
                  // Glass overlay effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  
                  // Progress ring around artwork
                  if (widget.duration != null && widget.position != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ProgressRingPainter(
                          progress: widget.position!.inMilliseconds / widget.duration!.inMilliseconds,
                          color: Colors.white.withOpacity(0.8),
                          strokeWidth: 3.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth;
    
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
    
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
    
    if (progress > 0.0) {
      final dotAngle = -math.pi / 2 + sweepAngle;
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);
      
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth * 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
