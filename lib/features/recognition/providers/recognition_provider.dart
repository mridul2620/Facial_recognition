import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/recognition_result.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/api/api_exceptions.dart';

// Recognition State
enum RecognitionStatus {
  initial,
  processing,
  success,
  noMatch,
  error,
}

class RecognitionState {
  final RecognitionStatus status;
  final String? errorMessage;
  final RecognitionResult? result;

  const RecognitionState({
    this.status = RecognitionStatus.initial,
    this.errorMessage,
    this.result,
  });

  RecognitionState copyWith({
    RecognitionStatus? status,
    String? errorMessage,
    RecognitionResult? result,
  }) {
    return RecognitionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      result: result ?? this.result,
    );
  }

  bool get isLoading => status == RecognitionStatus.processing;
}

// Recognition Notifier using StateNotifier
class RecognitionNotifier extends StateNotifier<RecognitionState> {
  final Ref ref;

  RecognitionNotifier(this.ref) : super(const RecognitionState());

  // Recognize Face
  Future<bool> recognizeFace({
    required File imageFile,
    double threshold = 0.6,
    int topK = 5,
  }) async {
    try {
      debugPrint('\n🔍 Starting face recognition...');
      debugPrint('📂 Image file: ${imageFile.path}');
      debugPrint('🎯 Threshold: $threshold');
      debugPrint('🔢 Top K: $topK');
      
      state = state.copyWith(status: RecognitionStatus.processing);

      // Get the service
      final service = ref.read(faceRecognitionServiceProvider);
      debugPrint('✅ Service obtained');

      // Call API
      debugPrint('📡 Calling API...');
      final response = await service.recognizeFace(
        imageFile: imageFile,
        threshold: threshold,
        topK: topK,
        onUploadProgress: (progress) {
          debugPrint('📤 Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      debugPrint('✅ API call completed');
      debugPrint('📊 Response: matched=${response.matched}, name=${response.name}, confidence=${response.confidence}');

      // Create result
      final result = RecognitionResult(
        matched: response.matched,
        userId: response.userId,
        name: response.name,
        confidence: response.confidence,
        processingTimeMs: response.processingTimeMs,
        alternatives: response.alternatives
            ?.map(
              (alt) => AlternativeMatch(
                userId: alt.userId,
                name: alt.name,
                confidence: alt.confidence,
              ),
            )
            .toList(),
      );

      if (response.matched) {
        debugPrint('✅ Match found!');
        state = state.copyWith(
          status: RecognitionStatus.success,
          result: result,
        );
      } else {
        debugPrint('⚠️  No match found');
        state = state.copyWith(
          status: RecognitionStatus.noMatch,
          result: result,
        );
      }

      return response.matched;
    } on ApiException catch (e) {
      debugPrint('❌ API error: ${e.message}');
      debugPrint('❌ Status code: ${e.statusCode}');
      state = state.copyWith(
        status: RecognitionStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ Recognition error: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      state = state.copyWith(
        status: RecognitionStatus.error,
        errorMessage: 'Failed to recognize: $e',
      );
      return false;
    }
  }

  // Reset state
  void reset() {
    state = const RecognitionState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(
      status: RecognitionStatus.initial,
      errorMessage: null,
    );
  }
}

// Provider Definition
final recognitionProvider =
    StateNotifierProvider<RecognitionNotifier, RecognitionState>((ref) {
  return RecognitionNotifier(ref);
});