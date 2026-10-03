import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/configure_providers.dart';
import 'ui/page/home_page.dart';

/// Ponto de entrada do aplicativo Flutter (Aulas 02, 06, 08 e 12).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Constrói a árvore de injeção de dependências
  final data = await ConfigureProviders.createDependencyTree();

  runApp(AppRoot(data: data));
}

/// Widget raiz da aplicação que inicializa o MultiProvider e o MaterialApp.
class AppRoot extends StatelessWidget {
  final ConfigureProviders data;

  const AppRoot({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: data.providers,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Call of Heroes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A), // Azul escuro tático
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}