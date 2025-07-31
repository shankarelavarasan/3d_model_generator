import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ModelStatisticsWidget extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onClose;

  const ModelStatisticsWidget({
    super.key,
    required this.isVisible,
    required this.onClose,
  });

  @override
  State<ModelStatisticsWidget> createState() => _ModelStatisticsWidgetState();
}

class _ModelStatisticsWidgetState extends State<ModelStatisticsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Mock statistics data
  final Map<String, dynamic> _statistics = {
    'volume': 1247.8,
    'surfaceArea': 892.3,
    'boundingBox': {
      'width': 45.2,
      'height': 32.8,
      'depth': 18.5,
    },
    'vertices': 2847,
    'faces': 5694,
    'materials': 3,
    'complexity': 'Medium',
    'fileSize': '2.4 MB',
    'lastModified': '2025-01-25 17:20:42',
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(ModelStatisticsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _fadeController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _fadeController.reverse();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Positioned(
        top: 20.h,
        right: 4.w,
        child: Container(
          width: 70.w,
          constraints: BoxConstraints(maxHeight: 60.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'analytics',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Model Statistics',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Statistics content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      // Physical properties
                      _buildStatisticsSection(
                        'Physical Properties',
                        [
                          _buildStatItem('Volume',
                              '${_statistics['volume']} cm³', 'inventory'),
                          _buildStatItem('Surface Area',
                              '${_statistics['surfaceArea']} cm²', 'crop_free'),
                          _buildStatItem(
                              'Complexity', _statistics['complexity'], 'tune'),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // Dimensions
                      _buildStatisticsSection(
                        'Bounding Box',
                        [
                          _buildStatItem(
                              'Width',
                              '${(_statistics['boundingBox'] as Map)['width']} mm',
                              'straighten'),
                          _buildStatItem(
                              'Height',
                              '${(_statistics['boundingBox'] as Map)['height']} mm',
                              'height'),
                          _buildStatItem(
                              'Depth',
                              '${(_statistics['boundingBox'] as Map)['depth']} mm',
                              'view_in_ar'),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // Mesh properties
                      _buildStatisticsSection(
                        'Mesh Properties',
                        [
                          _buildStatItem('Vertices',
                              '${_statistics['vertices']}', 'scatter_plot'),
                          _buildStatItem(
                              'Faces', '${_statistics['faces']}', 'category'),
                          _buildStatItem('Materials',
                              '${_statistics['materials']}', 'palette'),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // File properties
                      _buildStatisticsSection(
                        'File Properties',
                        [
                          _buildStatItem(
                              'File Size', _statistics['fileSize'], 'storage'),
                          _buildStatItem('Last Modified',
                              _statistics['lastModified'], 'schedule'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, String iconName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
