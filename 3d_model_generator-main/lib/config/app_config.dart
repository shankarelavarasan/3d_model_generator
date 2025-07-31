class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL', 
      defaultValue: 'https://your-project.supabase.co');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', 
      defaultValue: 'your-anon-key');
  
  // Open-Source API Configuration
  static const String cadProcessorEndpoint = String.fromEnvironment('CAD_PROCESSOR_URL', 
      defaultValue: 'http://localhost:5000');
  static const String hunyuan3dEndpoint = String.fromEnvironment('HUNYUAN3D_URL', 
      defaultValue: 'http://localhost:8080');
  static const String hunyuan3dApiKey = String.fromEnvironment('HUNYUAN3D_API_KEY', 
      defaultValue: '');
  
  // Feature Flags
  static const bool useLocalProcessing = bool.fromEnvironment('USE_LOCAL_PROCESSING', 
      defaultValue: true);
  static const bool enableDebugMode = bool.fromEnvironment('DEBUG_MODE', 
      defaultValue: true);
  
  // Storage Configuration
  static const String storageBucket = '3d-uploads';
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedExtensions = [
    'pdf', 'dwg', 'dxf', 'step', 'stp', 'iges', 'igs', 'stl', 'obj'
  ];
  
  // Processing Limits
  static const int maxFilesPerUpload = 3;
  static const int maxProcessingTime = 3600; // 1 hour in seconds
  
  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100; // number of models
  
  // Validation
  static bool isValidFileExtension(String extension) {
    return allowedExtensions.contains(extension.toLowerCase());
  }
  
  static bool isValidFileSize(int size) {
    return size <= maxFileSize;
  }
  
  static String get cadEndpoint => useLocalProcessing ? cadProcessorEndpoint : 
      'https://api.hunyuan3d.com';
}