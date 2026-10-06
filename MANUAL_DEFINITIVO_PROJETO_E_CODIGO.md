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
2. [Rastreamento Tecnico Completo Clique a Clique de Todo o Aplicativo](#2-rastreamento-tecnico-completo-clique-a-clique-de-todo-o-aplicativo)
   - 2.0 O Ponto de Partida: Inicializacao do App (main.dart)
   - 2.1 Fluxo: Clique em "Agentes" (Catalogo Infinito de Herois)
   - 2.2 Fluxo: Clique em um Card de Heroi (Detalhes do Agente)
   - 2.3 Fluxo: Clique em "Contrato Diario" (Sorteio e Recrutamento)
   - 2.4 Fluxo: Clique em "Meu Esquadrao" (Gestao e Dispensa)
   - 2.5 Fluxo: Clique em "Missoes" (Batalha Tatica e Evolucao de Nivel)
3. [Os 5 Herois de Teste Semeados (seedTestSquad)](#3-os-5-herois-de-teste-semeados-seedtestsquad)
   - 3.1 Justificativa Tecnica e Regra de Negocio do Slide 10
   - 3.2 Ficha Tecnica dos 5 Especialistas (Atributos Dominantes)
   - 3.3 Como a Semeadura Funciona no Codigo-Fonte
4. [Analise Meticulosa do Slide 12 e Todos os Slides do Professor](#4-analise-meticulosa-do-slide-12-e-todos-os-slides-do-professor)
   - 4.1 Slide 12: Execucao dos Rounds, Indicadores, Trava de Uso Unico e Avanco
   - 4.2 Slide 03: Servidor Mock json-server e Superhero API
   - 4.3 Slide 04: Hub de Navegacao (HomePage)
   - 4.4 Slide 05: Catalogo Infinito e Paginacao sob Demanda
   - 4.5 Slide 06: Ficha Tecnica e Barras Proporcionais Primer
   - 4.6 Slide 07: Contrato Diario com SharedPreferences e Trava de 24 Horas
   - 4.7 Slide 08: Gestao do Esquadrao, Teto de 15 Agentes e Papel Tatico
   - 4.8 Slide 09: Dispensa com AwesomeDialog e Limpeza no SQLite
   - 4.9 Slide 10: Desafio de Crise, Minimo 5 Agentes e Sorteio Anti-Clone
   - 4.10 Slide 11: Arena de Combate, Grade 3x5 e Atributos Ocultos
   - 4.11 Slide 13: Criterio de Vitoria, Dialogos e Evolucao Permanente (+1)
   - 4.12 Slide 14: Resumo dos Criterios e Conformidade Arquitetural
5. [Dicionario Tecnico Arquivo por Arquivo, Funcao por Funcao](#5-dicionario-tecnico-arquivo-por-arquivo-funcao-por-funcao)
   - 5.1 Camada de Inicializacao e DI (main.dart, configure_providers.dart)
   - 5.2 Camada de Dominio (hero_model.dart, exceptions)
   - 5.3 Camada de Rede (api_client.dart, entities, network_mapper.dart)
   - 5.4 Camada de Banco de Dados SQLite (base_dao.dart, hero_dao.dart, squad_dao.dart, database_mapper.dart, entities)
   - 5.5 Camada de Repositorio (hero_repository.dart, hero_repository_impl.dart)
   - 5.6 Componentes Visuais (hero_card.dart)
   - 5.7 Telas da Interface (home_page.dart, heroes_catalog_page.dart, hero_detail_page.dart, daily_contract_page.dart, my_squad_page.dart, mission_battle_page.dart)
6. [Banco de Perguntas de Alto Nivel da Banca e Respostas Senior](#6-banco-de-perguntas-de-alto-nivel-da-banca-e-respostas-senior)
7. [Roteiro de Demonstracao Pratica de 5 Minutos para o Professor](#7-roteiro-de-demonstracao-pratica-de-5-minutos-para-o-professor)
8. [Fundamentos do Flutter e Engenharia Mobile para a Banca](#8-fundamentos-do-flutter-e-engenharia-mobile-para-a-banca)
   - 8.1 Arvore de Widgets, Elementos e Render Objects
   - 8.2 Ciclo de Vida: StatelessWidget vs StatefulWidget
   - 8.3 O Padrao Provider por Baixo dos Panos (InheritedWidget e O(1) Lookup)
   - 8.4 SQLite em Producao: Transacoes Atomicas (ACID), Batching e ConflictAlgorithm
   - 8.5 Paginacao Infinita: PagingController e Prevencao de Memory Leaks
   - 8.6 Persistencia Leve: SharedPreferences e Chaves ISO
   - 8.7 Componentes Graficos Externos: Primer, CachedNetworkImage e AwesomeDialog
9. [Matriz de Casos de Borda e Seguranca Operacional (Edge Cases)](#9-matriz-de-casos-de-borda-e-seguranca-operacional-edge-cases)
   - 9.1 Falha de Rede Durante a Rolagem do Catalogo
   - 9.2 Cliques Repetidos e Concorrentes em "Recrutar"
   - 9.3 Atributos com Valores Empatados e Resolucao via Reduce
   - 9.4 Empate de Pontuacao na Rodada da Missao
   - 9.5 Complexidade Assintotica do Set de Herois Utilizados
   - 9.6 Idempotencia da Semeadura de Teste
10. [Banco Estendido de Perguntas da Banca (Perguntas 8 a 15)](#10-banco-estendido-de-perguntas-da-banca-perguntas-8-a-15)
11. [Checklist Matinal de Preparacao e Comandos de Execucao](#11-checklist-matinal-de-preparacao-e-comandos-de-execucao)
    - 11.1 Comandos de Inicializacao do Servidor Mock e Aplicativo
    - 11.2 Como Chavear a URL Base (Render vs Localhost)
    - 11.3 Comandos de Teste e Analise Estatica
    - 11.4 Resumo Mental em 3 Frases para Iniciar a Apresentacao

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

# 2. RASTREAMENTO TECNICO COMPLETO CLIQUE A CLIQUE DE TODO O APLICATIVO

### 2.0 O Ponto de Partida: Inicializacao do App (main.dart)

Quando o aplicativo abre no celular:
1. `lib/main.dart`: O metodo `main()` roda `ConfigureProviders.createDependencyTree()`.
2. `lib/core/di/configure_providers.dart`: Instancia todas as pecas em cascata:
   - `ApiClient` (aponta para a API no Render).
   - `NetworkMapper` e `DatabaseMapper` (tradutores puros).
   - `HeroDao` e `SquadDao` (que abrem a conexao unica com o SQLite `heroes_database.db` via `BaseDao`).
   - `HeroRepositoryImpl` (recebe todas as pecas acima no construtor).
3. O `MultiProvider` envelopa o aplicativo, disponibilizando o repositorio para todas as telas.
4. A tela inicial `home_page.dart` e desenhada com 4 opcoes taticas de navegacao.

---

### 2.1 Fluxo: Clique em "Agentes" (Catalogo Infinito de Herois)

#### O que o usuario faz:
Toca no card "Agentes" na tela inicial.

#### O caminho tecnico passo a passo:
1. **Navegacao (UI)**: O `HomePage` executa `Navigator.push` e abre `heroes_catalog_page.dart`.
2. **Inicializacao do Controlador**: O `_pagingController` da biblioteca `infinite_scroll_pagination` dispara automaticamente a busca da primeira pagina:
   ```dart
   fetchPage: (pageKey) => _heroRepository.getHeroes(page: pageKey, limit: 10)
   ```
3. **Repositorio (`hero_repository_impl.dart`)**:
   - Calcula o offset SQL: `offset = (page * 10) - 10`. Na pagina 1, `offset = 0`.
   - **Consulta o Cache Local Primeiro**: Chama `heroDao.selectAll(limit: 10, offset: 0)`.
   - **Cenario A (Ja existem dados no SQLite)**: 
     - O `DatabaseMapper.toHeroes()` converte as entidades do SQLite para `List<HeroModel>`.
     - O repositorio entrega a lista para o `PagingController` imediatamente, sem usar internet.
   - **Cenario B (Primeira vez, SQLite vazio)**:
     - O repositorio chama `apiClient.getHeroes(page: 1, limit: 10)`.
     - O `ApiClient` (`dio`) faz uma requisicao HTTP `GET /heroes?_page=1&_limit=10`.
     - A resposta JSON vira `HeroNetworkEntity` (DTO).
     - O `NetworkMapper.toHeroes()` converte o DTO para modelo puro `HeroModel`.
     - O repositorio chama `databaseMapper.toHeroDatabaseEntities(heroes)`.
     - O `HeroDao.insertAll()` grava os 10 herois na tabela `heroes` do SQLite dentro de uma transacao atomica (`db.transaction()`).
     - O repositorio devolve a lista para a UI.
4. **Renderizacao dos Cards**:
   - O `PagedListView` desenha cada item usando o `hero_card.dart`.
   - O `CachedNetworkImage` baixa a imagem em segundo plano e salva o arquivo em disco para nunca mais precisar baixar.
5. **Rolagem Infinita**: Quando o usuario rola ate o 10º heroi, o `PagingController` detecta o final da lista e dispara sozinho `page = 2` (`offset = 10`), repetindo o ciclo.

---

### 2.2 Fluxo: Clique em um Card de Heroi (Detalhes do Agente)

#### O que o usuario faz:
Toca em qualquer heroi listado no catalogo ou no esquadrao.

#### O caminho tecnico passo a passo:
1. **Navegacao (UI)**: O `HeroCard` executa `Navigator.push` abrindo `hero_detail_page.dart` passando o objeto `hero`.
2. **Exibicao Instantanea**: A tela renderiza na hora os dados que ja vieram no objeto (imagem grande, nome, biografias).
3. **Atualizacao em Segundo Plano (Slide 6)**:
   - No `initState`, o callback `_fetchLatestDetails()` chama `heroRepository.getHeroById(hero.id)`.
   - **Verificacao no Repositorio**:
     - O repositorio consulta primeiro o `squadDao.selectMemberById(id)`. Se esse heroi for do esquadrao, retorna os dados locais do SQLite para preservar os pontos que ele ganhou em combates (+1).
     - Se nao for do esquadrao, tenta buscar na API via `apiClient.getHeroById(id)` e atualiza o cache local. Se o celular estiver sem internet, recupera do cache via `heroDao.selectById(id)`.
   - O metodo faz `setState()` e atualiza a tela com as barras de progresso do `primer_progress_bar` (`SegmentedBar`).

---

### 2.3 Fluxo: Clique em "Contrato Diario" (Sorteio e Recrutamento)

#### O que o usuario faz:
Toca em "Contrato Diario" na tela inicial.

#### O caminho tecnico passo a passo:
1. **Verificacao de Regra de 24 Horas (`daily_contract_page.dart`)**:
   - O metodo `_checkDailyContract()` le o `SharedPreferences`.
   - Compara a data salva na chave `daily_contract_last_date` com a data atual no formato `yyyy-MM-dd`.
   - **Caso 1 (Ja sorteou hoje)**: Le o ID do heroi salvo em `daily_contract_hero_id`, busca no repositorio (`getHeroById`) e apenas exibe o card na tela.
   - **Caso 2 (Novo dia ou primeiro acesso)**:
     - Gera um numero aleatorio entre 1 e 560 (`Random().nextInt(560) + 1`).
     - Chama `repo.getHeroById(randomId)` para obter o heroi sorteado.
     - Grava no `SharedPreferences` a data de hoje e o ID sorteado.
     - Checa no banco se esse heroi ja faz parte do esquadrao (`repo.isHeroInSquad(id)`).
2. **Renderizacao do Card Exclusivo (Slide 7)**:
   - O metodo `_buildDailyContractCard()` desenha estritamente o que o Slide 7 pede: **apenas** nome, imagem e os 6 powerstats em barras de progresso lineares.
3. **Clique no Botao "Recrutar para o Esquadrao"**:
   - Dispara o metodo `_recruitAgent()`.
   - **Validacao de Capacidade**: Checa se `_squadCount >= 15`. Se o time estiver cheio, exibe um `AwesomeDialog` do tipo warning avisando que nao ha vagas.
   - Se houver vaga, chama `repo.recruitHero(todaysHero)`:
     - No repositorio, valida se ja esta no esquadrao via `squadDao.selectMemberById()`.
     - Converte o heroi para entidade de banco via `databaseMapper.toHeroDatabaseEntity()`.
     - Chama `squadDao.insertMember()`, inserindo o registro na tabela `squad` do SQLite.
   - O botao muda de cor e fica desabilitado ("Agente ja no Esquadrao").
   - Dispara um `AwesomeDialog` do tipo sucesso informando que o agente foi integrado ao time.

---

### 2.4 Fluxo: Clique em "Meu Esquadrao" (Gestao e Dispensa)

#### O que o usuario faz:
Toca em "Meu Esquadrao" na tela inicial.

#### O caminho tecnico passo a passo:
1. **Carregamento Local (`my_squad_page.dart`)**:
   - Chama `repo.getSquadMembers()`.
   - O repositorio executa `squadDao.selectAllMembers()`, que roda uma query direta no SQLite:
     ```sql
     SELECT * FROM squad ORDER BY name ASC
     ```
   - O `DatabaseMapper.toHeroes()` converte os registros para `HeroModel`.
2. **Calculo do Papel Tatico (Slide 8)**:
   - Para cada card renderizado, o subtitulo chama `hero.highestStatName`.
   - Esse getter no `hero_model.dart` usa a funcao `reduce` do Dart para descobrir qual dos 6 atributos e o maior e exibe na tela (ex.: `Papel Tatico: STRENGTH`).
3. **Caso de Esquadrao Vazio**:
   - Se o banco nao tiver nenhum heroi, a tela exibe o botao **"Recrutar 5 Especialistas (Teste)"**.
   - Ao clicar, o repositorio executa `seedTestSquad()`, que recruta Batman (70), Hulk (332), Flash (263), Wolverine (717) e Capitao America (149) no SQLite, liberando o acesso imediato as missoes.
4. **Clique no Icone de Lixeira (Dispensa - Slide 9)**:
   - Dispara um `AwesomeDialog` de confirmacao: *"Deseja dispensar [Nome] do esquadrao?"*.
   - Ao confirmar: chama `repo.dismissHero(hero.id)`.
   - O repositorio chama `squadDao.deleteMember(hero.id)`:
     ```sql
     DELETE FROM squad WHERE id = ?
     ```
   - O registro e removido do SQLite, a vaga e liberada (ex.: de 5/15 vai para 4/15) e a lista recarrega.

---

### 2.5 Fluxo: Clique em "Missoes" (Batalha Tatica e Evolucao de Nivel)

#### O que o usuario faz:
Toca em "Missoes" na tela inicial.

#### O caminho tecnico passo a passo:

##### Etapa 1: Validacao de Entrada e Sorteio da Crise (Slide 10)
1. O metodo `_startMission()` em `mission_battle_page.dart` busca os membros do esquadrao no banco.
2. **Trava de Seguranca**: Se o esquadrao tiver **menos de 5 herois**, a tela trava e exibe uma mensagem de bloqueio, impedindo o combate ate que o jogador recrute agentes.
3. Se tiver 5 ou mais:
   - Sorteia a quantidade de rounds da crise: `_random.nextInt(3) + 3` (sorteia 3, 4 ou 5 rounds).
   - Para cada round:
     - Sorteia um atributo em disputa (`Intelligence`, `Strength`, `Speed`, `Combat`, `Durability` ou `Power`).
     - **Regra Anti-Clone do Slide 10**: Executa um laco `do-while` que gera um ID aleatorio e verifica se o ID ja pertence ao esquadrao do jogador. Se pertencer, sorteia novamente ate achar um vilao externo.
     - Busca os dados do vilao via `repo.getHeroById(enemyId)`.

##### Etapa 2: A Arena de Combate (Slide 11)
1. A tela desenha o placar no topo (`Vitorias: 0, Derrotas: 0, Empates: 0`).
2. **Card do Vilao**: Exibe o nome do vilao, a foto e o nome do atributo da disputa (ex.: `ATRIBUTO EM DISPUTA: STRENGTH`). **Os numeros do vilao ficam estritamente ocultos**, conforme exigido no Slide 11.
3. **Grade de Escalacao 3x5**: Renderiza o esquadrao do jogador em formato 3x5 com avatares circulares (`CircleAvatar`) e o nome de cada agente.

##### Etapa 3: Resolucao do Round e Bloqueio de Agente (Slide 12)
1. O jogador toca no heroi que deseja enviar para o combate.
2. O metodo `_fightRound(chosenHero)` e disparado:
   - **Trava de Uso Unico (Slide 12)**: Registra o heroi no conjunto `_usedHeroIds.add(chosenHero.id)`. A partir deste momento, aquele heroi fica com opacidade 0.35, texto "Indisponivel" e nao pode mais ser clicado em nenhuma outra rodada desta missao.
   - **Comparacao Matematica**:
     ```dart
     final heroValue = chosenHero.powerstats.getStatByName(stat);
     final enemyValue = round.enemy.powerstats.getStatByName(stat);
     ```
     - Se `heroValue > enemyValue`: `_victories++`, adiciona o heroi a lista `_winningHeroes` e define `DialogType.success`.
     - Se `heroValue < enemyValue`: `_defeats++` e define `DialogType.error`.
     - Se `heroValue == enemyValue`: `_draws++` e define `DialogType.warning`.
3. Dispara o `AwesomeDialog` mostrando o resultado da rodada com as pontuacoes reais reveladas.
4. Ao clicar em "Continuar":
   - Se ainda houver rounds na fila: incrementa `_currentRoundIndex++` no `setState()`. A tela atualiza instantaneamente para o proximo round com o novo inimigo e novo atributo.
   - Se foi o ultimo round: invoca `_finishMission()`.

##### Etapa 4: Fim da Missao e Evolucao Permanente no SQLite (Slide 13)
1. O metodo `_finishMission()` avalia se o jogador venceu a campanha (`_victories > _defeats && _victories > 0`).
2. **Se VENCEU ("Missao Cumprida!")**:
   - Sorteia um dos herois que participou das vitorias:
     ```dart
     final evolvedHero = _winningHeroes[_random.nextInt(_winningHeroes.length)];
     ```
   - Sorteia um powerstat aleatorio (ex.: `Speed`).
   - Chama o repositorio: `repo.evolveHeroStat(heroId: evolvedHero.id, statName: randomStat)`.
   - O `SquadDao.incrementStat()` executa um comando SQL nativo de incremento no SQLite:
     ```sql
     UPDATE squad SET speed = speed + 1 WHERE id = ?
     ```
   - O heroi agora tem +1 ponto gravado permanentemente no banco local do dispositivo.
   - Dispara o `AwesomeDialog` do tipo sucesso exibindo a foto do heroi vencedor e o anuncio: *"Bonus: +1 no atributo Speed!"*.
3. **Se PERDEU ("Operacao Fracassada!")**:
   - Dispara o `AwesomeDialog` do tipo erro exibindo o icone de derrota e o placar final, sem alterar o banco de dados.

---

# 3. OS 5 HEROIS DE TESTE SEMEADOS (seedTestSquad)

### 3.1 Justificativa Tecnica e Regra de Negocio do Slide 10

No Slide 10 da avaliacao do professor Taniro, ha uma trava rigida de negocio:
> "O esquadrao precisa ter pelo menos 5 agentes para iniciar uma Missao."

Por outro lado, o Slide 07 estabelece que o recrutamento regular so pode ser realizado atraves do Contrato Diario, limitado a **1 sorteio a cada 24 horas** (controlado por data no `SharedPreferences`).

Se a aplicacao dependesse unicamente do fluxo diario natural, o professor ou o avaliador precisaria abrir o aplicativo durante **5 dias consecutivos** para recrutar 5 agentes e conseguir testar a funcionalidade de Missao e Combate (Slides 10 a 13).

Para resolver essa restricao de avaliacao sem violar as regras de persistencia do SQLite, foi implementada a rotina de semeadura `seedTestSquad()` no `HeroRepositoryImpl`, acionada atraves de botoes de teste presentes na `MySquadPage` e na `MissionBattlePage`.

### 3.2 Ficha Tecnica dos 5 Especialistas (Atributos Dominantes)

Foram selecionados cirurgicamente 5 herois canonicos da Superhero API, onde cada um possui pontuacao maxima (100) exatamente em um dos 5 atributos principais exigidos nos Desafios de Crise do Slide 10:

| ID | Nome do Heroi | Atributo Dominante | Pontuacao | Papel Tatico no Esquadrao |
| :--- | :--- | :--- | :--- | :--- |
| **70** | **Batman** | **Intelligence** | 100 | Estrategista Tatico (Inteligencia) |
| **332** | **Hulk** | **Strength** | 100 | Vanguarda de Impacto (Forca) |
| **263** | **Flash** | **Speed** | 100 | Interceptador Veloz (Velocidade) |
| **717** | **Wolverine** | **Durability** | 100 | Resistencia e Regeneracao (Durabilidade) |
| **149** | **Capitao America** | **Combat** | 100 | Mestre em Artes Marciais (Combate) |

Essa selecao garante que o jogador possua exatamente 1 especialista de nivel maximo para cada tipo de round que o sistema sortear durante o Desafio de Crise.

### 3.3 Como a Semeadura Funciona no Codigo-Fonte

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

# 4. ANALISE METICULOSA DO SLIDE 12 E TODOS OS SLIDES DO PROFESSOR

### 4.1 Slide 12: Execucao dos Rounds, Indicadores, Trava de Uso Unico e Avanco

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

### 4.2 Slide 03: Servidor Mock json-server e Superhero API
- **Requisito**: Consumir dados da Superhero API (Akabab) atraves de servidor REST simulado com `json-server`.
- **Implementacao**:
  - O arquivo `backend/db.json` contem 563 super-herois.
  - Para flexibilidade e avaliacao em qualquer ambiente, a API foi disponibilizada tanto localmente (`npm start` na porta 3000) quanto em producao na nuvem no Render (`https://call-hero-pdm.onrender.com`).
  - O `ApiClient` (`dio`) suporta paginacao via query parameters `_page` e `_limit`.

### 4.3 Slide 04: Hub de Navegacao (HomePage)
- **Requisito**: Tela principal com 4 opcoes de navegacao: Agentes, Contrato Diario, Meu Esquadrao e Missoes.
- **Implementacao**:
  - `lib/ui/page/home_page.dart` renderiza uma lista vertical com 4 `ListTile` estilizados dentro de `Card`.
  - Navega diretamente utilizando `Navigator.push(context, MaterialPageRoute(...))`.

### 4.4 Slide 05: Catalogo Geral de Agentes (HeroesCatalogPage)
- **Requisito**: Catalogo paginado com rolagem infinita exibindo cards com nome, alinhamento, atributos dominantes e aparencia.
- **Implementacao**:
  - Utiliza o pacote `infinite_scroll_pagination` com `PagingController<int, HeroModel>`.
  - Cada item e renderizado pelo componente reutilizavel `HeroCard`.
  - Realiza persistencia em lote no SQLite via `HeroDao.insertAll()` com transacao atomica.

### 4.5 Slide 06: Tela Detalhes do Agente (HeroDetailPage)
- **Requisito**: Exibir a ficha completa do heroi (biografia, aparencia, trabalho, conexoes) com barras de atributos proporcionais usando `primer_progress_bar`. Carregar dados da API ou do banco local.
- **Implementacao**:
  - Imagem em alta resolucao renderizada com `CachedNetworkImage`.
  - Os 6 powerstats utilizam o widget `SegmentedBar` do `primer_progress_bar` com escala proporcional (0 a 100).
  - No `initState`, busca dados atualizados atraves do `HeroRepository.getHeroById()`.

### 4.6 Slide 07: Contrato Diario e Recrutamento (DailyContractPage)
- **Requisito**: Sorteio diario de 1 agente aleatorio. Exibir apenas nome, imagem e powerstats. Botao para recrutar com trava de maximo 15 agentes. Sorteio limitado a 1 vez por dia.
- **Implementacao**:
  - O `SharedPreferences` armazena a chave `daily_contract_last_date` no formato `yyyy-MM-dd` e o ID do heroi em `daily_contract_hero_id`.
  - Se a data coincidir com hoje, restaura o heroi sorteado sem permitir novo sorteio.
  - O card desenha estritamente apenas nome, imagem e barras de progresso lineares dos 6 atributos.
  - O botao de recrutamento valida a capacidade do esquadrao (`_squadCount >= 15`) e impede duplicatas.

### 4.7 Slide 08: Gestao do Esquadrao Local (MySquadPage)
- **Requisito**: Listar exclusivamente os herois recrutados no SQLite (ate 15). Exibir papel tatico / maior atributo. Toque no card leva para Detalhes.
- **Implementacao**:
  - Consulta a tabela `squad` via `HeroRepository.getSquadMembers()`.
  - O papel tatico e calculado funcionalmente no modelo de dominio atraves de `hero.highestStatName` usando `reduce`.
  - Exibe contador visual de ocupacao de vagas (`X / 15`).

### 4.8 Slide 09: Detalhes do Meu Agente e Dispensa (HeroDetailPage)
- **Requisito**: Ficha do heroi com botao "Dispensar do Esquadrao", liberando vaga no banco de dados. Exibir caixa de dialogo com `awesome_dialog`. Cache de imagem com `cached_network_image`.
- **Implementacao**:
  - Botao vermelho "Dispensar do Esquadrao" exibido condicionalmente quando `isSquadMember == true`.
  - Dispara `AwesomeDialog` do tipo `DialogType.warning` solicitando confirmacao.
  - Ao confirmar, executa `HeroRepository.dismissHero(id)`, removendo o registro da tabela `squad` no SQLite.

### 4.9 Slide 10: Iniciar Missao e Desafio de Crise (MissionBattlePage)
- **Requisito**: Trava de pelo menos 5 agentes no esquadrao. Sorteio aleatorio de 3 a 5 rounds. Em cada round, sorteia um atributo de teste dominante e um oponente do catalogo. Se sortear membro do esquadrao, deve sortear novamente.
- **Implementacao**:
  - Trava no `initState`: se `squad.length < 5`, bloqueia o combate e exibe tela de aviso com atalhos de recrutamento.
  - Sorteio de rounds: `final int totalRounds = _random.nextInt(3) + 3;` (gera 3, 4 ou 5).
  - Regra anti-clone: loop `do { enemyId = ... } while (squadIds.contains(enemyId));`.

### 4.10 Slide 11: Arena de Combate e Escalacao 3x5 (MissionBattlePage)
- **Requisito**: Exibir imagem e nome do inimigo com atributos ocultos e nome do atributo em disputa. Escalacao de 1 agente em grid 3x5 com miniaturas circulares. Comparar atributo: maior vence, menor perde, igual empata.
- **Implementacao**:
  - Card do Inimigo: exibe nome, imagem via `CachedNetworkImage` e badge textual com o nome do atributo, omitindo deliberadamente todos os numeros do vilao.
  - Grid de Escalacao: `GridView.builder` com `crossAxisCount: 3` (formato 3x5 para ate 15 herois), utilizando `CircleAvatar` e nome truncado.
  - Resolucao: metodo `_fightRound` executa a comparacao direta e pontua no placar.

### 4.11 Slide 13: Fim da Missao e Evolucao Permanente (+1) no SQLite
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

### 4.12 Slide 14: Resumo dos Criterios e Conformidade Arquitetural
- **Requisito**: Integracao obrigatoria de: `json-server`, `infinite_scroll_pagination`, `cached_network_image`, `primer_progress_bar`, `awesome_dialog`, `shared_preferences` e `sqflite`.
- **Status**: 100% implementado, testado e validado sem erros ou advertencias no `flutter analyze`.

---

# 5. DICIONARIO TECNICO ARQUIVO POR ARQUIVO, FUNCAO POR FUNCAO

Abaixo esta a analise exaustiva de cada um dos 23 arquivos Dart que compoem o projeto Call-Hero.

---

### 5.1 Camada de Inicializacao e DI

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

### 5.2 Camada de Dominio

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

### 5.3 Camada de Rede

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

### 5.4 Camada de Banco de Dados SQLite

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

### 5.5 Camada de Repositorio

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

### 5.6 Componentes Visuais

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

### 5.7 Telas da Interface

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

# 6. BANCO DE PERGUNTAS DE ALTO NIVEL DA BANCA E RESPOSTAS SENIOR

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

---

# 7. ROTEIRO DE DEMONSTRACAO PRATICA DE 5 MINUTOS PARA O PROFESSOR

Se o professor pedir para voce demonstrar o aplicativo funcionando ao vivo no celular/emulador, siga exatamente este roteiro em 5 passos:

1. **Passo 1: Mostrar o Hub Inicial e o Catalogo (Slides 4 e 5)**:
   - Abra o app e mostre a `HomePage` com os 4 botoes.
   - Toque em "Agentes". Role a lista para baixo para mostrar a rolagem infinita funcionando (`infinite_scroll_pagination`).
   - Toque em qualquer heroi para mostrar a tela de detalhes com as barras de atributos do `primer_progress_bar`.
2. **Passo 2: Mostrar o Contrato Diario (Slide 7)**:
   - Volte e entre em "Contrato Diario".
   - Mostre o card exclusivo (apenas nome, imagem e os 6 powerstats).
   - Mostre o contador de vagas `Esquadrao: X/15`.
   - Toque em "Recrutar para o Esquadrao" para recrutar o heroi sorteado. Mostre a caixa de dialogo de sucesso do `AwesomeDialog`.
3. **Passo 3: Mostrar Meu Esquadrao e a Semeadura de Teste (Slides 8 e 10)**:
   - Volte e entre em "Meu Esquadrao".
   - Mostre os herois com o papel tatico exibido no subtitulo (`highestStatName`).
   - Se o time tiver menos de 5 agentes, toque no botao **"Recrutar 5 Especialistas (Teste)"**.
   - Mostre o esquadrao sendo preenchido instantaneamente com Batman, Hulk, Flash, Wolverine e Capitao America.
4. **Passo 4: Executar uma Missao Tatica (Slides 10, 11 e 12)**:
   - Volte e entre em "Missoes".
   - Aponte para o banner do Desafio de Crise (mostrando de 3 a 5 rounds sorteados).
   - Aponte para o card do vilao: mostre que os numeros do vilao estao ocultos e apenas o atributo da disputa esta visivel.
   - Aponte para a grade 3x5 de escalacao dos seus agentes com avatares circulares.
   - Toque em um heroi para lutar o round: mostre o dialogo do `AwesomeDialog` com o resultado e pontuacoes reais.
   - Mostre que o heroi escalado agora ficou esmaecido e com o texto "Indisponivel" (trava de uso unico do Slide 12).
5. **Passo 5: Concluir a Missao e Demonstrar a Evolucao (+1) no SQLite (Slide 13)**:
   - Jogue os rounds restantes ate o final da missao.
   - Mostre o dialogo final de "Missao Cumprida!" com a foto do heroi sorteado e o anuncio do bonus de +1 ponto.
   - Volte em "Meu Esquadrao", toque no heroi que ganhou o bonus e mostre que o atributo dele aumentou e foi gravado no SQLite!

---

# 8. FUNDAMENTOS DO FLUTTER E ENGENHARIA MOBILE PARA A BANCA

Para demonstrar dominio senior durante a arguicao, esta secao detalha o funcionamento interno do Flutter, da linguagem Dart e dos mecanismos de persistencia utilizados no projeto.

---

### 8.1 Arvore de Widgets, Elementos e Render Objects

O Flutter opera com tres arvores sincronizadas para garantir alto desempenho grafico (60 a 120 FPS):

```
[Widget Tree] (Configuracao Imutavel, Declarativa e Barata)
     |
     v (Infla e instancia)
[Element Tree] (Gerenciador Estrutural de Ciclo de Vida e Estado)
     |
     v (Comanda geometria e desenho)
[RenderObject Tree] (Calculo de Layout, Geometria e Rasterizacao no Canvas)
```

1. **Widget Tree**: Descreve a configuracao visual da interface. Os widgets sao imutaveis (`immutable`). Quando o estado muda e o metodo `build()` e invocado, novos widgets sao instanciados em memoria com custo insignificante.
2. **Element Tree**: Representa a instancia viva do widget na hierarquia. O `Element` retem o vinculo com o `State` (no caso de `StatefulWidget`) e decide se um `RenderObject` precisa ser reconstruido ou apenas atualizado quando um novo widget do mesmo tipo e chave (`Key`) e fornecido.
3. **RenderObject Tree**: Responsavel pelo calculo geometrico estrito e pela pintura na GPU. Segue o principio basico do Flutter: *Constraints go down, Sizes go up, Parents set positions* (Restricoes descem, tamanhos sobem, pais definem posicoes).

No Call-Hero, em [heroes_catalog_page.dart](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/ui/page/heroes_catalog_page.dart), a lista paginada reaproveita os elementos visuais atraves de virtualizacao (ListView), garantindo que apenas os cards visiveis na tela sejam renderizados na GPU.

---

### 8.2 Ciclo de Vida: StatelessWidget vs StatefulWidget

A aplicacao divide seus componentes entre widgets sem estado e com estado:

- **StatelessWidget** (exemplo: [HeroCard](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/ui/widgets/hero_card.dart)): Depende exclusivamente de propriedades imutaveis passadas em seu construtor. Possui apenas o metodo `build()`.
- **StatefulWidget** (exemplo: [MissionBattlePage](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/ui/page/mission_battle_page.dart)): Mantem um objeto `State` persistente ao longo do tempo.

O ciclo de vida completo do `StatefulWidget` no projeto segue a ordem:

1. `createState()`: Cria a instancia viva do estado.
2. `initState()`: Executado exatamente uma vez quando o elemento e inserido na arvore. E o local obrigatorio para inicializar controladores (`PagingController`), listeners e disparar requisicoes iniciais. **Regra de ouro**: `initState()` nunca pode ser marcado como `async`.
3. `didChangeDependencies()`: Invocado imediatamente apos o `initState()` e sempre que um `InheritedWidget` (como o `Provider`) notificar alteracoes.
4. `build()`: Metodo sincrono e puro que retorna a arvore de widgets a ser renderizada. Deve ser livre de efeitos colaterais de rede ou banco.
5. `setState()`: Sinaliza ao framework que o estado interno mudou, agendando uma nova execucao de `build()` para o proximo frame.
6. `dispose()`: Chamado quando o widget e removido definitivamente da arvore. E obrigatorio liberar recursos manuais para evitar **Memory Leaks** (vazamento de memoria).

#### O Padrao Post-Frame Callback
Em [hero_detail_page.dart](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/ui/page/hero_detail_page.dart#L28-L32), para consultar o banco apos a tela ser montada sem travar o primeiro desenho, utilizamos:
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _fetchLatestDetails();
});
```
Isso agenda a execucao assincrona para o instante exato apos o pipeline grafico ter desenhado o primeiro quadro, garantindo uma transicao de tela sem travamentos perceptíveis.

---

### 8.3 O Padrao Provider por Baixo dos Panos (InheritedWidget e O(1) Lookup)

O pacote `provider` adotado em [configure_providers.dart](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/core/di/configure_providers.dart) e uma abstracao robusta construida sobre o mecanismo nativo `InheritedWidget`.

- **Como o Flutter busca o Provider?**: Cada `Element` na arvore mantem internamente um mapa hash `_inheritedWidgets` herdado de seus ancestrais.
- Quando executamos `Provider.of<HeroRepository>(context, listen: false)`, a chamada delega para `context.getElementForInheritedWidgetOfExactType<Provider<HeroRepository>>()`. Essa operacao e resolvida em **tempo constante O(1)**, sem percorrer a arvore de cima a baixo.
- **Diferenca Crucial entre listen: true e listen: false**:
  - `listen: true`: Registra uma dependencia formal. Se o provedor emitir um evento, o widget que chamou sera reconstruido.
  - `listen: false`: Apenas obtem a referencia para invocar metodos imperativos (como cliques de botao ou inicializacoes no `initState`). Evita reconstrucoes desnecessarias e melhora a performance.

---

### 8.4 SQLite em Producao: Transacoes Atomicas (ACID), Batching e ConflictAlgorithm

O plugin `sqflite` gerencia o banco relacional embarcado no aparelho:

1. **Propriedades ACID via Transacao**: Em [hero_dao.dart](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/database/dao/hero_dao.dart#L44-L52), o salvamento em lote utiliza `db.transaction()`:
   ```dart
   await db.transaction((txn) async {
     final batch = txn.batch();
     for (final entity in entities) {
       batch.insert('heroes', entity.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
     }
     await batch.commit(noResult: true);
   });
   ```
   - **Atomicidade**: Se qualquer registro falhar, todo o lote e revertido (Rollback), impedindo corrupcao parcial do catalogo.
   - **Batching**: O `batch.commit(noResult: true)` agrupa todas as instrucoes SQL em uma unica comunicacao com o kernel do SQLite. Sem o batch, cada `insert` dispararia uma gravacao fisica no disco (`fsync`), tornando a insercao de 10 registros ate 100 vezes mais lenta.
2. **ConflictAlgorithm.replace**: Garante a idempotencia. Se um heroi com o mesmo `id` ja existir, os dados sao atualizados sem lancar excecao de violacao de chave primaria.

---

### 8.5 Paginacao Infinita: PagingController e Prevencao de Memory Leaks

O componente [HeroesCatalogPage](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/ui/page/heroes_catalog_page.dart) utiliza o pacote `infinite_scroll_pagination`:

- **Mecanica do PagingController**:
  1. Escuta a rolagem da lista (`ScrollController`). Quando o usuario se aproxima do final (limite de gatilho), invoca o listener cadastrado com a proxima chave de pagina (`pageKey`).
  2. Se a chamada retornar 10 itens (tamanho da pagina), executa `_pagingController.appendPage(newItems, nextPageKey)`.
  3. Se a chamada retornar menos de 10 itens ou lista vazia, executa `_pagingController.appendLastPage(newItems)`, informando que nao ha mais dados a carregar.
  4. Em caso de falha de rede, atribui `_pagingController.error = error`, exibindo o botao de retry na tela.
- **Liberacao de Recursos (`dispose`)**:
  ```dart
  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
  ```
  Se o controlador nao for liberado no `dispose()`, os listeners de rolagem continuam referenciados em memoria global, gerando vazamento de memoria.

---

### 8.6 Persistencia Leve: SharedPreferences e Chaves ISO

O [DailyContractPage](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/ui/page/daily_contract_page.dart) gerencia a regra do Slide 07:

- O `SharedPreferences` persiste pares chave-valor no armazenamento de preferencias do sistema operacional (arquivo XML no Android em `/data/data/<package>/shared_prefs`, e `NSUserDefaults` plist no iOS).
- **Sanitizacao da Chave de Data**: Para comparar se o contrato ja foi utilizado hoje sem problemas com mudancas de hora ou fuso horario, a data atual e formatada de forma estrita em padrao ISO:
  ```dart
  final String today = DateTime.now().toIso8601String().substring(0, 10); // Ex: '2026-10-06'
  ```
  Isso isola o ano, mes e dia, impedindo que diferencas de milissegundos permitam sorteios indevidos no mesmo dia civil.

---

### 8.7 Componentes Graficos Externos: Primer, CachedNetworkImage e AwesomeDialog

1. **primer_progress_bar**:
   - Desenvolvido seguindo as especificacoes do GitHub Primer Design System.
   - Renderiza barras segmentadas proporcionais com cantos arredondados e suporte a multiplas cores de acordo com o atributo de combate.
2. **cached_network_image**:
   - Gerencia cache multinivel:
     - **Nivel 1 (RAM)**: Guarda as imagens decodificadas na memoria volátil para renderizacao instantanea.
     - **Nivel 2 (Disco)**: Persiste os bytes brutos no cache local do dispositivo para sobrevivencia ao modo aviao.
   - Fornece construtores declarativos para `placeholder` (indicador de carregamento) e `errorWidget` (icone de fallback em caso de URL corrompida).
3. **awesome_dialog**:
   - Cria janelas de dialogo modais com transicoes animadas nativas (`AnimType.scale`).
   - Fornece tipagem semantica: `DialogType.success` (icone verde animado), `DialogType.error` (icone vermelho animado) e `DialogType.warning` (icone de alerta).
   - Bloqueia o fechamento acidental ao configurar `dismissOnTouchOutside: false`.

---

# 9. MATRIZ DE CASOS DE BORDA E SEGURANCA OPERACIONAL (EDGE CASES)

Esta secao documenta os cenarios criticos de teste e a forma como o codigo do Call-Hero se comporta defensivamente em cada situacao.

---

### 9.1 Falha de Rede Durante a Rolagem do Catalogo
- **Cenario**: O usuario desce a rolagem do catalogo e o sinal de internet cai no meio da requisicao da pagina 3.
- **Comportamento do Codigo**:
  1. O [ApiClient](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/network/client/api_client.dart) detecta o erro do `Dio` (`DioException`) e lanca uma `NetworkException`.
  2. O [HeroRepositoryImpl](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/repository/hero_repository_impl.dart) intercepta a excecao e tenta consultar o cache local no SQLite via `HeroDao.selectAll()`.
  3. Se a pagina 3 nunca tiver sido baixada e o banco estiver vazio para aquele offset, o erro e propagado para o `_pagingController.error`.
  4. O widget `newPageErrorIndicatorBuilder` renderiza uma mensagem clara informando a indisponibilidade de conexao com um botao "Tentar Novamente", sem fechar o app ou corromper a lista ja carregada.

---

### 9.2 Cliques Repetidos e Concorrentes em "Recrutar"
- **Cenario**: O usuario pressiona o botao "Recrutar para o Esquadrao" varias vezes rapidamente (Double-Tap / Race Condition).
- **Comportamento do Codigo**:
  1. Na primeira invocacao em [DailyContractPage](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/ui/page/daily_contract_page.dart), a variavel de controle `_isRecruiting` e definida como `true`, desabilitando o botao imediatamente no proximo redesenho.
  2. No [HeroRepositoryImpl](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/repository/hero_repository_impl.dart#L71-L82), o metodo `recruitHero()` executa uma checagem sincronizada no banco SQLite:
     ```dart
     final isAlreadyMember = await isHeroInSquad(hero.id);
     if (isAlreadyMember) return false;
     ```
  3. Caso uma segunda execucao ultrapasse o estado da tela, ela e barrada pelo banco, retornando `false` e impedindo registros duplicados na tabela `squad`.

---

### 9.3 Atributos com Valores Empatados e Resolucao via Reduce
- **Cenario**: Um heroi possui pontuacao maxima empatada entre dois atributos (exemplo: Forca 80 e Combate 80).
- **Comportamento do Codigo**:
  - Em [hero_model.dart](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/domain/hero_model.dart#L107-L113), o calculo funcional e definido como:
    ```dart
    stats.entries.reduce((curr, next) => curr.value >= next.value ? curr : next).key
    ```
  - Como o operador utilizado e `>=` (maior ou igual), o acumulador mantem a primeira chave registrada no Map cuja pontuacao nao seja estritamente superada pelas subsequentes.
  - Isso garante **determinismo estrito**: o papel tatico do heroi sempre sera consistente entre reinicializacoes do app, sem flutuacoes aleatorias.

---

### 9.4 Empate de Pontuacao na Rodada da Missao
- **Cenario**: O atributo do heroi do jogador e exatamente igual ao atributo sorteado do vilao (exemplo: Velocidade 60 vs Velocidade 60).
- **Comportamento do Codigo**:
  - O metodo `_fightRound()` em [mission_battle_page.dart](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/ui/page/mission_battle_page.dart#L131-L150) avalia:
    ```dart
    if (heroStat > enemyStat) {
      _victories++;
    } else if (heroStat < enemyStat) {
      _defeats++;
    } else {
      _draws++;
    }
    ```
  - Em caso de igualdade, dispara um `AwesomeDialog` com `DialogType.warning` informando "Empate Tatico!".
  - Na regra final de encerramento do Slide 13 (*"Se venceu mais da metade dos rounds"*), a condicao avaliada e:
    ```dart
    final bool overallVictory = _victories > _defeats && _victories > 0;
    ```
  - Portanto, empates nao computam vitoria para o esquadrao, exigindo que o jogador realmente supere o adversario em numero de rounds.

---

### 9.5 Complexidade Assintotica do Set de Herois Utilizados
- **Cenario**: A tela de batalha precisa verificar se cada um dos herois escalados na grade 3x5 ja foi utilizado na rodada atual.
- **Comportamento do Codigo**:
  - Declarado como `final Set<int> _usedHeroIds = {};`.
  - A operacao `_usedHeroIds.contains(hero.id)` possui complexidade assintotica **O(1)** (busca em tabela hash).
  - Se tivessemos utilizado uma `List<int>`, a complexidade seria **O(N)** para cada item desenhado. Com 15 cards sendo avaliados em cada frame de animacao, o `Set` garante custo computacional zero e eliminacao de qualquer engasgo de renderizacao (jank).

---

### 9.6 Idempotencia da Semeadura de Teste
- **Cenario**: O usuario toca repetidas vezes no botao "Recrutar 5 Especialistas (Teste)" em `MySquadPage`.
- **Comportamento do Codigo**:
  - O metodo `seedTestSquad()` no [HeroRepositoryImpl](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/repository/hero_repository_impl.dart#L104-L121) itera sobre os 5 especialistas e executa:
    ```dart
    final inSquad = await isHeroInSquad(seed.id);
    if (!inSquad) {
      await recruitHero(seed);
    }
    ```
  - Se o especialista ja residir no banco, a insercao e ignorada. Se o esquadrao ja contiver os 5 herois, a operacao e 100% idempotente (nao altera o estado e nao consome vagas excedentes).

---

# 10. BANCO ESTENDIDO DE PERGUNTAS DA BANCA (PERGUNTAS 8 A 15)

Complemento estrategico para assegurar nota maxima na arguicao tecnica do Professor Taniro.

---

### Pergunta 8: "Por que voce implementou dispose() no PagingController em HeroesCatalogPage?"
**Resposta Senior**:
"Professor, no Flutter, controladores que gerenciam listeners e eventos de rolagem, como o `PagingController` do pacote `infinite_scroll_pagination`, mantem vinculos fortes na memoria com o `ScrollController` e os canais de eventos.
Se o usuario sair do Catalogo e retornar a `HomePage`, o widget e destruido, mas se o controlador nao for liberado no metodo `dispose()`, ele continua registrado no garbage collector do Dart, criando um **vazamento de memoria (Memory Leak)**. Implementar o `dispose()` explicitamente garante a liberacao imediata dos recursos alocados."

---

### Pergunta 9: "Explique o mapeamento bidirecional no DatabaseMapper e por que campos como height e weight foram serializados como JSON no SQLite."
**Resposta Senior**:
"O SQLite e um banco de dados relacional que suporta nativamente tipos primitivos (INTEGER, REAL, TEXT, BLOB), mas nao suporta listas aninhadas em colunas.
No modelo de dominio `HeroModel`, atributos como `height`, `weight` e `aliases` sao representados como `List<String>`.
No [DatabaseMapper](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/database/database_mapper.dart), serializamos essas listas em formato JSON utilizando `jsonEncode` na gravacao para a entidade [HeroDatabaseEntity](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/database/entity/hero_database_entity.dart) e deserializamos com `jsonDecode` na leitura.
Essa decisao evitou a criacao de 3 tabelas associativas adicionais com chaves estrangeiras (1:N), simplificando a persistencia local sem perda de tipagem no dominio."

---

### Pergunta 10: "No Slide 07, como voce garante que o usuario nao consiga burlar o sorteio diario alterando a hora do relogio local?"
**Resposta Senior**:
"Em uma aplicacao de producao comercial conectada a um backend proprio, o carimbo de data/hora (timestamp) deve ser validado via cabecalho do servidor HTTP (exemplo: header `Date`).
No escopo academico do projeto baseado em mock local (`json-server`), a restricao foi modelada de forma robusta no cliente atraves do `SharedPreferences`, persistindo o dia civil no formato ISO `yyyy-MM-dd`. Caso o aplicativo seja reiniciado, o sistema checa a chave gravada e impede novos sorteios ate que o sistema registre um novo dia de calendario."

---

### Pergunta 11: "Por que todas as entidades de rede (HeroNetworkEntity) utilizam null-coalescing defensivo em vez de confiar no payload?"
**Resposta Senior**:
"Em desenvolvimento mobile profissional, a camada de rede nunca deve confiar cegamente na integridade dos dados retornados por APIs externas.
Na Superhero API, diversos herois possuem campos como `fullName`, `placeOfBirth` ou arrays de atributos vazios (`null`).
No arquivo [hero_network_entity.dart](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/network/entity/hero_network_entity.dart), implementamos conversores de fabrica com operadores null-coalescing (`?? ''`, `?? 0`, `?? []`).
Isso impede que uma resposta inesperada da API dispare uma `TypeError` em tempo de execucao, blindando o aplicativo contra fechamentos repentinos (crashes)."

---

### Pergunta 12: "O que e a Superhero API e por que o backend/db.json possui 563 herois em vez dos 731 originais?"
**Resposta Senior**:
"A base utilizada e o dataset da Superhero API compilado por Akabab, que padroniza os personagens das principais editoras (Marvel, DC, Dark Horse).
O arquivo original continha 731 registros brutos, muitos com imagens descontinuadas ou registros duplicados. O arquivo `backend/db.json` fornecido contem uma selecao curada de 563 super-herois com metadados e imagens ativas, servindo como a massa de dados homologada para o `json-server`."

---

### Pergunta 13: "Como funciona a animacao e a pilha de navegacao do AwesomeDialog no Flutter?"
**Resposta Senior**:
"O pacote `awesome_dialog` utiliza internamente a pilha de navegacao do `Navigator`, abrindo uma rota modal do tipo `PageRouteBuilder` com uma camada de barreira semi-transparente (`ModalBarrier`).
A animacao `AnimType.scale` e executada por um `ScaleTransition` acoplado a um `AnimationController` nativo.
Quando o dialogo e exibido, ele retem o foco da tela. Quando o usuario clica em um botao de acao, o callback e executado e o modal e removido da pilha (`Navigator.pop()`), restabelecendo o fluxo normal de interacao com a tela hospedeira."

---

### Pergunta 14: "Se a aplicacao escalasse para 100.000 herois, quais seriam os gargalos e como a arquitetura atual se comportaria?"
**Resposta Senior**:
"Nossa arquitetura em camadas esta preparada para escalabilidade:
1. **Rede e UI**: O catalogo utiliza paginacao sob demanda (10 itens por vez) com `infinite_scroll_pagination` e virtualizacao de `ListView`. Mesmo com 100.000 herois na API, a memoria do dispositivo consumira apenas os dados das paginas navegadas.
2. **Gargalo Potencial**: No SQLite local, consultas sem indice poderiam degradar com 100.000 registros. A solucao seria criar um indice explicito na coluna `id` (`CREATE INDEX idx_heroes_id ON heroes(id);`) e paginar as consultas de selecao local com `LIMIT` e `OFFSET` indexados, o que ja esta implementado no `HeroDao`."

---

### Pergunta 15: "Qual a diferenca fundamental entre o padrao Active Record e o padrao Data Mapper / DAO implementado no Call-Hero?"
**Resposta Senior**:
"No padrao **Active Record**, o proprio modelo de dominio e responsavel por saber como se salvar no banco de dados (exemplo: `hero.save()` ou `hero.delete()`), misturando regras de negocio com codigo SQL.
No Call-Hero, adotamos o padrao **Data Mapper / DAO**:
- O [HeroModel](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/domain/hero_model.dart) e um modelo puro de dominio, 100% agnostico de banco ou rede.
- As responsabilidades de persistencia ficam isoladas nos DAOs ([HeroDao](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/database/dao/hero_dao.dart), [SquadDao](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/database/dao/squad_dao.dart)) e a transformacao de dados no [DatabaseMapper](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/data/database/database_mapper.dart).
Isso segue rigorosamente o principio da Responsabilidade Unica (SRP) e permite testar as regras de negocio unitariamente sem precisar instanciar o SQLite."

---

# 11. CHECKLIST MATINAL DE PREPARACAO E COMANDOS DE EXECUCAO

Utilize este roteiro rapido de 3 minutos para validar o ambiente antes da avaliacao.

---

### 11.1 Comandos de Inicializacao do Servidor Mock e Aplicativo

1. **Testar / Iniciar o Backend Mock Local (Opcional se usar Nuvem)**:
   ```bash
   cd backend
   npm install
   npm start
   ```
   O servidor ficara disponivel em `http://localhost:3000/heroes`.

2. **Executar o Aplicativo no Flutter**:
   ```bash
   # Execucao em Web/Chrome (Ideal para exibicao rapida na apresentacao)
   flutter run -d chrome

   # Ou execucao em emulador/dispositivo Android conectado
   flutter run -d android
   ```

---

### 11.2 Como Chavear a URL Base (Render vs Localhost)

O app esta atualmente apontando para a nuvem no Render (`https://call-hero-pdm.onrender.com`), dispensando a necessidade de ligar o servidor Node.js local.
Caso o professor peca para demonstrar o consumo no `localhost` local:

Abra [configure_providers.dart](file:///media/natan_luc/HD%201TB/projetos/call-hero/call-hero-pdm/lib/core/di/configure_providers.dart#L24) e altere a URL base:
```dart
// Para ambiente de nuvem (Padrao atual):
final apiClient = ApiClient(baseUrl: 'https://call-hero-pdm.onrender.com');

// Para ambiente local com json-server:
// final apiClient = ApiClient(baseUrl: 'http://localhost:3000'); // No Chrome
// final apiClient = ApiClient(baseUrl: 'http://10.0.2.2:3000');   // No Emulador Android
```

---

### 11.3 Comandos de Teste e Analise Estatica

Execute os dois comandos de garantia de qualidade para provar que o projeto esta 100% em conformidade:

1. **Analise Estatica de Codigo (Zero Avisos e Zero Erros)**:
   ```bash
   dart analyze --fatal-infos
   ```
   *Resultado esperado: `No issues found!`*

2. **Bateria de Testes Automatizados**:
   ```bash
   flutter test
   ```
   *Resultado esperado: `All tests passed! (6/6)`*

---

### 11.4 Resumo Mental em 3 Frases para Iniciar a Apresentacao

Quando o professor iniciar a avaliacao, abra o app e comece com estas 3 frases de impacto:

1. *"Professor, o Call-Hero foi arquitetado seguindo rigorosamente o padrao Repository com Data Access Objects e politicas estritas de Offline-First, separando o catalogo descartavel da API do estado permanente de evolucao do esquadrao no SQLite."*
2. *"Integramos 100% das bibliotecas exigidas nas especificacoes: infinite_scroll_pagination, primer_progress_bar, cached_network_image, awesome_dialog, shared_preferences e sqflite com transacoes atomicas."*
3. *"O fluxo de missoes cumpre todas as regras do Desafio de Crise: sorteio anti-clone de inimigos, grade tatica 3x5 com trava de uso unico por round e evolucao permanente de +1 atributo para um heroi vencedor gravada diretamente no banco de dados."*

