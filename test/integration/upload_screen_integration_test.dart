import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/screens/upload_screen.dart';
import '../lib/services/upload_service.dart';
import '../lib/services/cad_processing_service.dart';
import '../test_helpers/mock_services.dart';

void main() {
  group('UploadScreen Integration Tests', () {
    late MockUploadService mockUploadService;
    late MockCADProcessingService mockCADProcessingService;

    setUp(() {
      mockUploadService = MockUploadService();
      mockCADProcessingService = MockCADProcessingService();
    });

    group('CAD file selection', () {
      testWidgets('should display selected CAD files', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Verify initial state
        expect(find.text('Upload CAD Files'), findsOneWidget);
        expect(find.text('No CAD files selected'), findsOneWidget);

        // Simulate file selection
        final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
        uploadScreen.onFilesSelected([
          'test1.pdf',
          'test2.dwg',
          'test3.dxf',
        ]);

        await tester.pumpAndSettle();

        // Verify file display
        expect(find.text('3 CAD files selected'), findsOneWidget);
        expect(find.text('test1.pdf'), findsOneWidget);
        expect(find.text('test2.dwg'), findsOneWidget);
        expect(find.text('test3.dxf'), findsOneWidget);
      });

      testWidgets('should enable upload button when files are selected', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Initially disabled
        final uploadButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(uploadButton.enabled, isFalse);

        // Select files
        final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
        uploadScreen.onFilesSelected(['test.pdf']);
        await tester.pumpAndSettle();

        // Should be enabled
        final updatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(updatedButton.enabled, isTrue);
      });

      testWidgets('should handle file count limit', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Try to select more than 5 files
        final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
        uploadScreen.onFilesSelected(
          List.generate(6, (i) => 'file$i.pdf'),
        );
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Maximum 5 files allowed'), findsOneWidget);
      });
    });

    group('upload flow', () {
      testWidgets('should complete successful upload flow', (WidgetTester tester) async {
        // Setup mocks
        when(mockUploadService.uploadCADFile(any, any))
            .thenAnswer((_) async => 'https://storage.supabase.co/uploaded/file.pdf');
        when(mockCADProcessingService.processCADFiles(any, any))
            .thenAnswer((_) async => CADProcessingResult(
                  success: true,
                  modelUrl: 'https://storage.supabase.co/models/model.glb',
                  processingTime: Duration(seconds: 30),
                  fileSize: 1024000,
                ));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Select files
        final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
        uploadScreen.onFilesSelected(['test.pdf', 'test.dwg']);
        await tester.pumpAndSettle();

        // Start upload
        await tester.tap(find.text('Generate 3D Model from CAD Files'));
        await tester.pumpAndSettle();

        // Verify upload started
        verify(mockUploadService.uploadCADFile(any, any)).called(2);
        verify(mockCADProcessingService.processCADFiles(any, any)).called(1);

        // Verify success state
        expect(find.text('Processing...'), findsOneWidget);
        expect(find.text('Upload completed successfully'), findsOneWidget);
      });

      testWidgets('should handle upload errors gracefully', (WidgetTester tester) async {
        // Setup error mock
        when(mockUploadService.uploadCADFile(any, any))
            .thenThrow(Exception('Upload failed'));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Select files and start upload
        final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
        uploadScreen.onFilesSelected(['test.pdf']);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate 3D Model from CAD Files'));
        await tester.pumpAndSettle();

        // Verify error handling
        expect(find.text('Upload failed'), findsOneWidget);
        expect(find.text('Error: Upload failed'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });
    });

    group('progress tracking', () {
      testWidgets('should show real-time progress', (WidgetTester tester) async {
        // Setup mock with progress updates
        when(mockUploadService.uploadCADFile(any, any))
            .thenAnswer((_) async => 'https://storage.supabase.co/uploaded/file.pdf');
        when(mockCADProcessingService.processCADFiles(any, any))
            .thenAnswer((_) async {
          await Future.delayed(Duration(seconds: 1)); // Simulate processing
          return CADProcessingResult(
            success: true,
            modelUrl: 'https://storage.supabase.co/models/model.glb',
            processingTime: Duration(seconds: 30),
            fileSize: 1024000,
          );
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Start upload
        final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
        uploadScreen.onFilesSelected(['test.pdf']);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate 3D Model from CAD Files'));
        await tester.pump();

        // Check progress indicators
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle(Duration(seconds: 2));

        // Check completion
        expect(find.text('Processing...'), findsNothing);
        expect(find.text('Upload completed successfully'), findsOneWidget);
      });
    });

    group('file validation', () {
      testWidgets('should validate file types before upload', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Try to select invalid file type
        final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
        uploadScreen.onFilesSelected(['test.txt', 'test.exe']);
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Invalid file type'), findsOneWidget);
        expect(find.text('Supported: PDF, DWG, DXF'), findsOneWidget);
      });

      testWidgets('should validate file size limits', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Create mock for oversized file
        when(mockUploadService.uploadCADFile(any, any))
            .thenThrow(Exception('File too large'));

        // Try to upload large file
        final uploadScreen = tester.widget<UploadScreen>(find.byType(UploadScreen));
        uploadScreen.onFilesSelected(['large_file.pdf']);
        await tester.pumpAndSettle();

        await tester.tap(find.text('Generate 3D Model from CAD Files'));
        await tester.pumpAndSettle();

        // Should show size error
        expect(find.text('File too large'), findsOneWidget);
        expect(find.text('Maximum 50MB per file'), findsOneWidget);
      });
    });

    group('UI responsiveness', () {
      testWidgets('should be responsive on different screen sizes', (WidgetTester tester) async {
        // Test on mobile size
        tester.binding.window.physicalSizeTestValue = Size(375, 667);
        tester.binding.window.devicePixelRatioTestValue = 2.0;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              uploadServiceProvider.overrideWithValue(mockUploadService),
              cadProcessingServiceProvider.overrideWithValue(mockCADProcessingService),
            ],
            child: MaterialApp(home: UploadScreen()),
          ),
        );

        // Verify mobile layout
        expect(find.byType(Column), findsWidgets);

        // Test on tablet size
        tester.binding.window.physicalSizeTestValue = Size(768, 1024);
        await tester.pumpAndSettle();

        // Verify tablet layout
        expect(find.byType(Row), findsWidgets);
      });
    });

    tearDown(() async {
      await TestFileUtils.cleanupTestFiles();
    });
  });
}