import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/live_preview_widget.dart';
import './widgets/log_viewer_widget.dart';
import './widgets/processing_stage_widget.dart';
import './widgets/progress_indicator_widget.dart';

class ProcessingStatus extends StatefulWidget {
  const ProcessingStatus({super.key});

  @override
  State<ProcessingStatus> createState() => _ProcessingStatusState();
}

class _ProcessingStatusState extends State<ProcessingStatus>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late Animation<double> _celebrationAnimation;

  double _currentProgress = 0.0;
  int _currentStageIndex = 0;
  String _estimatedTimeRemaining = "5 min 30 sec";
  String? _previewImageUrl;
  bool _isProcessingComplete = false;
  bool _isLogExpanded = false;

  final List<int> _expandedStages = [];

  final List<Map<String, dynamic>> _processingStages = [
    {
      "name": "PDF Analysis",
      "description":
          "Extracting text and dimensions using OCR technology, detecting technical drawing elements and coordinate systems.",
      "estimatedTime": "2 min 15 sec",
      "isCompleted": false,
      "isActive": true,
    },
    {
      "name": "View Alignment",
      "description":
          "Mapping coordinate systems between top, front, and side views. Calibrating scale and aligning reference points.",
      "estimatedTime": "1 min 45 sec",
      "isCompleted": false,
      "isActive": false,
    },
    {
      "name": "3D Generation",
      "description":
          "Creating mesh geometry from 2D views, reconstructing surfaces and applying boolean operations for model merging.",
      "estimatedTime": "3 min 20 sec",
      "isCompleted": false,
      "isActive": false,
    },
    {
      "name": "Quality Optimization",
      "description":
          "Cleaning topology, optimizing mesh density, and preparing model for export in multiple formats.",
      "estimatedTime": "1 min 10 sec",
      "isCompleted": false,
      "isActive": false,
    },
  ];

  final List<Map<String, dynamic>> _processingLogs = [
    {
      "level": "info",
      "message": "Starting PDF analysis for technical drawing conversion",
      "timestamp": "17:23:18",
    },
    {
      "level": "info",
      "message":
          "OCR engine initialized, detecting text and dimension annotations",
      "timestamp": "17:23:19",
    },
    {
      "level": "success",
      "message": "Found 3 technical views: top, front, side projections",
      "timestamp": "17:23:22",
    },
    {
      "level": "info",
      "message": "Extracting coordinate systems and scale references",
      "timestamp": "17:23:24",
    },
    {
      "level": "warning",
      "message":
          "Minor alignment discrepancy detected, applying automatic correction",
      "timestamp": "17:23:26",
    },
  ];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    _startProcessingSimulation();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  void _startProcessingSimulation() {
    // Simulate processing progress
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentProgress = 25.0;
          _estimatedTimeRemaining = "4 min 45 sec";
          _processingLogs.add({
            "level": "info",
            "message": "PDF analysis completed, moving to view alignment phase",
            "timestamp": "17:23:28",
          });
        });
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _processingStages[0]["isCompleted"] = true;
          _processingStages[0]["isActive"] = false;
          _processingStages[1]["isActive"] = true;
          _currentProgress = 45.0;
          _currentStageIndex = 1;
          _estimatedTimeRemaining = "3 min 20 sec";
          _processingLogs.add({
            "level": "success",
            "message": "View alignment successful, coordinate systems mapped",
            "timestamp": "17:23:32",
          });
        });
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _processingStages[1]["isCompleted"] = true;
          _processingStages[1]["isActive"] = false;
          _processingStages[2]["isActive"] = true;
          _currentProgress = 70.0;
          _currentStageIndex = 2;
          _estimatedTimeRemaining = "2 min 10 sec";
          _previewImageUrl =
              "https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?fm=jpg&q=60&w=800&ixlib=rb-4.0.3";
          _processingLogs.add({
            "level": "info",
            "message":
                "3D mesh generation in progress, creating surface geometry",
            "timestamp": "17:23:35",
          });
        });
      }
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _processingStages[2]["isCompleted"] = true;
          _processingStages[2]["isActive"] = false;
          _processingStages[3]["isActive"] = true;
          _currentProgress = 90.0;
          _currentStageIndex = 3;
          _estimatedTimeRemaining = "45 sec";
          _processingLogs.add({
            "level": "info",
            "message": "Optimizing mesh topology and preparing export formats",
            "timestamp": "17:23:38",
          });
        });
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _processingStages[3]["isCompleted"] = true;
          _processingStages[3]["isActive"] = false;
          _currentProgress = 100.0;
          _isProcessingComplete = true;
          _estimatedTimeRemaining = "Complete";
          _processingLogs.add({
            "level": "success",
            "message":
                "3D model generation completed successfully! Ready for export.",
            "timestamp": "17:23:42",
          });
        });
        _celebrationController.forward();
        HapticFeedback.lightImpact();

        // Auto-navigate to 3D viewer after celebration
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/3d-model-viewer');
          }
        });
      }
    });
  }

  void _toggleStageExpansion(int index) {
    setState(() {
      if (_expandedStages.contains(index)) {
        _expandedStages.remove(index);
      } else {
        _expandedStages.add(index);
      }
    });
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cancel Processing?',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel the 3D model generation? All progress will be lost and you\'ll need to start over.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continue Processing',
                style: TextStyle(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/pdf-upload');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '3D Model Generation',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: _isProcessingComplete ? null : _showCancelDialog,
          icon: CustomIconWidget(
            iconName: 'close',
            color: _isProcessingComplete
                ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.5)
                : AppTheme.lightTheme.colorScheme.error,
            size: 6.w,
          ),
        ),
        actions: [
          if (!_isProcessingComplete)
            TextButton(
              onPressed: _showCancelDialog,
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Column(
            children: [
              // Progress Indicator Section
              if (_isProcessingComplete)
                AnimatedBuilder(
                  animation: _celebrationAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_celebrationAnimation.value * 0.1),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 2.h),
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.lightTheme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: 'celebration',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 12.w,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Processing Complete!',
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.tertiary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Your 3D model has been successfully generated and is ready for viewing and export.',
                              textAlign: TextAlign.center,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onTertiaryContainer,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        Navigator.pushReplacementNamed(
                                            context, '/3d-model-viewer'),
                                    icon: CustomIconWidget(
                                      iconName: 'view_in_ar',
                                      color: Colors.white,
                                      size: 5.w,
                                    ),
                                    label: const Text('View 3D Model'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 3.h),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/export-options'),
                                    icon: CustomIconWidget(
                                      iconName: 'download',
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                      size: 5.w,
                                    ),
                                    label: const Text('Export'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                      side: BorderSide(
                                        color: AppTheme
                                            .lightTheme.colorScheme.tertiary,
                                        width: 2,
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 3.h),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                ProgressIndicatorWidget(
                  progress: _currentProgress,
                  estimatedTimeRemaining: _estimatedTimeRemaining,
                ),

              SizedBox(height: 3.h),

              // Processing Stages Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                      child: Text(
                        'Processing Stages',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _processingStages.length,
                      itemBuilder: (context, index) {
                        final stage = _processingStages[index];
                        return ProcessingStageWidget(
                          stageName: stage["name"] as String,
                          description: stage["description"] as String,
                          estimatedTime: stage["estimatedTime"] as String,
                          isCompleted: stage["isCompleted"] as bool,
                          isActive: stage["isActive"] as bool,
                          isExpanded: _expandedStages.contains(index),
                          onTap: () => _toggleStageExpansion(index),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Live Preview Section
              LivePreviewWidget(
                previewImageUrl: _previewImageUrl,
                progress: _currentProgress,
              ),

              SizedBox(height: 3.h),

              // Processing Log Section
              LogViewerWidget(
                logs: _processingLogs,
                isExpanded: _isLogExpanded,
                onToggle: () {
                  setState(() {
                    _isLogExpanded = !_isLogExpanded;
                  });
                },
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
