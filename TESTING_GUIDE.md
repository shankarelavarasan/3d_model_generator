# Comprehensive Testing Guide

## Overview
This guide provides complete instructions for setting up and running the test suite for the 3D Model Generator application, including unit tests, integration tests, and end-to-end testing.

## Test Architecture

### Test Types
- **Unit Tests**: Test individual functions and classes in isolation
- **Integration Tests**: Test component interactions and workflows
- **Widget Tests**: Test Flutter UI components and user interactions
- **End-to-End Tests**: Test complete user flows

### Test Structure
```
test/
├── unit/
│   ├── cad_processing_service_test.dart
│   ├── upload_service_test.dart
│   └── model_model_test.dart
├── integration/
│   ├── upload_screen_integration_test.dart
│   └── api_integration_test.dart
├── test_helpers/
│   ├── mock_services.dart
│   └── test_utils.dart
├── test_runner.dart
└── coverage/
```

## Setup Instructions

### 1. Install Testing Dependencies

Add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
  integration_test:
    sdk: flutter
  test: ^1.24.9
```

### 2. Generate Mocks

Run these commands to generate mock classes:
```bash
flutter pub get
flutter pub run build_runner build
```

### 3. Configure Test Environment

Create `test/test_config.dart`:
```dart
class TestConfig {
  static const String testApiBaseUrl = 'http://localhost:3000';
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const String testUserId = 'test-user-123';
  static const String testModelId = 'test-model-456';
}
```

## Running Tests

### Run All Tests
```bash
# Run all unit tests
flutter test test/unit/

# Run all integration tests
flutter test test/integration/

# Run specific test file
flutter test test/unit/cad_processing_service_test.dart

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Tests with Debugging
```bash
# Run with verbose output
flutter test -v

# Run specific test group
flutter test --name "CAD file selection"

# Run with debugging
flutter test --start-paused
```

## Test Categories

### Unit Tests

#### CAD Processing Service Tests
Tests the `CADProcessingService` class:
- File validation (PDF, DWG, DXF)
- Processing time estimation
- Error handling
- Performance monitoring

```bash
flutter test test/unit/cad_processing_service_test.dart
```

#### Upload Service Tests
Tests the `UploadService` class:
- File upload functionality
- MIME type detection
- Error handling
- Storage integration

#### Model Tests
Tests the `ModelModel` class:
- JSON serialization/deserialization
- Field validation
- Default values

### Integration Tests

#### Upload Screen Integration
Tests the complete upload flow:
- File selection and validation
- Upload progress tracking
- Error handling
- Success scenarios

```bash
flutter test integration_test/upload_screen_integration_test.dart
```

#### API Integration Tests
Tests API endpoints:
- Authentication flows
- File upload endpoints
- 3D generation endpoints
- Error responses

### Widget Tests

#### Upload Screen Widget Tests
Tests Flutter UI components:
- File selection widgets
- Progress indicators
- Error messages
- Responsive design

## Writing New Tests

### Best Practices

1. **Test Naming Convention**
   - Use descriptive test names: `should_return_true_for_valid_pdf_file`
   - Group related tests with `group()`
   - Use `given_when_then` structure

2. **Test Structure**
```dart
group('CAD Processing Service', () {
  late CADProcessingService service;

  setUp(() {
    service = CADProcessingService();
  });

  group('validateCADFile', () {
    test('should return true for valid PDF file', () async {
      // Given
      final file = await createTestFile('test.pdf');
      
      // When
      final result = await service.validateCADFile(file);
      
      // Then
      expect(result, isTrue);
    });
  });
});
```

3. **Mock Usage**
   - Use mocks for external dependencies
   - Verify mock interactions
   - Reset mocks between tests

4. **Test Data**
   - Use test utilities for consistent test data
   - Clean up test files after tests
   - Use small test files for speed

### Test Utilities

#### File Creation
```dart
class TestFileUtils {
  static Future<File> createTestCADFile({
    String extension = 'pdf',
    int size = 1024,
  }) async {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/test.$extension');
    await file.writeAsString('CAD test content' * (size ~/ 16));
    return file;
  }
}
```

#### Mock Setup
```dart
setUp(() {
  mockClient = MockSupabaseClient();
  mockStorage = MockSupabaseStorage();
  
  when(mockClient.storage).thenReturn(mockStorage);
  when(mockStorage.from(any)).thenReturn(MockSupabaseStorageBucket());
});
```

## Performance Testing

### Test Execution Time
Monitor test execution time:
```bash
flutter test --timeout 30s
```

### Memory Usage
Check for memory leaks:
```bash
flutter test --enable-experiment=non-nullable
```

### Coverage Analysis
Generate coverage reports:
```bash
flutter test --coverage
flutter pub run test_coverage
```

## CI/CD Integration

### GitHub Actions
Create `.github/workflows/test.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
    
    - run: flutter pub get
    
    - run: flutter analyze
    
    - run: flutter test --coverage
    
    - uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
```

### Pre-commit Hooks
Create `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: flutter-test
        name: Flutter Test
        entry: flutter test
        language: system
        files: \.(dart)$
```

## Test Data Management

### Test Files
Store test files in `test/fixtures/`:
```
test/fixtures/
├── cad_files/
│   ├── sample.pdf
│   ├── sample.dwg
│   └── sample.dxf
├── models/
│   └── sample.glb
└── images/
    └── sample.jpg
```

### Test Database
Use test database for integration tests:
```dart
class TestDatabase {
  static Future<void> setup() async {
    // Setup test database
  }
  
  static Future<void> teardown() async {
    // Cleanup test database
  }
}
```

## Debugging Tests

### Common Issues

1. **Async Tests Timing Out**
   - Increase timeout: `test('test', () async {}, timeout: Timeout(Duration(seconds: 60)))`
   - Use `pumpAndSettle()` for widget tests

2. **Mock Setup Issues**
   - Ensure mocks are reset between tests
   - Verify mock method signatures

3. **File System Issues**
   - Use unique file names
   - Clean up files in tearDown

### Debug Commands
```bash
# Run with debugging
flutter test --start-paused test/unit/cad_processing_service_test.dart

# Run with verbose output
flutter test -v

# Run specific test
flutter test --name "should validate PDF file"
```

## Test Reports

### Generate HTML Reports
```bash
flutter test --coverage
flutter pub run test_coverage
open coverage/html/index.html
```

### JSON Reports
```bash
flutter test --reporter json > test_results.json
```

## Monitoring and Alerts

### Test Failure Alerts
- Slack notifications
- Email alerts
- GitHub issue creation

### Performance Monitoring
- Test execution time trends
- Coverage percentage tracking
- Flaky test detection

## Maintenance

### Regular Tasks
- Update test dependencies
- Review and update test cases
- Clean up obsolete tests
- Update test documentation

### Test Review Checklist
- [ ] Test covers all edge cases
- [ ] Test is independent
- [ ] Test has proper assertions
- [ ] Test has meaningful name
- [ ] Test is fast and reliable
- [ ] Test has proper setup/teardown

## Support

For testing support:
1. Check existing test examples
2. Review test documentation
3. Use test utilities
4. Ask team for help

## Quick Start Commands

```bash
# Setup
flutter pub get
flutter pub run build_runner build

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Generate coverage report
flutter pub run test_coverage
```