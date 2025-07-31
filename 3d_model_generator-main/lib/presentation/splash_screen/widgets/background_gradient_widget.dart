import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BackgroundGradientWidget extends StatefulWidget {
  const BackgroundGradientWidget({super.key});

  @override
  State<BackgroundGradientWidget> createState() =>
      _BackgroundGradientWidgetState();
}

class _BackgroundGradientWidgetState extends State<BackgroundGradientWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + (_gradientAnimation.value * 0.2),
                0.7 + (_gradientAnimation.value * 0.2),
                1.0,
              ],
              colors: [
                AppTheme.lightTheme.colorScheme.primary,
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.9),
                AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.8),
                AppTheme.lightTheme.colorScheme.secondary,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Geometric pattern overlay
              Positioned(
                top: 10.h,
                right: -5.w,
                child: Opacity(
                  opacity: 0.1 * _gradientAnimation.value,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 15.h,
                left: -10.w,
                child: Opacity(
                  opacity: 0.08 * _gradientAnimation.value,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      width: 35.w,
                      height: 35.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              // Grid pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05 * _gradientAnimation.value,
                  child: CustomPaint(
                    painter: GridPatternPainter(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const double spacing = 40.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
