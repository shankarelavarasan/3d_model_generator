import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';

class MeasurementOverlayWidget extends StatefulWidget {
  final List<Offset> measurementPoints;
  final Function(Offset) onPointAdded;
  final VoidCallback onClearPoints;
  final bool isActive;

  const MeasurementOverlayWidget({
    super.key,
    required this.measurementPoints,
    required this.onPointAdded,
    required this.onClearPoints,
    required this.isActive,
  });

  @override
  State<MeasurementOverlayWidget> createState() =>
      _MeasurementOverlayWidgetState();
}

class _MeasurementOverlayWidgetState extends State<MeasurementOverlayWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MeasurementOverlayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  double _calculateDistance(Offset point1, Offset point2) {
    final dx = point2.dx - point1.dx;
    final dy = point2.dy - point1.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  String _formatDistance(double distance) {
    // Convert pixels to approximate millimeters (mock conversion)
    final mm = distance * 0.5;
    if (mm < 10) {
      return '${mm.toStringAsFixed(1)} mm';
    } else if (mm < 1000) {
      return '${mm.toStringAsFixed(0)} mm';
    } else {
      return '${(mm / 1000).toStringAsFixed(2)} m';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        onTapDown: (details) {
          if (widget.isActive) {
            widget.onPointAdded(details.localPosition);
          }
        },
        child: CustomPaint(
          painter: _MeasurementPainter(
            points: widget.measurementPoints,
            pulseAnimation: _pulseAnimation,
            formatDistance: _formatDistance,
            calculateDistance: _calculateDistance,
          ),
          child: Stack(
            children: [
              // Instructions overlay
              if (widget.measurementPoints.isEmpty)
                Positioned(
                  top: 25.h,
                  left: 4.w,
                  right: 4.w,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              CustomIconWidget(
                                iconName: 'touch_app',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap on the model to place measurement points',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Two points will show distance',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Clear button
              if (widget.measurementPoints.isNotEmpty)
                Positioned(
                  bottom: 25.h,
                  right: 4.w,
                  child: FloatingActionButton.small(
                    onPressed: widget.onClearPoints,
                    backgroundColor: AppTheme.errorLight,
                    foregroundColor: Colors.white,
                    child: CustomIconWidget(
                      iconName: 'clear',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementPainter extends CustomPainter {
  final List<Offset> points;
  final Animation<double> pulseAnimation;
  final String Function(double) formatDistance;
  final double Function(Offset, Offset) calculateDistance;

  _MeasurementPainter({
    required this.points,
    required this.pulseAnimation,
    required this.formatDistance,
    required this.calculateDistance,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dashedLinePaint = Paint()
      ..color = AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw measurement points
    for (int i = 0; i < points.length; i++) {
      final point = points[i];

      // Draw point circle
      canvas.drawCircle(
        point,
        6.0 * pulseAnimation.value,
        pointPaint,
      );

      // Draw point border
      canvas.drawCircle(
        point,
        6.0 * pulseAnimation.value,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      // Draw point number
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          point.dx - textPainter.width / 2,
          point.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw lines and measurements between consecutive points
    for (int i = 0; i < points.length - 1; i++) {
      final point1 = points[i];
      final point2 = points[i + 1];

      // Draw line
      canvas.drawLine(point1, point2, linePaint);

      // Calculate and draw distance
      final distance = calculateDistance(point1, point2);
      final midPoint = Offset(
        (point1.dx + point2.dx) / 2,
        (point1.dy + point2.dy) / 2,
      );

      // Draw measurement background
      final measurementText = formatDistance(distance);
      final textPainter = TextPainter(
        text: TextSpan(
          text: measurementText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final textRect = Rect.fromCenter(
        center: midPoint,
        width: textPainter.width + 12,
        height: textPainter.height + 8,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(textRect, const Radius.circular(6)),
        Paint()..color = AppTheme.lightTheme.colorScheme.primary,
      );

      textPainter.paint(
        canvas,
        Offset(
          midPoint.dx - textPainter.width / 2,
          midPoint.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}