import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/pdf_upload/pdf_upload.dart';
import '../presentation/export_options/export_options.dart';
import '../presentation/model_library/model_library.dart';
import '../presentation/processing_status/processing_status.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/user_profile/user_profile.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String pdfUpload = '/pdf-upload';
  static const String exportOptions = '/export-options';
  static const String modelLibrary = '/model-library';
  static const String threeDModelViewer = '/3d-model-viewer';
  static const String processingStatus = '/processing-status';
  static const String splashScreen = '/splash-screen';
  static const String userProfile = '/user-profile';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => SplashScreen(),
    loginScreen: (context) => LoginScreen(),
    pdfUpload: (context) => PdfUpload(),
    exportOptions: (context) => ExportOptions(),
    modelLibrary: (context) => ModelLibrary(),
    processingStatus: (context) => ProcessingStatus(),
    splashScreen: (context) => SplashScreen(),
    userProfile: (context) => UserProfile(),
    // TODO: Add your other routes here
  };
}
