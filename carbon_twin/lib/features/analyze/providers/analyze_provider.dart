import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api_client.dart';

class AnalyzeState {
  final String status; // idle, uploading, done, error
  final Map<String, dynamic>? results;
  final String? error;

  AnalyzeState({this.status = 'idle', this.results, this.error});

  AnalyzeState copyWith({String? status, Map<String, dynamic>? results, String? error}) {
    return AnalyzeState(
      status: status ?? this.status,
      results: results ?? this.results,
      error: error,
    );
  }
}

class AnalyzeNotifier extends StateNotifier<AnalyzeState> {
  final Dio dio;

  AnalyzeNotifier(this.dio) : super(AnalyzeState());

  Future<void> analyzeImage(XFile imageFile) async {
    state = AnalyzeState(status: 'uploading');

    try {
      final bytes = await imageFile.readAsBytes();
      final formData = FormData.fromMap({
        'receipt': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name,
        ),
      });

      final response = await dio.post('/ocr', data: formData);

      state = AnalyzeState(
        status: 'done',
        results: response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data['error'] ?? 'Failed to process receipt';
      state = AnalyzeState(status: 'error', error: errorMsg);
    } catch (e) {
      state = AnalyzeState(status: 'error', error: 'An unexpected error occurred');
    }
  }

  void reset() {
    state = AnalyzeState();
  }
}

final analyzeProvider =
    StateNotifierProvider<AnalyzeNotifier, AnalyzeState>((ref) {
  final dio = ref.watch(dioProvider);
  return AnalyzeNotifier(dio);
});
