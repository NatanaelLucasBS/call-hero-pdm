import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';

/// ============================================================================
/// TELA DE CONTRATO DIÁRIO (Daily Contract - Slide 7)
/// ----------------------------------------------------------------------------
/// - PAPEL: Permitir o sorteio diário de 1 herói aleatório e o recrutamento para o esquadrão.
/// - O QUE PUXA: Consome o [HeroRepository] para buscar o herói sorteado e persistir
///   no SQLite do esquadrão, além do [SharedPreferences] para salvar a data do último sorteio.
/// - QUEM USA: Acessada via botão 'Contrato Diário' na [HomePage].
/// - O QUE FAZ:
///   1. Garante a regra de 1 sorteio por dia persistida em [SharedPreferences].
///   2. Renderiza o card exclusivo do Slide 7: apenas nome, imagem e os 6 powerstats.
///   3. Permite recrutar o agente respeitando o teto de 15 membros e evitando duplicatas.
///   4. Emite diálogos de feedback visual com [AwesomeDialog].
/// ============================================================================
class DailyContractPage extends StatefulWidget {
  const DailyContractPage({super.key});

  @override
  State<DailyContractPage> createState() => _DailyContractPageState();
}

class _DailyContractPageState extends State<DailyContractPage> {
  static const String _prefLastDateKey = 'daily_contract_last_date';
  static const String _prefHeroIdKey = 'daily_contract_hero_id';

  bool _isLoading = true;
  bool _alreadyDrawnToday = false;
  bool _isAlreadyInSquad = false;
  int _squadCount = 0;
  HeroModel? _todaysHero;

  @override
  void initState() {
    super.initState();
    _checkDailyContract();
  }

  /// Verifica se o usuário já realizou o sorteio diário na data atual (Slide 7).
  Future<void> _checkDailyContract() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<HeroRepository>(context, listen: false);
    _squadCount = await repo.getSquadCount();

    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastDrawnDate = prefs.getString(_prefLastDateKey);

    if (!mounted) return;

    if (lastDrawnDate == todayStr) {
      final savedHeroId = prefs.getInt(_prefHeroIdKey);
      if (savedHeroId != null) {
        final hero = await repo.getHeroById(savedHeroId);
        final inSquad = await repo.isHeroInSquad(savedHeroId);
        if (mounted) {
          setState(() {
            _todaysHero = hero;
            _alreadyDrawnToday = true;
            _isAlreadyInSquad = inSquad;
            _isLoading = false;
          });
          return;
        }
      }
    }

    // Se ainda não sorteou hoje, realiza o sorteio diário automaticamente (Slide 7)
    await _drawNewHero();
  }

  /// Sorteia um novo herói aleatório e registra a data do sorteio no SharedPreferences.
  Future<void> _drawNewHero() async {
    setState(() => _isLoading = true);
    try {
      final repo = Provider.of<HeroRepository>(context, listen: false);
      final random = Random();
      // A base possui 563 heróis (akabab superhero API)
      final randomId = random.nextInt(560) + 1;

      final hero = await repo.getHeroById(randomId);
      if (hero != null) {
        final prefs = await SharedPreferences.getInstance();
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await prefs.setString(_prefLastDateKey, todayStr);
        await prefs.setInt(_prefHeroIdKey, hero.id);

        final inSquad = await repo.isHeroInSquad(hero.id);
        _squadCount = await repo.getSquadCount();

        if (mounted) {
          setState(() {
            _todaysHero = hero;
            _alreadyDrawnToday = true;
            _isAlreadyInSquad = inSquad;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Falha ao obter agente');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao sortear agente. Tente novamente.')),
        );
      }
    }
  }

  /// Recruta o herói sorteado para o esquadrão, respeitando o teto de 15 agentes (Slides 7 e 8).
  Future<void> _recruitAgent() async {
    if (_todaysHero == null) return;
    final repo = Provider.of<HeroRepository>(context, listen: false);

    if (_squadCount >= 15) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Esquadrão Cheio',
        desc: 'Seu esquadrão já atingiu a capacidade máxima de 15 agentes (Slide 7). Dispense alguém antes de recrutar.',
        btnOkText: 'Entendido',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    final success = await repo.recruitHero(_todaysHero!);

    if (!mounted) return;

    if (success) {
      final updatedCount = await repo.getSquadCount();
      if (!mounted) return;
      setState(() {
        _isAlreadyInSquad = true;
        _squadCount = updatedCount;
      });

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: 'Recrutamento Confirmado!',
        desc: '${_todaysHero!.name} agora faz parte do seu esquadrão!\nVagas ocupadas: $_squadCount/15.',
        btnOkText: 'OK',
        btnOkOnPress: () {},
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Não Foi Possível Recrutar',
        desc: 'Este agente já faz parte do esquadrão ou a capacidade máxima foi atingida.',
        btnOkText: 'OK',
        btnOkOnPress: () {},
      ).show();
    }
  }

  /// Card conforme Slide 7: "Deve conter apenas nome, imagem e power stats."
  Widget _buildDailyContractCard(HeroModel hero) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagem do Herói
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 140,
                height: 170,
                child: CachedNetworkImage(
                  imageUrl: hero.images.md.isNotEmpty ? hero.images.md : hero.images.sm,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Nome do Herói
            Text(
              hero.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),

            // Power Stats (Apenas os 6 atributos, conforme Slide 7)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow('Inteligência', hero.powerstats.intelligence, Colors.blue),
                  const SizedBox(height: 6),
                  _buildStatRow('Força', hero.powerstats.strength, Colors.red),
                  const SizedBox(height: 6),
                  _buildStatRow('Velocidade', hero.powerstats.speed, Colors.amber.shade800),
                  const SizedBox(height: 6),
                  _buildStatRow('Durabilidade', hero.powerstats.durability, Colors.green),
                  const SizedBox(height: 6),
                  _buildStatRow('Poder', hero.powerstats.power, Colors.purple),
                  const SizedBox(height: 6),
                  _buildStatRow('Combate', hero.powerstats.combat, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value.clamp(0, 100)) / 100,
              backgroundColor: Colors.grey.shade300,
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSquadFull = _squadCount >= 15;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrato Diário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: _checkDailyContract,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Informações de Capacidade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Convocação de Hoje',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSquadFull ? Colors.red.shade100 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSquadFull ? Colors.red : Colors.blue),
                        ),
                        child: Text(
                          'Esquadrão: $_squadCount/15',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isSquadFull ? Colors.red.shade900 : Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Card com APENAS nome, imagem e power stats (Slide 7)
                  if (_todaysHero != null) ...[
                    _buildDailyContractCard(_todaysHero!),
                    const SizedBox(height: 16),

                    // Botão Recrutar para o Esquadrão
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAlreadyInSquad
                            ? Colors.grey
                            : (isSquadFull ? Colors.orange.shade700 : Colors.green.shade700),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        _isAlreadyInSquad ? Icons.check_circle : (isSquadFull ? Icons.block : Icons.group_add),
                      ),
                      label: Text(
                        _isAlreadyInSquad
                            ? 'Agente já no Esquadrão'
                            : (isSquadFull ? 'Esquadrão Cheio (15/15)' : 'Recrutar para o Esquadrão'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: (_isAlreadyInSquad || isSquadFull) ? null : _recruitAgent,
                    ),
                  ],

                  if (_alreadyDrawnToday) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Este é o seu contrato diário de hoje. Um novo agente estará disponível amanhã!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
