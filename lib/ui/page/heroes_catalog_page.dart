import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';
import '../widgets/hero_card.dart';

/// Tela de Catálogo de Agentes com scroll infinito e paginação automática (Slide 5 e Aula 12).
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
            noItemsFoundIndicatorBuilder: (context) => const Center(
              child: Text('Nenhum herói encontrado.'),
            ),
          ),
        ),
      ),
    );
  }
}
