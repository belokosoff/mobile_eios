import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import 'dart:developer';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://p.mrsu.ru/',
    connectTimeout: const Duration(seconds: 5),
  ));

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'OAuth/Token', 
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
          'client_id': '8',
          'client_secret': 'qweasd',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        if (token != null) {
          await TokenStorage.saveToken(token);
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
        log("Ошибка сервера (400): ${e.response?.data}"); 
      } else {
        log("Ошибка сети/запроса: ${e.message}");
      }
      return false;
    }
  }
}