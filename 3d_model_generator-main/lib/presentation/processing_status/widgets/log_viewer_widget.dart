import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LogViewerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> logs;
  final bool isExpanded;
  final VoidCallback onToggle;

  const LogViewerWidget({
    super.key,
    required this.logs,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<LogViewerWidget> createState() => _LogViewerWidgetState();
}

class _LogViewerWidgetState extends State<LogViewerWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(LogViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length > oldWidget.logs.length && widget.isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getLogColor(String level) {
    switch (level.toLowerCase()) {
      case 'info':
        return AppTheme.lightTheme.primaryColor;
      case 'warning':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'error':
        return AppTheme.lightTheme.colorScheme.error;
      case 'success':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getLogIcon(String level) {
    switch (level.toLowerCase()) {
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'terminal',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Processing Log',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${widget.logs.length} entries',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: widget.isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 6.w,
                  ),
                ],
              ),
            ),
          ),
          if (widget.isExpanded) ...[
            Divider(
              height: 1,
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
            Container(
              height: 30.h,
              padding: EdgeInsets.all(4.w),
              child: widget.logs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'hourglass_empty',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                            size: 8.w,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Waiting for processing to begin...',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      itemCount: widget.logs.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 1.h),
                      itemBuilder: (context, index) {
                        final log = widget.logs[index];
                        final level = (log['level'] as String?) ?? 'info';
                        final message = (log['message'] as String?) ?? '';
                        final timestamp = (log['timestamp'] as String?) ?? '';

                        return Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: _getLogColor(level).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getLogColor(level).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _getLogIcon(level),
                                color: _getLogColor(level),
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          level.toUpperCase(),
                                          style: AppTheme.getMonospaceStyle(
                                            isLight: true,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                          ).copyWith(
                                            color: _getLogColor(level),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          timestamp,
                                          style: AppTheme.getMonospaceStyle(
                                            isLight: true,
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w400,
                                          ).copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      message,
                                      style: AppTheme.getMonospaceStyle(
                                        isLight: true,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400,
                                      ).copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
