import 'package:dio/dio.dart';
import 'package:eios/core/network/api_service.dart';
import 'package:eios/data/models/student_rating_plan.dart';
import 'package:eios/data/models/student_time_table.dart';
import 'package:eios/data/storage/cache_service.dart';

class TimetableRepository {
  final _dio = ApiClient().dio;
  static const String _timetableKeyPrefix = 'timetable_';
  static const String _ratingPlanKeyPrefix = 'rating_plan_';

  Future<CacheService> get _cache async => await CacheService.getInstance();

  Future<List<StudentTimeTable>> getStudentTimeTable({
    required String date,
  }) async {
    final cacheKey = '$_timetableKeyPrefix$date';
    final cache = await _cache;

    final cachedData = await cache.get(cacheKey);
    if (cachedData != null && cachedData is List) {
      _fetchAndCacheTimetable(date);
      return cachedData
          .map((e) => StudentTimeTable.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get(
        '/v1/StudentTimeTable',
        queryParameters: {'date': date},
      );

      List<StudentTimeTable> data;
      if (response.data is List) {
        data = (response.data as List)
            .map((e) => StudentTimeTable.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        data = [];
      }

      final jsonData = response.data is List ? response.data : [];
      await cache.save(cacheKey, jsonData);

      return data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Сервер временно недоступен. Попробуйте позже.');
      } else {
        final cached = await cache.get(cacheKey);
        if (cached is List) {
          return cached
              .map((e) => StudentTimeTable.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        rethrow;
      }
    }
  }

  Future<void> _fetchAndCacheTimetable(String date) async {
    try {
      final response = await _dio.get(
        '/v1/StudentTimeTable',
        queryParameters: {'date': date},
      );
      final cacheKey = '$_timetableKeyPrefix$date';
      final cache = await _cache;
      await cache.save(cacheKey, response.data);
    } catch (_) {}
  }

  Future<StudentRatingPlan> getRatingPlan(int disciplineId) async {
    final cacheKey = '$_ratingPlanKeyPrefix$disciplineId';
    final cache = await _cache;

    final cachedData = await cache.get(cacheKey);
    if (cachedData != null && cachedData is Map) {
      _fetchAndCacheRatingPlan(disciplineId);
      return StudentRatingPlan.fromJson(Map<String, dynamic>.from(cachedData));
    }

    try {
      final response = await _dio.get(
        '/v2/StudentRatingPlan/',
        queryParameters: {'id': disciplineId},
      );

      if (response.statusCode == 200) {
        await cache.save(cacheKey, response.data);
        return StudentRatingPlan.fromJson(response.data);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      final cached = await cache.get(cacheKey);
      if (cached is Map) {
        return StudentRatingPlan.fromJson(Map<String, dynamic>.from(cached));
      }
      throw Exception('Не удалось загрузить рейтинг-план: $e');
    }
  }

  Future<void> _fetchAndCacheRatingPlan(int disciplineId) async {
    try {
      final response = await _dio.get(
        '/v2/StudentRatingPlan/',
        queryParameters: {'id': disciplineId},
      );
      final cacheKey = '$_ratingPlanKeyPrefix$disciplineId';
      final cache = await _cache;
      await cache.save(cacheKey, response.data);
    } catch (_) {}
  }
}
