import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/services/service_providers.dart';
import '../models/statistics.dart';
import '../services/stats_service.dart';

// Stats Service Provider
final statsServiceProvider = Provider<StatsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StatsService(apiClient);
});

// Stats State
class StatsState {
  final Statistics? statistics;
  final bool isLoading;
  final String? errorMessage;

  const StatsState({
    this.statistics,
    this.isLoading = false,
    this.errorMessage,
  });

  StatsState copyWith({
    Statistics? statistics,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StatsState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Stats Notifier
class StatsNotifier extends StateNotifier<StatsState> {
  final Ref ref;

  StatsNotifier(this.ref) : super(const StatsState());

  Future<void> loadStats() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final service = ref.read(statsServiceProvider);
      final statistics = await service.getStatistics();

      state = state.copyWith(
        statistics: statistics,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load statistics',
      );
    }
  }

  void reset() {
    state = const StatsState();
  }
}

// Stats Provider
final statsProvider = StateNotifierProvider<StatsNotifier, StatsState>((ref) {
  return StatsNotifier(ref);
});