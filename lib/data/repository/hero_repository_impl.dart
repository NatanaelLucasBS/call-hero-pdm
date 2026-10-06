import '../../domain/hero_model.dart';
import '../database/dao/hero_dao.dart';
import '../database/dao/squad_dao.dart';
import '../database/database_mapper.dart';
import '../network/client/api_client.dart';
import '../network/network_mapper.dart';
import 'hero_repository.dart';

/// Implementação do repositório de heróis e orquestrador da política offline-first.
class HeroRepositoryImpl implements HeroRepository {
  final ApiClient apiClient;
  final NetworkMapper networkMapper;
  final HeroDao heroDao;
  final SquadDao squadDao;
  final DatabaseMapper databaseMapper;

  HeroRepositoryImpl({
    required this.heroDao,
    required this.squadDao,
    required this.databaseMapper,
    required this.apiClient,
    required this.networkMapper,
  });

  /// Busca heróis no cache local SQLite; se vazio, busca na API, salva no banco e retorna.
  @override
  Future<List<HeroModel>> getHeroes({
    required int page,
    required int limit,
  }) async {
    final offset = (page * limit) - limit;
    final dbEntities = await heroDao.selectAll(limit: limit, offset: offset);

    if (dbEntities.isNotEmpty) {
      return databaseMapper.toHeroes(dbEntities);
    }

    final networkEntities = await apiClient.getHeroes(page: page, limit: limit);
    final heroes = networkMapper.toHeroes(networkEntities);

    await heroDao.insertAll(databaseMapper.toHeroDatabaseEntities(heroes));

    return heroes;
  }

  /// Retorna os detalhes de um herói pelo ID: preferencialmente da API ou do banco local em caso offline.
  @override
  Future<HeroModel?> getHeroById(int id) async {
    // Se for membro do esquadrão, prioriza os dados locais onde ficam os stats evoluídos (+1)
    final squadMember = await squadDao.selectMemberById(id);
    if (squadMember != null) {
      return databaseMapper.toHero(squadMember);
    }

    // Preferencialmente busca da API
    try {
      final networkEntity = await apiClient.getHeroById(id);
      final hero = networkMapper.toHero(networkEntity);
      // Salva ou atualiza no cache local
      await heroDao.insert(databaseMapper.toHeroDatabaseEntity(hero));
      return hero;
    } catch (_) {
      // Em caso offline, recupera do cache do banco de dados SQLite
      final cachedHero = await heroDao.selectById(id);
      if (cachedHero != null) {
        return databaseMapper.toHero(cachedHero);
      }
    }
    return null;
  }

  /// Retorna todos os membros do esquadrão salvos no SQLite.
  @override
  Future<List<HeroModel>> getSquadMembers() async {
    final entities = await squadDao.selectAllMembers();
    return databaseMapper.toHeroes(entities);
  }

  /// Verifica se um agente já foi recrutado para o esquadrão.
  @override
  Future<bool> isHeroInSquad(int id) async {
    final member = await squadDao.selectMemberById(id);
    return member != null;
  }

  /// Recruta um novo herói, barrando a operação se já atingiu o limite de 15 agentes ou se já está no time.
  @override
  Future<bool> recruitHero(HeroModel hero) async {
    final currentCount = await squadDao.countMembers();
    if (currentCount >= 15) {
      return false;
    }

    final alreadyRecruited = await squadDao.selectMemberById(hero.id);
    if (alreadyRecruited != null) {
      return false;
    }

    await squadDao.insertMember(databaseMapper.toHeroDatabaseEntity(hero));
    return true;
  }

  /// Dispensa um herói do esquadrão pelo ID.
  @override
  Future<void> dismissHero(int id) async {
    await squadDao.deleteMember(id);
  }

  /// Retorna a quantidade atual de membros no esquadrão.
  @override
  Future<int> getSquadCount() async {
    return squadDao.countMembers();
  }

  /// Incrementa em +1 o stat vencedor no banco de dados local.
  @override
  Future<void> evolveHeroStat({
    required int heroId,
    required String statName,
  }) async {
    await squadDao.incrementStat(heroId: heroId, statName: statName);
  }

  /// Recruta 5 heróis especialistas (um de cada atributo) para viabilizar testes de missões:
  /// - Batman (ID: 70) - Inteligência (100)
  /// - Hulk (ID: 332) - Força (100)
  /// - Flash (ID: 263) - Velocidade (100)
  /// - Wolverine (ID: 717) - Durabilidade (100)
  /// - Captain America (ID: 149) - Combate (100)
  @override
  Future<void> seedTestSquad() async {
    final testHeroIds = [70, 332, 263, 717, 149];
    for (final id in testHeroIds) {
      final hero = await getHeroById(id);
      if (hero != null) {
        await recruitHero(hero);
      }
    }
  }
}
