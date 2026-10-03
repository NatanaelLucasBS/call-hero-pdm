import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';

/// ============================================================================
/// TELA DE DETALHES DO AGENTE (Hero Details - Slides 6, 9 e Aula 12)
/// ----------------------------------------------------------------------------
/// - PAPEL: Exibir a ficha cadastral completa do herói (Atributos, Biografia,
///   Aparência, Trabalho e Grupos).
/// - O QUE PUXA: Recebe um [HeroModel] inicial e consome o [HeroRepository]
///   para atualizar dados via `getHeroById(id)` e para dispensar o agente via `dismissHero(id)`.
/// - QUEM USA: Navegada ao tocar em qualquer card no catálogo ([HeroesCatalogPage])
///   ou na lista do esquadrão ([MySquadPage]).
/// - O QUE FAZ:
///   1. Renderiza os 6 atributos usando o pacote obrigatório [SegmentedBar] (`primer_progress_bar`).
///   2. Atualiza os dados com a API/banco em segundo plano no `initState`.
///   3. Permite dispensar o herói do esquadrão com diálogo de confirmação via [AwesomeDialog].
/// ============================================================================
class HeroDetailPage extends StatefulWidget {
  final HeroModel hero;
  final bool isSquadMember;

  const HeroDetailPage({
    super.key,
    required this.hero,
    this.isSquadMember = false,
  });

  @override
  State<HeroDetailPage> createState() => _HeroDetailPageState();
}

class _HeroDetailPageState extends State<HeroDetailPage> {
  late HeroModel _hero;

  @override
  void initState() {
    super.initState();
    _hero = widget.hero;
    // Carrega preferencialmente da API com fallback para o banco local (Slide 6 e 9)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLatestDetails();
    });
  }

  /// Busca os dados mais recentes do agente (API primeiro, SQLite offline)
  Future<void> _fetchLatestDetails() async {
    final repo = Provider.of<HeroRepository>(context, listen: false);
    final updated = await repo.getHeroById(widget.hero.id);
    if (updated != null && mounted) {
      setState(() {
        _hero = updated;
      });
    }
  }

  /// Constrói uma barra de atributo proporcional usando primer_progress_bar (Slide 6).
  Widget _buildStatBar(BuildContext context, String label, int value, Color color) {
    final int safeValue = value.clamp(0, 100);
    final int remaining = 100 - safeValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                '$safeValue / 100',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SegmentedBar(
            segments: [
              Segment(value: safeValue, color: color),
              Segment(value: remaining, color: Colors.grey.shade200),
            ],
            maxTotalValue: 100,
          ),
        ],
      ),
    );
  }

  /// Constrói um item de texto com rótulo e valor formatado.
  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty || value == '-' || value == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe diálogo de confirmação via AwesomeDialog antes de dispensar o agente (Slide 9).
  void _confirmDismiss(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Dispensar Agente',
      desc: 'Tem certeza que deseja dispensar ${_hero.name} do esquadrão?',
      btnCancelText: 'Cancelar',
      btnOkText: 'Dispensar',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final repo = Provider.of<HeroRepository>(context, listen: false);
        await repo.dismissHero(_hero.id);
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hero.name),
        actions: [
          if (widget.isSquadMember)
            IconButton(
              icon: const Icon(Icons.person_remove, color: Colors.red),
              tooltip: 'Dispensar Agente',
              onPressed: () => _confirmDismiss(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem em alta resolução (Slide 6)
            SizedBox(
              height: 320,
              child: CachedNetworkImage(
                imageUrl: _hero.images.lg.isNotEmpty ? _hero.images.lg : _hero.images.md,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 80, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho de Identidade
                  Text(
                    _hero.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (_hero.biography.fullName.isNotEmpty)
                    Text(
                      _hero.biography.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  const SizedBox(height: 16),

                  // Seção: Atributos de Poder (Powerstats) com primer_progress_bar (Slide 6)
                  Text(
                    'Atributos de Combate',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(),
                  _buildStatBar(context, 'Inteligência', _hero.powerstats.intelligence, Colors.blue),
                  _buildStatBar(context, 'Força', _hero.powerstats.strength, Colors.red),
                  _buildStatBar(context, 'Velocidade', _hero.powerstats.speed, Colors.amber.shade700),
                  _buildStatBar(context, 'Durabilidade', _hero.powerstats.durability, Colors.green),
                  _buildStatBar(context, 'Poder', _hero.powerstats.power, Colors.purple),
                  _buildStatBar(context, 'Combate', _hero.powerstats.combat, Colors.orange),
                  const SizedBox(height: 20),

                  // Seção: Biografia
                  Text(
                    'Biografia',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(),
                  _buildInfoRow('Editora:', _hero.biography.publisher),
                  _buildInfoRow('Alinhamento:', _hero.biography.alignment.toUpperCase()),
                  _buildInfoRow('Local de Origem:', _hero.biography.placeOfBirth),
                  _buildInfoRow('1ª Aparição:', _hero.biography.firstAppearance),
                  _buildInfoRow('Alter Egos:', _hero.biography.alterEgos),
                  if (_hero.biography.aliases.isNotEmpty)
                    _buildInfoRow('Codinomes:', _hero.biography.aliases.join(', ')),
                  const SizedBox(height: 20),

                  // Seção: Aparência
                  Text(
                    'Aparência',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(),
                  _buildInfoRow('Gênero:', _hero.appearance.gender),
                  _buildInfoRow('Raça:', _hero.appearance.race),
                  _buildInfoRow('Altura:', _hero.appearance.height.join(' / ')),
                  _buildInfoRow('Peso:', _hero.appearance.weight.join(' / ')),
                  _buildInfoRow('Olhos:', _hero.appearance.eyeColor),
                  _buildInfoRow('Cabelo:', _hero.appearance.hairColor),
                  const SizedBox(height: 20),

                  // Seção: Ocupação e Afiliações
                  Text(
                    'Trabalho & Conexões',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(),
                  _buildInfoRow('Ocupação:', _hero.work.occupation),
                  _buildInfoRow('Base:', _hero.work.base),
                  _buildInfoRow('Grupos:', _hero.connections.groupAffiliation),
                  _buildInfoRow('Parentes:', _hero.connections.relatives),
                  const SizedBox(height: 30),

                  // Botão de Dispensa do Esquadrão (Slide 9)
                  if (widget.isSquadMember)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.person_remove),
                        label: const Text('Dispensar do Esquadrão'),
                        onPressed: () => _confirmDismiss(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
