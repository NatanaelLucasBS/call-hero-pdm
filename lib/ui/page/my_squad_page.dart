import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repository/hero_repository.dart';
import '../../domain/hero_model.dart';
import '../widgets/hero_card.dart';
import 'hero_detail_page.dart';

/// Tela "Meu Esquadrão" para gerenciamento de até 15 agentes recrutados (Slides 8 e 9).
class MySquadPage extends StatefulWidget {
  const MySquadPage({super.key});

  @override
  State<MySquadPage> createState() => _MySquadPageState();
}

class _MySquadPageState extends State<MySquadPage> {
  bool _isLoading = true;
  List<HeroModel> _squadMembers = [];

  @override
  void initState() {
    super.initState();
    _loadSquad();
  }

  /// Carrega os membros do esquadrão persistidos no SQLite.
  Future<void> _loadSquad() async {
    setState(() => _isLoading = true);
    final repo = Provider.of<HeroRepository>(context, listen: false);
    final members = await repo.getSquadMembers();
    if (mounted) {
      setState(() {
        _squadMembers = members;
        _isLoading = false;
      });
    }
  }

  /// Confirma e processa a dispensa de um agente usando AwesomeDialog (Slide 9).
  void _confirmDismiss(HeroModel hero) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Dispensar Agente',
      desc: 'Deseja dispensar ${hero.name} do esquadrão?',
      btnCancelText: 'Cancelar',
      btnOkText: 'Dispensar',
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        final repo = Provider.of<HeroRepository>(context, listen: false);
        await repo.dismissHero(hero.id);
        _loadSquad();
      },
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final count = _squadMembers.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Esquadrão'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: _loadSquad,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de Status de Capacidade do Esquadrão (Capacidade máxima: 15 agentes)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Agentes no Esquadrão:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: count >= 15 ? Colors.red.shade100 : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: count >= 15 ? Colors.red : Colors.blue,
                          ),
                        ),
                        child: Text(
                          '$count / 15',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: count >= 15 ? Colors.red.shade900 : Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de Agentes ou Estado Vazio
                Expanded(
                  child: _squadMembers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shield_outlined, size: 70, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'Nenhum agente recrutado ainda.',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Visite o Contrato Diário para recrutar novos heróis para o seu esquadrão.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _squadMembers.length,
                          itemBuilder: (context, index) {
                            final hero = _squadMembers[index];
                            return HeroCard(
                              hero: hero,
                              subtitleOverride: 'Função: Especialista em ${hero.highestStatName.toUpperCase()}',
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'Dispensar',
                                onPressed: () => _confirmDismiss(hero),
                              ),
                              onTap: () async {
                                final changed = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HeroDetailPage(
                                      hero: hero,
                                      isSquadMember: true,
                                    ),
                                  ),
                                );
                                if (changed == true) {
                                  _loadSquad();
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
