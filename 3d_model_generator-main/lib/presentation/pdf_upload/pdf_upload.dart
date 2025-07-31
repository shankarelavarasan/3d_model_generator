import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/process_button_widget.dart';
import './widgets/scan_document_button.dart';
import './widgets/unit_selector_widget.dart';
import './widgets/upload_zone_widget.dart';

class PdfUpload extends StatefulWidget {
  const PdfUpload({super.key});

  @override
  State<PdfUpload> createState() => _PdfUploadState();
}

class _PdfUploadState extends State<PdfUpload> {
  // File upload state
  final Map<String, Map<String, dynamic>> _uploadedFiles = {
    'top': {},
    'front': {},
    'side': {},
  };

  // Unit selection state
  String _selectedUnit = 'mm';

  // Camera state
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isInitializingCamera = false;

  // Processing state
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Camera initialization
  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint('Error initializing cameras: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) return;

    setState(() => _isInitializingCamera = true);

    try {
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();

      // Apply platform-specific settings
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        debugPrint('Focus mode not supported: $e');
      }

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _showErrorSnackBar('Camera initialization failed');
    } finally {
      setState(() => _isInitializingCamera = false);
    }
  }

  // File operations
  Future<void> _selectFile(String viewType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileSize = _formatFileSize(file.size);

        setState(() {
          _uploadedFiles[viewType] = {
            'name': file.name,
            'size': fileSize,
            'path': file.path,
            'bytes': file.bytes,
          };
        });

        _showSuccessSnackBar(
            '${_getViewTitle(viewType)} uploaded successfully');
      }
    } catch (e) {
      debugPrint('Error selecting file: $e');
      _showErrorSnackBar('Failed to select file');
    }
  }

  Future<void> _scanDocument() async {
    if (!await _requestCameraPermission()) {
      _showErrorSnackBar('Camera permission required');
      return;
    }

    if (!_isCameraInitialized) {
      await _initializeCamera();
    }

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      _showCameraDialog();
    } else {
      _showErrorSnackBar('Camera not available');
    }
  }

  void _showCameraDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 90.w,
          height: 70.h,
          child: Column(
            children: [
              AppBar(
                title: Text('Scan Document'),
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                elevation: 0,
                leading: IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    size: 6.w,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: _cameraController != null &&
                        _cameraController!.value.isInitialized
                    ? CameraPreview(_cameraController!)
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
              Container(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _capturePhoto,
                      icon: CustomIconWidget(
                        iconName: 'camera',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      label: Text('Capture'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      Navigator.pop(context);

      // In a real implementation, you would process the captured image
      // and convert it to PDF or extract text using OCR
      _showSuccessSnackBar('Document captured successfully');
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      _showErrorSnackBar('Failed to capture document');
    }
  }

  void _removeFile(String viewType) {
    setState(() {
      _uploadedFiles[viewType] = {};
    });
    _showSuccessSnackBar('${_getViewTitle(viewType)} removed');
  }

  void _replaceFile(String viewType) {
    _selectFile(viewType);
  }

  // Processing
  Future<void> _processDrawings() async {
    if (!_hasMinimumFiles()) return;

    setState(() => _isProcessing = true);

    try {
      // Simulate processing time
      await Future.delayed(Duration(seconds: 2));

      // Navigate to processing status screen
      Navigator.pushNamed(context, '/processing-status');
    } catch (e) {
      debugPrint('Error processing drawings: $e');
      _showErrorSnackBar('Failed to process drawings');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // Helper methods
  bool _hasMinimumFiles() {
    return _uploadedFiles.values.any((file) => file.isNotEmpty);
  }

  bool _hasFile(String viewType) {
    return _uploadedFiles[viewType]?.isNotEmpty ?? false;
  }

  String _getViewTitle(String viewType) {
    switch (viewType) {
      case 'top':
        return 'Top View';
      case 'front':
        return 'Front View';
      case 'side':
        return 'Side View';
      default:
        return 'View';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Upload Drawings'),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed:
                _hasMinimumFiles() && !_isProcessing ? _processDrawings : null,
            child: Text(
              'Next',
              style: TextStyle(
                color: _hasMinimumFiles() && !_isProcessing
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Upload zones
              UploadZoneWidget(
                title: 'Top View',
                fileName: _uploadedFiles['top']?['name'],
                fileSize: _uploadedFiles['top']?['size'],
                hasFile: _hasFile('top'),
                onTap: () => _selectFile('top'),
                onReplace: _hasFile('top') ? () => _replaceFile('top') : null,
                onRemove: _hasFile('top') ? () => _removeFile('top') : null,
              ),

              UploadZoneWidget(
                title: 'Front View',
                fileName: _uploadedFiles['front']?['name'],
                fileSize: _uploadedFiles['front']?['size'],
                hasFile: _hasFile('front'),
                onTap: () => _selectFile('front'),
                onReplace:
                    _hasFile('front') ? () => _replaceFile('front') : null,
                onRemove: _hasFile('front') ? () => _removeFile('front') : null,
              ),

              UploadZoneWidget(
                title: 'Side View',
                fileName: _uploadedFiles['side']?['name'],
                fileSize: _uploadedFiles['side']?['size'],
                hasFile: _hasFile('side'),
                onTap: () => _selectFile('side'),
                onReplace: _hasFile('side') ? () => _replaceFile('side') : null,
                onRemove: _hasFile('side') ? () => _removeFile('side') : null,
              ),

              SizedBox(height: 2.h),

              // Unit selector
              UnitSelectorWidget(
                selectedUnit: _selectedUnit,
                onUnitChanged: (unit) {
                  setState(() => _selectedUnit = unit);
                },
              ),

              SizedBox(height: 2.h),

              // Scan document button
              ScanDocumentButton(
                onPressed: _scanDocument,
                isLoading: _isInitializingCamera,
              ),

              SizedBox(height: 4.h),

              // Process button
              ProcessButtonWidget(
                isEnabled: _hasMinimumFiles(),
                isLoading: _isProcessing,
                onPressed: _processDrawings,
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
