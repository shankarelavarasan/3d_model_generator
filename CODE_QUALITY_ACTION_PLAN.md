# Code Quality Action Plan

## Executive Summary
This action plan provides concrete, step-by-step instructions to implement the code quality improvements discussed in the testing and quality enhancement phase.

## Implementation Phases

### Phase 1: Immediate Fixes (Day 1-2)
**Priority: Critical**

#### 1.1 Fix Missing Imports
**File**: `lib/screens/upload_screen.dart`
```dart
// Add these imports at the top
import '../services/cad_processing_service.dart';
import '../services/service_locator.dart';
```

#### 1.2 Implement Service Locator
**File**: `lib/main.dart`
```dart
import 'services/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(MyApp());
}
```

#### 1.3 Update Error Handling
**File**: `lib/screens/upload_screen.dart`
```dart
// Replace try-catch blocks with proper error handling
try {
  await _uploadModel();
} on CADProcessingException catch (e) {
  _showError('CAD Processing Error: ${e.message}');
} on NetworkException catch (e) {
  _showError('Network Error: ${e.message}');
} catch (e) {
  _showError('Unexpected error occurred');
  serviceLocator<ErrorHandler>().logError(e, StackTrace.current);
}
```

### Phase 2: Architecture Refactoring (Day 3-5)
**Priority: High**

#### 2.1 Create Repository Pattern
**File**: `lib/repositories/model_repository.dart`
```dart
abstract class ModelRepository {
  Future<ModelModel> createModel(ModelModel model);
  Future<ModelModel> updateModel(String id, ModelModel model);
  Future<List<ModelModel>> getUserModels(String userId);
  Future<ModelModel?> getModelById(String id);
}

class SupabaseModelRepository implements ModelRepository {
  final SupabaseClient _client;
  
  SupabaseModelRepository(this._client);
  
  @override
  Future<ModelModel> createModel(ModelModel model) async {
    final response = await _client
        .from('models')
        .insert(model.toJson())
        .select()
        .single();
    return ModelModel.fromJson(response);
  }
}
```

#### 2.2 Implement State Management
**File**: `lib/providers/upload_provider.dart`
```dart
class UploadState {
  final List<String> selectedFiles;
  final UploadStatus status;
  final double progress;
  final String? error;
  final ModelModel? result;

  UploadState({
    this.selectedFiles = const [],
    this.status = UploadStatus.idle,
    this.progress = 0.0,
    this.error,
    this.result,
  });
}

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier(this._repository, this._processingService) : super(UploadState());
  
  final ModelRepository _repository;
  final CADProcessingService _processingService;
  
  Future<void> uploadFiles() async {
    state = state.copyWith(status: UploadStatus.uploading, progress: 0.0);
    
    try {
      // Implementation here
    } catch (e) {
      state = state.copyWith(error: e.toString(), status: UploadStatus.error);
    }
  }
}
```

### Phase 3: Performance Optimization (Day 6-7)
**Priority: Medium**

#### 3.1 Implement Caching
**File**: `lib/services/cache_service.dart`
```dart
class CacheService {
  static const String _modelsKey = 'cached_models';
  static const Duration _cacheDuration = Duration(minutes: 30);

  Future<void> cacheModels(List<ModelModel> models) async {
    final cacheData = {
      'models': models.map((m) => m.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await serviceLocator<CacheManager>().set(_modelsKey, cacheData);
  }

  Future<List<ModelModel>?> getCachedModels() async {
    final cacheData = await serviceLocator<CacheManager>().get(_modelsKey);
    if (cacheData == null) return null;
    
    final timestamp = DateTime.parse(cacheData['timestamp']);
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      return null; // Cache expired
    }
    
    return (cacheData['models'] as List)
        .map((m) => ModelModel.fromJson(m))
        .toList();
  }
}
```

#### 3.2 Optimize Image Loading
**File**: `lib/widgets/optimized_image.dart`
```dart
class OptimizedImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const OptimizedImage({
    required this.url,
    this.width = 100,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(width: width, height: height, color: Colors.white),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      memCacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
    );
  }
}
```

### Phase 4: Testing Infrastructure (Day 8-10)
**Priority: Medium**

#### 4.1 Set Up Testing Framework
**Commands to run**:
```bash
# Install testing dependencies
flutter pub add dev:flutter_test
flutter pub add dev:mockito
flutter pub add dev:build_runner
flutter pub add dev:integration_test

# Generate mocks
flutter pub run build_runner build
```

#### 4.2 Create Test Configuration
**File**: `test/test_config.dart`
```dart
class TestConfig {
  static const String testUserId = 'test-user-123';
  static const String testModelId = 'test-model-456';
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  static Map<String, dynamic> get testModelJson => {
    'id': testModelId,
    'user_id': testUserId,
    'name': 'Test Model',
    'cad_file_urls': ['test.pdf', 'test.dwg'],
    'model_url': 'test.glb',
    'created_at': DateTime.now().toIso8601String(),
  };
}
```

### Phase 5: Monitoring and Logging (Day 11-12)
**Priority: Low**

#### 5.1 Implement Analytics
**File**: `lib/services/analytics_service.dart`
```dart
class AnalyticsService {
  static const String _eventUploadStart = 'upload_start';
  static const String _eventUploadSuccess = 'upload_success';
  static const String _eventUploadError = 'upload_error';

  Future<void> trackUploadStart(List<String> fileTypes) async {
    await FirebaseAnalytics.instance.logEvent(
      name: _eventUploadStart,
      parameters: {
        'file_count': fileTypes.length,
        'file_types': fileTypes.join(','),
      },
    );
  }

  Future<void> trackUploadSuccess(
    String modelId,
    Duration processingTime,
    int fileSize,
  ) async {
    await FirebaseAnalytics.instance.logEvent(
      name: _eventUploadSuccess,
      parameters: {
        'model_id': modelId,
        'processing_time': processingTime.inSeconds,
        'file_size': fileSize,
      },
    );
  }
}
```

## Implementation Checklist

### Setup Phase
- [ ] Install all testing dependencies
- [ ] Set up service locator
- [ ] Configure error handling
- [ ] Set up caching

### Code Quality Phase
- [ ] Refactor to repository pattern
- [ ] Implement state management
- [ ] Add comprehensive logging
- [ ] Set up performance monitoring

### Testing Phase
- [ ] Write unit tests for all services
- [ ] Write integration tests for upload flow
- [ ] Set up CI/CD pipeline
- [ ] Add code coverage reporting

### Monitoring Phase
- [ ] Add crash reporting
- [ ] Implement analytics
- [ ] Set up performance monitoring
- [ ] Create alerting system

## Quick Commands Reference

### Development
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage

# Generate mocks
flutter pub run build_runner build

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Debugging
```bash
# Debug tests
flutter test --start-paused

# Verbose output
flutter test -v

# Run specific test
flutter test --name "should validate CAD file"
```

### Performance
```bash
# Profile app
flutter run --profile

# Check build size
flutter build apk --analyze-size

# Memory profiling
flutter run --profile --trace-startup
```

## Validation Criteria

### Before Release
- [ ] All tests passing
- [ ] Code coverage > 80%
- [ ] No lint warnings
- [ ] Performance benchmarks met
- [ ] Security scan passed

### Quality Metrics
- **Test Coverage**: Target > 80%
- **Build Time**: < 2 minutes
- **App Size**: < 50MB
- **Memory Usage**: < 200MB
- **Crash Rate**: < 0.1%

## Support and Resources

### Documentation
- [Testing Guide](TESTING_GUIDE.md)
- [Integration Guide](INTEGRATION_GUIDE.md)
- [Code Quality Improvements](CODE_QUALITY_IMPROVEMENTS.md)

### Tools
- **VS Code Extensions**: Flutter, Dart, GitLens
- **Performance**: Flutter Inspector, Observatory
- **Testing**: Mockito, Integration Test

### Team Resources
- Code review guidelines
- Testing best practices
- Performance optimization tips
- Security checklist

## Next Steps

1. **Week 1**: Complete Phase 1 and 2
2. **Week 2**: Complete Phase 3 and 4
3. **Week 3**: Complete Phase 5 and final validation
4. **Week 4**: Performance optimization and monitoring setup

This action plan provides a systematic approach to improving code quality while maintaining development velocity. Each phase builds upon the previous one, ensuring a solid foundation for long-term maintainability.