import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final TextEditingController? controller;

  const SearchBarWidget({
    Key? key,
    this.hintText,
    this.onChanged,
    this.onFilterTap,
    this.controller,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.textSecondaryLight,
              size: 20.0,
            ),
          ),
          // Search input
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search models...',
                hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryLight.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 14.0,
                ),
              ),
              onChanged: widget.onChanged,
            ),
          ),
          // Clear button (when text exists)
          if (_hasText)
            GestureDetector(
              onTap: _clearSearch,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CustomIconWidget(
                  iconName: 'clear',
                  color: AppTheme.textSecondaryLight,
                  size: 20.0,
                ),
              ),
            ),
          // Filter button
          GestureDetector(
            onTap: widget.onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.only(right: 4.0),
              child: CustomIconWidget(
                iconName: 'filter_list',
                color: AppTheme.primaryLight,
                size: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
