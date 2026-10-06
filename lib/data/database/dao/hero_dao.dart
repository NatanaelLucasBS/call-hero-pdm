import 'package:sqflite/sqflite.dart';

import '../entity/hero_database_entity.dart';
import 'base_dao.dart';

/// DAO de cache do catálogo de heróis no SQLite.
class HeroDao extends BaseDao {
  /// Retorna lista paginada de heróis salvos no cache local.
  Future<List<HeroDatabaseEntity>> selectAll({
    int? limit,
    int? offset,
  }) async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      HeroDatabaseContract.heroesTable,
      limit: limit,
      offset: offset,
      orderBy: '${HeroDatabaseContract.idColumn} ASC',
    );
    return List.generate(maps.length, (i) {
      return HeroDatabaseEntity.fromJson(maps[i]);
    });
  }

  /// Retorna um único herói pelo seu ID caso exista no cache local.
  Future<HeroDatabaseEntity?> selectById(int id) async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      HeroDatabaseContract.heroesTable,
      where: '${HeroDatabaseContract.idColumn} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HeroDatabaseEntity.fromJson(maps.first);
    }
    return null;
  }

  /// Insere um herói individual no cache local.
  Future<void> insert(HeroDatabaseEntity entity) async {
    final Database db = await getDb();
    await db.insert(
      HeroDatabaseContract.heroesTable,
      entity.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insere uma lista de heróis em lote utilizando transação atômica.
  Future<void> insertAll(List<HeroDatabaseEntity> entities) async {
    final Database db = await getDb();
    await db.transaction((transaction) async {
      for (final entity in entities) {
        transaction.insert(
          HeroDatabaseContract.heroesTable,
          entity.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// Limpa todos os heróis da tabela de cache.
  Future<void> deleteAll() async {
    final Database db = await getDb();
    await db.delete(HeroDatabaseContract.heroesTable);
  }
}
