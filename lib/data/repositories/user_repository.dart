import 'package:eios/core/network/api_service.dart';
import 'package:eios/data/models/user_model.dart';
import 'package:eios/data/storage/cache_service.dart';

class UserRepository {
  final _dio = ApiClient().dio;
  static const String _profileKey = 'user_profile';

  Future<CacheService> get _cache async => await CacheService.getInstance();

  Future<UserModel> getUserProfile() async {
    final cache = await _cache;

    final cachedData = await cache.get(_profileKey);
    if (cachedData != null && cachedData is Map) {
      _fetchAndCacheProfile();
      return UserModel.fromJson(Map<String, dynamic>.from(cachedData));
    }

    try {
      final response = await _dio.get('/v1/User');
      final userData = response.data as Map<String, dynamic>;
      await cache.save(_profileKey, userData);
      return UserModel.fromJson(userData);
    } catch (e) {
      final cached = await cache.get(_profileKey);
      if (cached is Map) {
        return UserModel.fromJson(Map<String, dynamic>.from(cached));
      }
      rethrow;
    }
  }

  Future<void> _fetchAndCacheProfile() async {
    try {
      final response = await _dio.get('/v1/User');
      final cache = await _cache;
      await cache.save(_profileKey, response.data);
    } catch (_) {}
  }
}
