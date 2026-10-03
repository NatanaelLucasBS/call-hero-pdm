import '../../domain/exception/mapper_exception.dart';
import '../../domain/hero_model.dart';
import 'entity/hero_database_entity.dart';

/// Mapper da Camada de Banco de Dados: converte entidades SQLite em modelos de domínio e vice-versa (Aula 13).
class DatabaseMapper {
  /// Converte uma HeroDatabaseEntity persistida no SQLite em HeroModel imutável de domínio.
  HeroModel toHero(HeroDatabaseEntity entity) {
    try {
      return HeroModel(
        id: entity.id,
        name: entity.name,
        slug: entity.slug,
        powerstats: Powerstats(
          intelligence: entity.intelligence,
          strength: entity.strength,
          speed: entity.speed,
          durability: entity.durability,
          power: entity.power,
          combat: entity.combat,
        ),
        appearance: Appearance(
          gender: entity.gender,
          race: entity.race,
          height: entity.height,
          weight: entity.weight,
          eyeColor: entity.eyeColor,
          hairColor: entity.hairColor,
        ),
        biography: Biography(
          fullName: entity.fullName,
          alterEgos: entity.alterEgos,
          aliases: entity.aliases,
          placeOfBirth: entity.placeOfBirth,
          firstAppearance: entity.firstAppearance,
          publisher: entity.publisher,
          alignment: entity.alignment,
        ),
        work: Work(
          occupation: entity.occupation,
          base: entity.base,
        ),
        connections: Connections(
          groupAffiliation: entity.groupAffiliation,
          relatives: entity.relatives,
        ),
        images: HeroImages(
          xs: entity.imgXs,
          sm: entity.imgSm,
          md: entity.imgMd,
          lg: entity.imgLg,
        ),
      );
    } catch (e) {
      throw MapperException<HeroDatabaseEntity, HeroModel>(e.toString());
    }
  }

  /// Converte uma lista de HeroDatabaseEntity em lista de HeroModel.
  List<HeroModel> toHeroes(List<HeroDatabaseEntity> entities) {
    final List<HeroModel> heroes = [];
    for (var entity in entities) {
      heroes.add(toHero(entity));
    }
    return heroes;
  }

  /// Converte um HeroModel de domínio em HeroDatabaseEntity para persistência no SQLite.
  HeroDatabaseEntity toHeroDatabaseEntity(HeroModel hero) {
    try {
      return HeroDatabaseEntity(
        id: hero.id,
        name: hero.name,
        slug: hero.slug,
        intelligence: hero.powerstats.intelligence,
        strength: hero.powerstats.strength,
        speed: hero.powerstats.speed,
        durability: hero.powerstats.durability,
        power: hero.powerstats.power,
        combat: hero.powerstats.combat,
        gender: hero.appearance.gender,
        race: hero.appearance.race,
        height: hero.appearance.height,
        weight: hero.appearance.weight,
        eyeColor: hero.appearance.eyeColor,
        hairColor: hero.appearance.hairColor,
        fullName: hero.biography.fullName,
        alterEgos: hero.biography.alterEgos,
        aliases: hero.biography.aliases,
        placeOfBirth: hero.biography.placeOfBirth,
        firstAppearance: hero.biography.firstAppearance,
        publisher: hero.biography.publisher,
        alignment: hero.biography.alignment,
        occupation: hero.work.occupation,
        base: hero.work.base,
        groupAffiliation: hero.connections.groupAffiliation,
        relatives: hero.connections.relatives,
        imgXs: hero.images.xs,
        imgSm: hero.images.sm,
        imgMd: hero.images.md,
        imgLg: hero.images.lg,
      );
    } catch (e) {
      throw MapperException<HeroModel, HeroDatabaseEntity>(e.toString());
    }
  }

  /// Converte uma lista de HeroModel em lista de HeroDatabaseEntity para inserção em lote.
  List<HeroDatabaseEntity> toHeroDatabaseEntities(List<HeroModel> heroes) {
    final List<HeroDatabaseEntity> entities = [];
    for (var hero in heroes) {
      entities.add(toHeroDatabaseEntity(hero));
    }
    return entities;
  }
}