import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>)? onFiltersChanged;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilters,
    this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _filters;
  bool _formatExpanded = true;
  bool _dateExpanded = false;
  bool _statusExpanded = false;

  final List<String> _formats = ['STL', 'GLB', 'FBX', 'IGES', 'STEP'];
  final List<String> _dateRanges = [
    'Today',
    'This Week',
    'This Month',
    'This Year'
  ];
  final List<String> _statuses = ['Completed', 'Processing', 'Failed'];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

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
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Text(
                  'Filter Models',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // Filter sections
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFilterSection(
                    title: 'File Format',
                    isExpanded: _formatExpanded,
                    onToggle: () =>
                        setState(() => _formatExpanded = !_formatExpanded),
                    child: _buildFormatFilters(),
                  ),
                  _buildFilterSection(
                    title: 'Creation Date',
                    isExpanded: _dateExpanded,
                    onToggle: () =>
                        setState(() => _dateExpanded = !_dateExpanded),
                    child: _buildDateFilters(),
                  ),
                  _buildFilterSection(
                    title: 'Status',
                    isExpanded: _statusExpanded,
                    onToggle: () =>
                        setState(() => _statusExpanded = !_statusExpanded),
                    child: _buildStatusFilters(),
                  ),
                ],
              ),
            ),
          ),
          // Apply button
          Padding(
            padding: EdgeInsets.all(24.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                child: Text(
                  'Apply Filters',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Row(
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: isExpanded ? 'expand_less' : 'expand_more',
                  color: AppTheme.textSecondaryLight,
                  size: 24.0,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) child,
        Divider(
          color: AppTheme.borderLight,
          height: 1.h,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget _buildFormatFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _formats.map((format) {
          final isSelected =
              (_filters['formats'] as List<String>? ?? []).contains(format);
          return FilterChip(
            label: Text(format),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                final formats = List<String>.from(_filters['formats'] ?? []);
                if (selected) {
                  formats.add(format);
                } else {
                  formats.remove(format);
                }
                _filters['formats'] = formats;
              });
            },
            selectedColor: AppTheme.lightTheme.colorScheme.primaryContainer,
            checkmarkColor: AppTheme.primaryLight,
            labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? AppTheme.primaryLight
                  : AppTheme.textSecondaryLight,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        children: _dateRanges.map((dateRange) {
          final isSelected = _filters['dateRange'] == dateRange;
          return RadioListTile<String>(
            title: Text(
              dateRange,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            value: dateRange,
            groupValue: _filters['dateRange'] as String?,
            onChanged: (value) {
              setState(() {
                _filters['dateRange'] = value;
              });
            },
            activeColor: AppTheme.primaryLight,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Column(
        children: _statuses.map((status) {
          final isSelected =
              (_filters['statuses'] as List<String>? ?? []).contains(status);
          return CheckboxListTile(
            title: Text(
              status,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            value: isSelected,
            onChanged: (checked) {
              setState(() {
                final statuses = List<String>.from(_filters['statuses'] ?? []);
                if (checked == true) {
                  statuses.add(status);
                } else {
                  statuses.remove(status);
                }
                _filters['statuses'] = statuses;
              });
            },
            activeColor: AppTheme.primaryLight,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged?.call(_filters);
    Navigator.pop(context);
  }
}
