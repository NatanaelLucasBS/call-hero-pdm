/// DTO que espelha o JSON da Superhero API.
class HeroNetworkEntity {
  final int id;
  final String name;
  final String slug;
  final PowerstatsNetworkEntity powerstats;
  final AppearanceNetworkEntity appearance;
  final BiographyNetworkEntity biography;
  final WorkNetworkEntity work;
  final ConnectionsNetworkEntity connections;
  final ImagesNetworkEntity images;

  HeroNetworkEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.powerstats,
    required this.appearance,
    required this.biography,
    required this.work,
    required this.connections,
    required this.images,
  });

  /// Converte o Map da API com tratamento defensivo contra nulos.
  factory HeroNetworkEntity.fromJson(Map<String, dynamic> json) {
    return HeroNetworkEntity(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      powerstats: PowerstatsNetworkEntity.fromJson(
        json['powerstats'] as Map<String, dynamic>? ?? {},
      ),
      appearance: AppearanceNetworkEntity.fromJson(
        json['appearance'] as Map<String, dynamic>? ?? {},
      ),
      biography: BiographyNetworkEntity.fromJson(
        json['biography'] as Map<String, dynamic>? ?? {},
      ),
      work: WorkNetworkEntity.fromJson(
        json['work'] as Map<String, dynamic>? ?? {},
      ),
      connections: ConnectionsNetworkEntity.fromJson(
        json['connections'] as Map<String, dynamic>? ?? {},
      ),
      images: ImagesNetworkEntity.fromJson(
        json['images'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// DTO dos 6 atributos para barras do Primer e batalhas da missão.
class PowerstatsNetworkEntity {
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  PowerstatsNetworkEntity({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  factory PowerstatsNetworkEntity.fromJson(Map<String, dynamic> json) {
    return PowerstatsNetworkEntity(
      intelligence: json['intelligence'] as int? ?? 0,
      strength: json['strength'] as int? ?? 0,
      speed: json['speed'] as int? ?? 0,
      durability: json['durability'] as int? ?? 0,
      power: json['power'] as int? ?? 0,
      combat: json['combat'] as int? ?? 0,
    );
  }
}

/// DTO das características físicas.
class AppearanceNetworkEntity {
  final String gender;
  final String race;
  final List<String> height;
  final List<String> weight;
  final String eyeColor;
  final String hairColor;

  AppearanceNetworkEntity({
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
  });

  factory AppearanceNetworkEntity.fromJson(Map<String, dynamic> json) {
    return AppearanceNetworkEntity(
      gender: json['gender'] as String? ?? 'Unknown',
      race: json['race'] as String? ?? 'Unknown',
      height: (json['height'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weight: (json['weight'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      eyeColor: json['eyeColor'] as String? ?? '-',
      hairColor: json['hairColor'] as String? ?? '-',
    );
  }
}

/// DTO da biografia e histórico civil.
class BiographyNetworkEntity {
  final String fullName;
  final String alterEgos;
  final List<String> aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String publisher;
  final String alignment;

  BiographyNetworkEntity({
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
  });

  factory BiographyNetworkEntity.fromJson(Map<String, dynamic> json) {
    return BiographyNetworkEntity(
      fullName: json['fullName'] as String? ?? '',
      alterEgos: json['alterEgos'] as String? ?? '',
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      placeOfBirth: json['placeOfBirth'] as String? ?? '-',
      firstAppearance: json['firstAppearance'] as String? ?? '-',
      publisher: json['publisher'] as String? ?? 'Independent',
      alignment: json['alignment'] as String? ?? 'neutral',
    );
  }
}

/// DTO da profissão e base operacional.
class WorkNetworkEntity {
  final String occupation;
  final String base;

  WorkNetworkEntity({
    required this.occupation,
    required this.base,
  });

  factory WorkNetworkEntity.fromJson(Map<String, dynamic> json) {
    return WorkNetworkEntity(
      occupation: json['occupation'] as String? ?? '-',
      base: json['base'] as String? ?? '-',
    );
  }
}

/// DTO das afiliações de equipes e parentescos.
class ConnectionsNetworkEntity {
  final String groupAffiliation;
  final String relatives;

  ConnectionsNetworkEntity({
    required this.groupAffiliation,
    required this.relatives,
  });

  factory ConnectionsNetworkEntity.fromJson(Map<String, dynamic> json) {
    return ConnectionsNetworkEntity(
      groupAffiliation: json['groupAffiliation'] as String? ?? '-',
      relatives: json['relatives'] as String? ?? '-',
    );
  }
}

/// DTO das 4 resoluções de imagens da Superhero API.
class ImagesNetworkEntity {
  final String xs;
  final String sm;
  final String md;
  final String lg;

  ImagesNetworkEntity({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
  });

  factory ImagesNetworkEntity.fromJson(Map<String, dynamic> json) {
    return ImagesNetworkEntity(
      xs: json['xs'] as String? ?? '',
      sm: json['sm'] as String? ?? '',
      md: json['md'] as String? ?? '',
      lg: json['lg'] as String? ?? '',
    );
  }
}
