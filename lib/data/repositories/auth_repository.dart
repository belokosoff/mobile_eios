import 'package:dio/dio.dart';
import 'package:eios/core/network/access_token.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/token_storage.dart';
import 'dart:developer';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://p.mrsu.ru/',
    connectTimeout: const Duration(seconds: 15),
    contentType: Headers.formUrlEncodedContentType,
  ));

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'OAuth/Token', 
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
          'client_id': dotenv.env["CLIENT_ID"],
          'client_secret': dotenv.env["CLIENT_SECRET"],
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final tokens = AccessToken.fromJson(response.data);
        
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