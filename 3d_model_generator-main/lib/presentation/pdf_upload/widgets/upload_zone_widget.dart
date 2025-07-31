import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UploadZoneWidget extends StatelessWidget {
  final String title;
  final String? fileName;
  final String? fileSize;
  final VoidCallback onTap;
  final VoidCallback? onReplace;
  final VoidCallback? onRemove;
  final bool hasFile;

  const UploadZoneWidget({
    super.key,
    required this.title,
    this.fileName,
    this.fileSize,
    required this.onTap,
    this.onReplace,
    this.onRemove,
    this.hasFile = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: hasFile ? _showTooltip : null,
      child: Container(
        width: double.infinity,
        height: 20.h,
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: hasFile
              ? AppTheme.lightTheme.colorScheme.primaryContainer
              : AppTheme.lightTheme.colorScheme.surface,
          border: Border.all(
            color: hasFile
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline,
            width: hasFile ? 2.0 : 1.5,
            style: hasFile ? BorderStyle.solid : BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: hasFile ? _buildFilePreview() : _buildEmptyState(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'add',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 6.w,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Tap to select PDF file',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: CustomIconWidget(
                      iconName: 'picture_as_pdf',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          fileName ?? 'Unknown file',
                          style: AppTheme.lightTheme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (fileSize != null) ...[
                          SizedBox(height: 0.5.h),
                          Text(
                            fileSize!,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              Row(
                children: [
                  if (onReplace != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReplace,
                        icon: CustomIconWidget(
                          iconName: 'refresh',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                        label: Text('Replace'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                        ),
                      ),
                    ),
                  if (onReplace != null && onRemove != null)
                    SizedBox(width: 2.w),
                  if (onRemove != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onRemove,
                        icon: CustomIconWidget(
                          iconName: 'delete_outline',
                          color: AppTheme.lightTheme.colorScheme.error,
                          size: 4.w,
                        ),
                        label: Text('Remove'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                          side: BorderSide(
                            color: AppTheme.lightTheme.colorScheme.error,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 2.w,
          right: 2.w,
          child: Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'check',
              color: Colors.white,
              size: 3.w,
            ),
          ),
        ),
      ],
    );
  }

  void _showTooltip() {
    // This would show a tooltip explaining view requirements
    // Implementation would depend on the specific tooltip system used
  }
}
