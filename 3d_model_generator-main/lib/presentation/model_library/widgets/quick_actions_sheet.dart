import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsSheet extends StatelessWidget {
  final Map<String, dynamic> model;
  final VoidCallback? onShare;
  final VoidCallback? onExport;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const QuickActionsSheet({
    Key? key,
    required this.model,
    this.onShare,
    this.onExport,
    this.onDuplicate,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          SizedBox(height: 20.h),
          // Model info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                // Model thumbnail
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: AppTheme.lightTheme.colorScheme.surface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CustomImageWidget(
                      imageUrl: model['thumbnail'] as String? ?? '',
                      width: 60.w,
                      height: 60.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Model details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model['name'] as String? ?? 'Untitled Model',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${model['format'] as String? ?? 'STL'} • ${_formatFileSize(model['size'] as int? ?? 0)}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          // Action buttons
          _buildActionButton(
            icon: 'share',
            label: 'Share',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              onShare?.call();
            },
          ),
          _buildActionButton(
            icon: 'file_download',
            label: 'Export',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              onExport?.call();
            },
          ),
          _buildActionButton(
            icon: 'content_copy',
            label: 'Duplicate',
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              onDuplicate?.call();
            },
          ),
          _buildActionButton(
            icon: 'delete',
            label: 'Delete',
            isDestructive: true,
            onTap: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isDestructive
                  ? AppTheme.errorLight
                  : AppTheme.textPrimaryLight,
              size: 24.0,
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: isDestructive
                    ? AppTheme.errorLight
                    : AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Model',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${model['name']}"? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorLight,
              ),
              child: Text(
                'Delete',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
