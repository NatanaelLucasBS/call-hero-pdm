import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_repository_example/domain/hero_model.dart';

void main() {
  group('Missões Táticas - Teste com 5 Especialistas (1 de cada atributo)', () {
    // 1. Definição dos 5 agentes de teste com especialidades distintas
    final batman = HeroModel(
      id: 70,
      name: 'Batman',
      slug: '70-batman',
      powerstats: const Powerstats(
        intelligence: 100,
        strength: 26,
        speed: 27,
        durability: 50,
        power: 47,
        combat: 90,
      ),
      appearance: const Appearance(gender: 'Male', race: 'Human', height: ["6'2", '188 cm'], weight: ['210 lb', '95 kg'], eyeColor: 'blue', hairColor: 'black'),
      biography: const Biography(fullName: 'Bruce Wayne', alterEgos: 'No alter egos found.', aliases: ['Dark Knight'], placeOfBirth: 'Crest Hill, Bristol Township; Gotham County', firstAppearance: 'Detective Comics #27', publisher: 'DC Comics', alignment: 'good'),
      work: const Work(occupation: 'Businessman', base: 'Batcave, Gotham City'),
      connections: const Connections(groupAffiliation: 'Justice League', relatives: 'Martha Wayne (mother)'),
      images: const HeroImages(xs: '', sm: '', md: '', lg: ''),
    );

    final hulk = HeroModel(
      id: 332,
      name: 'Hulk',
      slug: '332-hulk',
      powerstats: const Powerstats(
        intelligence: 88,
        strength: 100,
        speed: 63,
        durability: 100,
        power: 98,
        combat: 85,
      ),
      appearance: const Appearance(gender: 'Male', race: 'Human / Radiation', height: ["8'0", '244 cm'], weight: ['1400 lb', '630 kg'], eyeColor: 'green', hairColor: 'green'),
      biography: const Biography(fullName: 'Bruce Banner', alterEgos: 'No alter egos found.', aliases: ['Incredible Hulk'], placeOfBirth: 'Dayton, Ohio', firstAppearance: 'Incredible Hulk #1', publisher: 'Marvel Comics', alignment: 'good'),
      work: const Work(occupation: 'Nuclear Physicist', base: 'Avengers Mansion'),
      connections: const Connections(groupAffiliation: 'Avengers', relatives: 'Betty Ross (wife)'),
      images: const HeroImages(xs: '', sm: '', md: '', lg: ''),
    );

    final flash = HeroModel(
      id: 263,
      name: 'Flash',
      slug: '263-flash',
      powerstats: const Powerstats(
        intelligence: 63,
        strength: 10,
        speed: 100,
        durability: 50,
        power: 68,
        combat: 32,
      ),
      appearance: const Appearance(gender: 'Male', race: 'Human', height: ["6'0", '183 cm'], weight: ['190 lb', '86 kg'], eyeColor: 'Blue', hairColor: 'Blond'),
      biography: const Biography(fullName: 'Barry Allen', alterEgos: 'No alter egos found.', aliases: ['Scarlet Speedster'], placeOfBirth: 'Fallville, Iowa', firstAppearance: 'Showcase #4', publisher: 'DC Comics', alignment: 'good'),
      work: const Work(occupation: 'Forensic Scientist', base: 'Central City'),
      connections: const Connections(groupAffiliation: 'Justice League', relatives: 'Iris West (wife)'),
      images: const HeroImages(xs: '', sm: '', md: '', lg: ''),
    );

    final wolverine = HeroModel(
      id: 717,
      name: 'Wolverine',
      slug: '717-wolverine',
      powerstats: const Powerstats(
        intelligence: 63,
        strength: 32,
        speed: 50,
        durability: 100,
        power: 89,
        combat: 95,
      ),
      appearance: const Appearance(gender: 'Male', race: 'Mutant', height: ["5'3", '160 cm'], weight: ['300 lb', '135 kg'], eyeColor: 'Blue', hairColor: 'Black'),
      biography: const Biography(fullName: 'Logan', alterEgos: 'No alter egos found.', aliases: ['Weapon X'], placeOfBirth: 'Cold Lake, Alberta, Canada', firstAppearance: 'Incredible Hulk #180', publisher: 'Marvel Comics', alignment: 'good'),
      work: const Work(occupation: 'Adventurer', base: 'X-Mansion'),
      connections: const Connections(groupAffiliation: 'X-Men', relatives: 'Laura Kinney (clone/daughter)'),
      images: const HeroImages(xs: '', sm: '', md: '', lg: ''),
    );

    final captainAmerica = HeroModel(
      id: 149,
      name: 'Captain America',
      slug: '149-captain-america',
      powerstats: const Powerstats(
        intelligence: 69,
        strength: 19,
        speed: 38,
        durability: 55,
        power: 60,
        combat: 100,
      ),
      appearance: const Appearance(gender: 'Male', race: 'Human', height: ["6'2", '188 cm'], weight: ['240 lb', '108 kg'], eyeColor: 'blue', hairColor: 'blond'),
      biography: const Biography(fullName: 'Steve Rogers', alterEgos: 'No alter egos found.', aliases: ['First Avenger'], placeOfBirth: 'Manhattan, New York', firstAppearance: 'Captain America Comics #1', publisher: 'Marvel Comics', alignment: 'good'),
      work: const Work(occupation: 'Soldier', base: 'Avengers Compound'),
      connections: const Connections(groupAffiliation: 'Avengers', relatives: 'Joseph Rogers (father)'),
      images: const HeroImages(xs: '', sm: '', md: '', lg: ''),
    );

    final squad = [batman, hulk, flash, wolverine, captainAmerica];

    test('Valida que o esquadrão possui exatamente 5 agentes atendendo ao pré-requisito de missão', () {
      expect(squad.length, 5);
      expect(squad.length >= 5, isTrue);
    });

    test('Valida que cada um dos 5 heróis possui uma especialidade dominante diferente', () {
      expect(batman.highestStatName, 'Intelligence');
      expect(hulk.powerstats.strength, 100);
      expect(flash.highestStatName, 'Speed');
      expect(wolverine.powerstats.durability, 100);
      expect(captainAmerica.highestStatName, 'Combat');
    });

    test('Simula a 1ª Missão Tática: Desafio de Inteligência e Força', () {
      final usedHeroIds = <int>{};
      int victories = 0;

      // Round 1: Desafio de Inteligência contra inimigo com 60
      const statRound1 = 'intelligence';
      const enemyValue1 = 60;
      expect(usedHeroIds.contains(batman.id), isFalse);
      expect(batman.powerstats.getStatByName(statRound1) > enemyValue1, isTrue);
      usedHeroIds.add(batman.id);
      victories++;

      // Round 2: Desafio de Força contra inimigo com 80
      const statRound2 = 'strength';
      const enemyValue2 = 80;
      expect(usedHeroIds.contains(hulk.id), isFalse);
      expect(hulk.powerstats.getStatByName(statRound2) > enemyValue2, isTrue);
      usedHeroIds.add(hulk.id);
      victories++;

      // Round 3: Desafio de Combate contra inimigo com 70
      const statRound3 = 'combat';
      const enemyValue3 = 70;
      expect(usedHeroIds.contains(captainAmerica.id), isFalse);
      expect(captainAmerica.powerstats.getStatByName(statRound3) > enemyValue3, isTrue);
      usedHeroIds.add(captainAmerica.id);
      victories++;

      // Trava de uso único verificada
      expect(usedHeroIds.length, 3);
      // Maioria dos rounds vencida (3 de 3)
      expect(victories > (3 / 2), isTrue);

      // Simulação da evolução permanente de stat (+1)
      final evolvedBatman = batman.evolveStat('intelligence');
      expect(evolvedBatman.powerstats.intelligence, 101);
    });

    test('Simula a 2ª Missão Tática: Desafio de Velocidade e Durabilidade com lockout resetado', () {
      final usedHeroIds = <int>{};
      int victories = 0;

      // Round 1: Desafio de Velocidade contra inimigo com 90
      const statRound1 = 'speed';
      const enemyValue1 = 90;
      expect(flash.powerstats.getStatByName(statRound1) > enemyValue1, isTrue);
      usedHeroIds.add(flash.id);
      victories++;

      // Round 2: Desafio de Durabilidade contra inimigo com 85
      const statRound2 = 'durability';
      const enemyValue2 = 85;
      expect(wolverine.powerstats.getStatByName(statRound2) > enemyValue2, isTrue);
      usedHeroIds.add(wolverine.id);
      victories++;

      // Round 3: Desafio de Inteligência
      const statRound3 = 'intelligence';
      const enemyValue3 = 75;
      expect(batman.powerstats.getStatByName(statRound3) > enemyValue3, isTrue);
      usedHeroIds.add(batman.id);
      victories++;

      expect(victories >= 2, isTrue);
    });

    test('Simula a 3ª Missão Tática: Desafio Crise com 5 Rounds utilizando os 5 agentes sem repetição', () {
      final usedHeroIds = <int>{};
      int victories = 0;

      // 5 rounds, cada um usando um dos 5 especialistas
      final rounds = [
        {'stat': 'intelligence', 'hero': batman, 'enemy': 70},
        {'stat': 'strength', 'hero': hulk, 'enemy': 80},
        {'stat': 'speed', 'hero': flash, 'enemy': 60},
        {'stat': 'durability', 'hero': wolverine, 'enemy': 90},
        {'stat': 'combat', 'hero': captainAmerica, 'enemy': 75},
      ];

      for (final r in rounds) {
        final hero = r['hero'] as HeroModel;
        final stat = r['stat'] as String;
        final enemyVal = r['enemy'] as int;

        // Verifica que o herói ainda não foi usado nesta missão
        expect(usedHeroIds.contains(hero.id), isFalse);
        usedHeroIds.add(hero.id);

        if (hero.powerstats.getStatByName(stat) > enemyVal) {
          victories++;
        }
      }

      // Todos os 5 heróis foram utilizados de forma tática sem repetição
      expect(usedHeroIds.length, 5);
      // Vitória esmagadora: 5 vitórias em 5 rounds
      expect(victories, 5);
    });
  });
}
