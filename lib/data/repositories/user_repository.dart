import 'package:eios/core/network/api_service.dart';
import 'package:eios/data/models/user_model.dart';

class UserRepository {
  final _dio = ApiClient().dio;

  Future<UserModel> getUserProfile() async {
    try {
      final response = await _dio.get('/v1/User');
      return UserModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}