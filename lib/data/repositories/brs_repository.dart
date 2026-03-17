import 'package:dio/dio.dart';
import 'package:eios/core/exceptions/app_exceptions.dart';
import 'package:eios/core/network/api_service.dart';
import 'package:eios/data/models/accepted_attendance.dart';
import 'package:eios/data/models/message.dart';
import 'package:eios/data/models/student_rating_plan.dart';
import 'package:eios/data/models/student_semestr.dart';
import 'package:eios/data/models/student_semestr_with_disciplines.dart';
import 'package:eios/data/storage/cache_service.dart';

class BrsRepository {
  final _dio = ApiClient().dio;
  static const String _semestrKey = 'semestr';
  static const String _disciplinesKeyPrefix = 'disciplines_';
  static const String _messagesKeyPrefix = 'messages_';

  Future<CacheService> get _cache async => await CacheService.getInstance();

  Future<List<StudentSemestr>> getStudentSemestr() async {
    final cache = await _cache;

    final cachedData = await cache.get(_semestrKey);
    if (cachedData != null && cachedData is List) {
      _fetchAndCacheSemestr();
      return cachedData
          .map((e) => StudentSemestr.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get('/v1/StudentSemester');

      List<StudentSemestr> data;
      if (response.data is List) {
        data = (response.data as List)
            .map((e) => StudentSemestr.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        data = [];
      }

      await cache.save(_semestrKey, response.data);
      return data;
    } catch (e) {
      final cached = await cache.get(_semestrKey);
      if (cached is List) {
        return cached
            .map((e) => StudentSemestr.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      rethrow;
    }
  }

  Future<void> _fetchAndCacheSemestr() async {
    try {
      final response = await _dio.get('/v1/StudentSemester');
      final cache = await _cache;
      await cache.save(_semestrKey, response.data);
    } catch (_) {}
  }

  Future<StudentRatingPlan> getStudentRatingPlan({required int id}) async {
    final cache = await _cache;
    final cacheKey = 'rating_plan_$id';

    final cachedData = await cache.get(cacheKey);
    if (cachedData != null && cachedData is Map) {
      _fetchAndCacheRatingPlan(id);
      return StudentRatingPlan.fromJson(Map<String, dynamic>.from(cachedData));
    }

    try {
      final response = await _dio.get(
        '/v2/StudentRatingPlan',
        queryParameters: {'id': id},
      );
      final data = StudentRatingPlan.fromJson(response.data);
      await cache.save(cacheKey, response.data);
      return data;
    } catch (e) {
      final cached = await cache.get(cacheKey);
      if (cached is Map) {
        return StudentRatingPlan.fromJson(Map<String, dynamic>.from(cached));
      }
      rethrow;
    }
  }

  Future<void> _fetchAndCacheRatingPlan(int id) async {
    try {
      final response = await _dio.get(
        '/v2/StudentRatingPlan',
        queryParameters: {'id': id},
      );
      final cache = await _cache;
      await cache.save('rating_plan_$id', response.data);
    } catch (_) {}
  }

  Future<StudentSemestrWithDisciplines> getDisciplinesBySemester({
    required String year,
    required int period,
  }) async {
    final cacheKey = '$_disciplinesKeyPrefix${year}_$period';
    final cache = await _cache;

    final cachedData = await cache.get(cacheKey);
    if (cachedData != null && cachedData is Map) {
      _fetchAndCacheDisciplines(year, period);
      return StudentSemestrWithDisciplines.fromJson(
        Map<String, dynamic>.from(cachedData),
      );
    }

    try {
      final response = await _dio.get(
        '/v1/StudentSemester',
        queryParameters: {'year': year, 'period': period},
      );
      final data = StudentSemestrWithDisciplines.fromJson(response.data);
      await cache.save(cacheKey, response.data);
      return data;
    } catch (e) {
      final cached = await cache.get(cacheKey);
      if (cached is Map) {
        return StudentSemestrWithDisciplines.fromJson(
          Map<String, dynamic>.from(cached),
        );
      }
      rethrow;
    }
  }

  Future<void> _fetchAndCacheDisciplines(String year, int period) async {
    try {
      final response = await _dio.get(
        '/v1/StudentSemester',
        queryParameters: {'year': year, 'period': period},
      );
      final cache = await _cache;
      await cache.save('$_disciplinesKeyPrefix${year}_$period', response.data);
    } catch (_) {}
  }

  Future<AcceptedAttendance> sendStudentAttendanceCode({
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/StudentAttendanceCode',
        queryParameters: {'code': code},
      );
      return AcceptedAttendance.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Message>> getMessages({required int disciplineId}) async {
    final cacheKey = '$_messagesKeyPrefix$disciplineId';
    final cache = await _cache;

    final cachedData = await cache.get(cacheKey);
    if (cachedData != null && cachedData is List) {
      _fetchAndCacheMessages(disciplineId);
      return cachedData
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    try {
      final response = await _dio.get(
        '/v1/ForumMessage',
        queryParameters: {'disciplineId': disciplineId},
      );

      List<Message> data;
      if (response.data is List) {
        data = (response.data as List)
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        data = [];
      }

      await cache.save(cacheKey, response.data);
      return data;
    } on DioException catch (e) {
      final cached = await cache.get(cacheKey);
      if (cached is List) {
        return cached
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchAndCacheMessages(int disciplineId) async {
    try {
      final response = await _dio.get(
        '/v1/ForumMessage',
        queryParameters: {'disciplineId': disciplineId},
      );
      final cache = await _cache;
      await cache.save('$_messagesKeyPrefix$disciplineId', response.data);
    } catch (_) {}
  }

  Future<Message> sendMessage({
    required int disciplineId,
    required String messageText,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/ForumMessage/',
        queryParameters: {'disciplineId': disciplineId},
        data: {'text': messageText},
      );

      return Message.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMessage({required int id}) async {
    try {
      final response = await _dio.delete(
        '/v1/ForumMessage',
        queryParameters: {'id': id},
      );

      if (response.statusCode == 204) {
        return;
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  AppException _handleError(DioException error) {
    final statusCode = error.response?.statusCode;
    final message =
        error.response?.data?['message'] ??
        error.response?.data?.toString() ??
        error.message;

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message ?? 'Сообщение не должно быть пустым',
        );
      case 403:
        return ForbiddenException(message ?? 'У вас нет доступа к дисциплине');
      case 404:
        return NotFoundException(message ?? 'Ресурс не найден');
      default:
        return AppException(message ?? 'Произошла ошибка', statusCode);
    }
  }
}
