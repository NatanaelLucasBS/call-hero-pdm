import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/hero_database_entity.dart';

/// DAO Base responsável pelo gerenciamento de conexão e criação do schema SQLite (Aula 08).
abstract class BaseDao {
  static const databaseVersion = 1;
  static const _databaseName = 'heroes_database.db';

  Database? _database;

  /// Retorna a instância ativa do banco de dados, inicializando se necessário.
  @protected
  Future<Database> getDb() async {
    _database ??= await _getDatabase();
    return _database!;
  }

  /// Abre a conexão com o banco de dados SQLite e executa o script de criação.
  Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), _databaseName),
      onCreate: (db, version) async {
        final batch = db.batch();
        _createHeroesTableV1(batch);
        _createSquadTableV1(batch);
        await batch.commit();
      },
      version: databaseVersion,
    );
  }

  /// Cria a tabela de heróis utilizada para o cache offline do catálogo (Slide 5).
  void _createHeroesTableV1(Batch batch) {
    batch.execute(
      '''
      CREATE TABLE ${HeroDatabaseContract.heroesTable}(
        ${HeroDatabaseContract.idColumn} INTEGER PRIMARY KEY,
        ${HeroDatabaseContract.nameColumn} TEXT NOT NULL,
        ${HeroDatabaseContract.slugColumn} TEXT NOT NULL,
        ${HeroDatabaseContract.intelligenceColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.strengthColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.speedColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.durabilityColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.powerColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.combatColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.genderColumn} TEXT NULL,
        ${HeroDatabaseContract.raceColumn} TEXT NULL,
        ${HeroDatabaseContract.heightColumn} TEXT NULL,
        ${HeroDatabaseContract.weightColumn} TEXT NULL,
        ${HeroDatabaseContract.eyeColorColumn} TEXT NULL,
        ${HeroDatabaseContract.hairColorColumn} TEXT NULL,
        ${HeroDatabaseContract.fullNameColumn} TEXT NULL,
        ${HeroDatabaseContract.alterEgosColumn} TEXT NULL,
        ${HeroDatabaseContract.aliasesColumn} TEXT NULL,
        ${HeroDatabaseContract.placeOfBirthColumn} TEXT NULL,
        ${HeroDatabaseContract.firstAppearanceColumn} TEXT NULL,
        ${HeroDatabaseContract.publisherColumn} TEXT NULL,
        ${HeroDatabaseContract.alignmentColumn} TEXT NULL,
        ${HeroDatabaseContract.occupationColumn} TEXT NULL,
        ${HeroDatabaseContract.baseColumn} TEXT NULL,
        ${HeroDatabaseContract.groupAffiliationColumn} TEXT NULL,
        ${HeroDatabaseContract.relativesColumn} TEXT NULL,
        ${HeroDatabaseContract.imgXsColumn} TEXT NULL,
        ${HeroDatabaseContract.imgSmColumn} TEXT NULL,
        ${HeroDatabaseContract.imgMdColumn} TEXT NULL,
        ${HeroDatabaseContract.imgLgColumn} TEXT NULL
      );
      ''',
    );
  }

  /// Cria a tabela de esquadrão com persistência de heróis recrutados e evolução de stats (Slides 8 e 13).
  void _createSquadTableV1(Batch batch) {
    batch.execute(
      '''
      CREATE TABLE ${HeroDatabaseContract.squadTable}(
        ${HeroDatabaseContract.idColumn} INTEGER PRIMARY KEY,
        ${HeroDatabaseContract.nameColumn} TEXT NOT NULL,
        ${HeroDatabaseContract.slugColumn} TEXT NOT NULL,
        ${HeroDatabaseContract.intelligenceColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.strengthColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.speedColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.durabilityColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.powerColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.combatColumn} INTEGER NOT NULL,
        ${HeroDatabaseContract.genderColumn} TEXT NULL,
        ${HeroDatabaseContract.raceColumn} TEXT NULL,
        ${HeroDatabaseContract.heightColumn} TEXT NULL,
        ${HeroDatabaseContract.weightColumn} TEXT NULL,
        ${HeroDatabaseContract.eyeColorColumn} TEXT NULL,
        ${HeroDatabaseContract.hairColorColumn} TEXT NULL,
        ${HeroDatabaseContract.fullNameColumn} TEXT NULL,
        ${HeroDatabaseContract.alterEgosColumn} TEXT NULL,
        ${HeroDatabaseContract.aliasesColumn} TEXT NULL,
        ${HeroDatabaseContract.placeOfBirthColumn} TEXT NULL,
        ${HeroDatabaseContract.firstAppearanceColumn} TEXT NULL,
        ${HeroDatabaseContract.publisherColumn} TEXT NULL,
        ${HeroDatabaseContract.alignmentColumn} TEXT NULL,
        ${HeroDatabaseContract.occupationColumn} TEXT NULL,
        ${HeroDatabaseContract.baseColumn} TEXT NULL,
        ${HeroDatabaseContract.groupAffiliationColumn} TEXT NULL,
        ${HeroDatabaseContract.relativesColumn} TEXT NULL,
        ${HeroDatabaseContract.imgXsColumn} TEXT NULL,
        ${HeroDatabaseContract.imgSmColumn} TEXT NULL,
        ${HeroDatabaseContract.imgMdColumn} TEXT NULL,
        ${HeroDatabaseContract.imgLgColumn} TEXT NULL
      );
      ''',
    );
  }
}