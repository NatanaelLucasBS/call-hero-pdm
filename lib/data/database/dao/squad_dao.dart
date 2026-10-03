import 'package:sqflite/sqflite.dart';

import '../entity/hero_database_entity.dart';
import 'base_dao.dart';

/// DAO responsável pelo gerenciamento de persistência do esquadrão no SQLite (Slides 8, 9 e 13).
class SquadDao extends BaseDao {
  /// Conta o total de agentes atualmente recrutados no esquadrão.
  Future<int> countMembers() async {
    final Database db = await getDb();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${HeroDatabaseContract.squadTable}'),
    );
    return count ?? 0;
  }

  /// Retorna todos os heróis recrutados no esquadrão.
  Future<List<HeroDatabaseEntity>> selectAllMembers() async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      HeroDatabaseContract.squadTable,
      orderBy: '${HeroDatabaseContract.nameColumn} ASC',
    );
    return List.generate(maps.length, (i) {
      return HeroDatabaseEntity.fromJson(maps[i]);
    });
  }

  /// Retorna um membro do esquadrão pelo seu ID.
  Future<HeroDatabaseEntity?> selectMemberById(int id) async {
    final Database db = await getDb();
    final List<Map<String, dynamic>> maps = await db.query(
      HeroDatabaseContract.squadTable,
      where: '${HeroDatabaseContract.idColumn} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return HeroDatabaseEntity.fromJson(maps.first);
    }
    return null;
  }

  /// Insere um novo herói no esquadrão (recrutamento).
  Future<void> insertMember(HeroDatabaseEntity entity) async {
    final Database db = await getDb();
    await db.insert(
      HeroDatabaseContract.squadTable,
      entity.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove um herói do esquadrão (dispensa).
  Future<void> deleteMember(int id) async {
    final Database db = await getDb();
    await db.delete(
      HeroDatabaseContract.squadTable,
      where: '${HeroDatabaseContract.idColumn} = ?',
      whereArgs: [id],
    );
  }

  /// Incrementa em +1 um atributo específico do herói após vitória em combate (Slide 13).
  Future<void> incrementStat({
    required int heroId,
    required String statName,
  }) async {
    final Database db = await getDb();
    // Mapeia o nome do atributo para a coluna correspondente no banco de dados.
    final columnMap = {
      'intelligence': HeroDatabaseContract.intelligenceColumn,
      'strength': HeroDatabaseContract.strengthColumn,
      'speed': HeroDatabaseContract.speedColumn,
      'durability': HeroDatabaseContract.durabilityColumn,
      'power': HeroDatabaseContract.powerColumn,
      'combat': HeroDatabaseContract.combatColumn,
    };

    final column = columnMap[statName.toLowerCase()];
    if (column == null) return;

    await db.rawUpdate(
      'UPDATE ${HeroDatabaseContract.squadTable} SET $column = $column + 1 WHERE ${HeroDatabaseContract.idColumn} = ?',
      [heroId],
    );
  }
}
