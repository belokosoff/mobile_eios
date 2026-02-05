import 'package:dio/dio.dart';
import 'package:eios/core/network/access_token.dart';
import '../storage/token_storage.dart';
import 'dart:developer';

class AuthRepository {
  // Используем тот же конфиг, что и в ApiClient для единообразия
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://p.mrsu.ru/',
    connectTimeout: const Duration(seconds: 15),
    contentType: Headers.formUrlEncodedContentType, // Указываем по умолчанию
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
      );

      if (response.statusCode == 200 && response.data != null) {
        // Парсим JSON в модель AccessToken
        final tokens = AccessToken.fromJson(response.data);
        
        // Сохраняем весь объект (access и refresh)
        await TokenStorage.saveTokens(tokens);
        
        log("LOG: Авторизация успешна");
        return true;
      }
      return false;
    } on DioException catch (e) {
      log("Ошибка авторизации: ${e.response?.data ?? e.message}");
      return false;
    } catch (e) {
      log("Непредвиденная ошибка: $e");
      return false;
    }
  }
}