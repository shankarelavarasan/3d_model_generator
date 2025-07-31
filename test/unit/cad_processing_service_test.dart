import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../test_helpers/mock_services.dart';
import '../lib/services/cad_processing_service.dart';
import '../lib/core/error/app_exceptions.dart';

void main() {
  group('CADProcessingService', () {
    late CADProcessingService cadProcessingService;
    late MockSupabaseClient mockClient;

    setUp(() {
      mockClient = MockSupabaseClient();
      cadProcessingService = CADProcessingService(
        client: mockClient,
        cache: MockCacheService(),
        monitor: PerformanceMonitor(),
      );
    });

    group('validateCADFile', () {
      test('should return true for valid PDF file', () async {
        final testFile = await TestFileUtils.createTestCADFile(extension: 'pdf');
        
        final result = await cadProcessingService.validateCADFile(testFile);
        
        expect(result, isTrue);
        
        await testFile.delete();
      });

      test('should return true for valid DWG file', () async {
        final testFile = await TestFileUtils.createTestCADFile(extension: 'dwg');
        
        final result = await cadProcessingService.validateCADFile(testFile);
        
        expect(result, isTrue);
        
        await testFile.delete();
      });

      test('should return false for invalid file type', () async {
        final testFile = await TestFileUtils.createTestFile(name: 'test.txt');
        
        final result = await cadProcessingService.validateCADFile(testFile);
        
        expect(result, isFalse);
        
        await testFile.delete();
      });

      test('should return false for empty file', () async {
        final testFile = await TestFileUtils.createTestFile(size: 0);
        
        final result = await cadProcessingService.validateCADFile(testFile);
        
        expect(result, isFalse);
        
        await testFile.delete();
      });

      test('should return false for oversized file', () async {
        final testFile = await TestFileUtils.createTestCADFile(size: 51 * 1024 * 1024); // 51MB
        
        final result = await cadProcessingService.validateCADFile(testFile);
        
        expect(result, isFalse);
        
        await testFile.delete();
      });
    });

    group('getProcessingRecommendations', () {
      test('should return recommendations for PDF file', () async {
        final testFile = await TestFileUtils.createTestCADFile(extension: 'pdf');
        
        final recommendations = await cadProcessingService.getProcessingRecommendations(testFile);
        
        expect(recommendations, isNotNull);
        expect(recommendations['recommended_format'], isNotNull);
        expect(recommendations['estimated_time'], isPositive);
        expect(recommendations['file_size'], equals(1024));
        
        await testFile.delete();
      });

      test('should handle different file types appropriately', () async {
        final pdfFile = await TestFileUtils.createTestCADFile(extension: 'pdf');
        final dwgFile = await TestFileUtils.createTestCADFile(extension: 'dwg');
        
        final pdfRecs = await cadProcessingService.getProcessingRecommendations(pdfFile);
        final dwgRecs = await cadProcessingService.getProcessingRecommendations(dwgFile);
        
        expect(pdfRecs['recommended_format'], isNot(equals(dwgRecs['recommended_format'])));
        
        await pdfFile.delete();
        await dwgFile.delete();
      });
    });

    group('processCADFiles', () {
      test('should successfully process valid CAD files', () async {
        final fileUrls = [
          'https://storage.supabase.co/test/file1.pdf',
          'https://storage.supabase.co/test/file2.dwg',
        ];
        const modelId = 'test-model-123';

        final result = await cadProcessingService.processCADFiles(fileUrls, modelId);
        
        expect(result.success, isTrue);
        expect(result.modelUrl, isNotNull);
        expect(result.processingTime, isNotNull);
        expect(result.fileSize, isPositive);
      });

      test('should handle empty file list', () async {
        const modelId = 'test-model-123';
        
        expect(
          () async => await cadProcessingService.processCADFiles([], modelId),
          throwsA(isA<CADProcessingException>()),
        );
      });

      test('should handle invalid file URLs', () async {
        final fileUrls = [
          'invalid-url',
          'https://storage.supabase.co/test/file.dwg',
        ];
        const modelId = 'test-model-123';

        final result = await cadProcessingService.processCADFiles(fileUrls, modelId);
        
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });

      test('should handle network errors gracefully', () async {
        final fileUrls = [
          'https://storage.supabase.co/test/file.pdf',
        ];
        const modelId = 'test-model-123';

        // Simulate network error
        when(mockClient.storage).thenThrow(Exception('Network error'));
        
        final result = await cadProcessingService.processCADFiles(fileUrls, modelId);
        
        expect(result.success, isFalse);
        expect(result.error, contains('Network error'));
      });

      test('should enforce file count limit', () async {
        final fileUrls = List.generate(6, (i) => 'https://storage.supabase.co/test/file$i.pdf');
        const modelId = 'test-model-123';

        expect(
          () async => await cadProcessingService.processCADFiles(fileUrls, modelId),
          throwsA(isA<CADProcessingException>()),
        );
      });
    });

    group('estimateProcessingTime', () {
      test('should estimate time based on file count and size', () {
        final fileUrls = [
          'https://storage.supabase.co/test/small.pdf',
          'https://storage.supabase.co/test/medium.dwg',
        ];
        
        final estimatedTime = cadProcessingService.estimateProcessingTime(fileUrls);
        
        expect(estimatedTime, isNotNull);
        expect(estimatedTime.inSeconds, greaterThan(0));
      });

      test('should handle single file', () {
        final fileUrls = ['https://storage.supabase.co/test/single.pdf'];
        
        final estimatedTime = cadProcessingService.estimateProcessingTime(fileUrls);
        
        expect(estimatedTime.inSeconds, greaterThan(0));
      });
    });

    group('error handling', () {
      test('should throw CADProcessingException for processing failures', () async {
        final fileUrls = ['https://storage.supabase.co/test/invalid.pdf'];
        const modelId = 'test-model-123';

        // Mock processing failure
        when(mockClient.storage).thenThrow(Exception('Processing failed'));
        
        final result = await cadProcessingService.processCADFiles(fileUrls, modelId);
        
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });

      test('should provide meaningful error messages', () async {
        final fileUrls = ['https://storage.supabase.co/test/malformed.dwg'];
        const modelId = 'test-model-123';

        final result = await cadProcessingService.processCADFiles(fileUrls, modelId);
        
        expect(result.error, isNotEmpty);
        expect(result.error, isNot(contains('Exception')));
      });
    });

    group('performance monitoring', () {
      test('should track processing performance', () async {
        final fileUrls = ['https://storage.supabase.co/test/test.pdf'];
        const modelId = 'test-model-123';

        final startTime = DateTime.now();
        final result = await cadProcessingService.processCADFiles(fileUrls, modelId);
        final endTime = DateTime.now();
        
        expect(result.processingTime, isNotNull);
        expect(result.processingTime, lessThanOrEqualTo(endTime.difference(startTime)));
      });
    });
  });
}