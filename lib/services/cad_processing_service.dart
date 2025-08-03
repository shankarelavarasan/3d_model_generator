import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'hunyuan3d_service.dart';
import 'upload_service.dart';
import '../core/error_handler.dart';

class CADProcessingService {
  final Hunyuan3DService _hunyuan3DService;
  final UploadService _uploadService;
  
  CADProcessingService({
    required String apiKey,
    bool useLocal = false,
  }) : _hunyuan3DService = Hunyuan3DService(apiKey: apiKey, useLocal: useLocal),
       _uploadService = UploadService();
  
  /// Process CAD files and generate 3D model
  Future<Map<String, dynamic>> processCADFiles({
    required List<String> cadFileUrls,
    required String modelId,
    String outputFormat = 'glb',
    String quality = 'high',
    Map<String, dynamic>? processingOptions,
  }) async {
    try {
      // Step 1: Validate CAD files
      final validationResult = await _validateCADFiles(cadFileUrls);
      if (!validationResult['valid']) {
        final error = AppError(
          type: ErrorType.processing,
          message: 'Invalid CAD files',
          details: validationResult['errors'].toString(),
        );
        ErrorHandler.logError(error);
        throw error;
      }
      
      // Step 2: Pre-process CAD files using OpenCascade
      final processedFiles = await _preProcessCADFiles(cadFileUrls, processingOptions);
      
      // Step 3: Generate 3D model using Hunyuan3D
      final generationResult = await _hunyuan3DService.generateFromCADFiles(
        cadFileUrls: processedFiles,
        modelId: modelId,
        outputFormat: outputFormat,
        quality: quality,
      );
      
      // Step 4: Upload generated 3D model
      final modelUrl = await _uploadGeneratedModel(
        generationResult['model_url'],
        modelId,
        outputFormat,
      );
      
      return {
        'success': true,
        'model_url': modelUrl,
        'processing_time': generationResult['processing_time'],
        'metadata': generationResult['metadata'],
        'cad_processing_notes': processedFiles.length > 1 
            ? 'Multiple CAD files processed and merged'
            : 'Single CAD file processed',
      };
      
    } on SocketException catch (e) {
      final error = AppError(
        type: ErrorType.network,
        message: 'Network error during CAD processing',
        details: e.toString(),
      );
      ErrorHandler.logError(error);
      return {
        'success': false,
        'error': ErrorHandler.getErrorMessage(error),
        'cad_processing_notes': 'Processing failed due to network issues',
      };
    } on AppError catch (e) {
      return {
        'success': false,
        'error': ErrorHandler.getErrorMessage(e),
        'cad_processing_notes': 'Processing failed at CAD processing stage',
      };
    } catch (e) {
      final error = AppError(
        type: ErrorType.processing,
        message: 'Unexpected error during CAD processing',
        details: e.toString(),
      );
      ErrorHandler.logError(error);
      return {
        'success': false,
        'error': ErrorHandler.getErrorMessage(error),
        'cad_processing_notes': 'Processing failed at CAD processing stage',
      };
    }
  }
  
  /// Validate CAD file formats and integrity
  Future<Map<String, dynamic>> _validateCADFiles(List<String> fileUrls) async {
    final errors = <String>[];
    final validFiles = <String>[];
    
    for (final url in fileUrls) {
      try {
        final fileName = path.basename(url);
        final extension = path.extension(fileName).toLowerCase();
        
        if (!_hunyuan3DService.isValidCADFormat(fileName)) {
          errors.add('Unsupported format: $extension');
          continue;
        }
        
        // Check file accessibility
        final response = await http.head(Uri.parse(url));
        if (response.statusCode != 200) {
          errors.add('File not accessible: $fileName');
          continue;
        }
        
        validFiles.add(url);
      } catch (e) {
        errors.add('Error validating $url: $e');
      }
    }
    
    return {
      'valid': errors.isEmpty,
      'errors': errors,
      'valid_files': validFiles,
    };
  }
  
  /// Pre-process CAD files using OpenCascade integration
  Future<List<String>> _preProcessCADFiles(
    List<String> fileUrls,
    Map<String, dynamic>? options,
  ) async {
    final processedFiles = <String>[];
    
    for (final url in fileUrls) {
      try {
        final fileName = path.basename(url);
        final extension = path.extension(fileName).toLowerCase();
        
        // Download file for processing
        final tempFile = await _downloadFile(url);
        
        // Process based on file type
        String processedUrl;
        switch (extension) {
          case '.pdf':
            processedUrl = await _processPDF(tempFile, options);
            break;
          case '.dwg':
            processedUrl = await _processDWG(tempFile, options);
            break;
          case '.dxf':
            processedUrl = await _processDXF(tempFile, options);
            break;
          case '.step':
          case '.stp':
            processedUrl = await _processSTEP(tempFile, options);
            break;
          case '.iges':
          case '.igs':
            processedUrl = await _processIGES(tempFile, options);
            break;
          default:
            processedUrl = url; // No processing needed
        }
        
        processedFiles.add(processedUrl);
        
        // Clean up temp file
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
        
      } catch (e) {
        // If processing fails, use original file
        processedFiles.add(url);
      }
    }
    
    return processedFiles;
  }
  
  /// Process PDF files - extract vector data
  Future<String> _processPDF(File pdfFile, Map<String, dynamic>? options) async {
    // This would integrate with OpenCascade PDF processing
    // For now, return the original file URL
    // In real implementation, this would extract vector data and convert to STEP
    return pdfFile.path;
  }
  
  /// Process DWG files using OpenCascade
  Future<String> _processDWG(File dwgFile, Map<String, dynamic>? options) async {
    // This would integrate with OpenCascade DWG processing
    // For now, return the original file URL
    // In real implementation, this would convert DWG to STEP format
    return dwgFile.path;
  }
  
  /// Process DXF files using OpenCascade
  Future<String> _processDXF(File dxfFile, Map<String, dynamic>? options) async {
    // This would integrate with OpenCascade DXF processing
    // For now, return the original file URL
    // In real implementation, this would process DXF geometry
    return dxfFile.path;
  }
  
  /// Process STEP files using OpenCascade
  Future<String> _processSTEP(File stepFile, Map<String, dynamic>? options) async {
    // This would integrate with OpenCascade STEP processing
    // For now, return the original file URL
    // In real implementation, this would validate and optimize STEP geometry
    return stepFile.path;
  }
  
  /// Process IGES files using OpenCascade
  Future<String> _processIGES(File igesFile, Map<String, dynamic>? options) async {
    // This would integrate with OpenCascade IGES processing
    // For now, return the original file URL
    // In real implementation, this would process IGES geometry
    return igesFile.path;
  }
  
  /// Download file from URL to temporary location
  Future<File> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    final tempDir = Directory.systemTemp;
    final fileName = path.basename(url);
    final tempFile = File('${tempDir.path}/$fileName');
    
    await tempFile.writeAsBytes(response.bodyBytes);
    return tempFile;
  }
  
  /// Upload generated 3D model to storage
  Future<String> _uploadGeneratedModel(
    String modelUrl,
    String modelId,
    String format,
  ) async {
    final fileName = 'model_${modelId}_generated.$format';
    return await _uploadService.uploadModel(
      modelUrl,
      fileName,
    );
  }
  
  /// Get processing recommendations
  Map<String, dynamic> getProcessingRecommendations(List<String> fileUrls) {
    final recommendations = <String, dynamic>{};
    
    if (fileUrls.length > 1) {
      recommendations['merge_strategy'] = 'automatic';
      recommendations['coordinate_system'] = 'unified';
    }
    
    final fileTypes = fileUrls.map((url) => path.extension(url).toLowerCase()).toList();
    recommendations['file_types'] = fileTypes;
    
    if (fileTypes.contains('.pdf')) {
      recommendations['pdf_processing'] = 'vector_extraction';
    }
    
    if (fileTypes.any((type) => ['.dwg', '.dxf', '.step', '.stp', '.iges', '.igs'].contains(type))) {
      recommendations['cad_processing'] = 'geometry_validation';
    }
    
    recommendations['estimated_time'] = _hunyuan3DService.estimateProcessingTime(
      fileUrls.length,
      'high',
    );
    
    return recommendations;
  }
  
  /// Check if files need preprocessing
  bool needsPreprocessing(List<String> fileUrls) {
    return fileUrls.any((url) {
      final extension = path.extension(url).toLowerCase();
      return ['.pdf', '.dwg', '.dxf'].contains(extension);
    });
  }
}
