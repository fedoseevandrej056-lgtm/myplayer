import 'dart:math' as math;
import 'package:flutter/material.dart';

class ElasticScrubber extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onSeek;
  final Color color;

  const ElasticScrubber({
    Key? key,
    required this.duration,
    required this.position,
    required this.onSeek,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  State<ElasticScrubber> createState() => _ElasticScrubberState();
}

class _ElasticScrubberState extends State<ElasticScrubber>
    with TickerProviderStateMixin {
  late final AnimationController _elasticController;
  late final AnimationController _waggleController;
  late final Animation<double> _elasticAnimation;
  late final Animation<double> _waggleAnimation;
  
  double _dragValue = 0.0;
  bool _isDragging = false;
  double _elasticity = 1.0;
  double _waggleAmount = 0.0;

  @override
  void initState() {
    super.initState();
    
    _elasticController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _waggleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _elasticAnimation = CurvedAnimation(
      parent: _elasticController,
      curve: Curves.elasticOut,
    );

    _waggleAnimation = CurvedAnimation(
      parent: _waggleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _elasticController.dispose();
    _waggleController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _elasticity = 1.5; // Stretch when grabbed
    });
    _elasticController.forward();
  }

  void _onDragUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    final double newValue = (details.localPosition.dx / constraints.maxWidth)
        .clamp(0.0, 1.0);
    
    setState(() {
      _dragValue = newValue;
      _elasticity = 1.2 + (details.primaryDelta!?.abs() ?? 0.0) * 0.01;
    });

    final newPosition = Duration(
      milliseconds: (widget.duration.inMilliseconds * newValue).round(),
    );
    widget.onSeek(newPosition);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _elasticity = 1.0;
    });
    
    _elasticController.reverse();
    
    // Add waggle effect based on velocity
    final velocity = details.primaryVelocity?.abs() ?? 0.0;
    if (velocity > 500) {
      _waggleAmount = math.min(velocity / 1000.0, 0.3);
      _waggleController.forward().then((_) {
        _waggleController.reverse();
      });
    }
  }

  double _getProgressValue() {
    if (widget.duration.inMilliseconds == 0) return 0.0;
    return widget.position.inMilliseconds / widget.duration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final progress = _isDragging ? _dragValue : _getProgressValue();
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              // Time labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(widget.position),
                    style: TextStyle(
                      color: widget.color.withOpacity(0.7),
                      fontSize: 12.0,
                    ),
                  ),
                  Text(
                    _formatDuration(widget.duration),
                    style: TextStyle(
                      color: widget.color.withOpacity(0.7),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              
              // Elastic scrubber
              AnimatedBuilder(
                animation: Listenable.merge([_elasticAnimation, _waggleAnimation]),
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(constraints.maxWidth - 40.0, 40.0),
                    painter: ElasticScrubberPainter(
                      progress: progress,
                      elasticity: _elasticity,
                      waggleAmount: _waggleAmount * _waggleAnimation.value,
                      color: widget.color,
                      isDragging: _isDragging,
                    ),
                    child: GestureDetector(
                      onPanStart: _onDragStart,
                      onPanUpdate: (details) => _onDragUpdate(details, constraints),
                      onPanEnd: _onDragEnd,
                      onTapDown: (details) {
                        final tapValue = details.localPosition.dx / constraints.maxWidth;
                        final newPosition = Duration(
                          milliseconds: (widget.duration.inMilliseconds * tapValue).round(),
                        );
                        widget.onSeek(newPosition);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class ElasticScrubberPainter extends CustomPainter {
  final double progress;
  final double elasticity;
  final double waggleAmount;
  final Color color;
  final bool isDragging;

  ElasticScrubberPainter({
    required this.progress,
    required this.elasticity,
    required this.waggleAmount,
    required this.color,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final trackHeight = isDragging ? 6.0 * elasticity : 4.0;
    
    // Draw background track with blur
    final bgPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, centerY),
        width: size.width,
        height: trackHeight,
      ),
      Radius.circular(trackHeight / 2),
    );
    
    canvas.drawRRect(bgRect, bgPaint);
    
    // Draw progress track with elastic effect
    final progressWidth = size.width * progress;
    final elasticProgress = progressWidth * (1.0 + (elasticity - 1.0) * 0.3);
    
    // Create gradient for progress
    final progressGradient = LinearGradient(
      colors: [
        color.withOpacity(0.8),
        color,
        color.withOpacity(0.9),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    final progressPaint = Paint()
      ..shader = progressGradient.createShader(
        Rect.fromCenter(
          center: Offset(elasticProgress / 2, centerY),
          width: elasticProgress,
          height: trackHeight * elasticity,
        ),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
    
    final progressRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(elasticProgress / 2, centerY),
        width: elasticProgress,
        height: trackHeight * elasticity,
      ),
      Radius.circular(trackHeight * elasticity / 2),
    );
    
    canvas.drawRRect(progressRect, progressPaint);
    
    // Draw elastic thumb with waggle
    final thumbX = elasticProgress + waggleAmount * math.sin(DateTime.now().millisecondsSinceEpoch * 0.01);
    final thumbSize = isDragging ? 16.0 * elasticity : 12.0;
    
    // Thumb glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    
    canvas.drawCircle(
      Offset(thumbX, centerY),
      thumbSize * 1.5,
      glowPaint,
    );
    
    // Main thumb
    final thumbPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(thumbX, centerY),
      thumbSize,
      thumbPaint,
    );
    
    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(thumbX - thumbSize * 0.2, centerY - thumbSize * 0.2),
      thumbSize * 0.3,
      highlightPaint,
    );
    
    // Draw elastic strands when dragging
    if (isDragging) {
      final strandPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      for (int i = 0; i < 3; i++) {
        final strandX = thumbX - (i + 1) * 10.0;
        final strandHeight = trackHeight * elasticity * (0.5 + i * 0.2);
        final waveOffset = math.sin(DateTime.now().millisecondsSinceEpoch * 0.02 + i) * 2.0;
        
        final path = Path();
        path.moveTo(strandX, centerY - strandHeight / 2);
        path.quadraticBezierTo(
          strandX - 5.0 + waveOffset,
          centerY,
          strandX,
          centerY + strandHeight / 2,
        );
        
        canvas.drawPath(path, strandPaint);
      }
    }
  }

  @override
  bool shouldRepaint(ElasticScrubberPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.elasticity != elasticity ||
           oldDelegate.waggleAmount != waggleAmount ||
           oldDelegate.isDragging != isDragging;
  }
}
