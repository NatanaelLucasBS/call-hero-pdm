import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/configure_providers.dart';
import 'ui/page/home_page.dart';

/// Inicializa os bindings, constrói a árvore de dependências e inicia o aplicativo.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Constrói e injeta todas as dependências da aplicação
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
        title: 'Call-Hero',
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