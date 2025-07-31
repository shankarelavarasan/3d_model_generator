import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TopToolbarWidget extends StatelessWidget {
  final String modelName;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;
  final VoidCallback onSavePressed;
  final VoidCallback onAnnotationsPressed;
  final VoidCallback onInfoPressed;

  const TopToolbarWidget({
    super.key,
    required this.modelName,
    required this.onBackPressed,
    required this.onSharePressed,
    required this.onSavePressed,
    required this.onAnnotationsPressed,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 4.w),

            // Model name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modelName,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Interactive 3D Model',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Row(
              children: [
                // Info button
                GestureDetector(
                  onTap: onInfoPressed,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'info_outline',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),

                // More actions menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'share':
                        onSharePressed();
                        break;
                      case 'save':
                        onSavePressed();
                        break;
                      case 'annotations':
                        onAnnotationsPressed();
                        break;
                    }
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'more_vert',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  color: AppTheme.lightTheme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'share',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Share Model',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'save',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Save to Library',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'annotations',
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'note_add',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Add Annotations',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
