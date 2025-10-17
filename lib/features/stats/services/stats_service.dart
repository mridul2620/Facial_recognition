import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../models/statistics.dart';

class StatsService {
  final ApiClient _apiClient;

  StatsService(this._apiClient);

  Future<Statistics> getStatistics() async {
    try {
      final response = await _apiClient.getStats();

      if (response.data['success'] == true) {
        return Statistics.fromJson(response.data['data']);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to get statistics',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to get statistics: $e');
    }
  }
}