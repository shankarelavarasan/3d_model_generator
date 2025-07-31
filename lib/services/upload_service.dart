import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class UploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      final fileExtension = path.extension(imageFile.path).toLowerCase();
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final filePath = '$userId/$fileName';
      
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      
      await _supabase.storage.from('3d-uploads').upload(
        filePath,
        imageFile,
        fileOptions: FileOptions(
          contentType: mimeType,
          cacheControl: '3600',
          upsert: false,
        ),
      );
      
      return _supabase.storage.from('3d-uploads').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }

  Future<String> uploadCADFile(File cadFile, String userId, String modelId, int fileIndex) async {
    try {
      final fileExtension = path.extension(cadFile.path).toLowerCase();
      final fileName = '${modelId}_cad_${fileIndex + 1}$fileExtension';
      final filePath = '$userId/cad_files/$fileName';
      
      final mimeType = _getCADMimeType(fileExtension);
      
      await _supabase.storage.from('3d-uploads').upload(
        filePath,
        cadFile,
        fileOptions: FileOptions(
          contentType: mimeType,
          cacheControl: '86400',
          upsert: false,
        ),
      );
      
      return _supabase.storage.from('3d-uploads').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('CAD file upload failed: ${e.toString()}');
    }
  }

  Future<String> uploadModel(File modelFile, String userId, String modelId) async {
    try {
      final fileExtension = path.extension(modelFile.path).toLowerCase();
      final fileName = '${modelId}_model$fileExtension';
      final filePath = '$userId/models/$fileName';
      
      final mimeType = _getModelMimeType(fileExtension);
      
      await _supabase.storage.from('3d-uploads').upload(
        filePath,
        modelFile,
        fileOptions: FileOptions(
          contentType: mimeType,
          cacheControl: '86400',
          upsert: true,
        ),
      );
      
      return _supabase.storage.from('3d-uploads').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Model upload failed: ${e.toString()}');
    }
  }

  String _getCADMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.dwg':
        return 'application/acad';
      case '.dxf':
        return 'application/dxf';
      default:
        return 'application/octet-stream';
    }
  }

  String _getModelMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.obj':
        return 'model/obj';
      case '.stl':
        return 'model/stl';
      case '.gltf':
        return 'model/gltf+json';
      case '.fbx':
        return 'application/fbx';
      default:
        return 'application/octet-stream';
    }
  }