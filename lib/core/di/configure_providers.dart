import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/database/dao/hero_dao.dart';
import '../../data/database/dao/squad_dao.dart';
import '../../data/database/database_mapper.dart';
import '../../data/network/client/api_client.dart';
import '../../data/network/network_mapper.dart';
import '../../data/repository/hero_repository.dart';
import '../../data/repository/hero_repository_impl.dart';

/// Configuração do container de Injeção de Dependências utilizando Provider (Aula 02 e Aula 12).
class ConfigureProviders {
  final List<SingleChildWidget> providers;

  ConfigureProviders({required this.providers});

  /// Constrói e resolve a árvore de dependências da aplicação.
  static Future<ConfigureProviders> createDependencyTree() async {
    // NOTA DIDÁTICA (Apresentação / Aula 06):
    // - Celular físico via adb reverse ou Desktop: "http://localhost:3000"
    // - Emulador Android: "http://10.0.2.2:3000"
    // - API na Nuvem (Render): "https://seu-app.onrender.com"
    const String baseUrl = "http://localhost:3000";

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
