import 'package:dio/dio.dart';
import 'package:eios/core/network/api_service.dart';
import 'package:eios/data/models/student_rating_plan.dart';
import 'package:eios/data/models/student_time_table.dart';

class TimetableRepository {
  final _dio = ApiClient().dio;

  Future<List<StudentTimeTable>> getStudentTimeTable({
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/StudentTimeTable',
        queryParameters: {'date': date},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((e) => StudentTimeTable.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('Сервер временно недоступен. Попробуйте позже.');
      } else {
        rethrow;
      }
    }
  }

  Future<StudentRatingPlan> getRatingPlan(int disciplineId) async {
    try {
      final response = await _dio.get(
        '/v2/StudentRatingPlan/',
        queryParameters: {'id': disciplineId},
      );

      if (response.statusCode == 200) {
        return StudentRatingPlan.fromJson(response.data);
      } else {
        throw Exception('Ошибка сервера: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Не удалось загрузить рейтинг-план: $e');
    }
  }
}
