import 'package:flutter/material.dart';

import 'daily_contract_page.dart';
import 'heroes_catalog_page.dart';
import 'mission_battle_page.dart';
import 'my_squad_page.dart';

/// Painel central de navegação do aplicativo Call-Hero.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Desenha um Card estilizado com ListTile contendo ícone tático, título, subtítulo e evento de toque.
  Widget _buildMenuOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  /// Desenha o Hub principal da aplicação: Scaffold com AppBar e lista vertical dos 4 pontos de acesso táticos.
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call-Hero'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildMenuOption(
            context: context,
            title: 'Agentes',
            subtitle: 'Catálogo de todos os heróis da API',
            icon: Icons.list,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HeroesCatalogPage()),
              );
            },
          ),
          _buildMenuOption(
            context: context,
            title: 'Contrato Diário',
            subtitle: 'Sorteio diário para recrutar novos agentes',
            icon: Icons.assignment,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyContractPage()),
              );
            },
          ),
          _buildMenuOption(
            context: context,
            title: 'Meu Esquadrão',
            subtitle: 'Gerenciar os agentes recrutados',
            icon: Icons.shield,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MySquadPage()),
              );
            },
          ),
          _buildMenuOption(
            context: context,
            title: 'Missões',
            subtitle: 'Combates táticos e evolução de atributos',
            icon: Icons.flash_on,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MissionBattlePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
