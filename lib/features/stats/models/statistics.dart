class Statistics {
  final int totalUsers;
  final int activeUsers;
  final int totalEmbeddings;
  final int recognitionsToday;
  final double successRate;
  final List<TopUser> topRecognizedUsers;
  final double avgConfidence;

  Statistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalEmbeddings,
    required this.recognitionsToday,
    required this.successRate,
    required this.topRecognizedUsers,
    required this.avgConfidence,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalUsers: json['total_users'] as int? ?? 0,
      activeUsers: json['active_users'] as int? ?? 0,
      totalEmbeddings: json['total_embeddings'] as int? ?? 0,
      recognitionsToday: json['recognitions_today'] as int? ?? 0,
      successRate: (json['success_rate'] as num?)?.toDouble() ?? 0.0,
      topRecognizedUsers: (json['top_recognized_users'] as List?)
              ?.map((e) => TopUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      avgConfidence: (json['avg_confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TopUser {
  final String userId;
  final String name;
  final int recognitionCount;

  TopUser({
    required this.userId,
    required this.name,
    required this.recognitionCount,
  });

  factory TopUser.fromJson(Map<String, dynamic> json) {
    return TopUser(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      recognitionCount: json['recognition_count'] as int,
    );
  }
}