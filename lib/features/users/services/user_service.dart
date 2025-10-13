import '../../../core/api/api_client.dart';
import '../../../core/api/api_exceptions.dart';
import '../models/user.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<List<AppUser>> getAllUsers() async {
    try {
      final response = await _apiClient.getAllUsers();

      if (response.data['success'] == true) {
        final List<dynamic> usersJson = response.data['data']['users'];
        return usersJson.map((json) => AppUser.fromJson(json)).toList();
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to get users',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to get users: $e');
    }
  }

  Future<AppUser> getUserById(String userId) async {
    try {
      final response = await _apiClient.getUserById(userId);

      if (response.data['success'] == true) {
        final userJson = response.data['data']['user'];
        return AppUser.fromJson(userJson);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to get user',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to get user: $e');
    }
  }

  Future<AppUser> updateUser(
    String userId, {
    String? name,
    String? email,
    String? phone,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _apiClient.updateUser(userId, data);

      if (response.data['success'] == true) {
        final userJson = response.data['data'];
        return AppUser.fromJson({
          ...userJson,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to update user',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await _apiClient.deleteUser(userId);

      if (response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to delete user',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to delete user: $e');
    }
  }

  Future<Map<String, int>> getStats() async {
    try {
      final response = await _apiClient.getStats();

      if (response.data['success'] == true) {
        final stats = response.data['data'];
        return {
          'total_users': stats['total_users'] as int,
          'total_embeddings': stats['total_embeddings'] as int,
          'active_users': stats['active_users'] as int,
        };
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to get stats',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Failed to get stats: $e');
    }
  }
}