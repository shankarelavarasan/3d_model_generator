import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:math';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ModelViewportWidget extends StatefulWidget {
  final String modelName;
  final VoidCallback onDoubleTap;
  final Function(Offset) onLongPress;
  final Function(double) onZoom;
  final Function(Offset) onRotate;
  final Function(Offset) onPan;

  const ModelViewportWidget({
    super.key,
    required this.modelName,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onZoom,
    required this.onRotate,
    required this.onPan,
  });

  @override
  State<ModelViewportWidget> createState() => _ModelViewportWidgetState();
}

class _ModelViewportWidgetState extends State<ModelViewportWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _zoomController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _zoomAnimation;

  double _currentZoom = 1.0;
  Offset _currentRotation = Offset.zero;
  Offset _currentPan = Offset.zero;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _zoomAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    _zoomAnimation = Tween<double>(
      begin: _currentZoom,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInOut,
    ));

    _zoomController.reset();
    _zoomController.forward().then((_) {
      setState(() {
        _currentZoom = 1.0;
        _currentRotation = Offset.zero;
        _currentPan = Offset.zero;
        _isAnimating = false;
      });
    });

    HapticFeedback.mediumImpact();
    widget.onDoubleTap();
  }

  void _handleLongPress(LongPressStartDetails details) {
    HapticFeedback.heavyImpact();
    widget.onLongPress(details.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.lightTheme.colorScheme.surface,
            AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: GestureDetector(
        onDoubleTap: _handleDoubleTap,
        onLongPressStart: _handleLongPress,
        onScaleStart: (details) {
          setState(() {
            _isAnimating = false;
          });
        },
        onScaleUpdate: (details) {
          if (_isAnimating) return;

          setState(() {
            // Handle zoom
            double newZoom = _currentZoom * details.scale;
            newZoom = newZoom.clamp(0.5, 3.0);
            if (newZoom != _currentZoom) {
              _currentZoom = newZoom;
              widget.onZoom(_currentZoom);
            }

            // Handle rotation
            if (details.pointerCount == 1) {
              _currentRotation += details.focalPointDelta * 0.01;
              widget.onRotate(_currentRotation);
            }

            // Handle pan
            if (details.pointerCount == 2) {
              _currentPan += details.focalPointDelta;
              widget.onPan(_currentPan);
            }
          });
        },
        child: Stack(
          children: [
            // 3D Model Rendering Area
            Positioned.fill(
              child: AnimatedBuilder(
                animation:
                    Listenable.merge([_rotationAnimation, _zoomAnimation]),
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scale(
                          _isAnimating ? _zoomAnimation.value : _currentZoom)
                      ..rotateX(_currentRotation.dy)
                      ..rotateY(_currentRotation.dx)
                      ..translate(_currentPan.dx, _currentPan.dy),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 80.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                AppTheme.lightTheme.colorScheme.secondary
                                    .withValues(alpha: 0.1),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Wireframe representation
                              CustomPaint(
                                size: Size.infinite,
                                painter: _WireframePainter(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  zoom: _currentZoom,
                                  rotation: _currentRotation,
                                ),
                              ),
                              // Model info overlay
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.modelName,
                                    style: AppTheme
                                        .lightTheme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Loading indicator
            if (_isAnimating)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
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

class _WireframePainter extends CustomPainter {
  final Color color;
  final double zoom;
  final Offset rotation;

  _WireframePainter({
    required this.color,
    required this.zoom,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final baseSize = size.width * 0.3 * zoom;

    // Draw a simple 3D cube wireframe
    final vertices = [
      Offset(-baseSize / 2, -baseSize / 2),
      Offset(baseSize / 2, -baseSize / 2),
      Offset(baseSize / 2, baseSize / 2),
      Offset(-baseSize / 2, baseSize / 2),
      Offset(-baseSize / 3, -baseSize / 3),
      Offset(baseSize / 3, -baseSize / 3),
      Offset(baseSize / 3, baseSize / 3),
      Offset(-baseSize / 3, baseSize / 3),
    ];

    // Apply rotation transformation
    final rotatedVertices = vertices.map((vertex) {
      final x = vertex.dx * math.cos(rotation.dx) - vertex.dy * math.sin(rotation.dx);
      final y = vertex.dx * math.sin(rotation.dx) + vertex.dy * math.cos(rotation.dx);
      return Offset(x, y) + center;
    }).toList();

    // Draw front face
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        rotatedVertices[i],
        rotatedVertices[(i + 1) % 4],
        paint,
      );
    }

    // Draw back face
    for (int i = 4; i < 8; i++) {
      canvas.drawLine(
        rotatedVertices[i],
        rotatedVertices[4 + ((i + 1) % 4)],
        paint,
      );
    }

    // Draw connecting lines
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        rotatedVertices[i],
        rotatedVertices[i + 4],
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}