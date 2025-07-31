import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/cad_processing_service.dart';
import '../../services/upload_service.dart';
import '../../services/auth_service.dart';
import '../../services/cache_service.dart';
import '../../services/hunyuan3d_service.dart';
import '../error/error_handler.dart';
import '../cache/cache_manager.dart';
import '../monitoring/performance_monitor.dart';

final GetIt locator = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core services - Singletons
  locator.registerSingleton<SupabaseClient>(Supabase.instance.client);
  locator.registerSingleton<ErrorHandler>(ErrorHandler());
  locator.registerSingleton<CacheManager>(CacheManager());
  locator.registerSingleton<PerformanceMonitor>(PerformanceMonitor());

  // Services - Factory (new instance each time)
  locator.registerFactory<CADProcessingService>(() => CADProcessingService(
        client: locator<SupabaseClient>(),
        cache: locator<CacheManager>(),
        monitor: locator<PerformanceMonitor>(),
      ));

  locator.registerFactory<UploadService>(() => UploadService(
        client: locator<SupabaseClient>(),
        cache: locator<CacheManager>(),
      ));

  locator.registerFactory<AuthService>(() => AuthService(
        client: locator<SupabaseClient>(),
      ));

  locator.registerFactory<Hunyuan3DService>(() => Hunyuan3DService(
        cache: locator<CacheManager>(),
        monitor: locator<PerformanceMonitor>(),
      ));
}

void resetServiceLocator() {
  locator.reset();
}