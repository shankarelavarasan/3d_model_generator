class ModelModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String originalImageUrl;
  final String? generatedModelUrl;
  final List<String> cadFileUrls;
  final String? thumbnailUrl;
  final ModelStatus status;
  final ModelType modelType;
  final int? fileSize;
  final int? verticesCount;
  final int? facesCount;
  final int? processingTimeMs;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ModelModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.originalImageUrl,
    this.generatedModelUrl,
    this.cadFileUrls = const [],
    this.thumbnailUrl,
    this.status = ModelStatus.pending,
    this.modelType = ModelType.obj,
    this.fileSize,
    this.verticesCount,
    this.facesCount,
    this.processingTimeMs,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModelModel.fromJson(Map<String, dynamic> json) => ModelModel(
    id: json['id'],
    userId: json['user_id'],
    title: json['title'],
    description: json['description'],
    originalImageUrl: json['original_image_url'],
    generatedModelUrl: json['generated_model_url'],
    cadFileUrls: List<String>.from(json['cad_file_urls'] ?? []),
    thumbnailUrl: json['thumbnail_url'],
    status: ModelStatus.values.firstWhere((e) => e.name == json['status']),
    modelType: ModelType.values.firstWhere((e) => e.name == json['model_type']),
    fileSize: json['file_size'],
    verticesCount: json['vertices_count'],
    facesCount: json['faces_count'],
    processingTimeMs: json['processing_time_ms'],
    errorMessage: json['error_message'],
    createdAt: DateTime.parse(json['created_at']),
    updatedAt: DateTime.parse(json['updated_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'original_image_url': originalImageUrl,
    'generated_model_url': generatedModelUrl,
    'cad_file_urls': cadFileUrls,
    'thumbnail_url': thumbnailUrl,
    'status': status.name,
    'model_type': modelType.name,
    'file_size': fileSize,
    'vertices_count': verticesCount,
    'faces_count': facesCount,
    'processing_time_ms': processingTimeMs,
    'error_message': errorMessage,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

enum ModelStatus { pending, processing, completed, failed }
enum ModelType { obj, stl, gltf, fbx }