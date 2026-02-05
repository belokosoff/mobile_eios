import 'package:dio/dio.dart';
import 'package:eios/core/network/api_service.dart';
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
}
