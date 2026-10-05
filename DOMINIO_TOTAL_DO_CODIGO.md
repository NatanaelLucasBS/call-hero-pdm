# DOMINIO TOTAL DO CODIGO: GUIA LINHA A LINHA PARA A ENTREVISTA

Disciplina: Programacao para Dispositivos Moveis (PDM)  
Professor: Taniro C. Rodrigues  
Projeto: Call-Hero (Implementacao do Trabalho 1 - UFRN 2026)  

Este documento foi projetado para ser lido lado a lado com o codigo-fonte. Ele disseca cada arquivo, classe, metodo, comando SQL e linha de decisao tecnica do projeto, preparando o aluno para responder a qualquer pergunta aleatoria que o professor fizer durante a arguicao individual.

---

## INDICE DE ARQUIVOS ANALISADOS

1. Camada de Dominio: `lib/domain/hero_model.dart`
2. Camada de Rede:
   - `lib/data/network/entity/hero_network_entity.dart`
   - `lib/data/network/entity/http_paged_result.dart`
   - `lib/data/network/client/api_client.dart`
   - `lib/data/network/network_mapper.dart`
3. Camada de Banco de Dados (SQLite):
   - `lib/data/database/entity/hero_database_entity.dart`
   - `lib/data/database/dao/base_dao.dart`
   - `lib/data/database/dao/hero_dao.dart`
   - `lib/data/database/dao/squad_dao.dart`
   - `lib/data/database/database_mapper.dart`
4. Camada de Repositorio e Injecao de Dependencias:
   - `lib/data/repository/hero_repository.dart`
   - `lib/data/repository/hero_repository_impl.dart`
   - `lib/core/di/configure_providers.dart`
   - `lib/main.dart`
5. Camada de Apresentacao e Telas (UI):
   - `lib/ui/widgets/hero_card.dart`
   - `lib/ui/page/home_page.dart`
   - `lib/ui/page/heroes_catalog_page.dart`
   - `lib/ui/page/hero_detail_page.dart`
   - `lib/ui/page/daily_contract_page.dart`
   - `lib/ui/page/my_squad_page.dart`
   - `lib/ui/page/mission_battle_page.dart`
6. Perguntas Aleatorias Classicas do Professor Taniro (FAQ de Entrevista)

---

## 1. CAMADA DE DOMINIO: `lib/domain/hero_model.dart`

### Papel da Camada
O Dominio contem as regras centrais de negocio em Dart puro. Nao depende de Flutter (Widgets), nem de SQLite (`sqflite`), nem de APIs (`dio`). Se trocassemos o Flutter por uma aplicacao Web ou CLI, esta camada permaneceria 100% reutilizavel.

### Micropartes Explicadas

#### Classe `HeroModel`
- `final int id`: Identificador unico oficial vindo da Superhero API.
- `final String name`: Nome de super-heroi do personagem.
- `final Powerstats powerstats`: Objeto aninhado contendo os 6 atributos numericos.
- `final Appearance appearance`: Caracteristicas fisicas e medidas.
- `final Biography biography`: Historico, editora, alinhamento moral.
- `final Work work` e `Connections connections`: Carreira civil, base e afilicoes.
- `final HeroImages images`: URLs das 4 resolucoes (xs, sm, md, lg).

#### Construtor `const HeroModel({ required ... })`
- **Por que `const`?** Permite que o compilador do Dart faca canonicalizacao de instancias na memoria. Objetos com atributos identicos compartilham o mesmo endereco em tempo de execucao, economizando memoria RAM.
- **Por que parametros nomeados e `required`?** Evita erros de inversao de parametros do mesmo tipo e obriga o preenchimento de todos os dados essenciais.

#### Metodo `HeroModel copyWith({ ... })`
- **Por que usamos `copyWith`?** Como a classe e imutavel (todos os campos sao `final`), nao podemos fazer `hero.name = "Novo Nome"`. O `copyWith` clona a instancia existente atualizando apenas os atributos explicitamente informados.
- **Operador de coalescencia nula `??`:** `name: name ?? this.name`. Se o argumento `name` passado for nulo, mantem o valor que o objeto ja tinha (`this.name`).

#### Metodo `HeroModel evolveStat(String statName)`
- **Regra de Negocio do Slide 13:** Quando um heroi vence rodadas na missao e e sorteado, ele ganha +1 ponto em um atributo. Este metodo invoca o `copyWith` de `powerstats` incrementando exatamente o atributo indicado pela string.

#### Classe `Powerstats` e o Getter `highestStatName`
- **Codigo:**
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
- **Por que usar `reduce` da Aula 02?** O metodo `reduce` aplica uma funcao acumuladora sobre as entradas do mapa sem necessidade de encadear 6 estruturas `if/else`.
- **Por que o operador `>=`?** Em caso de empate entre pontuacoes maximas (por exemplo, Batman com 100 em Inteligencia e 100 em Combate), o `>=` preserva a primeira entrada dominante na ordem de declaracao, mantendo a identidade canonica do personagem.

---

## 2. CAMADA DE REDE (`lib/data/network/`)

### 2.1 `hero_network_entity.dart`
- **Papel:** DTO (Data Transfer Object) que espelha exatamente a estrutura do JSON da Superhero API.
- **Por que nao usar `HeroModel` diretamente na API?** Isolamento de contrato. Se a API externa mudar a chave `fullName` para `full_name`, alteramos apenas o DTO de rede, sem quebrar o banco de dados nem a interface visual.
- **Tratamento defensivo contra nulos:**
  - `id: int.tryParse(json['id'].toString()) ?? 0`
  - `name: json['name'] as String? ?? ''`
  Se a API retornar um campo ausente ou nulo, o operador `??` fornece um valor padrao seguro, impedindo excecoes em tempo de execucao (`Null check operator used on a null value`).

### 2.2 `http_paged_result.dart`
- **Papel:** Envelope de resposta paginada do `json-server`.
- **Campos:** `first`, `prev`, `next`, `last`, `pages`, `items`, `data`.
- **Por que existe?** O `json-server` (versao moderna utilizada no Trabalho 1) encapsula a lista dentro de um objeto JSON contendo metadados de paginacao. Esse DTO desserializa a chave `data` transformando-a em lista de `HeroNetworkEntity`.

### 2.3 `api_client.dart`
- **Papel:** Cliente de comunicacao HTTP baseado na biblioteca `Dio` (Aula 06).
- **Linhas-chave:**
  - `BaseOptions(baseUrl: ..., connectTimeout: 10s, receiveTimeout: 10s)`: Define tempos limites para nao travar a interface se o servidor cair.
  - `InterceptorsWrapper(onRequest, onResponse, onError)`: Intercepta todas as requisicoes para fins de auditoria e log.
  - `if (response.statusCode != 200) throw NetworkException(...)`: Garante que respostas de erro da API sejam tratadas como excecoes tipadas.

### 2.4 `network_mapper.dart`
- **Papel:** Converte `HeroNetworkEntity` (Rede) para `HeroModel` (Dominio).
- **Tratamento com `MapperException`:** Se ocorrer alguma inconsistencia de tipos durante a conversao, o erro e capturado e relancado com detalhes precisos da entidade que falhou.

---

## 3. CAMADA DE BANCO DE DADOS LOCAL SQLITE (`lib/data/database/`)

### 3.1 `hero_database_entity.dart`
- **Papel:** DTO plano que representa uma linha na tabela do SQLite (`heroes` ou `squad`).
- **Problema resolvido:** O SQLite suporta nativamente apenas tipos primitivos: `INTEGER`, `REAL`, `TEXT`, `BLOB`. Ele nao possui tipos para listas (como `List<String> height`) ou objetos aninhados (como `Powerstats`).
- **Solucao tecnica implementada nas linhas 136-141 e no `toJson()`:**
  - Na gravacao (`toJson`): `jsonEncode(height)` converte a lista `["6'2", "188 cm"]` em uma String textual `'["6\'2","188 cm"]'`.
  - Na leitura (`fromJson`): `jsonDecode(json['height'] as String? ?? '[]') as List` converte a String de volta em uma lista manipulavel.

### 3.2 `base_dao.dart`
- **Papel:** Classe base abstrata para inicializacao e controle de versao do banco SQLite (Aula 08).
- **Linhas-chave:**
  - `openDatabase(join(await getDatabasesPath(), 'heroes_database.db'), ...)`: Localiza o caminho padrao do banco no sistema operacional do celular usando o pacote `path`.
  - `_database ??= await _getDatabase()`: Inicializacao preguicosa (*Lazy Initialization*). A conexao so e aberta quando o primeiro DAO solicitar, e uma vez aberta, a instancia em memoria e reutilizada.
  - `onCreate: (db, version) async { final batch = db.batch(); ... await batch.commit(); }`: Utiliza um `Batch` para executar os comandos DDL de criacao das tabelas `heroes` e `squad` dentro de uma unica transacao atomica.

### 3.3 `hero_dao.dart`
- **Papel:** Gerencia a tabela `heroes` utilizada para cache offline do catalogo (Slide 5).
- **Metodos:**
  - `selectAll({int? limit, int? offset})`: Executa `db.query('heroes', limit: limit, offset: offset, orderBy: 'id ASC')` para alimentar a paginacao infinita offline.
  - `insertAll(List<HeroDatabaseEntity> entities)`: Utiliza `db.transaction` com `batch` para salvar multiplos herois de uma vez, aumentando a velocidade de gravacao em ate 50 vezes.
  - `ConflictAlgorithm.replace`: Se um heroi com o mesmo ID ja existir no cache, o SQLite atualiza os dados em vez de lancar erro de chave duplicada.

### 3.4 `squad_dao.dart`
- **Papel:** Gerencia a tabela `squad` com os ate 15 membros recrutados pelo jogador (Slides 7, 8, 9 e 13).
- **Metodos:**
  - `countMembers()`: Executa `SELECT COUNT(*) FROM squad`. Se retornar >= 15, bloqueia novos recrutamentos (Slide 7). Se retornar < 5, bloqueia inicio de missoes (Slide 10).
  - `deleteMember(int id)`: Remove fisicamente o agente da tabela `squad` liberando vaga apos confirmacao modal (Slide 9).
  - `incrementStat({required int heroId, required String statName})`: Executa:
    ```sql
    UPDATE squad SET {coluna} = {coluna} + 1 WHERE id = ?
    ```
    Isso grava o bônus permanente de +1 diretamente no disco, persistindo a evolucao do heroi mesmo se o app for fechado.

### 3.5 `database_mapper.dart`
- **Papel:** Mapeador bidirecional entre `HeroDatabaseEntity` (Banco) e `HeroModel` (Dominio), desacoplando a estrutura das colunas do banco das regras de tela.

---

## 4. CAMADA DE REPOSITORIO E INJECAO DE DEPENDENCIAS

### 4.1 `hero_repository.dart`
- **Papel:** Contrato abstrato (Interface segundo Martin Fowler e Aula 13).
- **Por que usar uma interface abstrata?** Permite que as telas dependam de uma abstracao (`HeroRepository`) e nao de uma implementacao concreta. Em testes automatizados, podemos substituir a classe concreta por um Mock sem alterar nenhuma linha da interface visual.

### 4.2 `hero_repository_impl.dart`
- **Papel:** Ponto unico de verdade (*Single Source of Truth*) e orquestrador da politica **Offline-First**.
- **Logica do Metodo `getHeroes(page, limit)` (Slide 5):**
  1. Calcula `offset = (page * limit) - limit`.
  2. Consulta o banco local: `heroDao.selectAll(limit, offset)`.
  3. Se o banco retornar registros (`dbEntities.isNotEmpty`), entrega diretamente a tela sem gastar internet.
  4. Se o banco estiver vazio, busca da API remota: `apiClient.getHeroes(page, limit)`.
  5. Salva os herois recebidos no SQLite via `heroDao.insertAll`.
  6. Retorna os dados convertidos para a tela.
- **Logica do Metodo `recruitHero(HeroModel hero)` (Slides 7 e 8):**
  1. Verifica se `squadDao.countMembers() >= 15`. Se sim, aborta e retorna `false`.
  2. Verifica se o heroi ja esta no esquadrao via `squadDao.selectMemberById(hero.id)`. Se sim, aborta e retorna `false`.
  3. Insere o recruta no banco via `squadDao.insertMember` e retorna `true`.
- **Metodo `seedTestSquad()`:** Recruta automaticamente 5 especialistas canônicos (Batman em Inteligência, Hulk em Força, Flash em Velocidade, Wolverine em Durabilidade e Capitão América em Combate) para possibilitar testes imediatos da tela de missões.

### 4.3 `configure_providers.dart` e `main.dart`
- **Papel:** Inversao de Controle (IoC) e Injeção de Dependencias via `Provider` (Aula 13).
- **Como funciona:**
  - Instancia `ApiClient`, `HeroDao`, `SquadDao`, `NetworkMapper`, `DatabaseMapper` e os conecta no `HeroRepositoryImpl`.
  - Registra a instancia no `MultiProvider` em `main.dart`:
    ```dart
    Provider<HeroRepository>.value(value: heroRepository)
    ```
  - Em qualquer tela, recuperamos o repositorio usando:
    ```dart
    final repo = Provider.of<HeroRepository>(context, listen: false);
    ```
  - **Por que `listen: false`?** Porque estamos chamando metodos pontuais (como buscar dados ou recrutar). Se usassemos `listen: true`, a tela inteira seria reconstruida desnecessariamente a cada notificacao, gerando perda de performance.

---

## 5. CAMADA DE APRESENTACAO E TELAS (`lib/ui/`)

### 5.1 `hero_card.dart` (Slides 5 e 8)
- Widget reutilizavel para exibicao de agentes em listas.
- **Uso de `CachedNetworkImage`:** Faz o download da imagem e salva em disco/memoria. Se o app estiver sem internet, exibe a imagem a partir do cache local sem falhas visuais.
- **Badge de Alinhamento:** Metodo `_getAlignmentColor` pinta de verde se for "good", vermelho se for "bad" e âmbar se for neutro.
- **Papel Tatico:** Exibe a especialidade tática calculada com o getter funcional `hero.highestStatName`.

### 5.2 `home_page.dart` (Slide 4)
- Contém os 4 acessos solicitados no Slide 4:
  1. Agentes (Catálogo Geral)
  2. Contrato Diário (Recrutamento)
  3. Meu Esquadrão (Gestão da Equipe)
  4. Missões (Combate Tático)
- Utiliza navegação padrão do Flutter: `Navigator.push(context, MaterialPageRoute(...))`.

### 5.3 `heroes_catalog_page.dart` (Slide 5)
- **Biblioteca obrigatória:** `infinite_scroll_pagination`.
- **Controlador:** `PagingController<int, HeroModel>` gerencia a pagina atual, o carregamento sob demanda conforme o usuario rola a tela e o tratamento de erros com `PagedChildBuilderDelegate`.
- **Descarte de Recursos (`dispose`):**
  ```dart
  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
  ```
  Evita vazamento de memoria (*memory leak*) ao sair da tela.

### 5.4 `hero_detail_page.dart` (Slide 6 e Slide 9)
- **Biblioteca obrigatória:** `primer_progress_bar`.
- **Barras de Atributos:** Metodo `_buildStatBar` utiliza `SegmentedBar` com preenchimento proporcional de 0 a 100 para cada um dos 6 atributos (Inteligência, Força, Velocidade, Durabilidade, Poder e Combate).
- **Botao de Dispensa do Esquadrão (Slide 9):**
  - Só aparece se `isSquadMember == true`.
  - Dispara caixa de diálogo de confirmação via `AwesomeDialog` com `DialogType.warning`. Se confirmado, chama `repo.dismissHero(id)`.

### 5.5 `daily_contract_page.dart` (Slide 7)
- **Biblioteca obrigatória:** `shared_preferences`.
- **Regra de 1 sorteio por dia:**
  - Salva a data atual em formato `yyyy-MM-dd` e o ID do heroi sorteado no dia.
  - Ao entrar na tela, se a data salva for igual a de hoje, recupera o mesmo heroi do dia sem gerar outro sorteio.
- **Restricao de 15 Agentes:**
  - O botao de recrutamento verifica `_squadCount >= 15`. Se o esquadrao estiver cheio, o botao e desabilitado visualmente com a legenda "Esquadrao Cheio (15/15)". Se clicado, emite `AwesomeDialog` explicativo.

### 5.6 `my_squad_page.dart` (Slides 8 e 9)
- Exibe o contador de ocupacao no topo (`X / 15`).
- Lista apenas os herois recrutados que estao salvos no SQLite.
- Permite dispensar herois tanto pelo icone de lixeira quanto navegando para a tela de detalhes.
- Disponibiliza estado vazio amigavel com botao de teste para recrutar 5 especialistas instantaneamente.

### 5.7 `mission_battle_page.dart` (Slides 10, 11, 12 e 13)
- **Trava de Inicio (Slide 10):** Se `squad.length < 5`, bloqueia o combate e exibe a mensagem de que sao necessarios pelo menos 5 herois.
- **Sorteio do Desafio (Slide 10):**
  - Sorteia aleatoriamente de 3 a 5 rounds: `final totalRounds = _random.nextInt(3) + 3`.
  - Sorteia um oponente aleatorio fora do esquadrao:
    ```dart
    do {
      enemyId = _random.nextInt(560) + 1;
    } while (squadIds.contains(enemyId));
    ```
    Se o ID sorteado pertencer ao esquadrao do jogador, o laco `do-while` sorteia novamente, atendendo com fidelidade ao Slide 10.
- **Apresentacao da Rodada (Slide 11):** Exibe a imagem e o nome do vilao, ocultando seus numeros e revelando apenas o atributo em teste (ex: "ATRIBUTO EM DISPUTA: SPEED").
- **Escalacao em Grade 3x5:** Renderiza avatares circulares (`CircleAvatar`) com nomes dos agentes disponiveis.
- **Lockout de Uso Unico (Slide 12):** Quando um heroi e escalado, seu ID e adicionado ao `Set<int> _usedHeroIds`. O avatar fica com opacidade 0.35 e o clique e desabilitado ate o fim da missao.
- **Resolucao do Combate:**
  - `heroValue > enemyValue`: Vitoria na rodada ("Seu heroi venceu!"), incrementa `_victories` e adiciona o heroi aos vencedores.
  - `heroValue < enemyValue`: Derrota na rodada ("Seu heroi perdeu!"), incrementa `_defeats`.
  - `heroValue == enemyValue`: Empate tatico ("Empate Tatico!"), incrementa `_draws`. Nao pontua para nenhum lado e nao altera a contagem total de rounds.
- **Encerramento da Missao (Slide 13):**
  - Se `_victories > _defeats` e `_victories > 0`: Dispara `AwesomeDialog` com `DialogType.success`, informando "Missão Cumprida!". Sorteia um dos herois que venceu rodadas e um atributo aleatorio, executando `repo.evolveHeroStat(heroId, statName)` para gravar o bônus permanente no SQLite, exibindo a foto do heroi e a mensagem "Bônus: +1 no atributo {Stat}!".
  - Se perdeu a maioria: Dispara `AwesomeDialog` com `DialogType.error`, informando "Operacao Fracassada!" com icone de derrota.

---

## 6. PERGUNTAS ALEATORIAS CLASSICAS DO PROFESSOR TANIRO (FAQ DE ENTREVISTA)

### Pergunta 1: "Por que voce usou `listen: false` no Provider dentro de metodos assincronos?"
**Resposta:**  
"Professor, o `listen: true` faz com que o widget se registre como ouvinte de alteracoes e seja reconstruido sempre que o Provider notificar mudancas. Dentro de funcoes de clique, metodos assincronos ou no `initState`, nos apenas queremos disparar uma acao pontual no repositorio (como buscar dados ou recrutar). Usar `listen: true` dentro de callbacks pode disparar erros de reconstrucao no meio do ciclo de renderizacao do Flutter e prejudica o desempenho."

### Pergunta 2: "Qual a diferenca entre `db.insert` direto e usar `db.batch()` como voce fez no `BaseDao` e no `HeroDao`?"
**Resposta:**  
"No SQLite, cada chamada individual a `db.insert` abre e fecha uma transacao de disco no sistema de arquivos. Para inserir 20 herois vindos da API, seriam 20 escritas lentas em disco. Ao usar `db.batch()` ou envolver no `db.transaction`, nos agrupamos todas as instrucoes SQL em uma unica transacao atomica na memoria e fazemos um unico commit no disco, o que aumenta dramaticamente a velocidade de execucao e garante atomicidade: se um heroi falhar, nenhum dado corrompido fica no banco."

### Pergunta 3: "Por que voce usou `jsonEncode` e `jsonDecode` nas colunas de altura e peso em `hero_database_entity.dart`?"
**Resposta:**  
"O SQLite suporta apenas tipos primitivos (INTEGER, REAL, TEXT, BLOB). Ele nao tem tipo ARRAY ou LIST nativo. As propriedades `height` e `weight` da API sao listas contendo medidas em padrao imperial e metrico (como `['6\'2', '188 cm']`). Para armazenar isso no SQLite sem precisar criar uma tabela relacional secundaria excessiva para apenas duas strings, convertemos a lista em uma String JSON via `jsonEncode` na gravacao e desserializamos de volta para lista via `jsonDecode` na leitura."

### Pergunta 4: "Como funciona a verificacao de `mounted` antes do `setState`?"
**Resposta:**  
"Como realizamos operacoes assincronas que levam tempo (como requisicoes de rede com o Dio ou leituras no SQLite), o usuario pode tocar no botao de voltar do celular antes que a operacao termine. Se tentarmos chamar `setState` em um State cujo widget ja foi removido da arvore de elementos, o Flutter lanca uma excecao de `setState called after dispose`. O `if (!mounted) return;` verifica se a tela ainda esta ativa antes de atualizar o estado visual."

### Pergunta 5: "Por que no `Powerstats.highestStatName` voce usou `reduce` e nao um laco `for` comum?"
**Resposta:**  
"Ambos funcionariam, mas o `reduce` e uma funcao de ordem superior nativa da biblioteca padrao do Dart que implementa o paradigma de Programacao Funcional ensinado na Aula 02. Ele reduz uma colecao de pares chave-valor a um unico elemento maximo comparando os acumuladores de forma declarativa e concisa, sem necessidade de variaveis de controle de estado mutaveis."

### Pergunta 6: "Se o usuario estiver sem internet em modo aviao, o aplicativo abre?"
**Resposta:**  
"Sim, o aplicativo atende ao criterio de Offline-First do Slide 5 e Slide 14. O `HeroRepositoryImpl` busca os herois no cache local do `HeroDao` antes de tentar qualquer chamada remota. Alem disso, os herois recrutados no `squad_dao` e as fotos em cache do `cached_network_image` ficam salvos no disco local do aparelho, permitindo navegar no esquadrao, consultar detalhes e executar combates mesmo completamente sem conexao."
