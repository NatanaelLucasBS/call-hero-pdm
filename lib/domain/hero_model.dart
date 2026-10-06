/// Camada de Domínio: modelo puro do herói, imutável e sem dependências externas.
class HeroModel {
  final int id;
  final String name;
  final String slug;
  final Powerstats powerstats;
  final Appearance appearance;
  final Biography biography;
  final Work work;
  final Connections connections;
  final HeroImages images;

  const HeroModel({
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

  /// Clona o herói atualizando apenas os atributos informados (Imutabilidade).
  HeroModel copyWith({
    int? id,
    String? name,
    String? slug,
    Powerstats? powerstats,
    Appearance? appearance,
    Biography? biography,
    Work? work,
    Connections? connections,
    HeroImages? images,
  }) {
    return HeroModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      powerstats: powerstats ?? this.powerstats,
      appearance: appearance ?? this.appearance,
      biography: biography ?? this.biography,
      work: work ?? this.work,
      connections: connections ?? this.connections,
      images: images ?? this.images,
    );
  }

  /// Aplica a evolução de +1 no atributo sorteado após vitória na missão.
  HeroModel evolveStat(String statName) {
    return copyWith(
      powerstats: powerstats.copyWith(
        intelligence: statName.toLowerCase() == 'intelligence' ? powerstats.intelligence + 1 : null,
        strength: statName.toLowerCase() == 'strength' ? powerstats.strength + 1 : null,
        speed: statName.toLowerCase() == 'speed' ? powerstats.speed + 1 : null,
        durability: statName.toLowerCase() == 'durability' ? powerstats.durability + 1 : null,
        power: statName.toLowerCase() == 'power' ? powerstats.power + 1 : null,
        combat: statName.toLowerCase() == 'combat' ? powerstats.combat + 1 : null,
      ),
    );
  }

  /// Retorna o nome do atributo dominante do herói para papel tático.
  String get highestStatName => powerstats.highestStatName;
}

/// Modela os 6 atributos vitais de combate.
class Powerstats {
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  const Powerstats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  /// Permite atualizar atributos pontualmente após vitória na missão.
  Powerstats copyWith({
    int? intelligence,
    int? strength,
    int? speed,
    int? durability,
    int? power,
    int? combat,
  }) {
    return Powerstats(
      intelligence: intelligence ?? this.intelligence,
      strength: strength ?? this.strength,
      speed: speed ?? this.speed,
      durability: durability ?? this.durability,
      power: power ?? this.power,
      combat: combat ?? this.combat,
    );
  }

  /// Obtém o valor do atributo exigido no round pelo nome sorteado.
  int getStatByName(String name) {
    switch (name.toLowerCase()) {
      case 'intelligence':
        return intelligence;
      case 'strength':
        return strength;
      case 'speed':
        return speed;
      case 'durability':
        return durability;
      case 'power':
        return power;
      case 'combat':
        return combat;
      default:
        return 0;
    }
  }

  /// Retorna o nome do maior atributo usando Programação Funcional (reduce) para papel tático.
  /// Em caso de empate entre pontuações máximas (ex: Batman com 100 em Inteligência e Combate; Hulk com 100 em Força e Durabilidade),
  /// o operador '>=' preserva o primeiro atributo dominante de sua essência canônica (Batman = Inteligência, Hulk = Força).
  String get highestStatName {
    final stats = {
      'Intelligence': intelligence,
      'Strength': strength,
      'Speed': speed,
      'Durability': durability,
      'Power': power,
      'Combat': combat,
    };

    return stats.entries
        .reduce((curr, next) => curr.value >= next.value ? curr : next)
        .key;
  }
}

/// Características físicas e visuais do herói.
class Appearance {
  final String gender;
  final String race;
  final List<String> height;
  final List<String> weight;
  final String eyeColor;
  final String hairColor;

  const Appearance({
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
  });
}

/// Histórico, identidade civil e publicação do herói.
class Biography {
  final String fullName;
  final String alterEgos;
  final List<String> aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String publisher;
  final String alignment;

  const Biography({
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
  });
}

/// Profissão civil e base de operações do personagem.
class Work {
  final String occupation;
  final String base;

  const Work({
    required this.occupation,
    required this.base,
  });
}

/// Equipes e conexões familiares do personagem.
class Connections {
  final String groupAffiliation;
  final String relatives;

  const Connections({
    required this.groupAffiliation,
    required this.relatives,
  });
}

/// URLs das 4 resoluções de imagens da Superhero API.
class HeroImages {
  final String xs;
  final String sm;
  final String md;
  final String lg;

  const HeroImages({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
  });
}
