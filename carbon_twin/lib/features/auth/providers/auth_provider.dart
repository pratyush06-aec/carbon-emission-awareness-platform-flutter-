import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api_client.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({this.isLoading = false, this.error, this.isAuthenticated = false});

  AuthState copyWith({bool? isLoading, String? error, bool? isAuthenticated}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio dio;
  final Ref ref;

  AuthNotifier(this.dio, this.ref) : super(AuthState()) {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: 'jwt_token');
    if (token != null) {
      state = state.copyWith(isAuthenticated: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      await ref.read(secureStorageProvider).write(key: 'jwt_token', value: token);
      
      state = state.copyWith(isLoading: false, isAuthenticated: true);
      return true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['error'] ?? 'Login failed';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      final token = response.data['token'];
      await ref.read(secureStorageProvider).write(key: 'jwt_token', value: token);
      
      state = state.copyWith(isLoading: false, isAuthenticated: true);
      return true;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['error'] ?? 'Registration failed';
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(secureStorageProvider).delete(key: 'jwt_token');
    state = state.copyWith(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthNotifier(dio, ref);
});
