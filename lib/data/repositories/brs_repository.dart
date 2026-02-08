import 'package:dio/dio.dart';
import 'package:eios/core/exceptions/app_exceptions.dart';
import 'package:eios/core/network/api_service.dart';
import 'package:eios/data/models/accepted_attendance.dart';
import 'package:eios/data/models/message.dart';
import 'package:eios/data/models/student_rating_plan.dart';
import 'package:eios/data/models/student_semestr.dart';
import 'package:eios/data/models/student_semestr_with_disciplines.dart';

class BrsRepository {
  final _dio = ApiClient().dio;

  Future<List<StudentSemestr>> getStudentSemestr() async {
    try {
      final response = await _dio.get('/v1/StudentSemester');

      if (response.data is List) {
        return (response.data as List)
            .map((e) => StudentSemestr.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentRatingPlan> getStudentRatingPlan({required int id}) async {
    try {
      final response = await _dio.get(
        '/v2/StudentRatingPlan',
        queryParameters: {'id': id},
      );
      return StudentRatingPlan.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<StudentSemestrWithDisciplines> getDisciplinesBySemester({
    required String year,
    required int period,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/StudentSemester',
        queryParameters: {
          'year': year,
          'period': period,
        },
      );
      return StudentSemestrWithDisciplines.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AcceptedAttendance> sendStudentAttendanceCode ({ required String code }) async {
    try {
      final response = await _dio.post('/v1/StudentAttendanceCode', queryParameters: {'code': code},);
      return AcceptedAttendance.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Message>> getMessages({
    required int disciplineId,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/ForumMessage',
        queryParameters: {'disciplineId': disciplineId},
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<Message> sendMessage({
    required int disciplineId,
    required String messageText,
  }) async {
    try {
      final response = await _dio.post(
        '/v1/ForumMessage',
        data: {
          'disciplineId': disciplineId,
          'text': messageText,
        },
      );
      
      return Message.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMessage({
    required int id,
  }) async {
    try {
      final response = await _dio.delete(
        '/v1/ForumMessage',
        queryParameters: {'id': id},
      );
      
      // 204 - успешное удаление
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
    final message = error.response?.data?['message'] ?? 
                    error.response?.data?.toString() ?? 
                    error.message;

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message ?? 'Сообщение не должно быть пустым'
        );
      case 403:
        return ForbiddenException(
          message ?? 'У вас нет доступа к дисциплине'
        );
      case 404:
        return NotFoundException(
          message ?? 'Ресурс не найден'
        );
      default:
        return AppException(
          message ?? 'Произошла ошибка',
          statusCode,
        );
    }
  }
}
