import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/database/dao/hero_dao.dart';
import '../../data/database/dao/squad_dao.dart';
import '../../data/database/database_mapper.dart';
import '../../data/network/client/api_client.dart';
import '../../data/network/network_mapper.dart';
import '../../data/repository/hero_repository.dart';
import '../../data/repository/hero_repository_impl.dart';

/// ============================================================================
/// CONTAINER DE INJEÇÃO DE DEPENDÊNCIAS (IoC / DI - Aulas 02 e 12)
/// ----------------------------------------------------------------------------
/// - PAPEL: Montar a árvore de objetos e instâncias da aplicação.
/// - O QUE PUXA: Instancia o [ApiClient], os mappers ([NetworkMapper], [DatabaseMapper]),
///   os DAOs ([HeroDao], [SquadDao]) e o repositório ([HeroRepositoryImpl]).
/// - QUEM USA: [main.dart] na inicialização, fornecendo a lista de Providers para
///   o [MultiProvider]. Todas as telas consom o [HeroRepository] via context.
/// - O QUE FAZ: Aplica o princípio da Inversão de Controle (IoC), garantindo que
///   as telas dependam da abstração [HeroRepository] e não de implementações concretas.
/// ============================================================================
class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  /// Constrói e resolve a árvore de dependências da aplicação.
  static Future<ConfigureProviders> createDependencyTree() async {
    // API na Nuvem hospedada no Render:
    const String baseUrl = "https://call-hero-pdm.onrender.com";

    final apiClient = ApiClient(baseUrl: baseUrl);
    final networkMapper = NetworkMapper();
    final databaseMapper = DatabaseMapper();
    final heroDao = HeroDao();
    final squadDao = SquadDao();

    final heroRepository = HeroRepositoryImpl(
      apiClient: apiClient,
      networkMapper: networkMapper,
      databaseMapper: databaseMapper,
      heroDao: heroDao,
      squadDao: squadDao,
    );

    return ConfigureProviders(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<NetworkMapper>.value(value: networkMapper),
        Provider<DatabaseMapper>.value(value: databaseMapper),
        Provider<HeroDao>.value(value: heroDao),
        Provider<SquadDao>.value(value: squadDao),
        Provider<HeroRepository>.value(value: heroRepository),
        Provider<HeroRepositoryImpl>.value(value: heroRepository),
      ],
    );
  }
}
