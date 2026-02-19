import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../data/storage/token_storage.dart';
import '../../presentation/screens/login_screen.dart';
import '../navigation/navigator_key.dart';
import 'access_token.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  ApiClient._internal();
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;
  final String baseUrl = 'https://papi.mrsu.ru';

  bool _isLoggingOut = false;

  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('OAuth/Token')) {
            final refreshToken = await TokenStorage.getRefreshToken();

            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                log(
                  "LOG: Токен истёк, пытаюсь обновить через Refresh Token...",
                );

                final newTokens = await _refreshTokens(refreshToken);

                await TokenStorage.saveTokens(newTokens);
                log("LOG: Токены успешно обновлены");

                final options = e.requestOptions;
                options.headers['Authorization'] =
                    'Bearer ${newTokens.accessToken}';

                final response = await dio.fetch(options);
                return handler.resolve(response);
              } catch (refreshError) {
                log("LOG: Ошибка при попытке обновить токен: $refreshError");
                await _forceLogout();
                return handler.next(e);
              }
            } else {
              log("LOG: Refresh token отсутствует в хранилище");
              await _forceLogout();
              return handler.next(e);
            }
          }
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<AccessToken> _refreshTokens(String refreshToken) async {
    final refreshDio = Dio(BaseOptions(baseUrl: 'https://p.mrsu.ru/'));

    try {
      final response = await refreshDio.post(
        'OAuth/Token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': dotenv.env["CLIENT_ID"],
          'client_secret': dotenv.env["CLIENT_SECRET"],
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      return AccessToken.fromJson(response.data);
    } on DioException catch (e) {
      log("LOG: Ошибка сервера при refresh_token: ${e.response?.statusCode}");
      rethrow;
    }
  }

  Future<void> _forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    log("LOG: Принудительный выход из системы");
    await TokenStorage.logout();

    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    Future.delayed(const Duration(seconds: 3), () => _isLoggingOut = false);
  }
}
