import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ControlPanelWidget extends StatefulWidget {
  final Function(String) onViewPresetChanged;
  final Function(double) onAmbientLightChanged;
  final Function(double) onDirectionalLightChanged;
  final VoidCallback onMeasurementToggle;
  final bool isMeasurementActive;

  const ControlPanelWidget({
    super.key,
    required this.onViewPresetChanged,
    required this.onAmbientLightChanged,
    required this.onDirectionalLightChanged,
    required this.onMeasurementToggle,
    required this.isMeasurementActive,
  });

  @override
  State<ControlPanelWidget> createState() => _ControlPanelWidgetState();
}

class _ControlPanelWidgetState extends State<ControlPanelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  bool _isExpanded = false;
  String _selectedPreset = 'Isometric';
  double _ambientLight = 0.6;
  double _directionalLight = 0.8;

  final List<Map<String, dynamic>> _viewPresets = [
    {'name': 'Front', 'icon': 'view_in_ar'},
    {'name': 'Top', 'icon': 'keyboard_arrow_up'},
    {'name': 'Side', 'icon': 'view_sidebar'},
    {'name': 'Isometric', 'icon': 'view_in_ar_outlined'},
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toggle button
          GestureDetector(
            onTap: _togglePanel,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: _isExpanded
                        ? 'keyboard_arrow_down'
                        : 'keyboard_arrow_up',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Controls',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Control panel content
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // View presets section
                    _buildSectionTitle('View Presets'),
                    SizedBox(height: 2.h),
                    _buildViewPresets(),
                    SizedBox(height: 3.h),

                    // Lighting controls section
                    _buildSectionTitle('Lighting Controls'),
                    SizedBox(height: 2.h),
                    _buildLightingControls(),
                    SizedBox(height: 3.h),

                    // Measurement tools section
                    _buildSectionTitle('Tools'),
                    SizedBox(height: 2.h),
                    _buildMeasurementTools(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildViewPresets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _viewPresets.map((preset) {
        final isSelected = _selectedPreset == preset['name'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedPreset = preset['name'];
              });
              widget.onViewPresetChanged(preset['name']);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: preset['icon'],
                    color: isSelected
                        ? Colors.white
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset['name'],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLightingControls() {
    return Column(
      children: [
        // Ambient light control
        Row(
          children: [
            CustomIconWidget(
              iconName: 'wb_sunny',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Ambient',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Slider(
                value: _ambientLight,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    _ambientLight = value;
                  });
                  widget.onAmbientLightChanged(value);
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                inactiveColor: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            Text(
              '${(_ambientLight * 100).round()}%',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
        SizedBox(height: 1.h),
        // Directional light control
        Row(
          children: [
            CustomIconWidget(
              iconName: 'highlight',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Directional',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Slider(
                value: _directionalLight,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    _directionalLight = value;
                  });
                  widget.onDirectionalLightChanged(value);
                },
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                inactiveColor: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            Text(
              '${(_directionalLight * 100).round()}%',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeasurementTools() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onMeasurementToggle,
            icon: CustomIconWidget(
              iconName:
                  widget.isMeasurementActive ? 'straighten' : 'straighten',
              color: widget.isMeasurementActive
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.primary,
              size: 18,
            ),
            label: Text(
              widget.isMeasurementActive ? 'Stop Measuring' : 'Start Measuring',
              style: TextStyle(
                color: widget.isMeasurementActive
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isMeasurementActive
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.surface,
              foregroundColor: widget.isMeasurementActive
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.primary,
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 1.5,
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
