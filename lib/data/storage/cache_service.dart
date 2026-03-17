import 'dart:convert';
import 'package:eios/data/database/app_database.dart';

class CacheService {
  static CacheService? _instance;
  late AppDatabase _database;

  CacheService._();

  static Future<CacheService> getInstance() async {
    if (_instance == null) {
      _instance = CacheService._();
      _instance!._database = AppDatabase();
    }
    return _instance!;
  }

  Future<void> save(String key, dynamic data) async {
    final jsonString = jsonEncode(data);
    await _database.setCacheEntry(key, jsonString);
  }

  Future<dynamic> get(String key) async {
    final entry = await _database.getCacheEntry(key);
    if (entry == null) return null;

    final decoded = jsonDecode(entry.dataJson);
    return decoded;
  }

  Future<List<T>> getList<T>(String key) async {
    final entry = await _database.getCacheEntry(key);
    if (entry == null) return [];

    final decoded = jsonDecode(entry.dataJson);
    if (decoded is List) {
      return decoded.map((e) => e as T).toList();
    }
    return [];
  }

  Future<bool> hasCache(String key) async {
    final entry = await _database.getCacheEntry(key);
    return entry != null;
  }

  Future<DateTime?> getLastUpdated(String key) async {
    final entry = await _database.getCacheEntry(key);
    return entry?.updatedAt;
  }

  Future<void> clearAll() async {
    await _database.clearAllCache();
  }

  Future<void> clear(String key) async {
    await _database.clearCacheEntry(key);
  }
}
