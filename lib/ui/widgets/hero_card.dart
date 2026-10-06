import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/hero_model.dart';
import '../page/hero_detail_page.dart';

/// ============================================================================
/// COMPONENTE VISUAL DO CARD DE AGENTE (HeroCard - Slides 5, 8 e Aula 02)
/// ----------------------------------------------------------------------------
/// - PAPEL: Widget reutilizável que renderiza as informações resumidas de um herói
///   nas listas do Catálogo e do Meu Esquadrão.
/// - O QUE PUXA: Recebe um [HeroModel] completo, callbacks opcionais de [onTap],
///   widget de ação [trailing] (ex: botão de dispensar/lixeira) e subtítulo customizado.
/// - QUEM USA: [HeroesCatalogPage] e [MySquadPage].
/// - O QUE FAZ:
///   1. Exibe a imagem miniatura com [CachedNetworkImage] (cache de imagens na memória/disco).
///   2. Exibe o nome do herói e o badge colorido de alinhamento moral (GOOD / BAD).
///   3. Destaca o papel tático / maior atributo (ex: STRENGTH: 100) com cor temática.
///   4. Ao tocar, navega com animação nativa para a tela de detalhes ([HeroDetailPage]).
/// ============================================================================
class HeroCard extends StatelessWidget {
  final HeroModel hero;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? subtitleOverride;

  const HeroCard({
    super.key,
    required this.hero,
    this.onTap,
    this.trailing,
    this.subtitleOverride,
  });

  /// Define a cor temática para o badge de alinhamento moral (Bom = Verde, Mau = Vermelho, Neutro = Âmbar).
  Color _getAlignmentColor(String alignment) {
    switch (alignment.toLowerCase()) {
      case 'good':
        return Colors.green.shade600;
      case 'bad':
        return Colors.red.shade600;
      default:
        return Colors.amber.shade700;
    }
  }

  /// Desenha o card do agente: miniatura em cache à esquerda, nome, badge moral e atributo dominante ao centro, e ação à direita.
  @override
  Widget build(BuildContext context) {

    final highestStat = hero.highestStatName;
    final highestValue = hero.powerstats.getStatByName(highestStat);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HeroDetailPage(hero: hero),
                ),
              );
            },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Imagem em miniatura com cache eficiente (Aula 06)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 75,
                  height: 95,
                  child: CachedNetworkImage(
                    imageUrl: hero.images.sm,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Informações textuais e badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hero.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Badge de alinhamento
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getAlignmentColor(hero.biography.alignment).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getAlignmentColor(hero.biography.alignment),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            hero.biography.alignment.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getAlignmentColor(hero.biography.alignment),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      subtitleOverride ??
                          (hero.biography.fullName.isNotEmpty
                              ? hero.biography.fullName
                              : (hero.biography.publisher.isNotEmpty
                                  ? hero.biography.publisher
                                  : 'Identidade Secreta')),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Atributo Dominante (powerstats) e Aparência (appearance) conforme Slide 5
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${highestStat.toUpperCase()}: $highestValue',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        if (hero.appearance.race.isNotEmpty &&
                            hero.appearance.race != 'null' &&
                            hero.appearance.race != '-') ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hero.appearance.race,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else if (hero.appearance.gender.isNotEmpty &&
                            hero.appearance.gender != '-') ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hero.appearance.gender,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
