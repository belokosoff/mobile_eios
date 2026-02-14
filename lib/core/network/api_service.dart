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
                log("LOG: Токен истёк, пытаюсь обновить...");
                final newTokens = await _refreshTokens(refreshToken);
                await TokenStorage.saveTokens(newTokens);
                log("LOG: Токен успешно обновлён");

                final options = e.requestOptions;
                options.headers['Authorization'] =
                    'Bearer ${newTokens.accessToken}';

                final response = await dio.fetch(options);
                return handler.resolve(response);
              } catch (refreshError) {
                await _forceLogout();
                return handler.next(e);
              }
            } else {
              log(
                "LOG: No refresh token available for this flow. Logging out.",
              );
              await _forceLogout();
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  error: "Сессия истекла. Пожалуйста авторизируйте заново.",
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          }
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  Future<void> _forceLogout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    await TokenStorage.logout();

    final context = navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      _isLoggingOut = false;
    });
  }

  Future<void> login(String username, String password) async {
    final response = await dio.post(
      '/OAuth/Token',
      data: {
        'username': username,
        'password': password,
        'grant_type': 'password',
        'client_id': dotenv.env["CLIENT_ID"],
        'client_secret': dotenv.env["CLIENT_SECRET"],
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final tokens = AccessToken.fromJson(response.data);
    await TokenStorage.saveTokens(tokens);
  }

  Future<AccessToken> _refreshTokens(String refreshToken) async {
    final refreshDio = Dio();
    final response = await refreshDio.post(
      '$baseUrl/OAuth/Token',
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': dotenv.env["CLIENT_ID"],
        'client_secret': dotenv.env["CLIENT_SECRET"],
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return AccessToken.fromJson(response.data);
  }
}
