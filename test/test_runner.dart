import 'package:flutter_test/flutter_test.dart';

// Import all test files
import 'unit/cad_processing_service_test.dart' as cad_processing_service_test;
import 'integration/upload_screen_integration_test.dart' as upload_screen_integration_test;

void main() {
  group('All Tests', () {
    cad_processing_service_test.main();
    upload_screen_integration_test.main();
  });
}