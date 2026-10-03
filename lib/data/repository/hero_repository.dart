import '../../domain/hero_model.dart';

/// ============================================================================
/// CONTRATO DO REPOSITÓRIO (Repository Interface - Aulas 08 e 12)
/// ----------------------------------------------------------------------------
/// - PAPEL: Definir a abstração de acesso a dados (Catálogo e Esquadrão),
///   desacoplando totalmente a UI das implementações concretas (Dio/SQLite).
/// - O QUE PUXA: Opera exclusivamente com modelos de domínio ([HeroModel]) e tipos puros.
/// - QUEM USA: Todas as telas da UI consom essa interface via `Provider.of<HeroRepository>(context)`.
/// - O QUE FAZ: Estabelece os contratos de busca paginada, busca por ID, recrutamento,
///   dispensa, contagem de vagas e evolução de atributos.
/// ============================================================================
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

  /// Recruta 5 heróis especialistas (um de cada atributo) para viabilizar testes de missões.
  Future<void> seedTestSquad();
}