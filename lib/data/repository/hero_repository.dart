import '../../domain/hero_model.dart';

/// Interface do repositório de heróis e esquadrão segundo o padrão Repository (Aulas 08 e 12).
abstract class HeroRepository {
  /// Retorna lista paginada de heróis com estratégia de cache offline-first.
  Future<List<HeroModel>> getHeroes({required int page, required int limit});

  /// Busca os dados detalhados de um herói pelo seu identificador único.
  Future<HeroModel?> getHeroById(int id);

  /// Retorna todos os membros atualmente recrutados no esquadrão.
  Future<List<HeroModel>> getSquadMembers();

  /// Recruta um novo herói para o esquadrão, respeitando a regra de no máximo 15 membros.
  Future<bool> recruitHero(HeroModel hero);

  /// Dispensa um herói do esquadrão.
  Future<void> dismissHero(int id);

  /// Retorna a quantidade total de membros do esquadrão.
  Future<int> getSquadCount();

  /// Verifica se um herói específico já está recrutado no esquadrão.
  Future<bool> isHeroInSquad(int id);

  /// Incrementa em +1 um atributo de um herói após vencer um combate (Slide 13).
  Future<void> evolveHeroStat({required int heroId, required String statName});
}