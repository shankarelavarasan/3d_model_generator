import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/export_preview_widget.dart';
import './widgets/export_progress_overlay.dart';
import './widgets/format_selection_card.dart';
import './widgets/quality_slider_widget.dart';

class ExportOptions extends StatefulWidget {
  const ExportOptions({super.key});

  @override
  State<ExportOptions> createState() => _ExportOptionsState();
}

class _ExportOptionsState extends State<ExportOptions> {
  String selectedFormat = '';
  double qualityValue = 0.7;
  bool isAdvancedExpanded = false;
  String selectedCoordinateSystem = 'Right-handed';
  String selectedUnit = 'Millimeters';
  bool includeTextures = true;
  bool isGeneratingPreview = false;
  bool isExporting = false;
  double exportProgress = 0.0;
  String exportStatusMessage = '';

  final List<Map<String, dynamic>> exportFormats = [
    {
      "format": "STL",
      "title": "STL Format",
      "description": "Standard format for 3D printing with mesh geometry",
      "useCase": "3D Printing",
      "estimatedSize": "2.4 MB",
      "iconName": "print",
    },
    {
      "format": "GLB",
      "title": "GLB Format",
      "description": "Optimized for web viewing and AR applications",
      "useCase": "Web/AR",
      "estimatedSize": "1.8 MB",
      "iconName": "language",
    },
    {
      "format": "FBX",
      "title": "FBX Format",
      "description": "Industry standard for animation and game development",
      "useCase": "Animation",
      "estimatedSize": "3.2 MB",
      "iconName": "movie",
    },
    {
      "format": "IGES",
      "title": "IGES Format",
      "description": "CAD interchange format for engineering applications",
      "useCase": "CAD",
      "estimatedSize": "4.1 MB",
      "iconName": "engineering",
    },
    {
      "format": "STEP",
      "title": "STEP Format",
      "description": "Precision engineering format for manufacturing",
      "useCase": "Engineering",
      "estimatedSize": "3.8 MB",
      "iconName": "precision_manufacturing",
    },
  ];

  String _getFileSizeEstimate() {
    final baseSize = 2.4;
    final qualityMultiplier = 0.5 + (qualityValue * 1.5);
    final estimatedSize = baseSize * qualityMultiplier;
    return '${estimatedSize.toStringAsFixed(1)} MB';
  }

  String _getProcessingTimeEstimate() {
    final baseTime = 15;
    final qualityMultiplier = 0.5 + (qualityValue * 2.0);
    final estimatedTime = (baseTime * qualityMultiplier).round();
    return '${estimatedTime}s';
  }

  void _generatePreview() {
    setState(() {
      isGeneratingPreview = true;
    });

    // Simulate preview generation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isGeneratingPreview = false;
        });
        _showPreviewDialog();
      }
    });
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Export Preview',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 30.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline,
                    width: 1.0,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'view_in_ar',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 15.w,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '3D Model Preview',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '$selectedFormat Format',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Preview shows how your model will appear in $selectedFormat format with current quality settings.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _startExport() {
    setState(() {
      isExporting = true;
      exportProgress = 0.0;
      exportStatusMessage = 'Preparing export...';
    });

    _simulateExportProgress();
  }

  void _simulateExportProgress() {
    final steps = [
      'Preparing export...',
      'Processing geometry...',
      'Applying quality settings...',
      'Converting to $selectedFormat...',
      'Finalizing export...',
    ];

    int currentStep = 0;
    const stepDuration = Duration(seconds: 2);

    void nextStep() {
      if (currentStep < steps.length && isExporting) {
        setState(() {
          exportStatusMessage = steps[currentStep];
          exportProgress = (currentStep + 1) / steps.length;
        });

        currentStep++;
        if (currentStep < steps.length) {
          Future.delayed(stepDuration, nextStep);
        } else {
          _completeExport();
        }
      }
    }

    nextStep();
  }

  void _completeExport() {
    setState(() {
      isExporting = false;
      exportProgress = 0.0;
      exportStatusMessage = '';
    });

    // Show success message and close modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Model exported successfully as $selectedFormat',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  void _cancelExport() {
    setState(() {
      isExporting = false;
      exportProgress = 0.0;
      exportStatusMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: 85.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 10.0,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 10.w,
                    height: 0.5.h,
                    margin: EdgeInsets.symmetric(vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      children: [
                        Text(
                          'Export Options',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            size: 6.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 2.h),
                          // Format Selection
                          Text(
                            'Select Export Format',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          ...exportFormats.map((format) => FormatSelectionCard(
                                format: format["format"] as String,
                                title: format["title"] as String,
                                description: format["description"] as String,
                                useCase: format["useCase"] as String,
                                estimatedSize:
                                    format["estimatedSize"] as String,
                                iconName: format["iconName"] as String,
                                isSelected: selectedFormat == format["format"],
                                onTap: () {
                                  setState(() {
                                    selectedFormat = format["format"] as String;
                                  });
                                },
                              )),
                          SizedBox(height: 3.h),
                          // Quality Slider
                          QualitySliderWidget(
                            qualityValue: qualityValue,
                            onChanged: (value) {
                              setState(() {
                                qualityValue = value;
                              });
                            },
                            fileSizeEstimate: _getFileSizeEstimate(),
                            processingTimeEstimate:
                                _getProcessingTimeEstimate(),
                          ),
                          SizedBox(height: 3.h),
                          // Advanced Options
                          AdvancedOptionsWidget(
                            isExpanded: isAdvancedExpanded,
                            onToggle: () {
                              setState(() {
                                isAdvancedExpanded = !isAdvancedExpanded;
                              });
                            },
                            selectedCoordinateSystem: selectedCoordinateSystem,
                            onCoordinateSystemChanged: (system) {
                              setState(() {
                                selectedCoordinateSystem = system;
                              });
                            },
                            selectedUnit: selectedUnit,
                            onUnitChanged: (unit) {
                              setState(() {
                                selectedUnit = unit;
                              });
                            },
                            includeTextures: includeTextures,
                            onTextureToggle: (value) {
                              setState(() {
                                includeTextures = value;
                              });
                            },
                          ),
                          SizedBox(height: 3.h),
                          // Export Preview
                          ExportPreviewWidget(
                            selectedFormat: selectedFormat,
                            onPreview: _generatePreview,
                            isGeneratingPreview: isGeneratingPreview,
                          ),
                          SizedBox(height: 4.h),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 3.h),
                                    side: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelLarge
                                        ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: selectedFormat.isNotEmpty
                                      ? _startExport
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 3.h),
                                    backgroundColor: selectedFormat.isNotEmpty
                                        ? AppTheme
                                            .lightTheme.colorScheme.primary
                                        : AppTheme
                                            .lightTheme.colorScheme.surface,
                                    foregroundColor: selectedFormat.isNotEmpty
                                        ? Colors.white
                                        : AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: Text(
                                    'Export',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelLarge
                                        ?.copyWith(
                                      color: selectedFormat.isNotEmpty
                                          ? Colors.white
                                          : AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExporting)
            ExportProgressOverlay(
              progress: exportProgress,
              statusMessage: exportStatusMessage,
              onCancel: _cancelExport,
            ),
        ],
      ),
    );
  }
}
