class FaceRegistrationResponse {
  final String userId;
  final int faissIndexId;
  final bool faceDetected;
  final double qualityScore;
  final String? imageUrl;

  FaceRegistrationResponse({
    required this.userId,
    required this.faissIndexId,
    required this.faceDetected,
    required this.qualityScore,
    this.imageUrl,
  });

  factory FaceRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return FaceRegistrationResponse(
      userId: json['user_id'] as String,
      faissIndexId: json['faiss_index_id'] as int,
      faceDetected: json['face_detected'] as bool? ?? true,
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'faiss_index_id': faissIndexId,
      'face_detected': faceDetected,
      'quality_score': qualityScore,
      'image_url': imageUrl,
    };
  }
}

class FaceRecognitionResponse {
  final bool matched;
  final String? userId;
  final String? name;
  final double confidence;
  final List<AlternativeMatch>? alternatives;
  final int processingTimeMs;

  FaceRecognitionResponse({
    required this.matched,
    this.userId,
    this.name,
    required this.confidence,
    this.alternatives,
    required this.processingTimeMs,
  });

  factory FaceRecognitionResponse.fromJson(Map<String, dynamic> json) {
    return FaceRecognitionResponse(
      matched: json['matched'] as bool,
      userId: json['user_id'] as String?,
      name: json['name'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      alternatives: json['alternatives'] != null
          ? (json['alternatives'] as List)
              .map((e) => AlternativeMatch.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      processingTimeMs: json['processing_time_ms'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matched': matched,
      'user_id': userId,
      'name': name,
      'confidence': confidence,
      'alternatives': alternatives?.map((e) => e.toJson()).toList(),
      'processing_time_ms': processingTimeMs,
    };
  }
}

class AlternativeMatch {
  final String userId;
  final String name;
  final double confidence;

  AlternativeMatch({
    required this.userId,
    required this.name,
    required this.confidence,
  });

  factory AlternativeMatch.fromJson(Map<String, dynamic> json) {
    return AlternativeMatch(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'confidence': confidence,
    };
  }
}

class HealthCheckResponse {
  final String status;
  final int faissIndexSize;
  final bool modelLoaded;
  final bool mongodbConnected;

  HealthCheckResponse({
    required this.status,
    required this.faissIndexSize,
    required this.modelLoaded,
    required this.mongodbConnected,
  });

  factory HealthCheckResponse.fromJson(Map<String, dynamic> json) {
    return HealthCheckResponse(
      status: json['status'] as String,
      faissIndexSize: json['faiss_index_size'] as int? ?? 0,
      modelLoaded: json['model_loaded'] as bool? ?? false,
      mongodbConnected: json['mongodb_connected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'faiss_index_size': faissIndexSize,
      'model_loaded': modelLoaded,
      'mongodb_connected': mongodbConnected,
    };
  }
}