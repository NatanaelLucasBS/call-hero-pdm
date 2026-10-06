import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';
import '../widgets/hero_card.dart';

/// Tela de catálogo geral de agentes com rolagem infinita e paginação sob demanda.
class HeroesCatalogPage extends StatefulWidget {
  const HeroesCatalogPage({super.key});

  @override
  State<HeroesCatalogPage> createState() => _HeroesCatalogPageState();
}

class _HeroesCatalogPageState extends State<HeroesCatalogPage> {
  late final HeroRepository _heroRepository;

  late final PagingController<int, HeroModel> _pagingController = PagingController<int, HeroModel>(
    getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => _heroRepository.getHeroes(page: pageKey, limit: 10),
  );

  @override
  void initState() {
    super.initState();
    _heroRepository = Provider.of<HeroRepository>(context, listen: false);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  /// Desenha a tela do catálogo infinito: Scaffold com AppBar, botão de atualização e PagedListView com HeroCards.
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Agentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Catálogo',
            onPressed: () => _pagingController.refresh(),
          ),
        ],
      ),
      body: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) => PagedListView<int, HeroModel>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<HeroModel>(
            itemBuilder: (context, hero, index) => HeroCard(hero: hero),
            firstPageProgressIndicatorBuilder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
            newPageProgressIndicatorBuilder: (context) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            firstPageErrorIndicatorBuilder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Falha ao carregar catálogo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Não foi possível estabelecer conexão com o servidor de agentes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                      onPressed: () => _pagingController.refresh(),
                    ),
                  ],
                ),
              ),
            ),
            newPageErrorIndicatorBuilder: (context) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Erro ao carregar mais heróis. Toque para tentar novamente.'),
                  onPressed: fetchNextPage,
                ),
              ),
            ),
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text('Nenhum herói encontrado.'),
            ),
          ),
        ),
      ),
    );
  }
}
