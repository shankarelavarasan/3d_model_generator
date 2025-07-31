import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class Hunyuan3DService {
  static const String _baseUrl = 'https://api-inference.huggingface.co/models/tencent/Hunyuan3D-2';
  
  // For local Hunyuan3D deployment
  static const String _localBaseUrl = 'http://localhost:7860';
  
  final String apiKey;
  final bool useLocal;
  
  Hunyuan3DService({required this.apiKey, this.useLocal = false});
  
  String get _currentBaseUrl => useLocal ? _localBaseUrl : _baseUrl;
  
  /// Generate 3D model from CAD files using Hunyuan3D
  Future<Map<String, dynamic>> generateFromCADFiles({
    required List<String> cadFileUrls,
    required String modelId,
    String outputFormat = 'glb',
    String quality = 'high',
  }) async {
    try {
      final payload = {
        'inputs': {
          'cad_files': cadFileUrls,
          'output_format': outputFormat,
          'quality': quality,
          'model_type': 'cad_based',
          'model_id': modelId,
        },
        'options': {
          'wait_for_model': true,
          'use_cache': false,
        }
      };
      
      final response = await http.post(
        Uri.parse('$_currentBaseUrl/generate'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate 3D model: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in 3D generation: $e');
    }
  }
  
  /// Generate 3D model from single image using Hunyuan3D
  Future<Map<String, dynamic>> generateFromImage({
    required String imageUrl,
    required String modelId,
    String outputFormat = 'glb',
    String quality = 'high',
  }) async {
    try {
      final payload = {
        'inputs': {
          'image': imageUrl,
          'output_format': outputFormat,
          'quality': quality,
          'model_type': 'image_based',
          'model_id': modelId,
        },
        'options': {
          'wait_for_model': true,
          'use_cache': false,
        }
      };
      
      final response = await http.post(
        Uri.parse('$_currentBaseUrl/generate'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to generate 3D model: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in 3D generation: $e');
    }
  }
  
  /// Check generation status
  Future<Map<String, dynamic>> checkStatus(String jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$_currentBaseUrl/status/$jobId'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to check status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking status: $e');
    }
  }
  
  /// Download generated 3D model
  Future<String> downloadModel(String modelUrl, String localPath) async {
    try {
      final response = await http.get(
        Uri.parse(modelUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      
      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        return localPath;
      } else {
        throw Exception('Failed to download model: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading model: $e');
    }
  }
  
  /// Validate CAD file formats
  bool isValidCADFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.pdf', '.dwg', '.dxf', '.step', '.stp', '.iges', '.igs'].contains(extension);
  }
  
  /// Get supported formats
  List<String> getSupportedFormats() {
    return ['glb', 'gltf', 'obj', 'fbx', 'stl'];
  }
  
  /// Estimate processing time
  String estimateProcessingTime(int fileCount, String quality) {
    final baseTime = quality == 'high' ? 180 : 60; // seconds
    final totalTime = baseTime * fileCount;
    
    if (totalTime < 60) {
      return '$totalTime seconds';
    } else if (totalTime < 3600) {
      return '${(totalTime / 60).toStringAsFixed(1)} minutes';
    } else {
      return '${(totalTime / 3600).toStringAsFixed(1)} hours';
    }
  }
}