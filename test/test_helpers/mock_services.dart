import 'dart:async';
import 'dart:io';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../lib/services/cad_processing_service.dart';
import '../lib/services/upload_service.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/cache_service.dart';
import '../lib/services/hunyuan3d_service.dart';

/// Mock Supabase Client
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock Supabase Storage
class MockSupabaseStorage extends Mock implements SupabaseStorageClient {}

/// Mock Supabase Storage Bucket
class MockSupabaseStorageBucket extends Mock implements SupabaseStorageFileApi {}

/// Mock CAD Processing Service
class MockCADProcessingService extends Mock implements CADProcessingService {
  @override
  Future<CADProcessingResult> processCADFiles(
    List<String> fileUrls,
    String modelId,
  ) async {
    return super.noSuchMethod(
      Invocation.method(#processCADFiles, [fileUrls, modelId]),
      returnValue: Future.value(CADProcessingResult(
        success: true,
        modelUrl: 'https://example.com/model.glb',
        processingTime: Duration(seconds: 45),
        fileSize: 1024000,
        metadata: {'test': true},
      )),
    );
  }

  @override
  Future<bool> validateCADFile(File file) async {
    return super.noSuchMethod(
      Invocation.method(#validateCADFile, [file]),
      returnValue: Future.value(true),
    );
  }

  @override
  Future<Map<String, dynamic>> getProcessingRecommendations(File file) async {
    return super.noSuchMethod(
      Invocation.method(#getProcessingRecommendations, [file]),
      returnValue: Future.value({
        'recommended_format': 'glb',
        'estimated_time': 30,
        'file_size': 1024000,
      }),
    );
  }
}

/// Mock Upload Service
class MockUploadService extends Mock implements UploadService {
  @override
  Future<String> uploadCADFile(File file, String modelId) async {
    return super.noSuchMethod(
      Invocation.method(#uploadCADFile, [file, modelId]),
      returnValue: Future.value('https://storage.supabase.co/uploaded/file.pdf'),
    );
  }

  @override
  Future<String> uploadModel(File file, String modelId) async {
    return super.noSuchMethod(
      Invocation.method(#uploadModel, [file, modelId]),
      returnValue: Future.value('https://storage.supabase.co/uploaded/model.glb'),
    );
  }

  @override
  Future<bool> deleteFile(String fileUrl) async {
    return super.noSuchMethod(
      Invocation.method(#deleteFile, [fileUrl]),
      returnValue: Future.value(true),
    );
  }
}

/// Mock Auth Service
class MockAuthService extends Mock implements AuthService {
  @override
  Future<AuthResponse> signIn(String email, String password) async {
    return super.noSuchMethod(
      Invocation.method(#signIn, [email, password]),
      returnValue: Future.value(AuthResponse(
        user: User(
          id: 'test-user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: Session(
          accessToken: 'test-token',
          refreshToken: 'test-refresh-token',
          expiresIn: 3600,
          expiresAt: DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
          tokenType: 'bearer',
          user: User(
            id: 'test-user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        ),
      )),
    );
  }

  @override
  Future<AuthResponse> signUp(String email, String password) async {
    return super.noSuchMethod(
      Invocation.method(#signUp, [email, password]),
      returnValue: Future.value(AuthResponse(
        user: User(
          id: 'new-user-id',
          appMetadata: {},
          userMetadata: {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        ),
        session: Session(
          accessToken: 'new-token',
          refreshToken: 'new-refresh-token',
          expiresIn: 3600,
          expiresAt: DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch,
          tokenType: 'bearer',
          user: User(
            id: 'new-user-id',
            appMetadata: {},
            userMetadata: {},
            aud: 'authenticated',
            createdAt: DateTime.now().toIso8601String(),
          ),
        ),
      )),
    );
  }

  @override
  Future<void> signOut() async {
    return super.noSuchMethod(
      Invocation.method(#signOut, []),
      returnValue: Future.value(null),
    );
  }

  @override
  User? get currentUser => User(
        id: 'test-user-id',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
      );
}

/// Mock Cache Service
class MockCacheService extends Mock implements CacheService {
  final Map<String, dynamic> _cache = {};

  @override
  Future<T?> get<T>(String key) async {
    return super.noSuchMethod(
      Invocation.method(#get, [key]),
      returnValue: Future.value(_cache[key] as T?),
    );
  }

  @override
  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    return super.noSuchMethod(
      Invocation.method(#set, [key, value], {#ttl: ttl}),
      returnValue: Future.value(_cache[key] = value),
    );
  }

  @override
  Future<void> remove(String key) async {
    return super.noSuchMethod(
      Invocation.method(#remove, [key]),
      returnValue: Future.value(_cache.remove(key)),
    );
  }

  @override
  Future<void> clear() async {
    return super.noSuchMethod(
      Invocation.method(#clear, []),
      returnValue: Future.value(_cache.clear()),
    );
  }
}

/// Mock Hunyuan3D Service
class MockHunyuan3DService extends Mock implements Hunyuan3DService {
  @override
  Future<GenerationResult> generateFromCAD(List<String> fileUrls) async {
    return super.noSuchMethod(
      Invocation.method(#generateFromCAD, [fileUrls]),
      returnValue: Future.value(GenerationResult(
        jobId: 'test-job-${DateTime.now().millisecondsSinceEpoch}',
        status: 'processing',
        estimatedTime: Duration(seconds: 30),
      )),
    );
  }

  @override
  Future<GenerationStatus> checkStatus(String jobId) async {
    return super.noSuchMethod(
      Invocation.method(#checkStatus, [jobId]),
      returnValue: Future.value(GenerationStatus(
        jobId: jobId,
        status: 'completed',
        progress: 100,
        modelUrl: 'https://example.com/generated/model.glb',
        processingTime: Duration(seconds: 45),
      )),
    );
  }

  @override
  Future<File> downloadModel(String modelUrl, String savePath) async {
    return super.noSuchMethod(
      Invocation.method(#downloadModel, [modelUrl, savePath]),
      returnValue: Future.value(File(savePath)),
    );
  }
}

/// Test file utilities
class TestFileUtils {
  static Future<File> createTestFile({
    String name = 'test_file.pdf',
    int size = 1024,
    String content = 'test content',
  }) async {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$name');
    await file.writeAsString(content * (size ~/ content.length));
    return file;
  }

  static Future<File> createTestCADFile({
    String extension = 'pdf',
    int size = 1024,
  }) async {
    return createTestFile(
      name: 'test_cad.$extension',
      size: size,
      content: 'CAD file content',
    );
  }

  static Future<void> cleanupTestFiles() async {
    final tempDir = Directory.systemTemp;
    final files = tempDir.listSync().where((f) => f.path.contains('test_'));
    for (final file in files) {
      await file.delete();
    }
  }
}

/// Test model factory
class TestModelFactory {
  static Map<String, dynamic> createModelData({
    String id = 'test-model-id',
    String name = 'Test Model',
    String description = 'Test description',
    String userId = 'test-user-id',
    List<String> cadFileUrls = const [],
    String modelType = 'cad_based',
    int sourceFilesCount = 1,
  }) {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user_id': userId,
      'cad_file_urls': cadFileUrls,
      'model_type': modelType,
      'source_files_count': sourceFilesCount,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Test utilities for widget testing
class TestWidgetUtils {
  static Future<void> pumpWithProviders(
    WidgetTester tester,
    Widget widget, {
    List<Override>? overrides,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          home: widget,
        ),
      ),
    );
  }
}

/// Custom matchers for testing
class CustomMatchers {
  static Matcher hasStatusCode(int expected) => _StatusCodeMatcher(expected);
  static Matcher completesWithSuccess() => _SuccessMatcher();
}

class _StatusCodeMatcher extends Matcher {
  final int expected;
  const _StatusCodeMatcher(this.expected);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Future) return false;
    return item?.statusCode == expected;
  }

  @override
  Description describe(Description description) =>
      description.add('has status code $expected');
}

class _SuccessMatcher extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Future) return false;
    return item?.success == true;
  }

  @override
  Description describe(Description description) =>
      description.add('completes with success');
}