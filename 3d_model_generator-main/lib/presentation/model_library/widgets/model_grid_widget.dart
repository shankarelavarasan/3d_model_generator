import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './model_card_widget.dart';

class ModelGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> models;
  final Function(Map<String, dynamic>)? onModelTap;
  final Function(Map<String, dynamic>)? onModelLongPress;
  final bool isLoading;
  final VoidCallback? onLoadMore;

  const ModelGridWidget({
    Key? key,
    required this.models,
    this.onModelTap,
    this.onModelLongPress,
    this.isLoading = false,
    this.onLoadMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            onLoadMore != null &&
            !isLoading) {
          onLoadMore!();
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.75,
        ),
        itemCount: models.length + (isLoading ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= models.length) {
            return _buildSkeletonCard();
          }

          final model = models[index];
          return ModelCardWidget(
            model: model,
            onTap: () => onModelTap?.call(model),
            onLongPress: () => onModelLongPress?.call(model),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton thumbnail
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'image',
                  color: AppTheme.textSecondaryLight.withValues(alpha: 0.3),
                  size: 40.0,
                ),
              ),
            ),
          ),
          // Skeleton details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton title
                  Container(
                    height: 16.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Skeleton date
                  Container(
                    height: 12.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // Skeleton badges
                  Row(
                    children: [
                      Container(
                        height: 20.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 16.h,
                        width: 16.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ],
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
