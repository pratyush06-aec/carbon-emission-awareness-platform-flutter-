import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
  final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:3000/api'));
  try {
    final response = await dio.post('/auth/register', data: {
      'name': 'Test User',
      'email': 'newuser123@test.com',
      'password': 'password123',
    });
    print('SUCCESS: ${response.data}');
  } on DioException catch(e) {
    print('Dio Error: ${e.response?.statusCode} - ${e.response?.data}');
  } catch (e) {
    print('Error: $e');
  }
}
