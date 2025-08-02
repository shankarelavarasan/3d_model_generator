import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import '../core/error_handler.dart';

class UploadService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<String> uploadImage(File imageFile, String userId) async {
    try {
      // Validate image file before upload
      await _validateImageFile(imageFile);
      
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
    } on StorageException catch (e) {
      ErrorHandler.logError('Storage error during image upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.upload,
        message: 'Failed to upload image to storage',
        originalError: e,
      );
    } on SocketException catch (e) {
      ErrorHandler.logError('Network error during image upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.network,
        message: 'Network connection failed during image upload',
        originalError: e,
      );
    } catch (e) {
      ErrorHandler.logError('Unexpected error during image upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.upload,
        message: 'Image upload failed unexpectedly',
        originalError: e,
      );
    }
  }

  Future<String> uploadCADFile(File cadFile, String userId, String modelId, int fileIndex) async {
    try {
      // Validate CAD file before upload
      await _validateCADFile(cadFile);
      
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
    } on StorageException catch (e) {
      ErrorHandler.logError('Storage error during CAD upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.upload,
        message: 'Failed to upload CAD file to storage',
        originalError: e,
      );
    } on SocketException catch (e) {
      ErrorHandler.logError('Network error during CAD upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.network,
        message: 'Network connection failed during CAD upload',
        originalError: e,
      );
    } catch (e) {
      ErrorHandler.logError('Unexpected error during CAD upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.upload,
        message: 'CAD file upload failed unexpectedly',
        originalError: e,
      );
    }
  }

  Future<String> uploadModel(File modelFile, String userId, String modelId) async {
    try {
      // Validate 3D model file before upload
      await _validate3DModelFile(modelFile);
      
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
    } on StorageException catch (e) {
      ErrorHandler.logError('Storage error during model upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.upload,
        message: 'Failed to upload 3D model to storage',
        originalError: e,
      );
    } on SocketException catch (e) {
      ErrorHandler.logError('Network error during model upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.network,
        message: 'Network connection failed during model upload',
        originalError: e,
      );
    } catch (e) {
      ErrorHandler.logError('Unexpected error during model upload', e, StackTrace.current);
      throw AppError(
        type: ErrorType.upload,
        message: '3D model upload failed unexpectedly',
        originalError: e,
      );
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

  /// Validate image file before upload
  Future<void> _validateImageFile(File file) async {
    if (!await file.exists()) {
      throw AppError(
        type: ErrorType.upload,
        message: 'Image file does not exist',
      );
    }

    final extension = path.extension(file.path).toLowerCase();
    const allowedImageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    
    if (!allowedImageExtensions.contains(extension)) {
      throw AppError(
        type: ErrorType.upload,
        message: 'Invalid image format. Supported formats: ${allowedImageExtensions.join(', ')}',
      );
    }

    final fileSize = await file.length();
    const maxImageSize = 10 * 1024 * 1024; // 10MB
    
    if (fileSize > maxImageSize) {
      throw AppError(
        type: ErrorType.upload,
        message: 'Image file too large. Maximum size: 10MB',
      );
    }

    if (fileSize == 0) {
      throw AppError(
        type: ErrorType.upload,
        message: 'Image file is empty',
      );
    }
  }

  /// Validate CAD file before upload
  Future<void> _validateCADFile(File file) async {
    if (!await file.exists()) {
      throw AppError(
        type: ErrorType.upload,
        message: 'CAD file does not exist',
      );
    }

    final extension = path.extension(file.path).toLowerCase();
    const allowedCADExtensions = ['.pdf', '.dwg', '.dxf', '.step', '.stp', '.iges', '.igs'];
    
    if (!allowedCADExtensions.contains(extension)) {
      throw AppError(
        type: ErrorType.upload,
        message: 'Invalid CAD format. Supported formats: ${allowedCADExtensions.join(', ')}',
      );
    }

    final fileSize = await file.length();
    const maxCADSize = 100 * 1024 * 1024; // 100MB
    
    if (fileSize > maxCADSize) {
      throw AppError(
        type: ErrorType.upload,
        message: 'CAD file too large. Maximum size: 100MB',
      );
    }

    if (fileSize == 0) {
      throw AppError(
        type: ErrorType.upload,
        message: 'CAD file is empty',
      );
    }
  }

  /// Validate 3D model file before upload
  Future<void> _validate3DModelFile(File file) async {
    if (!await file.exists()) {
      throw AppError(
        type: ErrorType.upload,
        message: '3D model file does not exist',
      );
    }

    final extension = path.extension(file.path).toLowerCase();
    const allowed3DExtensions = ['.obj', '.stl', '.ply', '.fbx', '.dae', '.gltf', '.glb'];
    
    if (!allowed3DExtensions.contains(extension)) {
      throw AppError(
        type: ErrorType.upload,
        message: 'Invalid 3D model format. Supported formats: ${allowed3DExtensions.join(', ')}',
      );
    }

    final fileSize = await file.length();
    const max3DSize = 50 * 1024 * 1024; // 50MB
    
    if (fileSize > max3DSize) {
      throw AppError(
        type: ErrorType.upload,
        message: '3D model file too large. Maximum size: 50MB',
      );
    }

    if (fileSize == 0) {
      throw AppError(
        type: ErrorType.upload,
        message: '3D model file is empty',
      );
    }
  }

  /// Get upload progress (for future implementation)
  Stream<double> getUploadProgress(String fileName) {
    // This would be implemented with actual progress tracking
    // For now, return a simple stream
    return Stream.periodic(Duration(milliseconds: 100), (i) => (i + 1) / 10)
        .take(10)
        .map((progress) => progress.clamp(0.0, 1.0));
  }

  /// Cancel upload (for future implementation)
  Future<void> cancelUpload(String fileName) async {
    // This would be implemented with actual upload cancellation
    // For now, just a placeholder
    throw UnimplementedError('Upload cancellation not yet implemented');
  }
}