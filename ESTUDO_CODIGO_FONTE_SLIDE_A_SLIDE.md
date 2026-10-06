# Estudo Completo do Código-Fonte por Slides (Aula 12 - PDM)

Este documento foi estruturado especificamente para a defesa e entrevista técnica do código-fonte com o professor Taniro C. Rodrigues. Ele apresenta de forma direta, técnica e sem analogias o que cada classe, método e linha de código executa em cada uma das etapas do projeto, cobrindo rigorosamente todos os slides da avaliação.

---

# Sumário dos Slides e Arquivos Correspondentes

- [Slide 03: Configuração da API e Backend com json-server](#slide-03-configuração-da-api-e-backend-com-json-server)
- [Slide 04: Tela Inicial e Navegação Central (HomePage)](#slide-04-tela-inicial-e-navegação-central-homepage)
- [Slide 05: Catálogo Geral de Agentes (HeroesCatalogPage)](#slide-05-catálogo-geral-de-agentes-heroescatalogpage)
- [Slide 06: Tela Detalhes do Agente (HeroDetailPage)](#slide-06-tela-detalhes-do-agente-herodetailpage)
- [Slide 07: Tela Contrato Diário e Recrutamento (DailyContractPage)](#slide-07-tela-contrato-diário-e-recrutamento-dailycontractpage)
- [Slide 08: Tela Meu Esquadrão e Gestão Local (MySquadPage)](#slide-08-tela-meu-esquadrão-e-gestão-local-mysquadpage)
- [Slide 09: Detalhes do Meu Agente e Dispensa (HeroDetailPage)](#slide-09-detalhes-do-meu-agente-e-dispensa-herodetailpage)
- [Slide 10: Iniciar Missão e Desafio de Crise (MissionBattlePage)](#slide-10-iniciar-missão-e-desafio-de-crise-missionbattlepage)
- [Slide 11: Mecânica de Combate, Escalação 3x5 e Resolução](#slide-11-mecânica-de-combate-escalação-3x5-e-resolução)
- [Slide 12: Execução dos Rounds, Placar e Trava de Uso Único](#slide-12-execução-dos-rounds-placar-e-trava-de-uso-único)
- [Slide 13: Fim da Missão e Evolução Permanente (+1) no SQLite](#slide-13-fim-da-missão-e-evolução-permanente-1-no-sqlite)
- [Slide 14: Resumo dos Critérios de Avaliação e Checklist Final](#slide-14-resumo-dos-critérios-de-avaliação-e-checklist-final)

---

# Slide 03: Configuração da API e Backend com json-server

### 1. Requisito Oficial
Implementar um arquivo para consumir uma API gerada com dados do repositório da Superhero API (Akabab). Baixar o arquivo JSON e executar um servidor simulando uma API REST utilizando a biblioteca do npm `json-server`.

### 2. Arquivos Envolvidos
- `backend/db.json`: Base de dados contendo os 563 super-heróis em formato JSON.
- `backend/package.json`: Configuração do servidor Node.js com a biblioteca `json-server`.
- `lib/data/network/client/api_client.dart`: Cliente HTTP em Dart utilizando o pacote `dio`.
- `lib/data/network/entity/hero_network_entity.dart`: DTO (Data Transfer Object) de rede.
- `lib/data/network/network_mapper.dart`: Mapper que converte DTOs de rede para entidades puras de domínio.

### 3. Como Funciona no Código-Fonte

#### A. O Servidor Mock (`json-server`)
O arquivo `backend/package.json` define o script de inicialização do servidor:
```json
"scripts": {
  "start": "json-server --watch db.json --port $PORT --host 0.0.0.0"
}
```
O servidor foi publicado em produção no Render sob o endereço HTTPS:
`https://call-hero-pdm.onrender.com`
Ele atende nativamente às rotas REST:
- `GET /heroes`: Retorna a lista de heróis com suporte a paginação via query parameters (`_page` e `_limit`).
- `GET /heroes/:id`: Retorna um herói individual pelo seu identificador único.

#### B. O Cliente de Rede (`api_client.dart`)
A classe `ApiClient` encapsula a biblioteca `dio` e centraliza todas as requisições HTTP da aplicação:
```dart
ApiClient({required String baseUrl}) {
  _dio = Dio()
    ..options.baseUrl = baseUrl
    ..interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
}
```
No método `getHeroes({int? page, int? limit})`:
```dart
final response = await _dio.get(
  "/heroes",
  queryParameters: {
    '_page': page,
    '_limit': limit,
    '_per_page': limit,
  },
);
```
- **Tratamento de Erros:** Se o código de status for maior ou igual a 400 (`statusCode >= 400`), dispara a exceção personalizada `NetworkException(statusCode, message)`.
- **Desserialização:** Se a resposta for bem-sucedida, o JSON bruto é convertido para instâncias de `HeroNetworkEntity` através do construtor fábrica `HeroNetworkEntity.fromJson()`.

#### C. O Mapper de Rede (`network_mapper.dart`)
O `NetworkMapper` transforma `HeroNetworkEntity` no modelo puro `HeroModel`. Ele isola a camada de rede: se o formato do JSON da API mudar, apenas o mapper e a entidade de rede são alterados, mantendo as telas e a regra de negócio intactas.

---

# Slide 04: Tela Inicial e Navegação Central (HomePage)

### 1. Requisito Oficial
Apresentar o painel inicial de comando da aplicação com 4 pontos de acesso táticos: Agentes, Contrato Diário, Meu Esquadrão e Missões.

### 2. Arquivos Envolvidos
- `lib/main.dart`: Ponto de entrada da aplicação.
- `lib/core/di/configure_providers.dart`: Raiz de composição da Injeção de Dependências.
- `lib/ui/page/home_page.dart`: Tela inicial de navegação.

### 3. Como Funciona no Código-Fonte

#### A. Inicialização e Injeção de Dependências (`main.dart` e `configure_providers.dart`)
Na função `main()`:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final data = await ConfigureProviders.createDependencyTree();
  runApp(AppRoot(data: data));
}
```
- `WidgetsFlutterBinding.ensureInitialized()`: Inicializa os canais de plataforma C++ do motor do Flutter antes de qualquer chamada assíncrona de banco de dados SQLite.
- `ConfigureProviders.createDependencyTree()`: Método estático assíncrono que instancia `ApiClient`, `NetworkMapper`, `DatabaseMapper`, `HeroDao`, `SquadDao` e injeta todos eles no construtor de `HeroRepositoryImpl`.
- `MultiProvider`: Envolve o `MaterialApp` na raiz de `AppRoot`, disponibilizando a instância de `HeroRepository` para todas as rotas filhas criadas na aplicação.

#### B. Estrutura da `HomePage` (`home_page.dart`)
- **StatelessWidget:** A tela é puramente declarativa e não gerencia estado mutável em memória.
- **Prevenção de RenderFlex Overflow:** O corpo da tela utiliza `ListView` em vez de `Column`. Isso garante responsividade quando a tela é aberta em aparelhos menores, em modo paisagem ou com fontes ampliadas de acessibilidade.
- **Fábrica de Itens Reutilizável (`_buildMenuOption`):**
  Encapsula a criação de `Card` com `ListTile`, ícone primário, título, subtítulo e a seta indicadora `Icons.chevron_right`.
- **Navegação Imperativa via Pilha (`Navigator.push`):**
  Cada uma das 4 opções empilha a rota correspondente usando `MaterialPageRoute`:
  1. Agentes -> `HeroesCatalogPage`
  2. Contrato Diário -> `DailyContractPage`
  3. Meu Esquadrão -> `MySquadPage`
  4. Missões -> `MissionBattlePage`

---

# Slide 05: Catálogo Geral de Agentes (HeroesCatalogPage)

### 1. Requisito Oficial
Listar todos os heróis em uma `PagedListView` utilizando a biblioteca `infinite_scroll_pagination`. Ao invocar a API, salvar em cache todas as informações no SQLite. Se o dispositivo estiver sem internet, exibir as informações com base no cache local do banco. Os cards devem conter nome, powerstats e appearance, com miniaturas salvas em cache via `cached_network_image`. O clique no card abre a tela de Detalhes do Agente.

### 2. Arquivos Envolvidos
- `lib/ui/page/heroes_catalog_page.dart`: Tela do catálogo com rolagem infinita.
- `lib/ui/widgets/hero_card.dart`: Componente visual do cartão de herói.
- `lib/data/repository/hero_repository_impl.dart`: Lógica da estratégia Offline-First.
- `lib/data/database/dao/hero_dao.dart`: DAO responsável pela tabela `heroes`.
- `lib/data/database/dao/base_dao.dart`: Infraestrutura de conexão com o banco SQLite.

### 3. Como Funciona no Código-Fonte

#### A. O Controlador de Paginação (`HeroesCatalogPage`)
A classe é um `StatefulWidget` que inicializa o `PagingController`:
```dart
late final PagingController<int, HeroModel> _pagingController = PagingController<int, HeroModel>(
  getNextPageKey: (state) => state.lastPageIsEmpty ? null : state.nextIntPageKey,
  fetchPage: (pageKey) => _heroRepository.getHeroes(page: pageKey, limit: 10),
);
```
- `pageKey`: Representa a página atual (iniciando em 1).
- `lastPageIsEmpty`: Quando a busca retorna lista vazia, a chave é definida como `null`, interrompendo novas requisições.
- `dispose()`: O controlador é obrigatoriamente descartado no `dispose()` do widget para evitar vazamentos de memória (memory leaks).

#### B. A Estratégia Offline-First no Repositório (`HeroRepositoryImpl.getHeroes`)
```dart
@override
Future<List<HeroModel>> getHeroes({required int page, required int limit}) async {
  final offset = (page * limit) - limit;
  
  // 1. TENTA PRIMEIRO NO BANCO LOCAL (SQLite)
  final dbEntities = await heroDao.selectAll(limit: limit, offset: offset);
  if (dbEntities.isNotEmpty) {
    return databaseMapper.toHeroes(dbEntities);
  }

  // 2. SE O CACHE ESTIVER VAZIO, VAI NA API REMOTA
  final networkEntities = await apiClient.getHeroes(page: page, limit: limit);
  final heroes = networkMapper.toHeroes(networkEntities);

  // 3. SALVA EM LOTE NO SQLITE PARA AS PRÓXIMAS CONSULTAS
  await heroDao.insertAll(databaseMapper.toHeroDatabaseEntities(heroes));

  return heroes;
}
```
- **Funcionamento Offline:** Se o aparelho estiver sem internet mas já tiver carregado os dados uma vez, o `heroDao.selectAll()` retorna os dados instantaneamente do SQLite.
- **Transação Atômica no `HeroDao.insertAll`:**
  O método utiliza `db.transaction()` para gravar todos os heróis em uma única operação de disco no SQLite. Isso reduz o tempo de inserção de 10 segundos para menos de 100 milissegundos e evita inconsistências caso a operação seja interrompida.

#### C. O Card de Agente (`hero_card.dart`)
- **Cache de Miniaturas:** Utiliza `CachedNetworkImage(imageUrl: hero.images.sm)` com `placeholder` e `errorWidget`. A foto é baixada e persistida no disco local do aparelho.
- **Nome e Alinhamento Moral:** Exibe o nome do herói com truncamento (`TextOverflow.ellipsis`) e um badge colorido: Verde para alinhamento `good`, Vermelho para `bad` e Laranja para neutro.
- **Powerstats e Appearance:** Exibe o atributo de combate dominante do herói (`hero.highestStatName` e pontuação) e dados de aparência (`hero.appearance.race` ou gênero).
- **Navegação:** O `InkWell` envolve o card e executa `Navigator.push` para a `HeroDetailPage`.

---

# Slide 06: Tela Detalhes do Agente (HeroDetailPage)

### 1. Requisito Oficial
Exibir a imagem do herói em alta resolução. Exibir todos os detalhes disponíveis na API. Os dados devem ser lidos preferencialmente da API ou recuperados do banco local em caso offline. Utilizar `cached_network_image` para cache de imagens. Utilizar `primer_progress_bar` para exibir barra de progresso de cada um dos 6 powerstats (intelligence, strength, speed, durability, power, combat).

### 2. Arquivos Envolvidos
- `lib/ui/page/hero_detail_page.dart`: Tela de dossiê completo.
- `lib/data/repository/hero_repository_impl.dart`: Método `getHeroById`.
- `lib/data/database/dao/hero_dao.dart`: Método `selectById`.

### 3. Como Funciona no Código-Fonte

#### A. Leitura Preferencial da API com Fallback no Repositório
No arquivo `hero_repository_impl.dart` (método `getHeroById`):
```dart
@override
Future<HeroModel?> getHeroById(int id) async {
  // Se for membro do esquadrão, prioriza o SQLite onde residem os stats evoluídos
  final squadMember = await squadDao.selectMemberById(id);
  if (squadMember != null) {
    return databaseMapper.toHero(squadMember);
  }

  // 1. PREFERENCIALMENTE BUSCA DA API
  try {
    final networkEntity = await apiClient.getHeroById(id);
    final hero = networkMapper.toHero(networkEntity);
    await heroDao.insert(databaseMapper.toHeroDatabaseEntity(hero));
    return hero;
  } catch (_) {
    // 2. RECUPERA DO CACHE LOCAL SQLITE EM CASO OFFLINE
    final cachedHero = await heroDao.selectById(id);
    if (cachedHero != null) {
      return databaseMapper.toHero(cachedHero);
    }
  }
  return null;
}
```

#### B. As Barras de Atributo com `primer_progress_bar`
A tela utiliza o componente oficial `SegmentedBar` da biblioteca:
```dart
Widget _buildStatBar(BuildContext context, String label, int value, Color color) {
  final int barFill = value.clamp(0, 100);
  final int remaining = (100 - barFill).clamp(0, 100);

  return SegmentedBar(
    segments: [
      Segment(value: barFill, color: color),
      Segment(value: remaining, color: Colors.grey.shade200),
    ],
    maxTotalValue: 100,
  );
}
```
- Cores temáticas por atributo: Azul para Inteligência, Vermelho para Força, Amarelo para Velocidade, Verde para Durabilidade, Roxo para Poder e Laranja para Combate.
- O uso de `.clamp(0, 100)` impede que a barra quebre o layout caso um herói ultrapasse 100 pontos em batalhas.

#### C. Imagem em Alta Resolução e Dados Cadastrais
- A imagem utiliza `hero.images.lg` (Large), com fallback para `hero.images.md`, em um container de 320px com `CachedNetworkImage`.
- O método auxiliar `_buildInfoRow` filtra e oculta automaticamente valores vazios, `null` ou `"-"`, mantendo as seções de Biografia, Aparência, Ocupação e Grupos limpas.

---

# Slide 07: Tela Contrato Diário e Recrutamento (DailyContractPage)

### 1. Requisito Oficial
Apresentar uma vez ao dia um card de herói aleatório disponível para contratação contendo apenas nome, imagem e powerstats. Utilizar `shared_preferences` para armazenar a data do último sorteio e o ID do herói convocado no dia. O botão "Recrutar para o Esquadrão" adiciona o herói ao SQLite. O esquadrão suporta no máximo 15 agentes. Se o usuário já tiver 15 agentes, o botão deve ser desabilitado ou disparar mensagem de erro.

### 2. Arquivos Envolvidos
- `lib/ui/page/daily_contract_page.dart`: Tela do sorteio e recrutamento.
- `lib/data/repository/hero_repository_impl.dart`: Método `recruitHero`.
- `lib/data/database/dao/squad_dao.dart`: Métodos `countMembers` e `insertMember`.

### 3. Como Funciona no Código-Fonte

#### A. A Regra das 24 Horas com `shared_preferences`
No método `_checkDailyContract()`:
```dart
final prefs = await SharedPreferences.getInstance();
final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
final lastDrawnDate = prefs.getString(_prefLastDateKey);

if (lastDrawnDate == todayStr) {
  // Já sorteou hoje: carrega o herói previamente salvo
  final savedHeroId = prefs.getInt(_prefHeroIdKey);
  _todaysHero = await repo.getHeroById(savedHeroId);
  return;
}

// Novo dia: sorteia um herói e grava a nova data
await _drawNewHero();
```
O sorteio gera um ID aleatório entre 1 e 560 através de `Random().nextInt(560) + 1` e persiste a chave `daily_contract_last_date` e `daily_contract_hero_id`.

#### B. O Card Minimalista do Slide 07
O método `_buildDailyContractCard` segue a restrição literal do slide:
- Contém exclusivamente a imagem do herói (`CachedNetworkImage`), o nome centralizado em negrito e os 6 powerstats renderizados em barras lineares (`LinearProgressIndicator`).
- Nenhuma biografia ou detalhe de aparência é renderizado neste card.

#### C. A Trava dos 15 Agentes e o Botão de Recrutamento
No repositório (`HeroRepositoryImpl.recruitHero`):
```dart
@override
Future<bool> recruitHero(HeroModel hero) async {
  final currentCount = await squadDao.countMembers();
  if (currentCount >= 15) {
    return false; // Trava do teto de 15 membros
  }

  final alreadyRecruited = await squadDao.selectMemberById(hero.id);
  if (alreadyRecruited != null) {
    return false; // Trava contra duplicatas
  }

  await squadDao.insertMember(databaseMapper.toHeroDatabaseEntity(hero));
  return true;
}
```
Na interface:
- Se `_isAlreadyInSquad`: Botão fica cinza com rótulo *"Agente já no Esquadrão"*.
- Se `isSquadFull` (`count >= 15`): Botão fica laranja com rótulo *"Esquadrão Cheio (15/15)"* e `onPressed` é anulado (`null`), impedindo o clique.
- Se o usuário tentar recrutar com esquadrão cheio, dispara um diálogo de aviso do `AwesomeDialog(dialogType: DialogType.warning)`.

---

# Slide 08: Tela Meu Esquadrão e Gestão Local (MySquadPage)

### 1. Requisito Oficial
Listar exclusivamente os heróis (até 15) já recrutados e salvos no banco SQLite local. Exibir cards com nome, papel tático ou maior atributo e miniatura via `cached_network_image`. Um toque no card leva o usuário para a tela Detalhes do Meu Agente.

### 2. Arquivos Envolvidos
- `lib/ui/page/my_squad_page.dart`: Tela de gerenciamento do esquadrão.
- `lib/ui/widgets/hero_card.dart`: Cartão de exibição reutilizado.
- `lib/data/database/dao/squad_dao.dart`: DAO da tabela `squad`.
- `lib/domain/hero_model.dart`: Lógica do cálculo do maior atributo.

### 3. Como Funciona no Código-Fonte

#### A. Leitura Exclusiva do SQLite
No método `_loadSquad()`:
```dart
final members = await repo.getSquadMembers();
```
O método chama `squadDao.selectAllMembers()`, executando a consulta SQL:
```sql
SELECT * FROM squad ORDER BY name ASC;
```
A tela não toca na internet nem na tabela de cache do catálogo; ela lê unicamente os heróis salvos na tabela `squad`.

#### B. Indicador Visual de Vagas
No topo da página, um container dinâmico monitora a capacidade:
- Exibe o texto `$count / 15`.
- Se o contador estiver entre 0 e 14, o badge exibe borda azul.
- Se atingir 15, a borda e o texto tornam-se vermelhos.

#### C. O Papel Tático (Maior Atributo)
No modelo `hero_model.dart`:
```dart
String get highestStatName {
  final stats = {
    'Intelligence': powerstats.intelligence,
    'Strength': powerstats.strength,
    'Speed': powerstats.speed,
    'Durability': powerstats.durability,
    'Power': powerstats.power,
    'Combat': powerstats.combat,
  };
  return stats.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}
```
Na `MySquadPage`, o `HeroCard` é reutilizado recebendo o subtítulo customizado:
`subtitleOverride: 'Papel Tático: ${hero.highestStatName}'`

#### D. Navegação e Atualização
Ao clicar no card, abre a `HeroDetailPage(hero: hero, isSquadMember: true)`. Se o agente for dispensado dentro da tela de detalhes, o `Navigator.push` devolve `true` e a lista do esquadrão recarrega reativamente na mesma hora.

---

# Slide 09: Detalhes do Meu Agente e Dispensa (HeroDetailPage)

### 1. Requisito Oficial
Exibir a carta do herói em todos os detalhes, com informações vindas da API ou do cache local. O botão "Dispensar do Esquadrão" remove o agente do banco SQLite, liberando vaga no esquadrão. Exibir uma caixa de diálogo de confirmação utilizando a biblioteca `awesome_dialog`. Utilizar `cached_network_image`.

### 2. Arquivos Envolvidos
- `lib/ui/page/hero_detail_page.dart`: Parametrizada com `isSquadMember: true`.
- `lib/data/database/dao/squad_dao.dart`: Método `deleteMember`.
- `lib/data/repository/hero_repository_impl.dart`: Método `dismissHero`.

### 3. Como Funciona no Código-Fonte

#### A. Polimorfismo da Tela de Detalhes
A `HeroDetailPage` recebe a propriedade `final bool isSquadMember;`. Quando esse valor é `true`:
1. Um ícone vermelho de lixeira/remoção (`Icons.person_remove`) é injetado na `AppBar`.
2. Um botão vermelho em destaque ocupando toda a largura da tela é adicionado no fim da rolagem: *"Dispensar do Esquadrão"*.
3. O repositório prioriza a busca na tabela `squad`, garantindo que se o herói tiver atributos aumentados após vitórias em missões (+1), esses valores evoluídos sejam mantidos na tela.

#### B. A Confirmação com `AwesomeDialog`
Ao clicar no botão de dispensa, o método `_confirmDismiss` é disparado:
```dart
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
        Navigator.pop(context, true); // Retorna sinalizando exclusão
      }
    },
  ).show();
}
```
- No banco de dados, `squadDao.deleteMember(id)` executa:
  ```sql
  DELETE FROM squad WHERE id = ?;
  ```
- O herói é deletado do SQLite, uma vaga é liberada na contagem geral e a tela fecha devolvendo `true` para a `MySquadPage`.

---

# Slide 10: Iniciar Missão e Desafio de Crise (MissionBattlePage)

### 1. Requisito Oficial
Permitir ao jogador testar o nível tático do esquadrão. O esquadrão precisa ter pelo menos 5 agentes para iniciar uma missão. O app sorteia aleatoriamente um Desafio de Crise contendo de 3 a 5 rounds. Em cada round é exigido um atributo dominante de teste. O app sorteia um oponente do catálogo geral da API/banco como o "Inimigo da Rodada". Se sortear um herói do esquadrão do usuário, deve sortear novamente.

### 2. Arquivos Envolvidos
- `lib/ui/page/mission_battle_page.dart`: Controlador geral da missão e combate.
- `lib/data/repository/hero_repository_impl.dart`: Consulta de membros e sorteio de vilões.

### 3. Como Funciona no Código-Fonte

#### A. A Trava de Segurança dos 5 Heróis
No método `_startMission()`:
```dart
final squad = await repo.getSquadMembers();
if (squad.length < 5) {
  // Interrompe e desenha a interface de esquadrão incompleto
  return;
}
```
Se o jogador tiver menos de 5 agentes, a tela não inicia o combate e exibe um alerta amigável explicando a necessidade de 5 agentes para suprir a demanda de rounds sem repetição de heróis.

#### B. A Geração do Desafio de Crise (3 a 5 Rounds)
```dart
final int totalRounds = _random.nextInt(3) + 3; // Sorteia entre 3, 4 ou 5 rounds
final squadIds = squad.map((h) => h.id).toSet();

for (int i = 0; i < totalRounds; i++) {
  int enemyId;
  do {
    enemyId = _random.nextInt(560) + 1;
  } while (squadIds.contains(enemyId)); // REGRA ANTI-CLONE

  final enemy = await repo.getHeroById(enemyId);
  final testedStat = _challengeStats[_random.nextInt(_challengeStats.length)];

  generatedRounds.add(
    MissionCrisisRound(
      roundNumber: i + 1,
      enemy: enemy!,
      testedStat: testedStat,
    ),
  );
}
```
- **Laço `do-while`:** Garante que o inimigo da rodada nunca seja um herói pertencente ao esquadrão do jogador.
- **Atributo Dominante:** Sorteia entre Intelligence, Strength, Speed, Combat, Durability ou Power.
- **Banner do Desafio de Crise:** Exibe no topo a quantidade exata de rodadas que foram sorteadas para aquela operação.

---

# Slide 11: Mecânica de Combate, Escalação 3x5 e Resolução

### 1. Requisito Oficial
Apresentação do desafio com imagem e nome do inimigo (sem exibir seus atributos), além do nome do atributo em disputa. Escalação onde o jogador seleciona 1 dos seus agentes disponíveis em uma grade de miniaturas apenas com nome e imagem circular em um grid 3x5. Resolução: compara o atributo exigido entre herói e inimigo:
- Se Herói > Inimigo = Sucesso na Rodada.
- Se Herói < Inimigo = Falha na Rodada.
- Se Valores Iguais = Empate tático.

### 2. Arquivos Envolvidos
- `lib/ui/page/mission_battle_page.dart`: Método `_fightRound` e o widget `GridView.builder`.

### 3. Como Funciona no Código-Fonte

#### A. Card do Inimigo sem Revelar Atributos
O card do inimigo exibe a imagem via `CachedNetworkImage`, o nome do vilão e um container informando:
`ATRIBUTO EM DISPUTA: ${currentRound.testedStat.toUpperCase()}`
Nenhum número de powerstat do inimigo é desenhado na tela, preservando a surpresa tática.

#### B. O Grid 3x5 de Escalação com Fotos Circulares
```dart
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3, // 3 Colunas x até 5 linhas = Grid 3x5
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
        onTap: isUsed ? null : () => _fightRound(hero),
        child: Card(
          child: Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: CachedNetworkImageProvider(hero.images.sm),
              ),
              Text(hero.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (isUsed) const Text('Indisponível', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  },
)
```

#### C. A Resolução Matemática do Combate (`_fightRound`)
```dart
final heroValue = chosenHero.powerstats.getStatByName(stat);
final enemyValue = round.enemy.powerstats.getStatByName(stat);

if (heroValue > enemyValue) {
  _victories++;
  _winningHeroes.add(chosenHero);
  roundTitle = 'Seu herói venceu!';
  dialogType = DialogType.success;
} else if (heroValue < enemyValue) {
  _defeats++;
  roundTitle = 'Seu herói perdeu!';
  dialogType = DialogType.error;
} else {
  _draws++;
  roundTitle = 'Empate Tático!';
  roundDesc = 'Ambos empataram em $stat ($heroValue vs $enemyValue). Não pontua para nenhum lado.';
  dialogType = DialogType.warning;
}
```
O resultado do round é exibido através de um modal animado do `AwesomeDialog`, revelando as pontuações e permitindo avançar.

---

# Slide 12: Execução dos Rounds, Placar e Trava de Uso Único

### 1. Requisito Oficial
Após a rodada, o jogador visualiza os indicadores de resultado calculados pelo app (Vitória, Derrota ou Empate). Cada agente do esquadrão só pode ser enviado para uma rodada por missão. Após o confronto da rodada, o app atualiza o placar e avança automaticamente para o próximo round da fila até concluir a campanha.

### 2. Arquivos Envolvidos
- `lib/ui/page/mission_battle_page.dart`: Estado de placar, trava de uso e avanço de índice.

### 3. Como Funciona no Código-Fonte

#### A. O Placar em Tempo Real
No topo da interface de missão:
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    Text('Vitórias: $_victories', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
    Text('Derrotas: $_defeats', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
    Text('Empates: $_draws', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
  ],
)
```

#### B. A Trava de Uso Único por Missão (Lockout)
- A tela mantém um conjunto: `final Set<int> _usedHeroIds = {};`.
- No momento em que um agente luta em `_fightRound()`, seu ID é adicionado com `_usedHeroIds.add(chosenHero.id)`.
- No `GridView`, se `_usedHeroIds.contains(hero.id)` for verdadeiro:
  - A opacidade cai para `0.35` (efeito desabilitado).
  - O evento `onTap` recebe `null`.
  - Aparece o aviso vermelho *"Indisponível"*, impedindo a reescalação do mesmo herói em múltiplos rounds daquela missão.

#### C. O Avanço na Fila de Rodadas
No botão de confirmação do diálogo de resultado da rodada:
```dart
btnOkOnPress: () {
  if (_currentRoundIndex + 1 < _rounds.length) {
    setState(() {
      _currentRoundIndex++; // Avança o ponteiro da lista de rounds
    });
  } else {
    _finishMission(); // Última rodada: aciona a apuração final
  }
}
```
A AppBar é atualizada automaticamente para refletir o progresso:
`title: Text('Round ${currentRound.roundNumber} de ${_rounds.length}')`

---

# Slide 13: Fim da Missão e Evolução Permanente (+1) no SQLite

### 1. Requisito Oficial
A missão termina quando todos os rounds da operação forem finalizados. O app exibe o sumário com total de vitórias e derrotas. O encerramento dispara caixa de diálogo via `awesome_dialog`:
- **Tipo Sucesso (`DialogType.success`):** Se venceu mais da metade dos rounds, informando "Missão Cumprida!". É sorteado um dos heróis que participou da vitória que ganha +1 em um powerstat aleatório. Uma imagem do herói é exibida.
- **Tipo Erro/Aviso (`DialogType.error` ou `warning`):** Se perdeu a maioria, informando "Operação Fracassada!". Uma imagem de derrota é exibida.

### 2. Arquivos Envolvidos
- `lib/ui/page/mission_battle_page.dart`: Método `_finishMission`.
- `lib/data/database/dao/squad_dao.dart`: Método `incrementStat`.
- `lib/data/repository/hero_repository_impl.dart`: Método `evolveHeroStat`.

### 3. Como Funciona no Código-Fonte

#### A. A Apuração do Vencedor (`_finishMission`)
```dart
final bool overallVictory = _victories > _defeats && _victories > 0;
```
Empates não somam pontos para o jogador nem para o vilão. O jogador só vence a operação se o total de vitórias for estritamente superior ao total de derrotas.

#### B. A Premiação de +1 Permanente no SQLite
Se `overallVictory` for verdadeira:
```dart
// 1. Sorteia APENAS entre os heróis que venceram suas rodadas
final evolvedHero = _winningHeroes[_random.nextInt(_winningHeroes.length)];

// 2. Sorteia um dos 6 atributos
final randomStat = _challengeStats[_random.nextInt(_challengeStats.length)];

// 3. PERSISTE A EVOLUÇÃO NO BANCO DE DADOS LOCAL
await repo.evolveHeroStat(heroId: evolvedHero.id, statName: randomStat);
```
No `squad_dao.dart`, o método `incrementStat` executa no banco de dados nativo do celular:
```sql
UPDATE squad SET combat = combat + 1 WHERE id = ?;
```
Esse valor fica gravado permanentemente no SQLite. Quando o usuário abre as telas de Meu Esquadrão e Detalhes do Meu Agente, o herói reflete os novos pontos aumentados.

#### C. Os Diálogos de Fechamento com `AwesomeDialog`
- **Vitória:** Modal com `DialogType.success`, título *"Missão Cumprida!"*, exibindo a imagem do herói condecorado via `CachedNetworkImage`, a indicação do atributo que recebeu o bônus de +1 e o sumário detalhado do placar (`_formatScore()`).
- **Derrota:** Modal com `DialogType.error`, título *"Operação Fracassada!"*, exibindo um ícone de frustração (`Icons.sentiment_very_dissatisfied`) e o resumo dos rounds perdidos.

---

# Slide 14: Resumo dos Critérios de Avaliação e Checklist Final

Abaixo está o mapeamento exato de todos os critérios avaliativos presentes na prancheta do professor:

### 1. Arquitetura e Offline-First
- **Padrão Repository & IoC:** Implementado em `lib/data/repository/hero_repository_impl.dart` e orquestrado em `lib/core/di/configure_providers.dart`.
- **Estratégia de Cache:** O `HeroDao` grava o catálogo no SQLite com transação atômica (`db.transaction`). O aplicativo abre, lista, detalha e combate mesmo se o dispositivo estiver em Modo Avião.

### 2. Bibliotecas Obrigatórias Integradas
1. **`json-server`:** Configurado no diretório `backend/` e rodando em nuvem no Render (`https://call-hero-pdm.onrender.com`).
2. **`infinite_scroll_pagination`:** Integrado com `PagingController` e `PagedListView` em `HeroesCatalogPage`.
3. **`cached_network_image`:** Presente no `HeroCard`, `HeroDetailPage`, `DailyContractPage` e `MissionBattlePage`.
4. **`primer_progress_bar`:** Integrado via `SegmentedBar` nas 6 barras de atributos da `HeroDetailPage`.
5. **`awesome_dialog`:** Integrado com animações nas confirmações de dispensa, recrutamento e nos feedbacks de missão.
6. **`shared_preferences` e `sqflite`:** O primeiro controla o sorteio diário único no `DailyContractPage`, enquanto o segundo gerencia as tabelas `heroes` e `squad`.

### 3. Regras de Negócio e Travas de Segurança
- **Teto de 15 Agentes:** Travado em `HeroRepositoryImpl.recruitHero` com validação de `squadDao.countMembers() >= 15` e botão desabilitado na interface.
- **Sorteio 1x ao Dia:** Controlado pela data `yyyy-MM-dd` no `SharedPreferences`.
- **Mínimo de 5 Agentes para Missões:** Validação na inicialização de `MissionBattlePage`.
- **Bloqueio de Agente Duplicado na Missão:** Implementado com `Set<int> _usedHeroIds` que reduz a opacidade para 0.35 e anula cliques.
- **Inimigo Fora do Esquadrão:** Laço `do-while` que descarta oponentes pertencentes ao time do usuário.
- **Evolução de +1:** Incremento persistente no SQLite da tabela `squad` para um herói vitorioso da campanha.
