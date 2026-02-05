import 'package:eios/core/network/api_service.dart';
import 'package:eios/data/models/student_rating_plan.dart';
import 'package:eios/data/models/student_semestr.dart';

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
      final response = await _dio.get('/v2/StudentRatingPlan', queryParameters: {'id': id});
      return StudentRatingPlan.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}