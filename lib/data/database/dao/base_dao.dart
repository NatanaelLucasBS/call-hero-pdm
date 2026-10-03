import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../entity/hero_database_entity.dart';

/// ============================================================================
/// DAO BASE E CONEXÃO COM O BANCO DE DADOS (SQLite Helper / BaseDao - Aula 08)
/// ----------------------------------------------------------------------------
/// - PAPEL: Gerenciar o ciclo de vida da conexão com o SQLite, versionamento
///   e criação inicial das tabelas do banco local.
/// - O QUE PUXA: Utiliza o pacote [sqflite] e [path] para localizar e abrir
///   o arquivo 'heroes_database.db' no dispositivo do usuário.
/// - QUEM USA: As classes [HeroDao] e [SquadDao] herdam de [BaseDao] para obter
///   a instância do banco via método protegido [getDb].
/// - O QUE FAZ:
///   1. Abre a conexão via [openDatabase].
///   2. No callback [onCreate], executa em [Batch] os scripts DDL de criação
///      das tabelas 'heroes' (cache do catálogo) e 'squad' (membros do esquadrão).
/// ============================================================================
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