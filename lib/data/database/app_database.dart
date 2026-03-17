import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class CacheEntries extends Table {
  TextColumn get key => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [CacheEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<CacheEntry?> getCacheEntry(String cacheKey) {
    return (select(
      cacheEntries,
    )..where((t) => t.key.equals(cacheKey))).getSingleOrNull();
  }

  Future<void> setCacheEntry(String cacheKey, String jsonData) {
    return into(cacheEntries).insertOnConflictUpdate(
      CacheEntriesCompanion(
        key: Value(cacheKey),
        dataJson: Value(jsonData),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> clearAllCache() {
    return delete(cacheEntries).go();
  }

  Future<void> clearCacheEntry(String cacheKey) {
    return (delete(cacheEntries)..where((t) => t.key.equals(cacheKey))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'eios_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
