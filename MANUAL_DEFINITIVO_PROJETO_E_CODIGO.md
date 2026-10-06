# MANUAL DEFINITIVO DO PROJETO E DO CODIGO-FONTE: CALL-HERO
## Disciplina: Programacao para Dispositivos Moveis (PDM)
## Professor: Taniro C. Rodrigues | UFRN
## Trabalho Pratico 1: Centro Tatico de Recrutamento e Batalhas de Super-Herois

---

# SUMARIO GERAL

1. [Visao Geral da Arquitetura e Engenharia de Software](#1-visao-geral-da-arquitetura-e-engenharia-de-software)
   - 1.1 O Pipeline Completo de Dados (Rede ao Banco e UI)
   - 1.2 Politica Offline-First e Isolamento de Tabelas
   - 1.3 Inversao de Controle (IoC) e Arvore de Dependencias
2. [Os 5 Herois de Teste Semeados (seedTestSquad)](#2-os-5-herois-de-teste-semeados-seedtestsquad)
   - 2.1 Justificativa Tecnica e Regra de Negocio do Slide 10
   - 2.2 Ficha Tecnica dos 5 Especialistas (Atributos Dominantes)
   - 2.3 Como a Semeadura Funciona no Codigo-Fonte
3. [Analise Meticulosa do Slide 12 e Todos os Slides do Professor](#3-analise-meticulosa-do-slide-12-e-todos-os-slides-do-professor)
   - 3.1 Slide 12: Execucao dos Rounds, Indicadores, Trava de Uso Unico e Avanco
   - 3.2 Slide 03: Servidor Mock json-server e Superhero API
   - 3.3 Slide 04: Hub de Navegacao (HomePage)
   - 3.4 Slide 05: Catalogo Infinito e Paginacao sob Demanda
   - 3.5 Slide 06: Ficha Tecnica e Barras Proporcionais Primer
   - 3.6 Slide 07: Contrato Diario com SharedPreferences e Trava de 24 Horas
   - 3.7 Slide 08: Gestao do Esquadrao, Teto de 15 Agentes e Papel Tatico
   - 3.8 Slide 09: Dispensa com AwesomeDialog e Limpeza no SQLite
   - 3.9 Slide 10: Desafio de Crise, Minimo 5 Agentes e Sorteio Anti-Clone
   - 3.10 Slide 11: Arena de Combate, Grade 3x5 e Atributos Ocultos
   - 3.11 Slide 13: Criterio de Vitoria, Dialogos e Evolucao Permanente (+1)
   - 3.12 Slide 14: Resumo dos Criterios e Conformidade Arquitetural
4. [Dicionario Tecnico Arquivo por Arquivo, Funcao por Funcao](#4-dicionario-tecnico-arquivo-por-arquivo-funcao-por-funcao)
   - 4.1 Camada de Inicializacao e DI (main.dart, configure_providers.dart)
   - 4.2 Camada de Dominio (hero_model.dart, exceptions)
   - 4.3 Camada de Rede (api_client.dart, entities, network_mapper.dart)
   - 4.4 Camada de Banco de Dados SQLite (base_dao.dart, hero_dao.dart, squad_dao.dart, database_mapper.dart, entities)
   - 4.5 Camada de Repositorio (hero_repository.dart, hero_repository_impl.dart)
   - 4.6 Componentes Visuais (hero_card.dart)
   - 4.7 Telas da Interface (home_page.dart, heroes_catalog_page.dart, hero_detail_page.dart, daily_contract_page.dart, my_squad_page.dart, mission_battle_page.dart)
5. [Banco de Perguntas de Alto Nivel da Banca e Respostas Senior](#5-banco-de-perguntas-de-alto-nivel-da-banca-e-respostas-senior)

---

# 1. VISAO GERAL DA ARQUITETURA E ENGENHARIA DE SOFTWARE

O projeto Call-Hero adota uma arquitetura em camadas estritas orientada pelo principio da Separacao de Responsabilidades (Separation of Concerns - SoC), baseando-se nos padroes Repository Pattern, Data Access Object (DAO), Data Transfer Object (DTO) e Inversao de Controle (IoC) via Provider.

### 1.1 O Pipeline Completo de Dados (Rede ao Banco e UI)

O fluxo de dados da aplicacao obedece a um ciclo unidirecional e previsivel:

```
[API Remota / json-server (Render)]
               |
        (1. HTTP GET via Dio)
               v
       [ApiClient] (lib/data/network/client/api_client.dart)
               |
      (2. Converte JSON bruto em DTO)
               v
   [HeroNetworkEntity] (lib/data/network/entity/hero_network_entity.dart)
               |
     (3. Traducao de fronteira de rede)
               v
     [NetworkMapper] (lib/data/network/network_mapper.dart)
               |
               v
          [HeroModel] (lib/domain/hero_model.dart)
          (Modelo Puro de Dominio - Imutavel)
               ^
               |
     [HeroRepositoryImpl] (lib/data/repository/hero_repository_impl.dart)
    (Orquestrador Central - Ponto Unico da Verdade)
               |
               +--------------------------------------+
               |                                      |
     (4. Traducao para Banco)               (5. Persistencia Local)
               v                                      v
        [DatabaseMapper]                       [BaseDao / SQLite]
  (database_mapper.dart)                    (heroes_database.db)
               |                                      |
               v                                      +---> [hero_dao.dart] (Tabela 'heroes')
   [HeroDatabaseEntity]                               +---> [squad_dao.dart] (Tabela 'squad')
 (hero_database_entity.dart)
               |
               v
       [Interface do Usuario (UI) / Pages]
  (Consome HeroRepository via Provider.of<HeroRepository>(context))
```

### 1.2 Politica Offline-First e Isolamento de Tabelas

A aplicacao possui duas tabelas relacionais distintas dentro do SQLite (`heroes_database.db`):

1. **Tabela `heroes` (Cache Transiente do Catalogo)**:
   - Armazena os herois baixados da API para exibicao na lista infinita.
   - Funciona sob a politica Cache-First: `HeroRepositoryImpl.getHeroes()` consulta primeiro o SQLite (`HeroDao.selectAll()`). Se houver registros, entrega imediatamente para a UI. Se estiver vazio, realiza requisicao HTTP na API (`ApiClient.getHeroes()`), converte os dados, salva em lote no SQLite (`HeroDao.insertAll()`) dentro de uma transacao atomica e entrega a UI.
   - Em caso de queda de conexao, os herois ja cacheados continuam acessiveis.

2. **Tabela `squad` (Persistencia de Estado do Jogador)**:
   - Armazena exclusivamente os herois recrutados pelo usuario (maximo de 15 agentes).
   - **Regra Critica de Isolamento**: A tabela `squad` NUNCA e sobrescrita pelas chamadas da API do catalogo. Isso e fundamental porque quando um heroi vence rodadas em uma missao tatica, ele recebe +1 ponto permanente em um powerstat (`SquadDao.incrementStat`). Se sincronizassemos o esquadrao com a API, esses pontos conquistados em combate seriam destruidos e resetados para o valor padrao da API.
   - Na busca de detalhes (`HeroRepositoryImpl.getHeroById()`), o repositorio verifica primeiro se o ID requisitado existe na tabela `squad`. Se existir, retorna os dados locais para preservar os pontos evoluidos. Caso contrario, busca na API (com fallback na tabela `heroes`).

### 1.3 Inversao de Controle (IoC) e Arvore de Dependencias

O arquivo `lib/core/di/configure_providers.dart` centraliza a instanciacao de todos os servicos da aplicacao:
- Instancia o `ApiClient` com a URL base da nuvem (`https://call-hero-pdm.onrender.com`).
- Instancia os mappers puros `NetworkMapper` e `DatabaseMapper`.
- Instancia os DAOs concretos `HeroDao` e `SquadDao`.
- Injeta essas instancias no construtor de `HeroRepositoryImpl`.
- Expoe a interface abstrata `HeroRepository` e a implementacao concreta `HeroRepositoryImpl` atraves de `Provider<HeroRepository>.value` no widget raiz `MultiProvider`.
- Dessa forma, nenhum widget da UI instancia servicos diretamente via `new` ou depende de conexoes HTTP/SQL, respeitando o principio da Inversao de Dependencias (DIP do SOLID).

---

# 2. OS 5 HEROIS DE TESTE SEMEADOS (seedTestSquad)

### 2.1 Justificativa Tecnica e Regra de Negocio do Slide 10

No Slide 10 da avaliacao do professor Taniro, ha uma trava rigida de negocio:
> "O esquadrao precisa ter pelo menos 5 agentes para iniciar uma Missao."

Por outro lado, o Slide 07 estabelece que o recrutamento regular so pode ser realizado atraves do Contrato Diario, limitado a **1 sorteio a cada 24 horas** (controlado por data no `SharedPreferences`).

Se a aplicacao dependesse unicamente do fluxo diario natural, o professor ou o avaliador precisaria abrir o aplicativo durante **5 dias consecutivos** para recrutar 5 agentes e conseguir testar a funcionalidade de Missao e Combate (Slides 10 a 13).

Para resolver essa restricao de avaliacao sem violar as regras de persistencia do SQLite, foi implementada a rotina de semeadura `seedTestSquad()` no `HeroRepositoryImpl`, acionada atraves de botoes de teste presentes na `MySquadPage` e na `MissionBattlePage`.

### 2.2 Ficha Tecnica dos 5 Especialistas (Atributos Dominantes)

Foram selecionados cirurgicamente 5 herois canonicos da Superhero API, onde cada um possui pontuacao maxima (100) exatamente em um dos 5 atributos principais exigidos nos Desafios de Crise do Slide 10:

| ID | Nome do Heroi | Atributo Dominante | Pontuacao | Papel Tatico no Esquadrao |
| :--- | :--- | :--- | :--- | :--- |
| **70** | **Batman** | **Intelligence** | 100 | Estrategista Tatico (Inteligencia) |
| **332** | **Hulk** | **Strength** | 100 | Vanguarda de Impacto (Forca) |
| **263** | **Flash** | **Speed** | 100 | Interceptador Veloz (Velocidade) |
| **717** | **Wolverine** | **Durability** | 100 | Resistencia e Regeneracao (Durabilidade) |
| **149** | **Capitao America** | **Combat** | 100 | Mestre em Artes Marciais (Combate) |

Essa selecao garante que o jogador possua exatamente 1 especialista de nivel maximo para cada tipo de round que o sistema sortear durante o Desafio de Crise.

### 2.3 Como a Semeadura Funciona no Codigo-Fonte

A implementacao no `lib/data/repository/hero_repository_impl.dart` executa o seguinte fluxo assincrono:

```dart
@override
Future<void> seedTestSquad() async {
  final testHeroIds = [70, 332, 263, 717, 149];
  for (final id in testHeroIds) {
    final hero = await getHeroById(id);
    if (hero != null) {
      await recruitHero(hero);
    }
  }
}
```

1. Itera sobre a lista de IDs predefinidos.
2. Invoca `getHeroById(id)` para obter o modelo completo com imagens e biografias (via API ou cache SQLite).
3. Invoca `recruitHero(hero)` que:
   - Valida se o esquadrao ja atingiu a capacidade maxima de 15 agentes (`squadDao.countMembers() < 15`).
   - Verifica se o heroi ja esta cadastrado no time (`squadDao.selectMemberById(hero.id) == null`).
   - Converte para `HeroDatabaseEntity` e insere na tabela `squad` do SQLite.

Dessa forma, o esquadrao atinge instantaneamente 5 integrantes, destravando a entrada imediata nas arenas de combate da `MissionBattlePage`.

---

# 3. ANALISE METICULOSA DO SLIDE 12 E TODOS OS SLIDES DO PROFESSOR

### 3.1 Slide 12: Execucao dos Rounds, Indicadores, Trava de Uso Unico e Avanco

O Slide 12 representa o nucleo de controle da maquina de estados de combate da missao. Abaixo estao os 3 requisitos exigidos pelo professor Taniro e a demonstracao exata de como foram implementados no codigo-fonte:

#### Requisito 1: Indicadores de Resultado Visualizados pelo Jogador
- **Texto do Slide**: *"Apos a rodada o jogador visualiza os indicadores de resultado calculados pelo app (Vitoria, Derrota ou Empate)."*
- **Implementacao no Codigo (`_fightRound` em `mission_battle_page.dart`)**:
  - A funcao extrai o valor numerico do atributo em disputa para o heroi escalado e para o inimigo da rodada:
    ```dart
    final heroValue = chosenHero.powerstats.getStatByName(stat);
    final enemyValue = round.enemy.powerstats.getStatByName(stat);
    ```
  - Executa a comparacao matematica:
    - `heroValue > enemyValue`: Incrementa `_victories++`, adiciona o heroi a `_winningHeroes`, define o titulo como `'Seu heroi venceu!'` e o tipo de dialogo como `DialogType.success`.
    - `heroValue < enemyValue`: Incrementa `_defeats++`, define o titulo como `'Seu heroi perdeu!'` e o tipo como `DialogType.error`.
    - `heroValue == enemyValue`: Incrementa `_draws++`, define o titulo como `'Empate Tatico!'` e o tipo como `DialogType.warning`.
  - Apresenta instantaneamente a caixa de dialogo personalizada via `AwesomeDialog` contendo os nomes de ambos os combatentes, o atributo comparado e as pontuacoes individuais (ex.: *Flash (100) superou Venom (60) em Speed*).

#### Requisito 2: Trava de Uso Unico por Heroi na Missao
- **Texto do Slide**: *"Cada agente do esquadrao so pode ser enviado para uma rodada por missao."*
- **Implementacao no Codigo (`mission_battle_page.dart`)**:
  - Declarado no estado o conjunto de IDs utilizados:
    ```dart
    final Set<int> _usedHeroIds = {};
    ```
  - No momento em que o jogador confirma o heroi no combate, seu identificador e registrado no Set:
    ```dart
    _usedHeroIds.add(chosenHero.id);
    ```
  - Na renderizacao da grade 3x5 de escalacao (`GridView.builder`), cada card e avaliado contra esse conjunto:
    ```dart
    final isUsed = _usedHeroIds.contains(hero.id);
    ```
  - Se `isUsed == true`:
    - `opacity: 0.35` (efeito visual esmaecido).
    - `onTap: isUsed ? null : () => _fightRound(hero)` (desabilita o clique).
    - Renderiza o texto `'Indisponivel'` em vermelho abaixo do nome.
  - Isso impede categoricamente que o mesmo heroi lute mais de uma rodada na mesma operacao.

#### Requisito 3: Atualizacao do Placar e Avanco Automatico de Rodada
- **Texto do Slide**: *"Apos o confronto da rodada, o app atualiza o placar e avanca automaticamente para o proximo round da fila ate concluir a campanha."*
- **Implementacao no Codigo (`mission_battle_page.dart`)**:
  - No topo da tela de missao, o placar e desenhado com reatividade do Flutter:
    ```dart
    Text('Vitorias: $_victories', style: const TextStyle(color: Colors.green)),
    Text('Derrotas: $_defeats', style: const TextStyle(color: Colors.red)),
    Text('Empates: $_draws', style: const TextStyle(color: Colors.orange)),
    ```
  - No callback do botao 'Continuar' do `AwesomeDialog` do resultado da rodada:
    ```dart
    btnOkOnPress: () {
      if (_currentRoundIndex + 1 < _rounds.length) {
        setState(() {
          _currentRoundIndex++;
        });
      } else {
        _finishMission();
      }
    }
    ```
  - Se ainda restarem rounds na fila, o indice `_currentRoundIndex` e incrementado, reconstruindo a tela com o proximo inimigo e atributo sorteado. Se a fila foi esgotada, invoca automaticamente `_finishMission()`.

---

### 3.2 Slide 03: Servidor Mock json-server e Superhero API
- **Requisito**: Consumir dados da Superhero API (Akabab) atraves de servidor REST simulado com `json-server`.
- **Implementacao**:
  - O arquivo `backend/db.json` contem 563 super-herois.
  - Para flexibilidade e avaliacao em qualquer ambiente, a API foi disponibilizada tanto localmente (`npm start` na porta 3000) quanto em producao na nuvem no Render (`https://call-hero-pdm.onrender.com`).
  - O `ApiClient` (`dio`) suporta paginacao via query parameters `_page` e `_limit`.

### 3.3 Slide 04: Hub de Navegacao (HomePage)
- **Requisito**: Tela principal com 4 opcoes de navegacao: Agentes, Contrato Diario, Meu Esquadrao e Missoes.
- **Implementacao**:
  - `lib/ui/page/home_page.dart` renderiza uma lista vertical com 4 `ListTile` estilizados dentro de `Card`.
  - Navega diretamente utilizando `Navigator.push(context, MaterialPageRoute(...))`.

### 3.4 Slide 05: Catalogo Geral de Agentes (HeroesCatalogPage)
- **Requisito**: Catalogo paginado com rolagem infinita exibindo cards com nome, alinhamento, atributos dominantes e aparencia.
- **Implementacao**:
  - Utiliza o pacote `infinite_scroll_pagination` com `PagingController<int, HeroModel>`.
  - Cada item e renderizado pelo componente reutilizavel `HeroCard`.
  - Realiza persistencia em lote no SQLite via `HeroDao.insertAll()` com transacao atomica.

### 3.5 Slide 06: Tela Detalhes do Agente (HeroDetailPage)
- **Requisito**: Exibir a ficha completa do heroi (biografia, aparencia, trabalho, conexoes) com barras de atributos proporcionais usando `primer_progress_bar`. Carregar dados da API ou do banco local.
- **Implementacao**:
  - Imagem em alta resolucao renderizada com `CachedNetworkImage`.
  - Os 6 powerstats utilizam o widget `SegmentedBar` do `primer_progress_bar` com escala proporcional (0 a 100).
  - No `initState`, busca dados atualizados atraves do `HeroRepository.getHeroById()`.

### 3.6 Slide 07: Contrato Diario e Recrutamento (DailyContractPage)
- **Requisito**: Sorteio diario de 1 agente aleatorio. Exibir apenas nome, imagem e powerstats. Botao para recrutar com trava de maximo 15 agentes. Sorteio limitado a 1 vez por dia.
- **Implementacao**:
  - O `SharedPreferences` armazena a chave `daily_contract_last_date` no formato `yyyy-MM-dd` e o ID do heroi em `daily_contract_hero_id`.
  - Se a data coincidir com hoje, restaura o heroi sorteado sem permitir novo sorteio.
  - O card desenha estritamente apenas nome, imagem e barras de progresso lineares dos 6 atributos.
  - O botao de recrutamento valida a capacidade do esquadrao (`_squadCount >= 15`) e impede duplicatas.

### 3.7 Slide 08: Gestao do Esquadrao Local (MySquadPage)
- **Requisito**: Listar exclusivamente os herois recrutados no SQLite (ate 15). Exibir papel tatico / maior atributo. Toque no card leva para Detalhes.
- **Implementacao**:
  - Consulta a tabela `squad` via `HeroRepository.getSquadMembers()`.
  - O papel tatico e calculado funcionalmente no modelo de dominio atraves de `hero.highestStatName` usando `reduce`.
  - Exibe contador visual de ocupacao de vagas (`X / 15`).

### 3.8 Slide 09: Detalhes do Meu Agente e Dispensa (HeroDetailPage)
- **Requisito**: Ficha do heroi com botao "Dispensar do Esquadrao", liberando vaga no banco de dados. Exibir caixa de dialogo com `awesome_dialog`. Cache de imagem com `cached_network_image`.
- **Implementacao**:
  - Botao vermelho "Dispensar do Esquadrao" exibido condicionalmente quando `isSquadMember == true`.
  - Dispara `AwesomeDialog` do tipo `DialogType.warning` solicitando confirmacao.
  - Ao confirmar, executa `HeroRepository.dismissHero(id)`, removendo o registro da tabela `squad` no SQLite.

### 3.9 Slide 10: Iniciar Missao e Desafio de Crise (MissionBattlePage)
- **Requisito**: Trava de pelo menos 5 agentes no esquadrao. Sorteio aleatorio de 3 a 5 rounds. Em cada round, sorteia um atributo de teste dominante e um oponente do catalogo. Se sortear membro do esquadrao, deve sortear novamente.
- **Implementacao**:
  - Trava no `initState`: se `squad.length < 5`, bloqueia o combate e exibe tela de aviso com atalhos de recrutamento.
  - Sorteio de rounds: `final int totalRounds = _random.nextInt(3) + 3;` (gera 3, 4 ou 5).
  - Regra anti-clone: loop `do { enemyId = ... } while (squadIds.contains(enemyId));`.

### 3.10 Slide 11: Arena de Combate e Escalacao 3x5 (MissionBattlePage)
- **Requisito**: Exibir imagem e nome do inimigo com atributos ocultos e nome do atributo em disputa. Escalacao de 1 agente em grid 3x5 com miniaturas circulares. Comparar atributo: maior vence, menor perde, igual empata.
- **Implementacao**:
  - Card do Inimigo: exibe nome, imagem via `CachedNetworkImage` e badge textual com o nome do atributo, omitindo deliberadamente todos os numeros do vilao.
  - Grid de Escalacao: `GridView.builder` com `crossAxisCount: 3` (formato 3x5 para ate 15 herois), utilizando `CircleAvatar` e nome truncado.
  - Resolucao: metodo `_fightRound` executa a comparacao direta e pontua no placar.

### 3.11 Slide 13: Fim da Missao e Evolucao Permanente (+1) no SQLite
- **Requisito**: Sumario com total de vitorias e derrotas. Dialogo `awesome_dialog`: Sucesso se venceu mais da metade dos rounds ("Missao Cumprida!"), sorteando 1 heroi vencedor para ganhar +1 em powerstat aleatorio com imagem exibida. Erro se perdeu a maioria ("Operacao Fracassada!") com imagem de derrota.
- **Implementacao**:
  - Avaliacao: `final bool overallVictory = _victories > _defeats && _victories > 0;`.
  - Em caso de Vitoria:
    - Sorteia um heroi vencedor: `final evolvedHero = _winningHeroes[_random.nextInt(_winningHeroes.length)];`.
    - Sorteia um atributo: `final randomStat = _challengeStats[_random.nextInt(_challengeStats.length)];`.
    - Atualiza no banco: `HeroRepository.evolveHeroStat(heroId: evolvedHero.id, statName: randomStat)`.
    - Dispara `AwesomeDialog` com `DialogType.success`, exibindo a foto do heroi e o bonus conquistado.
  - Em caso de Derrota:
    - Dispara `AwesomeDialog` com `DialogType.error`, exibindo icone de fracasso e placar final.

### 3.12 Slide 14: Resumo dos Criterios e Conformidade Arquitetural
- **Requisito**: Integracao obrigatoria de: `json-server`, `infinite_scroll_pagination`, `cached_network_image`, `primer_progress_bar`, `awesome_dialog`, `shared_preferences` e `sqflite`.
- **Status**: 100% implementado, testado e validado sem erros ou advertencias no `flutter analyze`.

---

# 4. DICIONARIO TECNICO ARQUIVO POR ARQUIVO, FUNCAO POR FUNCAO

Abaixo esta a analise exaustiva de cada um dos 23 arquivos Dart que compoem o projeto Call-Hero.

---

### 4.1 Camada de Inicializacao e DI

#### `lib/main.dart`
- **Papel**: Ponto de entrada do ciclo de vida da aplicacao Flutter.
- **Funcoes e Metodos**:
  - `main()`: Metodo de inicializacao global. Executa `WidgetsFlutterBinding.ensureInitialized()`, invoca `ConfigureProviders.createDependencyTree()` de forma assincrona e repassa o container de dependencias para o widget raiz com `runApp(AppRoot(data: data))`.
  - `AppRoot.build()`: Desenha o widget raiz do app. Injeta o `MultiProvider` globalmente na arvore de widgets e instancia o `MaterialApp` configurando o tema tatico (ColorScheme com seed azul escuro `0xFF1E3A8A`, Material 3 habilitado) e definindo `home: const HomePage()`.

#### `lib/core/di/configure_providers.dart`
- **Papel**: Container de Inversao de Controle (IoC) e Injecao de Dependencias.
- **Classes e Metodos**:
  - `ConfigureProviders`: Modela a lista de provedores `List<SingleChildWidget> providers`.
  - `createDependencyTree()`: Metodo estatico assincrono. Instancia em cascata: `ApiClient` (apontando para a nuvem no Render), `NetworkMapper`, `DatabaseMapper`, `HeroDao` e `SquadDao`. Em seguida, instancia o `HeroRepositoryImpl` injetando todas as dependencias em seu construtor. Retorna a lista contendo provedores tipados para cada servico e repositorio.

---

### 4.2 Camada de Dominio

#### `lib/domain/hero_model.dart`
- **Papel**: Modelo puro e imutavel do super-heroi no dominio da aplicacao. Nao possui nenhuma dependencia de pacotes externos, SQLite ou HTTP.
- **Classes e Metodos**:
  - `HeroModel`: Entidade principal contendo `id`, `name`, `slug`, `powerstats`, `appearance`, `biography`, `work`, `connections` e `images`.
  - `HeroModel.copyWith()`: Metodo utilitario para clonagem imutavel de instancias.
  - `HeroModel.evolveStat(String statName)`: Retorna uma copia do heroi com o atributo informado incrementado em +1.
  - `HeroModel.highestStatName`: Propriedade getter que delega para `powerstats.highestStatName`.
  - `Powerstats`: Classe contendo os 6 atributos (`intelligence`, `strength`, `speed`, `durability`, `power`, `combat`).
  - `Powerstats.copyWith()`: Permite clonar a estrutura atualizando atributos pontuais.
  - `Powerstats.getStatByName(String name)`: Executa um `switch` case-insensitive e retorna o valor inteiro do atributo solicitado pelo nome.
  - `Powerstats.highestStatName`: Calcula funcionalmente o nome do atributo dominante atraves de `stats.entries.reduce((curr, next) => curr.value >= next.value ? curr : next).key`. O operador `>=` garante estabilidade e preserva a identidade canonica do heroi em caso de empates.
  - `Appearance`: Modela caracteristicas fisicas (`gender`, `race`, `height`, `weight`, `eyeColor`, `hairColor`).
  - `Biography`: Modela historico civil (`fullName`, `alterEgos`, `aliases`, `placeOfBirth`, `firstAppearance`, `publisher`, `alignment`).
  - `Work`: Modela ocupacao civil e base de operacoes (`occupation`, `base`).
  - `Connections`: Modela vinculos de equipe e parentescos (`groupAffiliation`, `relatives`).
  - `HeroImages`: Armazena as URLs das 4 resolucoes de imagem (`xs`, `sm`, `md`, `lg`).

#### `lib/domain/exception/mapper_exception.dart`
- **Papel**: Excecao tipada lancada quando ocorrem erros ou incompatibilidades durante a transformacao de dados entre camadas.
- **Metodos**:
  - `toString()`: Formata a mensagem descritiva indicando os tipos de origem (`From`) e destino (`To`).

#### `lib/domain/exception/network_exception.dart`
- **Papel**: Excecao tipada para falhas na comunicacao HTTP com a API REST.
- **Metodos**:
  - `NetworkException({required this.statusCode, this.message})`: Construtor que recebe o codigo de status HTTP e a mensagem do servidor.
  - `toString()`: Formata a descricao com status code e mensagem de erro.

---

### 4.3 Camada de Rede

#### `lib/data/network/client/api_client.dart`
- **Papel**: Cliente HTTP responsavel por requisicoes remotas a API REST utilizando o pacote `dio`.
- **Metodos**:
  - `ApiClient({required String baseUrl})`: Configura a URL base e anexa o `LogInterceptor` para monitoramento no console.
  - `getHeroes({int? page, int? limit})`: Executa requisicao `GET /heroes` com parametros `_page`, `_limit` e `_per_page`. Trata a resposta: se for uma lista pura em JSON, desserializa diretamente; se vier enveloped em formato paginado, utiliza o `HttpPagedResult`. Lanca `NetworkException` se status >= 400.
  - `getHeroById(int id)`: Executa requisicao `GET /heroes/$id` e desserializa o objeto em `HeroNetworkEntity`.

#### `lib/data/network/entity/hero_network_entity.dart`
- **Papel**: DTO que reflete a estrutura JSON retornada pela Superhero API.
- **Classes e Fabricas**:
  - `HeroNetworkEntity.fromJson(Map<String, dynamic> json)`: Fabrica que mapeia campos do JSON com tratamento defensivo contra valores nulos e converte subestruturas (`powerstats`, `appearance`, `biography`, `work`, `connections`, `images`).
  - `PowerstatsNetworkEntity.fromJson(...)`: Mapeia inteiros dos 6 atributos com fallback para zero.
  - `AppearanceNetworkEntity.fromJson(...)`: Mapeia atributos fisicos convertendo arrays para listas de strings.
  - `BiographyNetworkEntity.fromJson(...)`: Mapeia dados biográficos e codinomes.
  - `WorkNetworkEntity.fromJson(...)`: Mapeia trabalho e base operacional.
  - `ConnectionsNetworkEntity.fromJson(...)`: Mapeia afiliações de equipes e parentes.
  - `ImagesNetworkEntity.fromJson(...)`: Mapeia as URLs das imagens.

#### `lib/data/network/entity/http_paged_result.dart`
- **Papel**: DTO para mapeamento de envelopes paginados retornados por servidores `json-server`.
- **Metodos**:
  - `HttpPagedResult.fromJson(Map<String, dynamic> json)`: Extrai metadados de paginacao (`first`, `prev`, `next`, `last`, `pages`, `items`) e a lista de registros `data`.

#### `lib/data/network/network_mapper.dart`
- **Papel**: Conversor de fronteira que transforma DTOs brutos de rede (`HeroNetworkEntity`) em modelos de dominio (`HeroModel`).
- **Metodos**:
  - `toHero(HeroNetworkEntity entity)`: Instancia um `HeroModel` completo transferindo todos os campos e aninhamentos. Envolve a operacao em bloco `try/catch` disparando `MapperException` em caso de erro.
  - `toHeroes(List<HeroNetworkEntity> entities)`: Itera sobre a lista de entidades convertendo cada elemento para `HeroModel`.

---

### 4.4 Camada de Banco de Dados SQLite

#### `lib/data/database/entity/hero_database_entity.dart`
- **Papel**: Contrato de banco de dados e entidade tabular para armazenamento no SQLite.
- **Classes e Metodos**:
  - `HeroDatabaseContract`: Constantes com nomes das tabelas (`heroes`, `squad`) e de todas as colunas.
  - `HeroDatabaseEntity`: Estrutura com todos os campos necessarios para persistencia relacional. Campos de lista (como `height`, `weight`, `aliases`) sao serializados como strings JSON (`jsonEncode`/`jsonDecode`).
  - `HeroDatabaseEntity.fromJson(Map<String, dynamic> json)`: Reconstrói a entidade a partir do Map retornado por consultas SQL.
  - `HeroDatabaseEntity.toJson()`: Serializa a entidade em Map para comandos `INSERT` e `UPDATE` no SQLite.

#### `lib/data/database/dao/base_dao.dart`
- **Papel**: Classe abstrata que gerencia a conexao unica com o SQLite e a criacao inicial das tabelas.
- **Metodos**:
  - `getDb()`: Retorna a instancia ativa do banco de dados `Database`. Se for nula, inicializa atraves de `_getDatabase()`.
  - `_getDatabase()`: Abre a conexao no diretorio do dispositivo (`heroes_database.db`) e registra a versao `databaseVersion = 1`. No callback `onCreate`, executa um `db.batch()` para criar atomicamente as tabelas `heroes` e `squad`.
  - `_createHeroesTableV1(Batch batch)`: Adiciona o script DDL da tabela `heroes` ao batch.
  - `_createSquadTableV1(Batch batch)`: Adiciona o script DDL da tabela `squad` ao batch.

#### `lib/data/database/dao/hero_dao.dart`
- **Papel**: DAO para operacoes na tabela de cache do catalogo (`heroes`).
- **Metodos**:
  - `selectAll({int? limit, int? offset})`: Executa `db.query('heroes', limit: limit, offset: offset, orderBy: 'id ASC')` e retorna a lista de entidades convertidas.
  - `selectById(int id)`: Busca um heroi pelo ID (`where: 'id = ?'`).
  - `insert(HeroDatabaseEntity entity)`: Insere um registro com algoritmo `ConflictAlgorithm.replace`.
  - `insertAll(List<HeroDatabaseEntity> entities)`: Executa insercao em lote dentro de `db.transaction()` garantindo atomicidade e alto desempenho.
  - `deleteAll()`: Limpa todos os registros da tabela de cache.

#### `lib/data/database/dao/squad_dao.dart`
- **Papel**: DAO para operacoes na tabela de membros recrutados (`squad`).
- **Metodos**:
  - `countMembers()`: Executa `SELECT COUNT(*) FROM squad` e retorna a contagem inteira de agentes.
  - `selectAllMembers()`: Retorna todos os membros do esquadrao ordenados alfabeticamente por nome.
  - `selectMemberById(int id)`: Busca um integrante especifico do esquadrao pelo ID.
  - `insertMember(HeroDatabaseEntity entity)`: Insere o novo heroi recrutado no esquadrao.
  - `deleteMember(int id)`: Remove o integrante do esquadrao pelo ID (`where: 'id = ?'`).
  - `incrementStat({required int heroId, required String statName})`: Executa comando SQL nativo `UPDATE squad SET [coluna] = [coluna] + 1 WHERE id = ?` para aplicar o bonus de vitoria conquistado na missao (Slide 13).

#### `lib/data/database/database_mapper.dart`
- **Papel**: Conversor bidirecional entre entidades do SQLite (`HeroDatabaseEntity`) e modelos de dominio (`HeroModel`).
- **Metodos**:
  - `toHero(HeroDatabaseEntity entity)`: Converte entidade tabular plana em `HeroModel` hierarquico.
  - `toHeroes(List<HeroDatabaseEntity> entities)`: Converte listas de entidades em listas de modelos.
  - `toHeroDatabaseEntity(HeroModel hero)`: Converte `HeroModel` de dominio em `HeroDatabaseEntity` para persistencia no banco.
  - `toHeroDatabaseEntities(List<HeroModel> heroes)`: Converte colecoes de modelos para entidades de banco.

---

### 4.5 Camada de Repositorio

#### `lib/data/repository/hero_repository.dart`
- **Papel**: Interface abstrata que define o contrato de dados consumido pela UI.
- **Metodos**:
  - `Future<List<HeroModel>> getHeroes({required int page, required int limit})`
  - `Future<HeroModel?> getHeroById(int id)`
  - `Future<List<HeroModel>> getSquadMembers()`
  - `Future<bool> recruitHero(HeroModel hero)`
  - `Future<void> dismissHero(int id)`
  - `Future<int> getSquadCount()`
  - `Future<bool> isHeroInSquad(int id)`
  - `Future<void> evolveHeroStat({required int heroId, required String statName})`
  - `Future<void> seedTestSquad()`

#### `lib/data/repository/hero_repository_impl.dart`
- **Papel**: Implementacao concreta do padrao Repository e orquestrador da politica Offline-First.
- **Metodos**:
  - `getHeroes({required int page, required int limit})`: Calcula `offset = (page * limit) - limit`. Consulta `heroDao.selectAll()`. Se encontrar dados, mapeia e retorna. Se vazio, consome `apiClient.getHeroes()`, converte com `networkMapper`, persiste no SQLite via `heroDao.insertAll()` e retorna a lista.
  - `getHeroById(int id)`: Verifica primeiro se o heroi existe na tabela `squad` via `squadDao.selectMemberById()` (para garantir a recuperacao de powerstats evoluidos). Se nao estiver no esquadrao, tenta obter da API via `apiClient.getHeroById()` e atualiza o cache local. Em caso de falha de rede (offline), recupera do cache via `heroDao.selectById()`.
  - `getSquadMembers()`: Consulta `squadDao.selectAllMembers()` e retorna os herois do time convertidos para `HeroModel`.
  - `isHeroInSquad(int id)`: Retorna `true` se `squadDao.selectMemberById(id)` nao for nulo.
  - `recruitHero(HeroModel hero)`: Valida se `squadDao.countMembers() >= 15` (bloqueia se cheio). Valida se o heroi ja existe no esquadrao (bloqueia duplicatas). Se valido, insere via `squadDao.insertMember()` e retorna `true`.
  - `dismissHero(int id)`: Remove o integrante do banco via `squadDao.deleteMember(id)`.
  - `getSquadCount()`: Delega a contagem para `squadDao.countMembers()`.
  - `evolveHeroStat({required int heroId, required String statName})`: Delega o incremento SQL para `squadDao.incrementStat()`.
  - `seedTestSquad()`: Recruta os 5 herois especialistas de teste (IDs 70, 332, 263, 717, 149) para permitir testes imediatos de missao.

---

### 4.6 Componentes Visuais

#### `lib/ui/widgets/hero_card.dart`
- **Papel**: Widget reaproveitavel de exibicao resumida de super-herois.
- **Funcoes e Metodos**:
  - `_getAlignmentColor(String alignment)`: Retorna a cor do badge moral (Verde para 'good', Vermelho para 'bad', Âmbar para outros).
  - `build(BuildContext context)`: Desenha um `Card` estilizado contendo:
    - Miniatura de imagem renderizada com `CachedNetworkImage` dentro de `ClipRRect` (75x95).
    - Coluna central com nome do heroi, badge colorido de alinhamento moral, subtitulo (nome civil ou papel tatico).
    - Badge do maior atributo / papel tatico (`${highestStat.toUpperCase()}: $highestValue`).
    - Slot de acao opcional a direita (`trailing`, como botao de lixeira).
    - Ao ser tocado, navega automaticamente para `HeroDetailPage(hero: hero)`.

---

### 4.7 Telas da Interface

#### `lib/ui/page/home_page.dart`
- **Papel**: Painel central (Hub) de navegacao do aplicativo Call-Hero.
- **Funcoes e Metodos**:
  - `_buildMenuOption(...)`: Desenha um `Card` com `ListTile` contendo icone tematico, titulo em negrito, subtitulo descritivo e seta indicadora.
  - `build(BuildContext context)`: Desenha o `Scaffold` com `AppBar` centralizada e lista vertical contendo os 4 acessos taticos: Agentes, Contrato Diario, Meu Esquadrao e Missoes.

#### `lib/ui/page/heroes_catalog_page.dart`
- **Papel**: Catalogo geral de agentes com rolagem infinita sob demanda.
- **Funcoes e Metodos**:
  - `initState()`: Obtem a instancia de `HeroRepository` via `Provider.of`.
  - `dispose()`: Libera o `_pagingController` da memoria para prevenir memory leaks.
  - `_pagingController`: Controlador da biblioteca `infinite_scroll_pagination`. Busca 10 herois por pagina chamando `_heroRepository.getHeroes(page, limit)`.
  - `build(BuildContext context)`: Desenha o `Scaffold` com `AppBar` (contendo botao de recarregar) e `PagedListView` com delegados visuais completos: renderizacao de cada heroi com `HeroCard`, spinners de carregamento inicial e subsequente, e tela de erro de conexao com botao 'Tentar Novamente'.

#### `lib/ui/page/hero_detail_page.dart`
- **Papel**: Ficha cadastral completa do agente e tela de dispensa.
- **Funcoes e Metodos**:
  - `initState()`: Registra callback de post-frame para invocar `_fetchLatestDetails()`.
  - `_fetchLatestDetails()`: Busca os dados mais atualizados do agente no repositorio (`getHeroById`) e atualiza o estado com `setState`.
  - `_buildStatBar(context, label, value, color)`: Desenha barra horizontal proporcional usando o componente `SegmentedBar` do pacote `primer_progress_bar`. Exibe rotulo, pontuacao numerica (`$value / 100`) e barra preenchida.
  - `_buildInfoRow(label, value)`: Desenha linha com rotulo em negrito e valor descritivo (oculta se vazio).
  - `_confirmDismiss(context)`: Exibe dialogo modal com `AwesomeDialog` do tipo `DialogType.warning`. Ao confirmar, invoca `repo.dismissHero(_hero.id)` e retorna a tela anterior com indicador de modificacao.
  - `build(BuildContext context)`: Desenha a ficha tecnica completa: banner de imagem grande no topo (320px de altura) com `CachedNetworkImage`, nome e identidade civil, secao de Atributos de Combate com as barras do Primer, secao de Biografia, secao de Aparencia, secao de Trabalho e Conexoes, e botao inferior vermelho de dispensa caso o heroi faca parte do esquadrao.

#### `lib/ui/page/daily_contract_page.dart`
- **Papel**: Convocacao e sorteio diario de agentes com persistencia em `SharedPreferences`.
- **Funcoes e Metodos**:
  - `_checkDailyContract()`: Le o `SharedPreferences`. Compara a data gravada com a data atual (`yyyy-MM-dd`). Se for o mesmo dia, recupera o heroi sorteado anteriormente. Se for um novo dia, dispara `_drawNewHero()`.
  - `_drawNewHero()`: Gera numero aleatorio de 1 a 560, busca o heroi correspondente no repositorio, grava a data de hoje e o ID no `SharedPreferences` e atualiza o estado.
  - `_recruitAgent()`: Valida se o esquadrao possui vagas (`_squadCount < 15`). Invoca `repo.recruitHero()`. Dispara `AwesomeDialog` com `DialogType.success` em caso de sucesso ou `DialogType.warning`/`DialogType.error` se o esquadrao estiver cheio ou se o heroi ja for membro.
  - `_buildDailyContractCard(HeroModel hero)`: Desenha o card restrito do Slide 7 contendo exclusivamente a imagem centralizada do heroi, nome em destaque e os 6 powerstats formatados em barras de progresso lineares.
  - `_buildStatRow(label, value, color)`: Desenha linha individual com rotulo, barra `LinearProgressIndicator` colorida e valor numerico.
  - `build(BuildContext context)`: Desenha a tela de convocacao com indicador de vagas preenchidas (`Esquadrao: X/15`), o card exclusivo do Slide 7, o botao de recrutamento com estados desabilitados e texto informativo.

#### `lib/ui/page/my_squad_page.dart`
- **Papel**: Gestao do esquadrao local de ate 15 agentes salvos no SQLite.
- **Funcoes e Metodos**:
  - `_loadSquad()`: Consulta `repo.getSquadMembers()` e atualiza a lista de agentes do estado.
  - `_confirmDismiss(HeroModel hero)`: Dispara `AwesomeDialog` de aviso para confirmar a dispensa do heroi e chama `repo.dismissHero(hero.id)` ao confirmar.
  - `build(BuildContext context)`: Desenha a barra superior de ocupacao (`X / 15`) com alerta visual vermelho quando atinge o teto maximo. Se a lista estiver vazia, exibe mensagem informativa com botao de teste para recrutar os 5 herois especialistas. Se houver membros, exibe a lista de `HeroCard` configurando o papel tatico no subtitulo (`hero.highestStatName`), botao de lixeira a direita e navegacao para detalhes com recarregamento automatico ao retornar.

#### `lib/ui/page/mission_battle_page.dart`
- **Papel**: Arena de combate tatico por turnos, controle de regras de crise e evolucao de atributos.
- **Funcoes e Metodos**:
  - `MissionCrisisRound`: Modelo que armazena numero do round, inimigo e o atributo em disputa.
  - `_startMission()`: Carrega o esquadrao. Valida se ha no minimo 5 agentes (Slide 10). Se houver, sorteia de 3 a 5 rounds, sorteia inimigos garantindo que nao pertencam ao esquadrao (`do-while` anti-clone) e sorteia um atributo de combate para cada etapa. Reseta placares e a lista de herois utilizados.
  - `_fightRound(HeroModel chosenHero)`: Trava o heroi adicionando ao `Set _usedHeroIds`. Compara os atributos. Incrementa o placar e exibe dialogo de feedback (`AwesomeDialog`). Ao clicar em Continuar, avanca o round (`_currentRoundIndex++`) ou finaliza a missao.
  - `_formatStatName(String stat)`: Formata o nome do atributo.
  - `_formatScore()`: Formata a mensagem do placar com singular/plural correto.
  - `_finishMission()`: Avalia se o jogador venceu a maioria das rodadas (`_victories > _defeats && _victories > 0`). Se venceu, sorteia um dos herois que venceu rounds e um powerstat aleatorio, grava o incremento no SQLite com `repo.evolveHeroStat()` e exibe `AwesomeDialog` de vitoria (`DialogType.success`) com a foto do heroi e o bonus recebido. Se perdeu, exibe `AwesomeDialog` de derrota (`DialogType.error`) com icone de falha.
  - `build(BuildContext context)`: Desenha os tres estados possiveis da tela:
    1. Spinner de carregamento.
    2. Tela de bloqueio quando o esquadrao possui menos de 5 agentes, oferecendo botao para recrutar os 5 especialistas de teste ou ir para o Contrato Diario.
    3. Arena de combate ativa: placar no topo, banner do Desafio de Crise, card do Inimigo da Rodada com imagem, nome e atributo em disputa (atributos numericos ocultos), e grade 3x5 de escalacao dos agentes com fotos circulares e trava visual para os herois ja utilizados.

---

# 5. BANCO DE PERGUNTAS DE ALTO NIVEL DA BANCA E RESPOSTAS SENIOR

Abaixo estao as perguntas tecnicas mais provaveis que o professor Taniro C. Rodrigues pode realizar durante a arguicao individual, acompanhadas das respostas exatas fundamentadas no codigo-fonte.

---

### Pergunta 1: "Como exatamente funciona a sua politica Offline-First? O que acontece se o usuario abrir o app no modo aviao?"
**Resposta Senior**:
"Professor, nossa politica Offline-First e orquestrada pelo `HeroRepositoryImpl` com auxilio do `HeroDao` e do `SquadDao` no SQLite.
No catalogo de agentes, aplicamos a estrategia Cache-First: antes de disparar qualquer requisicao de rede, o repositorio consulta a tabela local `heroes` via `HeroDao.selectAll(limit, offset)`. Se houver dados armazenados localmente, eles sao mapeados via `DatabaseMapper` e entregues instantaneamente a interface, sem tocar na internet. Se o banco estiver vazio e houver conexao, buscamos na API via `ApiClient`, convertemos os DTOs com `NetworkMapper` e realizamos uma insercao em lote no SQLite via `HeroDao.insertAll()` dentro de uma transacao atomica (`db.transaction()`).
Se o usuario abrir o app em modo aviao:
1. As telas que dependem do esquadrao (`MySquadPage`) e das batalhas (`MissionBattlePage`) funcionam normalmente, pois os membros recrutados residem na tabela local `squad`.
2. O catalogo (`HeroesCatalogPage`) exibe todos os herois ja cacheados no SQLite. Caso ele role ate uma pagina que ainda nao foi baixada, o interceptor do `Dio` lanca uma `NetworkException`, capturada pelo `PagingController`, que exibe uma tela amigavel de offline com o botao de tentar novamente, sem travar ou fechar o app."

---

### Pergunta 2: "Por que voce criou duas tabelas no SQLite ('heroes' e 'squad') em vez de usar apenas uma com uma coluna booleana 'is_recruited'?"
**Resposta Senior**:
"Foi uma decisao deliberada de arquitetura para garantir **integridade de dados e isolamento de responsabilidades**.
A tabela `heroes` funciona estritamente como um cache volátil e descartavel da API remota, podendo ser limpa ou sincronizada a qualquer momento.
A tabela `squad` contem o estado do jogo e o progresso do usuario. No Slide 13, quando o jogador vence uma missao, um heroi ganha +1 ponto permanente em um powerstat, atualizado no banco via `SquadDao.incrementStat()`.
Se utilizassemos uma unica tabela com uma flag, qualquer sincronizacao de cache da API ou limpeza de dados sobrescreveria os atributos dos herois recrutados, destruindo a evolucao conquistada pelo usuario nas batalhas. Mantendo tabelas separadas, o progresso do jogador na tabela `squad` permanece 100% isolado e protegido."

---

### Pergunta 3: "Explique como voce implementou cada uma das 3 exigencias do Slide 12."
**Resposta Senior**:
"No Slide 12, implementamos as 3 regras na classe `MissionBattlePage`:
1. **Indicadores de Resultado**: No metodo `_fightRound()`, extraimos o atributo da rodada tanto do heroi quanto do inimigo atraves de `getStatByName(stat)`. Realizamos a comparacao matematica e exibimos um `AwesomeDialog` com animacao de escala, informando explicitamente os nomes dos combatentes, as pontuacoes comparadas e se o resultado foi Vitoria (`DialogType.success`), Derrota (`DialogType.error`) ou Empate Tatico (`DialogType.warning`).
2. **Trava de Uso Unico**: Criamos no estado um `Set<int> _usedHeroIds`. Quando o jogador escolhe um heroi, inserimos seu ID nesse conjunto. No `GridView.builder` que renderiza a grade 3x5 de escalacao, verificamos `final isUsed = _usedHeroIds.contains(hero.id)`. Se for verdadeiro, aplicamos opacidade reduzida de `0.35`, definimos o callback `onTap` como `null` e exibimos o texto 'Indisponivel' em vermelho, impedindo que o agente seja escalado mais de uma vez na mesma missao.
3. **Placar e Avanco**: As variaveis `_victories`, `_defeats` e `_draws` estao vinculadas a widgets reativos no topo da tela. No callback de fechamento do dialogo da rodada, o codigo verifica se ha proximos rounds (`_currentRoundIndex + 1 < _rounds.length`). Se houver, incrementa o indice dentro de um `setState()`, avancando automaticamente a tela para a proxima etapa. Se todos os rounds foram disputados, invoca automaticamente `_finishMission()`."

---

### Pergunta 4: "Como voce garantiu que o sorteio de inimigos do Desafio de Crise nunca sorteie um heroi que ja esta no esquadrao do jogador?"
**Resposta Senior**:
"Na funcao `_startMission()` da `MissionBattlePage`, antes de sortear os rounds, coletamos todos os IDs dos herois do esquadrao em uma estrutura `Set` para busca em tempo constante O(1):
```dart
final squadIds = squad.map((h) => h.id).toSet();
```
Em seguida, para cada round do desafio, executamos um loop `do-while` que gera um ID aleatorio e so prossegue quando o ID gerado nao constar no conjunto do esquadrao:
```dart
int enemyId;
do {
  enemyId = _random.nextInt(560) + 1;
} while (squadIds.contains(enemyId));
```
Isso garante matematicamente conformidade total com o Slide 10: se o sorteio sortear um heroi do usuario, o laco e reexecutado ate obter um oponente externo."

---

### Pergunta 5: "Qual a razao da funcao seedTestSquad() e por que esses 5 herois especificos foram selecionados?"
**Resposta Senior**:
"O Slide 10 exige no minimo 5 herois no esquadrao para entrar em uma missao, mas o Slide 07 limita o recrutamento a 1 por dia via `SharedPreferences`. Sem a semeadura de teste, uma avaliacao pratica imediata da missao seria inviavel, pois exigiria 5 dias reais de espera.
Criamos a funcao `seedTestSquad()` no repositorio para recrutar 5 herois de elite instantaneamente no SQLite.
Selecionamos Batman (ID 70), Hulk (ID 332), Flash (ID 263), Wolverine (ID 717) e Capitao America (ID 149) porque cada um deles possui pontuacao maxima 100 em exatamente um dos 5 atributos principais testados nas crises: Inteligencia, Forca, Velocidade, Durabilidade e Combate. Dessa forma, o jogador dispoe de 1 especialista de nivel maximo para qualquer cenario de combate sorteado pelo sistema."

---

### Pergunta 6: "Como o app calcula o papel tatico do heroi no Slide 8 sem sobrecarregar a interface?"
**Resposta Senior**:
"O calculo e encapsulado diretamente no modelo de dominio `HeroModel` atraves da propriedade getter `highestStatName`, que por sua vez delega para `Powerstats.highestStatName`.
Utilizamos o paradigma de programacao funcional ensinado na Aula 02:
```dart
String get highestStatName {
  final stats = {
    'Intelligence': intelligence,
    'Strength': strength,
    'Speed': speed,
    'Durability': durability,
    'Power': power,
    'Combat': combat,
  };
  return stats.entries
      .reduce((curr, next) => curr.value >= next.value ? curr : next)
      .key;
}
```
A operacao `reduce` itera linearmente sobre as 6 entradas em complexidade O(1) e retorna o nome do atributo de maior valor. O operador `>=` garante estabilidade e mantem a prioridade canonica do heroi caso haja empate de pontuacoes maximas."

---

### Pergunta 7: "Como foi aplicada a Inversao de Controle (IoC) e a Injecao de Dependencias no projeto?"
**Resposta Senior**:
"A Inversao de Controle foi aplicada de ponta a ponta atraves do arquivo `lib/core/di/configure_providers.dart` em conjunto com o pacote `provider`.
Todas as classes de dados e infraestrutura sao instanciadas na inicializacao em `main.dart` atraves de `ConfigureProviders.createDependencyTree()`.
As telas da interface nunca instanciam dependencias concretas diretamente com `new`. Elas consom o contrato abstrato `HeroRepository` atraves de `Provider.of<HeroRepository>(context, listen: false)`.
Isso desacopla totalmente a camada de apresentacao da camada de dados: se amanha precisarmos trocar o `sqflite` por outro banco ou alterar o cliente HTTP `Dio`, nenhuma linha de codigo dos widgets da UI precisara ser modificada, respeitando os principios OCP e DIP do SOLID."
