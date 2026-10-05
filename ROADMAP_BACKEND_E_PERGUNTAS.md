# ROADMAP DE ESTUDO DO BACKEND E ARQUITETURA INTERNA (CALL-HERO)

Disciplina: Programacao para Dispositivos Moveis (PDM)  
Professor: Taniro C. Rodrigues  
Objetivo: Dominar todas as conexoes internas do aplicativo (Rede, SQLite, Mappers, Repositorio, Inversao de Controle e Provider), abstraindo as telas visuais para gabaritar a entrevista tecnica individual.

---

## 1. O MAPA DAS CONEXOES INTERNAS (COMO TUDO SE LIGA)

Antes de estudar classe por classe, memorize este diagrama mental de comunicacao:

```
[Superhero API / json-server]
             |
             | (1. Requisicao HTTP via Dio)
             v
     [api_client.dart]
             |
             | (2. Devolve Map/JSON desserializado)
             v
  [hero_network_entity.dart] (DTO de Rede)
             |
             | (3. Converte para objeto de negocio)
             v
   [network_mapper.dart]
             |
             +----------------------------+
             |                            |
             v                            v
      [HeroModel]                  [HeroDatabaseEntity] (DTO de Banco)
   (Modelo de Dominio)                    |
             ^                            | (4. Insere/Atualiza em Batch)
             |                            v
   [database_mapper.dart] <------- [hero_dao.dart] / [squad_dao.dart]
                                          |
                                          | (5. SQL direto via sqflite)
                                          v
                                   [base_dao.dart]
                                          |
                                          v
                              [heroes_database.db (SQLite)]
```

Tudo isso e orquestrado por uma unica classe central: **`HeroRepositoryImpl`**, que e entregue para o aplicativo atraves do **`ConfigureProviders`** via **`Provider`**.

---

## 2. ROADMAP DE ESTUDO: CLASSE POR CLASSE NA ORDEM EXATA

Siga esta rota de estudo numerada de 1 a 14. Se voce entender esta sequencia, entendera 100% da aplicacao.

---

### ETAPA 1: O NUCLEO DO NEGOCIO (DOMINIO)

#### 1. `lib/domain/hero_model.dart`
- **O que e:** A classe que representa o Super-Heroi no seu estado mais puro.
- **O que contem:**
  - `HeroModel`: Objeto principal com `id`, `name`, `slug`, `powerstats`, `appearance`, `biography`, `work`, `connections`, `images`.
  - `Powerstats`: Os 6 atributos numericos (`intelligence`, `strength`, `speed`, `durability`, `power`, `combat`).
  - `Appearance`, `Biography`, `Work`, `Connections`, `HeroImages`.
- **Com quem se conecta:** E o modelo que circula em todo o aplicativo. As telas so conhecem e manipulam `HeroModel`.
- **Por que existe:** Para isolar o aplicativo das dependencias tecnicas. Nem o banco de dados nem a internet mandam na estrutura do heroi; quem manda e o Dominio.
- **Micropartes cruciais:**
  - Construtor `const`: Permite reutilizacao de memoria na maquina virtual Dart (canonicalizacao).
  - Metodo `copyWith`: Clona o objeto imutavel alterando apenas os campos desejados usando o operador `??`.
  - Getter `highestStatName` no `Powerstats`:
    ```dart
    return stats.entries
        .reduce((curr, next) => curr.value >= next.value ? curr : next)
        .key;
    ```
    Usa Programacao Funcional da Aula 02 para achar o maior atributo (papel tatico) sem fazer 6 `if/else`.
- **Possivel Pergunta do Professor Taniro:**
  *"Por que seus atributos sao todos `final` e voce criou um metodo `copyWith`?"*
  **Resposta:** *"Para garantir o principio da Imutabilidade ensinado na Aula 02. Em aplicativos concorrentes ou com navegacao entre telas, se um objeto for mutavel, uma tela pode alterar um valor em memoria e corromper o estado de outra tela sem querer. Com atributos `final` e `copyWith`, toda alteracao gera uma nova instancia limpa e segura."*

#### 2. `lib/domain/exception/mapper_exception.dart` e `network_exception.dart`
- **O que sao:** Classes de excecao customizadas que herdam de `Exception`.
- **Com quem se conectam:** Lançadas pelos mappers e pelo `ApiClient`.
- **Por que existem:** Se a rede falhar ou a conversao de tipos quebrar, nao deixamos o app disparar erros genericos em ingles. Criamos excecoes tipadas com informacoes do tipo de origem e destino (`MapperException<From, To>`).

---

### ETAPA 2: A CAMADA DE REDE (COMO OS DADOS CHEGAM DA INTERNET)

#### 3. `lib/data/network/entity/hero_network_entity.dart`
- **O que e:** DTO (*Data Transfer Object*) que reflete fielmente o JSON que a Superhero API envia.
- **Com quem se conecta:** Recebido pelo `ApiClient` e consumido pelo `NetworkMapper`.
- **Por que existe:** APIs de terceiros mudam. Se amanha a chave `fullName` virar `full_name`, so alteramos este arquivo. O resto do aplicativo permanece intacto.
- **Micropartes cruciais:**
  - O metodo de fabrica `fromJson(Map<String, dynamic> json)`.
  - Uso de valores seguros contra nulos: `int.tryParse(json['id'].toString()) ?? 0` e `json['name'] as String? ?? ''`.
- **Possivel Pergunta do Professor Taniro:**
  *"Por que voce nao desserializou o JSON direto para a classe `HeroModel` do Dominio?"*
  **Resposta:** *"Para respeitar a Separação de Responsabilidades (SoC) e o isolamento de contratos externos. A API externa nao dita como o nosso modelo de negocio funciona. Se a API retornar campos sujos ou nulos, o DTO absorve e sanitiza essa sujeira antes de criar o modelo de negocio limpo."*

#### 4. `lib/data/network/entity/http_paged_result.dart`
- **O que e:** DTO de envelope da paginacao do `json-server`.
- **Com quem se conecta:** Usado pelo `ApiClient` para ler a resposta de `/heroes?_page=1&_per_page=10`.
- **Por que existe:** O `json-server` moderno devolve metadados (`first`, `prev`, `next`, `pages`, `items`, `data`). Esse arquivo garante tipagem estrita para a chave `data`.

#### 5. `lib/data/network/client/api_client.dart`
- **O que e:** O motor HTTP que dispara as chamadas de rede usando a biblioteca `Dio` (Aula 06).
- **Com quem se conecta:** Invocado exclusivamente pelo `HeroRepositoryImpl`.
- **Por que existe:** Centraliza a URL base, os tempos limites de conexao e os interceptores.
- **Micropartes cruciais:**
  - `BaseOptions`: Define `connectTimeout: 10s` e `receiveTimeout: 10s`. Se o servidor cair, o app nao fica congelado eternamente.
  - `InterceptorsWrapper`: Intercepta requisicoes e respostas para log e depuracao.
  - Se `response.statusCode != 200`, lanca `NetworkException`.
- **Possivel Pergunta do Professor Taniro:**
  *"Por que voce usou o pacote `Dio` e nao o `http` padrao do Dart?"*
  **Resposta:** *"Conforme abordado na Aula 06, o Dio oferece suporte nativo a interceptadores de requisicao/resposta, configuracao centralizada de timeouts com `BaseOptions`, cancelamento de tokens e tratamento robusto de erros sem precisar escrever codigo repetitivo de baixo nivel."*

#### 6. `lib/data/network/network_mapper.dart`
- **O que e:** O tradutor que converte `HeroNetworkEntity` em `HeroModel`.
- **Com quem se conecta:** Usado pelo `HeroRepositoryImpl` logo apos receber a resposta do `ApiClient`.
- **Por que existe:** Desacopla a rede do dominio (Aula 13 - Padrao Repository). Se a conversao falhar, ele captura e dispara `MapperException`.

---

### ETAPA 3: A CAMADA DE PERSISTENCIA LOCAL (SQLITE)

#### 7. `lib/data/database/entity/hero_database_entity.dart`
- **O que e:** DTO que representa exatamente uma linha no banco relacional SQLite local.
- **Com quem se conecta:** Recebido e retornado pelos DAOs (`HeroDao` e `SquadDao`).
- **Por que existe:** O SQLite nao suporta tipos complexos. Ele nao armazena listas nem objetos aninhados. Esta classe "achata" o heroi em colunas primitivas (`INTEGER` e `TEXT`).
- **Micropartes cruciais (Linhas 136 a 141):**
  - Gravacao: `jsonEncode(height)` transforma a lista `["6'2", "188 cm"]` em texto puro `'["6\'2","188 cm"]'`.
  - Leitura: `jsonDecode(json['height'] as String? ?? '[]') as List` transforma a string de volta em lista Dart.
- **Possivel Pergunta do Professor Taniro:**
  *"Como voce guardou as listas de altura e peso no SQLite se ele nao tem tipo de array?"*
  **Resposta:** *"Utilizei serializacao textual com `jsonEncode` na gravacao e `jsonDecode` na leitura dentro do DTO de banco de dados. Isso evita o custo desnecessario de criar tabelas relacionais auxiliares de 1 para N apenas para salvar duas strings de medidas."*

#### 8. `lib/data/database/dao/base_dao.dart`
- **O que e:** A classe base abstrata de todos os DAOs (Aula 08).
- **Com quem se conecta:** Herdada por `HeroDao` e `SquadDao`.
- **Por que existe:** Centraliza a abertura do arquivo de banco `heroes_database.db`, o versionamento e a criacao das tabelas no celular.
- **Micropartes cruciais:**
  - `openDatabase(join(await getDatabasesPath(), 'heroes_database.db'), ...)`: Usa o pacote `path` para achar a pasta segura do aplicativo no Android/iOS.
  - Inicializacao preguicosa (*Lazy Initialization*):
    ```dart
    Future<Database> getDb() async {
      _database ??= await _getDatabase();
      return _database!;
    }
    ```
    A conexao so e criada na primeira vez que for solicitada e reutilizada depois, economizando recursos do sistema operacional.
  - `onCreate` com `Batch`:
    ```dart
    final batch = db.batch();
    _createHeroesTableV1(batch);
    _createSquadTableV1(batch);
    await batch.commit();
    ```
    Cria as tabelas `heroes` e `squad` dentro de uma transacao atomica.
- **Possivel Pergunta do Professor Taniro:**
  *"Para que serve esse `db.batch()` dentro do callback `onCreate`?"*
  **Resposta:** *"O `Batch` agrupa multiplas instrucoes DDL de criacao de tabela para serem executadas de uma so vez dentro de uma unica transacao atomica do SQLite. Isso garante consistencia: ou ambas as tabelas sao criadas com sucesso, ou nada e gravado no disco."*

#### 9. `lib/data/database/dao/hero_dao.dart`
- **O que e:** O DAO que faz consultas e insercoes na tabela `heroes` (cache do catalogo - Slide 5).
- **Com quem se conecta:** Usado pelo `HeroRepositoryImpl`.
- **Metodos:**
  - `selectAll({int? limit, int? offset})`: Executa a busca paginada com `orderBy: 'id ASC'`.
  - `insertAll(List<HeroDatabaseEntity> entities)`: Envolve a gravacao de dezenas de herois em uma transacao (`db.transaction`), executando escritas rapidas em disco.
  - `ConflictAlgorithm.replace`: Se o heroi ja existe no cache, atualiza sem lancar erro de chave duplicada.

#### 10. `lib/data/database/dao/squad_dao.dart`
- **O que e:** O DAO que controla a tabela `squad` (herois recrutados e evolucoes de atributos - Slides 7, 8, 9 e 13).
- **Com quem se conecta:** Usado pelo `HeroRepositoryImpl`.
- **Metodos e Regras de Negocio:**
  - `countMembers()`: Executa `SELECT COUNT(*) FROM squad`. Valida a trava de maximo 15 membros (Slide 7) e a trava de minimo 5 membros para missao (Slide 10).
  - `insertMember()`: Salva o novo recruta.
  - `deleteMember(int id)`: Apaga o heroi da equipe ao ser dispensado (Slide 9).
  - `incrementStat({required int heroId, required String statName})`:
    ```dart
    await db.rawUpdate(
      'UPDATE squad SET $column = $column + 1 WHERE id = ?',
      [heroId],
    );
    ```
    Executa o SQL que da a evolucao definitiva de +1 ponto no atributo vencedor da missao (Slide 13).
- **Possivel Pergunta do Professor Taniro:**
  *"Como a evolucao do heroi apos vencer a missao e persistida?"*
  **Resposta:** *"Atraves do metodo `SquadDao.incrementStat()`. Ele mapeia a string do atributo sorteado para a coluna correspondente no banco e dispara um comando SQL `UPDATE squad SET coluna = coluna + 1 WHERE id = ?`. Dessa forma, o ganho de nivel e permanente no banco de dados local do usuario."*

#### 11. `lib/data/database/database_mapper.dart`
- **O que e:** O tradutor entre `HeroDatabaseEntity` (SQLite) e `HeroModel` (Dominio).
- **Com quem se conecta:** Usado pelo `HeroRepositoryImpl` para entregar dados limpos para as telas.
- **Por que existe:** Isola os tipos do banco. Se trocassemos o SQLite por outro banco, o `HeroModel` nao sofreria nenhuma alteracao.

---

### ETAPA 4: A ORQUESTRACAO (REPOSITORIO E INJECAO DE DEPENDENCIAS)

#### 12. `lib/data/repository/hero_repository.dart`
- **O que e:** A Interface Abstrata do Repositorio (Slide 15 da Aula 13).
- **Com quem se conecta:** As telas conhecem apenas este contrato.
- **Por que existe:** Estabelece o contrato de quais operacoes de dados o aplicativo permite, promovendo o desacoplamento arquitetural e a facilidade de testes com mocks.

#### 13. `lib/data/repository/hero_repository_impl.dart`
- **O que e:** A classe mais importante da arquitetura. E a fonte unica de verdade (*Single Source of Truth*) que orquestra a politica **Offline-First**.
- **Com quem se conecta:** Recebe no construtor o `ApiClient`, `NetworkMapper`, `DatabaseMapper`, `HeroDao` e `SquadDao`. E chamado por todas as telas do app.
- **Fluxo do Metodo `getHeroes(page, limit)` (Passo a Passo do Offline-First):**
  ```dart
  // 1. Calcula o deslocamento da pagina
  final offset = (page * limit) - limit;
  
  // 2. Tenta ler do banco SQLite primeiro
  final dbEntities = await heroDao.selectAll(limit: limit, offset: offset);
  if (dbEntities.isNotEmpty) {
    return databaseMapper.toHeroes(dbEntities); // Retorna na hora sem internet
  }
  
  // 3. Se o banco estava vazio, busca da API
  final networkEntities = await apiClient.getHeroes(page: page, limit: limit);
  final heroes = networkMapper.toHeroes(networkEntities);
  
  // 4. Salva em lote no SQLite para as proximas vezes
  await heroDao.insertAll(databaseMapper.toHeroDatabaseEntities(heroes));
  
  // 5. Devolve para a UI
  return heroes;
  ```
- **Fluxo do Metodo `recruitHero(hero)`:**
  1. Consulta `squadDao.countMembers()`. Se for >= 15, bloqueia e retorna `false`.
  2. Consulta se o ID ja esta no time. Se sim, bloqueia e retorna `false`.
  3. Insere no banco local via `squadDao.insertMember()` e retorna `true`.
- **Possivel Pergunta do Professor Taniro:**
  *"Explique a estrategia Offline-First implementada no seu repositorio."*
  **Resposta:** *"Implementamos uma estrategia de Cache-First no `HeroRepositoryImpl.getHeroes()`. O aplicativo sempre consulta primeiramente o SQLite local atraves do `HeroDao`. Se houver registros cacheados, eles sao convertidos e entregues a tela instantaneamente, garantindo funcionamento completo em modo aviao. Caso o banco esteja vazio, o app consome a API remota via `ApiClient`, grava as entidades em cache local no SQLite dentro de uma transacao atomica e entao entrega os dados para a interface."*

#### 14. `lib/core/di/configure_providers.dart` e `main.dart`
- **O que e:** O container de Inversao de Controle (IoC) e Injecao de Dependencias da Aula 13.
- **Como tudo e montado:**
  1. Cria o `ApiClient`, `NetworkMapper`, `DatabaseMapper`, `HeroDao` e `SquadDao`.
  2. Injeta todas essas instancias dentro do construtor de `HeroRepositoryImpl`.
  3. No `main.dart`, envolve a aplicacao inteira com `MultiProvider`, disponibilizando a abstracao `HeroRepository`:
     ```dart
     Provider<HeroRepository>.value(value: heroRepository)
     ```
  4. Qualquer tela acessa o repositorio chamando:
     ```dart
     final repo = Provider.of<HeroRepository>(context, listen: false);
     ```
- **Possivel Pergunta do Professor Taniro:**
  *"Por que voce utilizou `Provider.of<HeroRepository>(context, listen: false)` em vez de instanciar o repositorio com `HeroRepositoryImpl()` dentro de cada tela?"*
  **Resposta:** *"Para aplicar o principio da Inversao de Controle (IoC) e Injecao de Dependencias da Aula 13. Se as telas criassem suas proprias instancias concretas com `new`, gerariamos multiplas conexoes com o banco, acoplamento rigido e impossibilitariamos testes unitarios. Com o Provider, a tela depende apenas da abstracao e recebe a instancia unica compartilhada pelo ciclo de vida global."*

---

## 3. CHECKLIST DAS REGRAS DE NEGOCIO POR TRAS DOS SLIDES

Aqui esta o resumo de como o backend interno resolveu cada regra que o professor pediu:

1. **Slide 5 (Catálogo Offline):** Resolvido por `HeroRepositoryImpl.getHeroes` + `HeroDao.selectAll` + `PagingController`.
2. **Slide 6 (Barras de Atributos dos Detalhes):** `Powerstats` disponibiliza os 6 inteiros para a barra proporcional do `SegmentedBar`.
3. **Slide 7 (Trava de 1 Contrato por Dia e Teto de 15):** 
   - 1x ao dia: gravado no `SharedPreferences` com a chave de data no formato `yyyy-MM-dd`.
   - Teto de 15: validado no `SquadDao.countMembers() >= 15` e travado no `HeroRepositoryImpl.recruitHero()`.
4. **Slide 8 (Papel Tático do Meu Esquadrão):** Calculado pelo `Powerstats.highestStatName` usando `reduce` funcional.
5. **Slide 9 (Dispensa com Confirmação):** Executado pelo `SquadDao.deleteMember(id)` apos confirmacao de modal.
6. **Slide 10 (Mínimo de 5 Agentes para Missão):** Verificado por `squad.length < 5` ao entrar na tela.
7. **Slide 10 (Vilão fora do Esquadrão):**
   ```dart
   do {
     enemyId = _random.nextInt(560) + 1;
   } while (squadIds.contains(enemyId));
   ```
   Garante que nenhum herói do seu próprio time seja sorteado como adversário.
8. **Slide 11 (Ocultação de Números do Vilão):** O `MissionCrisisRound` passa o vilão para a tela, mas a interface renderiza apenas imagem, nome e a string do atributo desafiado, sem revelar o valor numérico.
9. **Slide 12 (Uso Único por Missão):** Controlado pelo conjunto em memoria `Set<int> _usedHeroIds`. Se o ID do heroi esta no conjunto, ele e bloqueado para os proximos rounds daquela missao.
10. **Slide 13 (Evolução +1 Permanente no Banco):** Executado pelo `SquadDao.incrementStat()` disparando comando SQL `UPDATE` direto no disco do celular.

---

## 4. ROTEIRO DE ESTUDO RECOMENDADO

1. Comece lendo `lib/domain/hero_model.dart` para entender a forma pura do dado.
2. Em seguida, leia `hero_network_entity.dart` e `api_client.dart` para entender como o dado vem da internet.
3. Depois, leia `hero_database_entity.dart`, `base_dao.dart` e `squad_dao.dart` para entender como o SQLite salva e evolui o heroi.
4. Por fim, leia `hero_repository_impl.dart` e `configure_providers.dart` para ver como o Repositorio e o Provider amarram todas essas pontas.
