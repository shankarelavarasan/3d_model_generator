import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/model_model.dart';
import '../config/app_config.dart';

class CADProcessingService {
  final String cadProcessorUrl;
  final String hunyuan3dUrl;
  final http.Client client;

  CADProcessingService({
    String? cadProcessorUrl,
    String? hunyuan3dUrl,
    http.Client? client,
  }) : cadProcessorUrl = cadProcessorUrl ?? 'http://localhost:5000',
       hunyuan3dUrl = hunyuan3dUrl ?? 'http://localhost:8080',
       client = client ?? http.Client();

  /// Process CAD files using OpenCascade and generate 3D model using Hunyuan3D
  Future<Map<String, dynamic>> processCADFiles({
    required List<String> cadFileUrls,
    required String modelId,
    String outputFormat = 'glb',
    String quality = 'high',
    Map<String, dynamic>? options,
  }) async {
    try {
      // Step 1: Validate and preprocess CAD files
      final preprocessingResult = await _preprocessCADFiles(
        files: cadFileUrls,
        modelId: modelId,
      );

      if (!preprocessingResult['success']) {
        return {
          'success': false,
          'error': preprocessingResult['error'],
          'stage': 'preprocessing',
        };
      }

      // Step 2: Generate 3D model using Hunyuan3D
      final generationResult = await _generate3DModel(
        processedFiles: preprocessingResult['processed_files'],
        modelId: modelId,
        outputFormat: outputFormat,
        quality: quality,
        options: options,
      );

      if (!generationResult['success']) {
        return {
          'success': false,
          'error': generationResult['error'],
          'stage': 'generation',
        };
      }

      return {
        'success': true,
        'model_url': generationResult['model_url'],
        'processing_time': generationResult['processing_time'],
        'vertices': generationResult['vertices'],
        'faces': generationResult['faces'],
        'texture_size': generationResult['texture_size'],
        'metadata': generationResult['metadata'],
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Processing failed: ${e.toString()}',
        'stage': 'general',
      };
    }
  }

  /// Preprocess CAD files using OpenCascade
  Future<Map<String, dynamic>> _preprocessCADFiles({
    required List<String> files,
    required String modelId,
  }) async {
    try {
      final response = await client.post(
        Uri.parse('$cadProcessorUrl/process-cad'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'files': files,
          'model_id': modelId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'CAD processing failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'CAD processing error: ${e.toString()}',
      };
    }
  }

  /// Generate 3D model using Hunyuan3D
  Future<Map<String, dynamic>> _generate3DModel({
    required List<dynamic> processedFiles,
    required String modelId,
    required String outputFormat,
    required String quality,
    Map<String, dynamic>? options,
  }) async {
    try {
      final payload = {
        'model_id': modelId,
        'input_files': processedFiles,
        'output_format': outputFormat,
        'quality': quality,
        'options': {
          'mesh_resolution': options?['mesh_resolution'] ?? 'high',
          'texture_quality': options?['texture_quality'] ?? 'high',
          'coordinate_system': options?['coordinate_system'] ?? 'right_handed',
          'unit_scale': options?['unit_scale'] ?? 'millimeters',
          'generate_textures': options?['generate_textures'] ?? true,
          'optimize_mesh': options?['optimize_mesh'] ?? true,
          ...?options,
        },
      };

      final response = await client.post(
        Uri.parse('$hunyuan3dUrl/generate'),
        headers: {
          'Content-Type': 'application/json',
          if (!AppConfig.useLocalProcessing) 'Authorization': 'Bearer ${AppConfig.hunyuan3dApiKey}',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': '3D generation failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '3D generation error: ${e.toString()}',
      };
    }
  }

  /// Check the status of a 3D generation job
  Future<Map<String, dynamic>> checkGenerationStatus(String modelId) async {
    try {
      final response = await client.get(
        Uri.parse('$hunyuan3dUrl/status/$modelId'),
        headers: {
          if (!AppConfig.useLocalProcessing) 'Authorization': 'Bearer ${AppConfig.hunyuan3dApiKey}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Status check failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Status check error: ${e.toString()}',
      };
    }
  }

  /// Get processing recommendations based on file types
  Future<Map<String, dynamic>> getProcessingRecommendations(
    List<String> files,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$cadProcessorUrl/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'files': files}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'error': 'Recommendations failed: ${response.statusCode}',
          'estimated_time': '60s',
          'recommendations': ['Use high-quality CAD files'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Recommendations error: ${e.toString()}',
        'estimated_time': '60s',
        'recommendations': ['Check file formats and sizes'],
      };
    }
  }

  /// Download generated 3D model
  Future<bool> downloadModel({
    required String modelUrl,
    required String outputPath,
  }) async {
    try {
      final response = await client.get(Uri.parse(modelUrl));

      if (response.statusCode == 200) {
        final file = File(outputPath);
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Validate CAD file format
  Future<bool> validateCADFile(String filePath) async {
    try {
      final extension = filePath.toLowerCase().split('.').last;
      final validExtensions = {
        'pdf', 'dwg', 'dxf', 'step', 'stp', 'iges', 'igs', 'stl', 'obj'
      };
      return validExtensions.contains(extension);
    } catch (e) {
      return false;
    }
  }

  /// Estimate processing time based on file characteristics
  String estimateProcessingTime(List<String> files) {
    final fileCount = files.length;
    final baseTime = 30; // seconds per file
    
    final complexityMultiplier = {
      'pdf': 2.0,
      'dwg': 3.0,
      'dxf': 2.5,
      'step': 1.5,
      'iges': 1.8,
      'stl': 1.0,
      'obj': 1.2,
    };

    var totalTime = 0.0;
    for (final file in files) {
      final extension = file.toLowerCase().split('.').last;
      totalTime += complexityMultiplier[extension] ?? 2.0;
    }

    final estimatedSeconds = (totalTime * baseTime).round();
    
    if (estimatedSeconds < 60) {
      return '$estimatedSeconds seconds';
    } else if (estimatedSeconds < 3600) {
      return '${(estimatedSeconds / 60).round()} minutes';
    } else {
      return '${(estimatedSeconds / 3600).round()} hours';
    }
  }
}