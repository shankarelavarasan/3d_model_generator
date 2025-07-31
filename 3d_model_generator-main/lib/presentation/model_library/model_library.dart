import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/model_grid_widget.dart';
import './widgets/quick_actions_sheet.dart';
import './widgets/search_bar_widget.dart';

class ModelLibrary extends StatefulWidget {
  const ModelLibrary({Key? key}) : super(key: key);

  @override
  State<ModelLibrary> createState() => _ModelLibraryState();
}

class _ModelLibraryState extends State<ModelLibrary>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isRefreshing = false;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};

  // Mock data for 3D models
  final List<Map<String, dynamic>> _allModels = [
    {
      "id": 1,
      "name": "Engine Block Assembly",
      "thumbnail":
          "https://images.pexels.com/photos/159298/gears-cogs-machine-machinery-159298.jpeg",
      "format": "STL",
      "size": 2048576,
      "status": "completed",
      "createdAt": "2025-01-24T10:30:00Z",
      "category": "Mechanical",
      "dimensions": "150x100x80mm"
    },
    {
      "id": 2,
      "name": "Gear Housing",
      "thumbnail":
          "https://images.pexels.com/photos/1108101/pexels-photo-1108101.jpeg",
      "format": "GLB",
      "size": 1536000,
      "status": "processing",
      "createdAt": "2025-01-23T14:15:00Z",
      "category": "Mechanical",
      "dimensions": "80x80x40mm"
    },
    {
      "id": 3,
      "name": "Bracket Mount",
      "thumbnail":
          "https://images.pexels.com/photos/162553/keys-workshop-mechanic-tools-162553.jpeg",
      "format": "FBX",
      "size": 3072000,
      "status": "completed",
      "createdAt": "2025-01-22T09:45:00Z",
      "category": "Structural",
      "dimensions": "120x60x20mm"
    },
    {
      "id": 4,
      "name": "Valve Assembly",
      "thumbnail":
          "https://images.pexels.com/photos/1108572/pexels-photo-1108572.jpeg",
      "format": "STEP",
      "size": 4096000,
      "status": "failed",
      "createdAt": "2025-01-21T16:20:00Z",
      "category": "Mechanical",
      "dimensions": "90x90x120mm"
    },
    {
      "id": 5,
      "name": "Connector Plate",
      "thumbnail":
          "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg",
      "format": "IGES",
      "size": 1024000,
      "status": "completed",
      "createdAt": "2025-01-20T11:10:00Z",
      "category": "Structural",
      "dimensions": "200x100x15mm"
    },
    {
      "id": 6,
      "name": "Motor Housing",
      "thumbnail":
          "https://images.pexels.com/photos/257736/pexels-photo-257736.jpeg",
      "format": "STL",
      "size": 2560000,
      "status": "completed",
      "createdAt": "2025-01-19T13:30:00Z",
      "category": "Mechanical",
      "dimensions": "180x120x100mm"
    }
  ];

  List<Map<String, dynamic>> _filteredModels = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _filteredModels = List.from(_allModels);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredModels = _allModels.where((model) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final name = (model['name'] as String).toLowerCase();
          final category = (model['category'] as String).toLowerCase();
          final query = _searchQuery.toLowerCase();
          if (!name.contains(query) && !category.contains(query)) {
            return false;
          }
        }

        // Format filter
        final formats = _activeFilters['formats'] as List<String>?;
        if (formats != null && formats.isNotEmpty) {
          if (!formats.contains(model['format'])) {
            return false;
          }
        }

        // Status filter
        final statuses = _activeFilters['statuses'] as List<String>?;
        if (statuses != null && statuses.isNotEmpty) {
          final modelStatus = (model['status'] as String).toLowerCase();
          final hasMatchingStatus =
              statuses.any((status) => status.toLowerCase() == modelStatus);
          if (!hasMatchingStatus) {
            return false;
          }
        }

        // Date filter
        final dateRange = _activeFilters['dateRange'] as String?;
        if (dateRange != null) {
          final createdAt = DateTime.parse(model['createdAt'] as String);
          final now = DateTime.now();

          switch (dateRange) {
            case 'Today':
              if (!_isSameDay(createdAt, now)) return false;
              break;
            case 'This Week':
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              if (createdAt.isBefore(weekStart)) return false;
              break;
            case 'This Month':
              if (createdAt.month != now.month || createdAt.year != now.year) {
                return false;
              }
              break;
            case 'This Year':
              if (createdAt.year != now.year) return false;
              break;
          }
        }

        return true;
      }).toList();
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      // In a real app, you would fetch fresh data here
    });

    HapticFeedback.lightImpact();
  }

  void _onModelTap(Map<String, dynamic> model) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/3d-model-viewer');
  }

  void _onModelLongPress(Map<String, dynamic> model) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickActionsSheet(
        model: model,
        onShare: () => _shareModel(model),
        onExport: () => _exportModel(model),
        onDuplicate: () => _duplicateModel(model),
        onDelete: () => _deleteModel(model),
      ),
    );
  }

  void _shareModel(Map<String, dynamic> model) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${model['name']}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _exportModel(Map<String, dynamic> model) {
    Navigator.pushNamed(context, '/export-options');
  }

  void _duplicateModel(Map<String, dynamic> model) {
    // Implement duplication functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicating ${model['name']}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteModel(Map<String, dynamic> model) {
    setState(() {
      _allModels.removeWhere((m) => m['id'] == model['id']);
      _applyFilters();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${model['name']} deleted'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _allModels.add(model);
              _applyFilters();
            });
          },
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: _activeFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _activeFilters = filters;
            _applyFilters();
          });
        },
      ),
    );
  }

  void _removeFilter(String filterType, [String? value]) {
    setState(() {
      if (filterType == 'formats' && value != null) {
        final formats = List<String>.from(_activeFilters['formats'] ?? []);
        formats.remove(value);
        if (formats.isEmpty) {
          _activeFilters.remove('formats');
        } else {
          _activeFilters['formats'] = formats;
        }
      } else if (filterType == 'statuses' && value != null) {
        final statuses = List<String>.from(_activeFilters['statuses'] ?? []);
        statuses.remove(value);
        if (statuses.isEmpty) {
          _activeFilters.remove('statuses');
        } else {
          _activeFilters['statuses'] = statuses;
        }
      } else {
        _activeFilters.remove(filterType);
      }
      _applyFilters();
    });
  }

  void _onConvertTap() {
    Navigator.pushNamed(context, '/pdf-upload');
  }

  List<Widget> _buildActiveFilterChips() {
    List<Widget> chips = [];

    // Format filters
    final formats = _activeFilters['formats'] as List<String>?;
    if (formats != null) {
      for (String format in formats) {
        chips.add(
          FilterChipWidget(
            label: format,
            isSelected: true,
            onRemove: () => _removeFilter('formats', format),
          ),
        );
      }
    }

    // Status filters
    final statuses = _activeFilters['statuses'] as List<String>?;
    if (statuses != null) {
      for (String status in statuses) {
        chips.add(
          FilterChipWidget(
            label: status,
            isSelected: true,
            onRemove: () => _removeFilter('statuses', status),
          ),
        );
      }
    }

    // Date filter
    final dateRange = _activeFilters['dateRange'] as String?;
    if (dateRange != null) {
      chips.add(
        FilterChipWidget(
          label: dateRange,
          isSelected: true,
          onRemove: () => _removeFilter('dateRange'),
        ),
      );
    }

    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Tab bar
            Container(
              color: AppTheme.lightTheme.cardColor,
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Library'),
                  Tab(text: 'Convert'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: SearchBarWidget(
                controller: _searchController,
                hintText: 'Search models...',
                onChanged: (query) {
                  // Handled by controller listener
                },
                onFilterTap: _showFilterSheet,
              ),
            ),
            // Active filter chips
            if (_activeFilters.isNotEmpty)
              Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _buildActiveFilterChips(),
                ),
              ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Library tab
                  _buildLibraryTab(),
                  // Convert tab (placeholder)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'upload_file',
                          color: AppTheme.primaryLight,
                          size: 64.0,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Convert Tab',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: _onConvertTap,
                          child: const Text('Upload PDF'),
                        ),
                      ],
                    ),
                  ),
                  // Profile tab (placeholder)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.primaryLight,
                          size: 64.0,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Profile Tab',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/user-profile'),
                          child: const Text('View Profile'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _onConvertTap,
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24.0,
              ),
            )
          : null,
    );
  }

  Widget _buildLibraryTab() {
    if (_filteredModels.isEmpty && !_isLoading) {
      return EmptyStateWidget(
        onConvertTap: _onConvertTap,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primaryLight,
      child: ModelGridWidget(
        models: _filteredModels,
        onModelTap: _onModelTap,
        onModelLongPress: _onModelLongPress,
        isLoading: _isLoading,
        onLoadMore: () {
          // Implement pagination if needed
        },
      ),
    );
  }
}
