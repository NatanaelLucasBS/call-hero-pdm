import 'dart:convert';

/// Contrato com nomes de tabelas e colunas para o SQLite (Aula 08).
class HeroDatabaseContract {
  static const String heroesTable = 'heroes';
  static const String squadTable = 'squad';

  static const String idColumn = 'id';
  static const String nameColumn = 'name';
  static const String slugColumn = 'slug';

  // Powerstats
  static const String intelligenceColumn = 'intelligence';
  static const String strengthColumn = 'strength';
  static const String speedColumn = 'speed';
  static const String durabilityColumn = 'durability';
  static const String powerColumn = 'power';
  static const String combatColumn = 'combat';

  // Appearance
  static const String genderColumn = 'gender';
  static const String raceColumn = 'race';
  static const String heightColumn = 'height';
  static const String weightColumn = 'weight';
  static const String eyeColorColumn = 'eye_color';
  static const String hairColorColumn = 'hair_color';

  // Biography
  static const String fullNameColumn = 'full_name';
  static const String alterEgosColumn = 'alter_egos';
  static const String aliasesColumn = 'aliases';
  static const String placeOfBirthColumn = 'place_of_birth';
  static const String firstAppearanceColumn = 'first_appearance';
  static const String publisherColumn = 'publisher';
  static const String alignmentColumn = 'alignment';

  // Work & Connections
  static const String occupationColumn = 'occupation';
  static const String baseColumn = 'base';
  static const String groupAffiliationColumn = 'group_affiliation';
  static const String relativesColumn = 'relatives';

  // Images
  static const String imgXsColumn = 'img_xs';
  static const String imgSmColumn = 'img_sm';
  static const String imgMdColumn = 'img_md';
  static const String imgLgColumn = 'img_lg';
}

/// Entidade de banco de dados para representar um herói nas tabelas SQLite (Aula 08).
class HeroDatabaseEntity {
  final int id;
  final String name;
  final String slug;

  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  final String gender;
  final String race;
  final List<String> height;
  final List<String> weight;
  final String eyeColor;
  final String hairColor;

  final String fullName;
  final String alterEgos;
  final List<String> aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String publisher;
  final String alignment;

  final String occupation;
  final String base;
  final String groupAffiliation;
  final String relatives;

  final String imgXs;
  final String imgSm;
  final String imgMd;
  final String imgLg;

  /// Construtor com todos os campos necessários para persistência local.
  HeroDatabaseEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
    required this.occupation,
    required this.base,
    required this.groupAffiliation,
    required this.relatives,
    required this.imgXs,
    required this.imgSm,
    required this.imgMd,
    required this.imgLg,
  });

  /// Desserializa um Map retornado do SQLite para a entidade.
  factory HeroDatabaseEntity.fromJson(Map<String, dynamic> json) {
    return HeroDatabaseEntity(
      id: json[HeroDatabaseContract.idColumn] as int,
      name: json[HeroDatabaseContract.nameColumn] as String? ?? '',
      slug: json[HeroDatabaseContract.slugColumn] as String? ?? '',
      intelligence: json[HeroDatabaseContract.intelligenceColumn] as int? ?? 0,
      strength: json[HeroDatabaseContract.strengthColumn] as int? ?? 0,
      speed: json[HeroDatabaseContract.speedColumn] as int? ?? 0,
      durability: json[HeroDatabaseContract.durabilityColumn] as int? ?? 0,
      power: json[HeroDatabaseContract.powerColumn] as int? ?? 0,
      combat: json[HeroDatabaseContract.combatColumn] as int? ?? 0,
      gender: json[HeroDatabaseContract.genderColumn] as String? ?? '',
      race: json[HeroDatabaseContract.raceColumn] as String? ?? '',
      height: (jsonDecode(json[HeroDatabaseContract.heightColumn] as String? ?? '[]') as List)
          .map((e) => e.toString())
          .toList(),
      weight: (jsonDecode(json[HeroDatabaseContract.weightColumn] as String? ?? '[]') as List)
          .map((e) => e.toString())
          .toList(),
      eyeColor: json[HeroDatabaseContract.eyeColorColumn] as String? ?? '',
      hairColor: json[HeroDatabaseContract.hairColorColumn] as String? ?? '',
      fullName: json[HeroDatabaseContract.fullNameColumn] as String? ?? '',
      alterEgos: json[HeroDatabaseContract.alterEgosColumn] as String? ?? '',
      aliases: (jsonDecode(json[HeroDatabaseContract.aliasesColumn] as String? ?? '[]') as List)
          .map((e) => e.toString())
          .toList(),
      placeOfBirth: json[HeroDatabaseContract.placeOfBirthColumn] as String? ?? '',
      firstAppearance: json[HeroDatabaseContract.firstAppearanceColumn] as String? ?? '',
      publisher: json[HeroDatabaseContract.publisherColumn] as String? ?? '',
      alignment: json[HeroDatabaseContract.alignmentColumn] as String? ?? '',
      occupation: json[HeroDatabaseContract.occupationColumn] as String? ?? '',
      base: json[HeroDatabaseContract.baseColumn] as String? ?? '',
      groupAffiliation: json[HeroDatabaseContract.groupAffiliationColumn] as String? ?? '',
      relatives: json[HeroDatabaseContract.relativesColumn] as String? ?? '',
      imgXs: json[HeroDatabaseContract.imgXsColumn] as String? ?? '',
      imgSm: json[HeroDatabaseContract.imgSmColumn] as String? ?? '',
      imgMd: json[HeroDatabaseContract.imgMdColumn] as String? ?? '',
      imgLg: json[HeroDatabaseContract.imgLgColumn] as String? ?? '',
    );
  }

  /// Serializa a entidade em um Map para inserção no SQLite.
  Map<String, dynamic> toJson() {
    return {
      HeroDatabaseContract.idColumn: id,
      HeroDatabaseContract.nameColumn: name,
      HeroDatabaseContract.slugColumn: slug,
      HeroDatabaseContract.intelligenceColumn: intelligence,
      HeroDatabaseContract.strengthColumn: strength,
      HeroDatabaseContract.speedColumn: speed,
      HeroDatabaseContract.durabilityColumn: durability,
      HeroDatabaseContract.powerColumn: power,
      HeroDatabaseContract.combatColumn: combat,
      HeroDatabaseContract.genderColumn: gender,
      HeroDatabaseContract.raceColumn: race,
      HeroDatabaseContract.heightColumn: jsonEncode(height),
      HeroDatabaseContract.weightColumn: jsonEncode(weight),
      HeroDatabaseContract.eyeColorColumn: eyeColor,
      HeroDatabaseContract.hairColorColumn: hairColor,
      HeroDatabaseContract.fullNameColumn: fullName,
      HeroDatabaseContract.alterEgosColumn: alterEgos,
      HeroDatabaseContract.aliasesColumn: jsonEncode(aliases),
      HeroDatabaseContract.placeOfBirthColumn: placeOfBirth,
      HeroDatabaseContract.firstAppearanceColumn: firstAppearance,
      HeroDatabaseContract.publisherColumn: publisher,
      HeroDatabaseContract.alignmentColumn: alignment,
      HeroDatabaseContract.occupationColumn: occupation,
      HeroDatabaseContract.baseColumn: base,
      HeroDatabaseContract.groupAffiliationColumn: groupAffiliation,
      HeroDatabaseContract.relativesColumn: relatives,
      HeroDatabaseContract.imgXsColumn: imgXs,
      HeroDatabaseContract.imgSmColumn: imgSm,
      HeroDatabaseContract.imgMdColumn: imgMd,
      HeroDatabaseContract.imgLgColumn: imgLg,
    };
  }
}
