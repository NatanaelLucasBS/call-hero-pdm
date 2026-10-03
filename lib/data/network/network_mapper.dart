import '../../domain/exception/mapper_exception.dart';
import '../../domain/hero_model.dart';
import 'entity/hero_network_entity.dart';

/// ============================================================================
/// MAPPER DA CAMADA DE REDE (Network Mapper - Aula 13)
/// ----------------------------------------------------------------------------
/// - PAPEL: Isolar a camada de rede do restante do aplicativo, convertendo DTOs
///   brutos da API ([HeroNetworkEntity]) em modelos puros de domínio ([HeroModel]).
/// - O QUE PUXA: Recebe instâncias de [HeroNetworkEntity] vindas do [ApiClient].
/// - QUEM USA: [HeroRepositoryImpl], ao receber dados da rede antes de repassá-los
///   às telas ou salvá-los no SQLite.
/// - O QUE FAZ:
///   1. Converte tipos primitivos e estruturas aninhadas do JSON em objetos de domínio.
///   2. Lança [MapperException] tipada se houver inconsistência ou corrupção de tipos.
/// ============================================================================
class NetworkMapper {
  /// Converte um HeroNetworkEntity em HeroModel com proteção de MapperException.
  HeroModel toHero(HeroNetworkEntity entity) {
    try {
      return HeroModel(
        id: entity.id,
        name: entity.name,
        slug: entity.slug,
        powerstats: Powerstats(
          intelligence: entity.powerstats.intelligence,
          strength: entity.powerstats.strength,
          speed: entity.powerstats.speed,
          durability: entity.powerstats.durability,
          power: entity.powerstats.power,
          combat: entity.powerstats.combat,
        ),
        appearance: Appearance(
          gender: entity.appearance.gender,
          race: entity.appearance.race,
          height: entity.appearance.height,
          weight: entity.appearance.weight,
          eyeColor: entity.appearance.eyeColor,
          hairColor: entity.appearance.hairColor,
        ),
        biography: Biography(
          fullName: entity.biography.fullName,
          alterEgos: entity.biography.alterEgos,
          aliases: entity.biography.aliases,
          placeOfBirth: entity.biography.placeOfBirth,
          firstAppearance: entity.biography.firstAppearance,
          publisher: entity.biography.publisher,
          alignment: entity.biography.alignment,
        ),
        work: Work(
          occupation: entity.work.occupation,
          base: entity.work.base,
        ),
        connections: Connections(
          groupAffiliation: entity.connections.groupAffiliation,
          relatives: entity.connections.relatives,
        ),
        images: HeroImages(
          xs: entity.images.xs,
          sm: entity.images.sm,
          md: entity.images.md,
          lg: entity.images.lg,
        ),
      );
    } catch (e) {
      throw MapperException<HeroNetworkEntity, HeroModel>(e.toString());
    }
  }

  /// Converte uma lista de HeroNetworkEntity em lista de HeroModel para o catálogo.
  List<HeroModel> toHeroes(List<HeroNetworkEntity> entities) {
    final List<HeroModel> heroes = [];
    for (var entity in entities) {
      heroes.add(toHero(entity));
    }
    return heroes;
  }
}