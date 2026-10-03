import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';

/// Modelo de uma rodada de crise na missão (Slide 10 e 11).
class MissionCrisisRound {
  final int roundNumber;
  final HeroModel enemy;
  final String testedStat;

  MissionCrisisRound({
    required this.roundNumber,
    required this.enemy,
    required this.testedStat,
  });
}

/// ============================================================================
/// TELA DE MISSÕES TÁTICAS E COMBATE (Tactical Missions - Slides 10 a 13)
/// ----------------------------------------------------------------------------
/// - PAPEL: Controlar a lógica de combate em turnos e evolução do esquadrão.
/// - O QUE PUXA: Consome o [HeroRepository] para obter os membros do esquadrão,
///   sortear vilões da API e salvar a evolução de atributos (+1 no SQLite).
/// - QUEM USA: Acessada via botão 'Missões' na [HomePage].
/// - O QUE FAZ:
///   1. Valida o pré-requisito de no mínimo 5 membros no esquadrão (Slide 10).
///   2. Gera aleatoriamente de 3 a 5 rounds de crise com inimigo e atributo testado.
///   3. Oculta os atributos do inimigo, exibindo apenas imagem, nome e o stat em teste.
///   4. Apresenta o esquadrão em grade circular 3x5 de avatares com nomes (Slide 11).
///   5. Aplica lockout de uso único por herói durante toda a missão (Slide 12).
///   6. Exibe diálogo de vitória com a foto do herói e evolução permanente (+1)
///      ou diálogo de derrota caso o jogador perca mais da metade dos rounds (Slide 13).
/// ============================================================================
class MissionBattlePage extends StatefulWidget {
  const MissionBattlePage({super.key});

  @override
  State<MissionBattlePage> createState() => _MissionBattlePageState();
}

class _MissionBattlePageState extends State<MissionBattlePage> {
  final Random _random = Random();

  bool _isLoading = true;
  List<HeroModel> _squadMembers = [];
  List<MissionCrisisRound> _rounds = [];
  int _currentRoundIndex = 0;

  // Controle de uso único por herói na missão (Slide 12)
  final Set<int> _usedHeroIds = {};

  // Controle de placar e heróis que venceram rodadas (Slide 12 e 13)
  int _victories = 0;
  int _defeats = 0;
  int _draws = 0;
  final List<HeroModel> _winningHeroes = [];

  // Atributos de teste conforme Slide 10 (Intelligence, Strength, Speed, Combat, Durability, Power)
  final List<String> _challengeStats = [
    'Intelligence',
    'Strength',
    'Speed',
    'Combat',
    'Durability',
    'Power',
  ];

  @override
  void initState() {
    super.initState();
    _startMission();
  }

  /// Inicializa a missão sorteando de 3 a 5 rounds e inimigos fora do esquadrão (Slide 10).
  Future<void> _startMission() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<HeroRepository>(context, listen: false);
    final squad = await repo.getSquadMembers();

    // Trava de segurança: esquadrão precisa ter pelo menos 5 agentes (Slide 10)
    if (squad.length < 5) {
      if (mounted) {
        setState(() {
          _squadMembers = squad;
          _isLoading = false;
        });
      }
      return;
    }

    final squadIds = squad.map((h) => h.id).toSet();

    // Sorteia de 3 a 5 rounds para o Desafio de Crise (Slide 10)
    final int totalRounds = _random.nextInt(3) + 3;
    final List<MissionCrisisRound> generatedRounds = [];

    for (int i = 0; i < totalRounds; i++) {
      // Regra do Slide 10: Se sortear herói do esquadrão, sorteia novamente
      int enemyId;
      HeroModel? enemy;
      do {
        enemyId = _random.nextInt(560) + 1;
      } while (squadIds.contains(enemyId));

      enemy = await repo.getHeroById(enemyId);
      // Fallback de segurança se id não existir na API
      enemy ??= await repo.getHeroById(1);

      final testedStat = _challengeStats[_random.nextInt(_challengeStats.length)];

      generatedRounds.add(
        MissionCrisisRound(
          roundNumber: i + 1,
          enemy: enemy!,
          testedStat: testedStat,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _squadMembers = squad;
        _rounds = generatedRounds;
        _currentRoundIndex = 0;
        _usedHeroIds.clear();
        _victories = 0;
        _defeats = 0;
        _draws = 0;
        _winningHeroes.clear();
        _isLoading = false;
      });
    }
  }

  /// Resolve o combate da rodada comparando o atributo em disputa (Slides 11 e 12).
  Future<void> _fightRound(HeroModel chosenHero) async {
    final round = _rounds[_currentRoundIndex];
    final stat = round.testedStat;

    final heroValue = chosenHero.powerstats.getStatByName(stat);
    final enemyValue = round.enemy.powerstats.getStatByName(stat);

    // Marca o herói como usado nesta missão (Slide 12)
    _usedHeroIds.add(chosenHero.id);

    String roundTitle;
    String roundDesc;
    DialogType dialogType;

    // Regra de Resolução do Slide 11:
    // Herói > Inimigo = Sucesso | Herói < Inimigo = Falha | Iguais = Empate
    if (heroValue > enemyValue) {
      _victories++;
      _winningHeroes.add(chosenHero);
      roundTitle = 'Sucesso na Rodada!';
      roundDesc = '${chosenHero.name} ($heroValue) superou ${round.enemy.name} ($enemyValue) em $stat.';
      dialogType = DialogType.success;
    } else if (heroValue < enemyValue) {
      _defeats++;
      roundTitle = 'Falha na Rodada!';
      roundDesc = '${round.enemy.name} ($enemyValue) superou ${chosenHero.name} ($heroValue) em $stat.';
      dialogType = DialogType.error;
    } else {
      _draws++;
      roundTitle = 'Empate Tático!';
      roundDesc = 'Ambos empataram em $stat com valor $heroValue.';
      dialogType = DialogType.warning;
    }

    if (!mounted) return;

    // Mostra o resultado do round e avança (Slide 12)
    AwesomeDialog(
      context: context,
      dialogType: dialogType,
      animType: AnimType.scale,
      title: roundTitle,
      desc: roundDesc,
      btnOkText: 'Continuar',
      btnOkOnPress: () {
        if (_currentRoundIndex + 1 < _rounds.length) {
          setState(() {
            _currentRoundIndex++;
          });
        } else {
          _finishMission();
        }
      },
    ).show();
  }

  /// Finaliza a missão e dispara o feedback com evolução de +1 no SQLite (Slide 13).
  Future<void> _finishMission() async {
    final totalRounds = _rounds.length;
    final bool overallVictory = _victories > (totalRounds / 2);
    final repo = Provider.of<HeroRepository>(context, listen: false);

    if (overallVictory && _winningHeroes.isNotEmpty) {
      // Sorteia um dos heróis que participou da vitória (Slide 13)
      final evolvedHero = _winningHeroes[_random.nextInt(_winningHeroes.length)];
      // Sorteia um powerstat aleatório para ganhar +1 (Slide 13)
      final randomStat = _challengeStats[_random.nextInt(_challengeStats.length)];

      // Grava a evolução de +1 permanente no SQLite
      await repo.evolveHeroStat(heroId: evolvedHero.id, statName: randomStat);

      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        body: Column(
          children: [
            Text(
              'Missão Cumprida!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
            ),
            const SizedBox(height: 12),
            // Imagem do herói exibida na caixa de diálogo conforme Slide 13
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 130,
                child: CachedNetworkImage(
                  imageUrl: evolvedHero.images.sm,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const Icon(Icons.person, size: 60),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              evolvedHero.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+1 permanente em ${randomStat.toUpperCase()}!',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Placar: $_victories Vitórias, $_defeats Derrotas, $_draws Empates.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        btnOkText: 'Nova Missão',
        btnOkOnPress: _startMission,
        btnCancelText: 'Sair',
        btnCancelOnPress: () => Navigator.pop(context),
      ).show();
    } else {
      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        body: Column(
          children: [
            Text(
              'Operação Fracassada!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
            ),
            const SizedBox(height: 12),
            // Imagem/ícone de derrota exibido na caixa de diálogo conforme Slide 13
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.shade200, width: 2),
              ),
              child: const Icon(Icons.sentiment_very_dissatisfied, size: 55, color: Colors.red),
            ),
            const SizedBox(height: 12),
            const Text(
              'Seu esquadrão não conseguiu superar a maioria das ameaças.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Placar: $_victories Vitórias, $_defeats Derrotas, $_draws Empates.',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        btnOkText: 'Tentar Novamente',
        btnOkOnPress: _startMission,
        btnCancelText: 'Sair',
        btnCancelOnPress: () => Navigator.pop(context),
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Missão Tática')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Trava de Entrada: Mínimo 5 membros no esquadrão (Slide 10)
    if (_squadMembers.length < 5) {
      return Scaffold(
        appBar: AppBar(title: const Text('Missão Tática')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 70, color: Colors.orange),
                const SizedBox(height: 16),
                Text(
                  'Esquadrão Incompleto',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'O esquadrão precisa ter pelo menos 5 agentes para iniciar uma Missão (Slide 10).\n\n'
                  'Você possui apenas ${_squadMembers.length} agente(s). Recrute mais heróis no Contrato Diário.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Voltar'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentRound = _rounds[_currentRoundIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Round ${currentRound.roundNumber} de ${_rounds.length}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placar atual da campanha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Vitórias: $_victories', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Text('Derrotas: $_defeats', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                Text('Empates: $_draws', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // Card do Inimigo da Rodada (Slide 11)
            // REGRA: "O app exibe a imagem e o nome do inimigo (não exibe seus atributos) além do nome do atributo em disputa"
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'INIMIGO DA RODADA',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        height: 120,
                        child: CachedNetworkImage(
                          imageUrl: currentRound.enemy.images.sm,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.person, size: 60),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentRound.enemy.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Exibe APENAS o nome do atributo em disputa, SEM revelar os números do inimigo!
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ATRIBUTO EM DISPUTA: ${currentRound.testedStat.toUpperCase()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Escalação: "Miniaturas apenas com nome e imagem circular em um grid 3x5" (Slide 11)
            Text(
              'Escale 1 Agente do Esquadrão (Grid 3x5):',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cada herói só pode lutar em uma rodada por missão.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Grade 3x5 com miniaturas circulares (Slide 11)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _squadMembers.length,
              itemBuilder: (context, index) {
                final hero = _squadMembers[index];
                final isUsed = _usedHeroIds.contains(hero.id);

                return Opacity(
                  opacity: isUsed ? 0.35 : 1.0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: isUsed ? null : () => _fightRound(hero),
                    child: Card(
                      elevation: isUsed ? 0 : 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Imagem Circular conforme Slide 11
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: CachedNetworkImageProvider(hero.images.sm),
                            ),
                            const SizedBox(height: 6),
                            // Apenas nome conforme Slide 11
                            Text(
                              hero.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                            if (isUsed)
                              const Text(
                                'Indisponível',
                                style: TextStyle(fontSize: 9, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
