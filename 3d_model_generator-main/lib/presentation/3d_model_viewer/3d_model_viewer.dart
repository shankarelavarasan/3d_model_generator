import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/control_panel_widget.dart';
import './widgets/cross_section_widget.dart';
import './widgets/export_fab_widget.dart';
import './widgets/measurement_overlay_widget.dart';
import './widgets/model_statistics_widget.dart';
import './widgets/model_viewport_widget.dart';
import './widgets/top_toolbar_widget.dart';

class ThreeDModelViewer extends StatefulWidget {
  const ThreeDModelViewer({super.key});

  @override
  State<ThreeDModelViewer> createState() => _ThreeDModelViewerState();
}

class _ThreeDModelViewerState extends State<ThreeDModelViewer>
    with TickerProviderStateMixin {
  // Mock model data
  final Map<String, dynamic> _modelData = {
    'name': 'Mechanical_Part_v2.3d',
    'type': 'Engineering Component',
    'createdDate': '2025-01-25',
    'fileSize': '2.4 MB',
    'originalPdf': 'technical_drawing_001.pdf',
  };

  // UI state variables
  bool _isMeasurementActive = false;
  bool _isCrossSectionVisible = false;
  bool _isStatisticsVisible = false;
  List<Offset> _measurementPoints = [];

  // 3D model state
  double _currentZoom = 1.0;
  Offset _currentRotation = Offset.zero;
  Offset _currentPan = Offset.zero;
  String _currentViewPreset = 'Isometric';
  double _ambientLight = 0.6;
  double _directionalLight = 0.8;
  double _crossSectionPosition = 0.5;

  @override
  void initState() {
    super.initState();
    // Set full screen mode for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _handleBackPressed() {
    Navigator.pop(context);
  }

  void _handleExportPressed() {
    Navigator.pushNamed(context, '/export-options');
  }

  void _handleSharePressed() {
    // Mock share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${_modelData['name']}...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSavePressed() {
    // Mock save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Model saved to library'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAnnotationsPressed() {
    // Mock annotations functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Annotations feature coming soon'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleInfoPressed() {
    setState(() {
      _isStatisticsVisible = !_isStatisticsVisible;
    });
  }

  void _handleDoubleTap() {
    // Reset view to default
    setState(() {
      _currentZoom = 1.0;
      _currentRotation = Offset.zero;
      _currentPan = Offset.zero;
    });

    HapticFeedback.mediumImpact();
  }

  void _handleLongPress(Offset position) {
    if (_isMeasurementActive) {
      setState(() {
        _measurementPoints.add(position);
        // Limit to 10 measurement points
        if (_measurementPoints.length > 10) {
          _measurementPoints.removeAt(0);
        }
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _handleZoom(double zoom) {
    setState(() {
      _currentZoom = zoom;
    });
  }

  void _handleRotate(Offset rotation) {
    setState(() {
      _currentRotation = rotation;
    });
  }

  void _handlePan(Offset pan) {
    setState(() {
      _currentPan = pan;
    });
  }

  void _handleViewPresetChanged(String preset) {
    setState(() {
      _currentViewPreset = preset;
    });

    // Mock view preset change with haptic feedback
    HapticFeedback.selectionClick();

    // Show preset change feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View changed to $preset'),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleAmbientLightChanged(double value) {
    setState(() {
      _ambientLight = value;
    });
  }

  void _handleDirectionalLightChanged(double value) {
    setState(() {
      _directionalLight = value;
    });
  }

  void _handleMeasurementToggle() {
    setState(() {
      _isMeasurementActive = !_isMeasurementActive;
      if (!_isMeasurementActive) {
        _measurementPoints.clear();
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _handleMeasurementPointAdded(Offset point) {
    setState(() {
      _measurementPoints.add(point);
      // Limit to 10 measurement points
      if (_measurementPoints.length > 10) {
        _measurementPoints.removeAt(0);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _handleClearMeasurementPoints() {
    setState(() {
      _measurementPoints.clear();
    });
    HapticFeedback.mediumImpact();
  }

  void _handleCrossSectionToggle() {
    setState(() {
      _isCrossSectionVisible = !_isCrossSectionVisible;
    });
  }

  void _handleCrossSectionPositionChanged(double position) {
    setState(() {
      _crossSectionPosition = position;
    });
  }

  void _handleStatisticsClose() {
    setState(() {
      _isStatisticsVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      body: Stack(
        children: [
          // Main 3D model viewport
          ModelViewportWidget(
            modelName: _modelData['name'],
            onDoubleTap: _handleDoubleTap,
            onLongPress: _handleLongPress,
            onZoom: _handleZoom,
            onRotate: _handleRotate,
            onPan: _handlePan,
          ),

          // Measurement overlay
          MeasurementOverlayWidget(
            measurementPoints: _measurementPoints,
            onPointAdded: _handleMeasurementPointAdded,
            onClearPoints: _handleClearMeasurementPoints,
            isActive: _isMeasurementActive,
          ),

          // Top toolbar with translucent overlay
          TopToolbarWidget(
            modelName: _modelData['name'],
            onBackPressed: _handleBackPressed,
            onSharePressed: _handleSharePressed,
            onSavePressed: _handleSavePressed,
            onAnnotationsPressed: _handleAnnotationsPressed,
            onInfoPressed: _handleInfoPressed,
          ),

          // Export floating action button
          ExportFabWidget(
            onExportPressed: _handleExportPressed,
          ),

          // Bottom control panel
          ControlPanelWidget(
            onViewPresetChanged: _handleViewPresetChanged,
            onAmbientLightChanged: _handleAmbientLightChanged,
            onDirectionalLightChanged: _handleDirectionalLightChanged,
            onMeasurementToggle: _handleMeasurementToggle,
            isMeasurementActive: _isMeasurementActive,
          ),

          // Cross-section control panel
          CrossSectionWidget(
            isVisible: _isCrossSectionVisible,
            onPlanePositionChanged: _handleCrossSectionPositionChanged,
            onToggleVisibility: _handleCrossSectionToggle,
          ),

          // Model statistics overlay
          ModelStatisticsWidget(
            isVisible: _isStatisticsVisible,
            onClose: _handleStatisticsClose,
          ),

          // Cross-section toggle button
          Positioned(
            left: 4.w,
            top: 30.h,
            child: FloatingActionButton.small(
              onPressed: _handleCrossSectionToggle,
              backgroundColor: _isCrossSectionVisible
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.surface,
              foregroundColor: _isCrossSectionVisible
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.onSurface,
              elevation: 4,
              child: CustomIconWidget(
                iconName: 'content_cut',
                color: _isCrossSectionVisible
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),

          // Performance indicator (60fps target)
          Positioned(
            bottom: 2.h,
            left: 4.w,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.successLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '60 FPS',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
