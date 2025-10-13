class RecognitionResult {
  final bool matched;
  final String? userId;
  final String? name;
  final double confidence;
  final int processingTimeMs;
  final List<AlternativeMatch>? alternatives;

  RecognitionResult({
    required this.matched,
    this.userId,
    this.name,
    required this.confidence,
    required this.processingTimeMs,
    this.alternatives,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      matched: json['matched'] as bool,
      userId: json['user_id'] as String?,
      name: json['name'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      processingTimeMs: json['processing_time_ms'] as int? ?? 0,
      alternatives: json['alternatives'] != null
          ? (json['alternatives'] as List)
              .map((e) => AlternativeMatch.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
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
}