import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user.dart';
import '../../../core/api/api_exceptions.dart';
import 'user_service_provider.dart';

// Users State
class UsersState {
  final List<AppUser> users;
  final bool isLoading;
  final String? errorMessage;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  UsersState copyWith({
    List<AppUser>? users,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Users Notifier
class UsersNotifier extends StateNotifier<UsersState> {
  final Ref ref;

  UsersNotifier(this.ref) : super(const UsersState());

  // Load all users
  Future<void> loadUsers() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final service = ref.read(userServiceProvider);
      final users = await service.getAllUsers();

      state = state.copyWith(
        users: users,
        isLoading: false,
      );
    } on ApiException catch (e) {
      debugPrint('❌ API error: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      debugPrint('❌ Error loading users: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load users: $e',
      );
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      final service = ref.read(userServiceProvider);
      await service.deleteUser(userId);

      // Remove user from local state
      state = state.copyWith(
        users: state.users.where((u) => u.userId != userId).toList(),
      );

      return true;
    } on ApiException catch (e) {
      debugPrint('❌ API error: ${e.message}');
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      state = state.copyWith(errorMessage: 'Failed to delete user: $e');
      return false;
    }
  }

  // Update user
  Future<bool> updateUser(
    String userId, {
    String? name,
    String? email,
    String? phone,
    bool? isActive,
  }) async {
    try {
      final service = ref.read(userServiceProvider);
      final updatedUser = await service.updateUser(
        userId,
        name: name,
        email: email,
        phone: phone,
        isActive: isActive,
      );

      // Update user in local state
      state = state.copyWith(
        users: state.users.map((u) {
          if (u.userId == userId) {
            return updatedUser;
          }
          return u;
        }).toList(),
      );

      return true;
    } on ApiException catch (e) {
      debugPrint('❌ API error: ${e.message}');
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      state = state.copyWith(errorMessage: 'Failed to update user: $e');
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider Definition
final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref);
});