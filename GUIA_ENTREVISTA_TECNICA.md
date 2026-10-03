# Guia Técnico de Defesa e Entrevista: Projeto Super-Heróis (PDM - UFRN 2026)
## Professor: Taniro C. Rodrigues
## Disciplina: Programação para Dispositivos Móveis

Este documento foi elaborado para servir como **roteiro de estudos e fundamentação teórica para a entrevista técnica individual**. Ele detalha cada classe, método, decisão arquitetural e regra de negócio implementada, explicando não apenas o **o quê**, mas principalmente o **porquê** de cada linha de código sob a ótica da metodologia ensinada pelo professor Taniro.

---

## 1. Visão Sistêmica da Arquitetura do Professor Taniro

O projeto segue uma arquitetura em camadas baseada em **Separação de Responsabilidades (SoC)**, **Repository Pattern** e **Injeção de Dependências com Provider**.

### 1.1 O Pipeline de Dados

```
[API Remota: json-server]         [Banco SQLite: sqflite]
           │                                 │
           ▼                                 ▼
   HeroNetworkEntity                HeroDatabaseEntity
  (Espelho do JSON)                (Espelho da Tabela)
           │                                 │
           ▼                                 ▼
     NetworkMapper                    DatabaseMapper
           │                                 │
           └────────────► HeroModel ◄────────┘
                       (Domínio Puro)
                             ▲
                             │
                     HeroRepositoryImpl
                  (Orquestrador Offline-First)
                             ▲
                             │ (Injetado via Provider)
                             │
                      Camada de Apresentação
                      (Widgets e Pages)
```

### 1.2 Por que temos 3 classes para representar o mesmo herói?
*Pergunta clássica de entrevista:* **"Por que não usar uma única classe `Hero` para a API, o Banco e a Tela?"**
- **Resposta Técnica:** Princípio da Responsabilidade Única (SRP) e Desacoplamento.
  1. **`HeroNetworkEntity` (Rede):** Acoplada à API externa (`json-server`). Se a API mudar uma chave de `fullName` para `full_name`, **apenas o DTO de rede muda**, sem quebrar o banco ou a interface visual.
  2. **`HeroDatabaseEntity` (Banco):** Acoplada aos tipos primitivos do SQLite (TEXT, INTEGER, REAL). O SQLite não entende listas nativas nem objetos aninhados.
  3. **`HeroModel` (Domínio):** O modelo puro de negócio. Ele desconhece se os dados vieram de um arquivo JSON, de um banco SQLite, de memória ou do Firebase. A UI consome exclusivamente esse modelo.

---

## 2. Documentação Detalhada das Classes e Camadas

---

### Camada: Domínio (`lib/domain/`)

O domínio é o núcleo do aplicativo. É escrito em **Dart puro**, sem nenhuma dependência de pacotes de infraestrutura (`sqflite`, `dio`, `http`, etc.).

#### Arquivo: `lib/domain/hero_model.dart`

Representa a entidade de negócio completa do super-herói e suas estruturas agregadas.

---

#### 2.1 Classe `HeroModel`
Representação unificada do herói dentro do aplicativo.

| Atributo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | `int` | Identificador único oficial do herói vindo da Superhero API. |
| `name` | `String` | Nome de guerra do herói (ex: "Batman", "Spider-Man"). |
| `slug` | `String` | Identificador textual amigável para URLs e buscas (ex: "70-batman"). |
| `powerstats` | `Powerstats` | Objeto contendo os 6 valores de atributos de combate. |
| `appearance` | `Appearance` | Objeto com traços físicos e visuais do personagem. |
| `biography` | `Biography` | Objeto com histórico, nome real, editora e alinhamento moral. |
| `work` | `Work` | Objeto com ocupação profissional e base operacional. |
| `connections` | `Connections` | Objeto com afiliações de equipes e parentescos. |
| `images` | `HeroImages` | Objeto com os 4 links de imagem em resoluções diferentes. |

##### Detalhes de Implementação:
1. **Atributos `final` (Imutabilidade):**
   - Todos os atributos são declarados com `final`. Uma vez instanciado, o objeto herói não pode ter seus campos alterados diretamente. Isso impede efeitos colaterais (*side-effects*) onde uma tela altera um dado e corrompe o estado de outra tela.
2. **Construtor `const` com Parâmetros Nomeados (`{ required ... }`):**
   - O modificador `const` permite ao compilador do Dart economizar memória através de instanciação canônica.
   - Parâmetros nomeados com `required` garantem que o desenvolvedor não cometa o erro de instanciar um herói esquecendo atributos obrigatórios ou passando-os na ordem trocada.
3. **Método `copyWith({ ... })`:**
   - **Objetivo:** Como a classe é imutável, o `copyWith` funciona como uma fábrica de clones. Ele cria uma nova instância de `HeroModel`, preservando todos os atributos anteriores, exceto aqueles que foram explicitamente passados como novos argumentos.
   - **Operador `??` (Null-Coalescing):** `name: name ?? this.name`. Avalia a expressão: se a nova variável `name` for nula (o desenvolvedor não quis alterá-la), preserva-se o valor pré-existente (`this.name`).

---

#### 2.2 Classe `Powerstats`
Armazena as 6 estatísticas vitais do herói utilizadas nas regras de combate e renderização de progresso.

| Atributo | Tipo | Finalidade no Projeto |
| :--- | :--- | :--- |
| `intelligence` | `int` | Avaliado em combates da central de missões (Slide 10) e na barra do Primer (Slide 6). |
| `strength` | `int` | Avaliado em combates da central de missões (Slide 10) e na barra do Primer (Slide 6). |
| `speed` | `int` | Avaliado em combates da central de missões (Slide 10) e na barra do Primer (Slide 6). |
| `durability` | `int` | Renderizado nas barras proporcionais do Primer (Slide 6). |
| `power` | `int` | Renderizado nas barras proporcionais do Primer (Slide 6). |
| `combat` | `int` | Avaliado em combates da central de missões (Slide 10) e na barra do Primer (Slide 6). |

##### Detalhes de Implementação:
1. **Método `copyWith({ ... })`:**
   - **Papel na Regra de Negócio (Slide 13):** Ao vencer uma missão, um herói vitorioso é sorteado e recebe **+1 ponto permanente** em um atributo aleatório gravado no banco de dados. O `copyWith` do `Powerstats` permite incrementar esse atributo de forma pontual e segura:
     ```dart
     heroi = heroi.copyWith(
       powerstats: heroi.powerstats.copyWith(
         intelligence: heroi.powerstats.intelligence + 1,
       ),
     );
     ```
2. **Getter `highestStatName`:**
   - **Papel na Regra de Negócio (Slide 8):** A tela "Meu Esquadrão" exige que cada card exiba o **papel tático** ou o **maior atributo** do agente recrutado.
   - **Algoritmo:**
     - Mapeia os 6 atributos com seus rótulos textuais legíveis (`'Intelligence'`, `'Strength'`, etc.).
     - Inicializa `highestEntry` com o primeiro registro do mapa.
     - Itera linearmente comparando os valores (`entry.value > highestEntry.value`).
     - Retorna a chave textual (`highestEntry.key`) que obteve a maior pontuação.

---

#### 2.3 Classe `Appearance`
Modela as características biológicas e visuais do personagem exigidas na tela de detalhes (Slide 6).

| Atributo | Tipo | Motivação |
| :--- | :--- | :--- |
| `gender` | `String` | Gênero do personagem. |
| `race` | `String` | Raça (ex: "Kryptonian", "Human", "Mutant"). |
| `height` | `List<String>` | Lista contendo as duas medidas oficiais da API: `["6'2", "188 cm"]`. |
| `weight` | `List<String>` | Lista contendo as duas medidas oficiais da API: `["210 lb", "95 kg"]`. |
| `eyeColor` | `String` | Cor dos olhos. |
| `hairColor` | `String` | Cor do cabelo. |

---

#### 2.4 Classe `Biography`
Modela a biografia e a história de origem do personagem exigidas no Slide 6.

| Atributo | Tipo | Motivação |
| :--- | :--- | :--- |
| `fullName` | `String` | Nome civil do herói (ex: "Bruce Wayne", "Peter Parker"). |
| `alterEgos` | `String` | Outros alter egos conhecidos. |
| `aliases` | `List<String>` | Lista de apelidos e títulos honoríficos. |
| `placeOfBirth` | `String` | Local de nascimento. |
| `firstAppearance`| `String` | Revista em quadrinhos da primeira aparição histórica. |
| `publisher` | `String` | Editora criadora (ex: "Marvel Comics", "DC Comics"). |
| `alignment` | `String` | Alinhamento moral do personagem ("good", "bad", "neutral"). |

---

#### 2.5 Classes `Work`, `Connections` e `HeroImages`

- **`Work`:**
  - `occupation`: Carreira civil / profissional.
  - `base`: Base de operações táticas (ex: "Batcave, Gotham City").
- **`Connections`:**
  - `groupAffiliation`: Times e ligas que integra (ex: "Justice League", "Avengers").
  - `relatives`: Parentescos diretos.
- **`HeroImages`:**
  - `xs`, `sm`, `md`, `lg`: Quatro URLs com resoluções progressivas.
  - **Decisão Técnica de Performance:** Nos cards da listagem infinita (`infinite_scroll_pagination`), utilizamos tamanhos intermediários (`sm` ou `md`) combinados com `cached_network_image` para economizar memória RAM e largura de banda do dispositivo. Na tela de detalhes (`HeroDetailPage`), carregamos a resolução máxima (`lg`).

---

### Camada: Rede (`lib/data/network/`)

A camada de rede é responsável pela comunicação HTTP externa com o servidor local (`json-server`) e pela desserialização inicial dos dados em DTOs.

#### Arquivo: `lib/data/network/entity/hero_network_entity.dart`

DTO (*Data Transfer Object*) que espelha fielmente o contrato JSON exposto pela Superhero API.

##### Por que precisamos desta classe e não usamos o `HeroModel` diretamente?
- **Tolerância a Falhas e Sanitização de Nulos:** APIs externas do mundo real podem retornar campos ausentes ou `null`. O `HeroNetworkEntity` implementa uma barreira defensiva nos seus métodos `fromJson`: valores nulos são convertidos para padrões seguros (`?? 0`, `?? ''`, `?? []`), impedindo que erros de `Null check operator` quebrem a aplicação Flutter.
- **Isolamento de Contrato:** Se a API alterar o nome de uma propriedade JSON (ex: de `fullName` para `full_name`), apenas o método `fromJson` deste arquivo é ajustado. O resto de todo o aplicativo permanece inalterado.

##### Mapeamento dos Sub-DTOs com os Slides do Trabalho 1:
1. **`HeroNetworkEntity`:** Representa a entidade completa recebida nas requisições paginadas da rota `/heroes` (Slide 5).
2. **`PowerstatsNetworkEntity`:** Mapeia os 6 atributos (`intelligence`, `strength`, `speed`, `durability`, `power`, `combat`). Alimenta as barras de progresso do `primer_progress_bar` (Slide 6) e o motor de combate procedural da Central de Missões (Slides 10 a 12).
3. **`AppearanceNetworkEntity`:** Mapeia dados visuais (gênero, raça, medidas em formatos imperial e métrico, olhos, cabelo). Atende aos requisitos do card do catálogo (Slide 5) e da tela de detalhes (Slide 6).
4. **`BiographyNetworkEntity`, `WorkNetworkEntity`, `ConnectionsNetworkEntity`:** Atendem ao Slide 6, que exige a renderização de **todos os dados disponíveis na API**.
5. **`ImagesNetworkEntity`:** Fornece 4 resoluções de imagem (`xs`, `sm`, `md`, `lg`). Permite economia de memória no catálogo infinito ao usar imagens leves nos cards (`sm` ou `md`), reservando a imagem `lg` para a tela de detalhes.

#### Arquivo: `lib/data/network/entity/http_paged_result.dart`
DTO de envelope paginado que espelha os metadados devolvidos pelo `json-server` (`first`, `prev`, `next`, `last`, `pages`, `items`, `data`). Garante que a lista de heróis seja desserializada com tipagem segura.

#### Arquivo: `lib/data/network/client/api_client.dart`
Cliente de comunicação HTTP baseado na biblioteca `Dio` (Aula 06).
- `getHeroes({int? page, int? limit})`: Faz a requisição `GET /heroes?_page=X&_per_page=Y` para alimentar a paginação infinita (Slide 5). Trata status code `>= 400` lançando `NetworkException`.
- `getHeroById(int id)`: Faz a requisição `GET /heroes/$id` para buscar um herói específico quando necessário (Slide 6 e Slide 7).

#### Arquivo: `lib/data/network/network_mapper.dart`
Mapper da camada de rede baseado na Aula 13 (Padrão Repository).
- `toHero(HeroNetworkEntity entity)`: Converte o DTO de rede em `HeroModel` de domínio. Caso haja inconsistência no mapeamento, captura e lança `MapperException<HeroNetworkEntity, HeroModel>`.
- `toHeroes(List<HeroNetworkEntity> entities)`: Itera e mapeia listas paginadas completas.
- **Justificativa de Arquitetura para a Entrevista:** O `NetworkMapper` é uma classe separada para permitir injeção de dependências via `Provider` e facilitar testes unitários com *mocks*, além de isolar o tratamento de falhas de conversão de dados.

---

### Camada: Banco de Dados Local SQLite (`lib/data/database/`)

Responsável pela persistência relacional offline (`sqflite`), garantindo a execução do app em Modo Avião (Slide 5) e a retenção do esquadrão recrutado de até 15 membros (Slides 7, 8, 9 e 13).

#### Arquivo: `lib/data/database/dao/base_dao.dart`
Classe base abstrata para todos os DAOs (Aula 08).
- **Gerenciamento de Conexão (Lazy Initialization):** O método `getDb()` assegura que a conexão com o SQLite seja aberta apenas uma vez (`_database ??= await _getDatabase()`), evitando abrir múltiplos descritores de arquivo.
- **Criação Atômica de Tabelas (`onCreate` com `batch`):** Utiliza um `db.batch()` para executar a criação da `heroes_table` (cache) e da `squad_table` (esquadrão) dentro de uma única transação atômica. Se uma falhar, nenhuma tabela corrompida é criada.

#### Arquivo: `lib/data/database/dao/hero_dao.dart`
DAO exclusivo do catálogo geral e do cache da API (Slide 5 e Slide 10).
- `selectAll({int? limit, int? offset})`: Permite a leitura paginada dos heróis direto do SQLite para o `infinite_scroll_pagination` quando o app estiver offline.
- `insertAll(List<HeroDatabaseEntity> entities)`: Grava listas de heróis baixadas da rede em lote dentro de uma transação (`db.transaction`), aumentando drasticamente a performance de escrita.
- `selectById(int id)`: Busca direta por chave primária.
- `selectRandom({List<int>? excludedIds})`: Utiliza a função SQL `ORDER BY RANDOM() LIMIT 1` com cláusula `NOT IN` para sortear o Inimigo da Rodada na missão (Slide 10), garantindo que o inimigo sorteado **não seja um herói do esquadrão do jogador**.

#### Arquivo: `lib/data/database/dao/squad_dao.dart`
DAO exclusivo da equipe tática do jogador (Slides 7, 8, 9, 10 e 13).
- `countMembers()`: Executa `SELECT COUNT(*)` para verificar se o time atingiu o limite de **15 membros** (Slide 7 - desabilitar botão de recrutamento) e se possui o mínimo de **5 membros** para autorizar o início de uma missão (Slide 10).
- `selectAllMembers()`: Recupera exclusivamente os heróis recrutados (Slide 8).
- `insertMember(HeroDatabaseEntity entity)`: Grava o novo recruta no SQLite (Slide 7).
- `deleteMember(int id)`: Exclui fisicamente o agente do banco liberando a vaga após confirmação modal do usuário (Slide 9).
- `incrementStat(int heroId, String statName)`: Executa um comando SQL `UPDATE squad_table SET stat = stat + 1 WHERE id = ?` para aplicar a **evolução permanente de +1** no herói sorteado após a vitória na missão (Slide 13).

#### Arquivo: `lib/data/database/database_mapper.dart`
Mapper bidirecional da camada de banco de dados baseado na Aula 13.
- `toHero(HeroDatabaseEntity entity)` e `toHeroes(...)`: Converte registros planos do banco em instâncias ricas e imutáveis de `HeroModel`.
- `toHeroDatabaseEntity(HeroModel hero)` e `toHeroDatabaseEntities(...)`: Converte modelos de domínio de volta para entidades de banco para inserção no SQLite.
- **Tratamento de Exceções:** Envolve os mapeamentos com `try/catch` disparando `MapperException<HeroDatabaseEntity, HeroModel>` para proteger o aplicativo contra corrupção de tipos.

---

---

### Camada: Repositório (`lib/data/repository/`)

O Repositório atua como o **árbitro de dados** da aplicação. Ele isola a camada de apresentação de saber se os dados estão vindo da rede (`ApiClient`), do cache do catálogo (`HeroDao`) ou do banco do esquadrão (`SquadDao`).

#### Arquivo: `lib/data/repository/hero_repository.dart`
Interface abstrata definindo as operações permitidas:
- `getHeroes({required int page, required int limit})`: Catálogo paginado.
- `getHeroById(int id)`: Detalhes do herói.
- `getSquadMembers()`: Membros do esquadrão.
- `recruitHero(HeroModel hero)`: Recrutamento com validação de até 15 heróis.
- `dismissHero(int id)`: Dispensa do esquadrão.
- `getSquadCount()`: Contagem atual de membros.
- `evolveHeroStat({required int heroId, required String statName})`: Evolução de atributo (+1 permanente).

#### Arquivo: `lib/data/repository/hero_repository_impl.dart`
Implementação concreta que orquestra a política de cache **Offline-First**:
1. **Fluxo do Catálogo Paginado (`getHeroes`):**
   - Primeiro, consulta o SQLite via `heroDao.selectAll(limit: limit, offset: offset)`.
   - Se encontrar dados (`dbEntities.isNotEmpty`), converte via `databaseMapper.toHeroes` e retorna imediatamente (sem gastar rede nem travar o app em Modo Avião).
   - Se não houver dados locais, faz a requisição remota com `apiClient.getHeroes(page, limit)`.
   - Converte os dados recebidos via `networkMapper.toHeroes`.
   - Persiste os heróis no banco local via `heroDao.insertAll` em lote (transação atômica).
   - Retorna os heróis para a UI.
2. **Regra de Negócio de Recrutamento (`recruitHero`):**
   - Consulta `squadDao.countMembers()`.
   - Se `count >= 15`, a operação é bloqueada e retorna `false` (limite máximo do Slide 8 e 9).
   - Se houver vaga, converte via `databaseMapper.toHeroDatabaseEntity(hero)` e salva no SQLite, retornando `true`.
3. **Evolução de Atributo (`evolveHeroStat`):**
   - Atualiza o atributo do herói no SQLite chamando `squadDao.incrementStat`, persistindo o `+1` ganho na missão.

---

### Camada: Injeção de Dependências (`lib/core/di/`)

#### Arquivo: `lib/core/di/configure_providers.dart`
Centraliza a criação da árvore de dependências utilizando o pacote `provider` (Aulas 02 e 12).
- **Inversão de Controle (IoC):** Nenhuma classe cria suas próprias dependências com `new`. Todas recebem suas instâncias prontas pelo construtor.
- **Configuração Dinâmica de Host:**
  - Emuladores Android mapeiam o host local em `http://10.0.2.2:3000`.
  - Desktop (Linux/macOS/Windows) e Web acessam em `http://localhost:3000`.
  - O código detecta dinamicamente a plataforma sem quebrar a execução.
- **Registro de Contratos e Implementações:**
  - Registra os DAOs, Mappers, ApiClient e registra o repositório como `Provider<HeroRepository>` e `Provider<HeroRepositoryImpl>`, permitindo que a interface do usuário dependa da abstração.

---

### Camada: Apresentação e Telas (`lib/ui/`)

Desenvolvida com **Material Design 3**, foco em responsividade, clareza visual e fidelidade absoluta aos slides da disciplina.

#### Arquivo: `lib/ui/widgets/hero_card.dart`
Widget reutilizável para exibição de agentes em listas:
- Renderiza miniatura com `CachedNetworkImage` (com placeholders e tratamento de falhas).
- Exibe nome do herói, alinhamento moral (Bom = Verde, Mau = Vermelho, Neutro = Âmbar).
- Exibe o badge de **Especialidade Tática** (`hero.highestStatName`), calculado dinamicamente com Programação Funcional (`reduce`).
- Navega para `HeroDetailPage` ao toque.

#### Arquivo: `lib/ui/page/home_page.dart` (Slide 4)
Ponto de entrada do usuário com layout tático e 4 cartões de navegação:
1. **Agentes:** Catálogo completo com rolagem infinita.
2. **Contrato Diário:** Sorteio diário de recrutamento.
3. **Meu Esquadrão:** Gestão dos até 15 heróis recrutados.
4. **Missões:** Central tática de combate e evolução de heróis.

#### Arquivo: `lib/ui/page/heroes_catalog_page.dart` (Slide 5)
Catálogo paginado utilizando a biblioteca `infinite_scroll_pagination`:
- `PagingController<int, HeroModel>` gerencia as chaves de página e o carregamento sob demanda.
- Consome `heroRepository.getHeroes(page: pageKey, limit: 10)`.
- Suporta recarregamento via ação na AppBar (`controller.refresh()`).

#### Arquivo: `lib/ui/page/hero_detail_page.dart` (Slide 6)
Visualização em alta resolução do agente:
- Imagem em alta definição (`hero.images.lg`).
- **6 Barras Proporcionais de Atributos:** Inteligência, Força, Velocidade, Durabilidade, Poder e Combate (valores de 0 a 100 com `LinearProgressIndicator` estilizado).
- Fichamento completo de biografia, aparência física, ocupação e afiliações.
- Ação para dispensar agente quando acessado a partir do esquadrão, com diálogo de confirmação via `AwesomeDialog` (Slide 9).

#### Arquivo: `lib/ui/page/daily_contract_page.dart` (Slide 7)
Mecanismo de contrato diário:
- **Persistência de Estado com `SharedPreferences`:** Armazena a data do último sorteio (`yyyy-MM-dd`) e o ID do herói sorteado.
- Se o usuário já sorteou hoje, recupera o herói do dia e bloqueia sorteios repetidos.
- Botão "Recrutar para o Esquadrão": aciona `repo.recruitHero()`.
- **Trava de Segurança dos 15 Membros:** Se o esquadrão atingiu 15 heróis, exibe `AwesomeDialog` avisando que a capacidade máxima foi atingida.

#### Arquivo: `lib/ui/page/my_squad_page.dart` (Slides 8 e 9)
Gestão dos recrutas do jogador:
- Indicador visual superior de capacidade (ex: `7 / 15 Agentes`).
- Lista os heróis salvos no SQLite com seus papéis táticos (`Especialista em ...`).
- Botão de lixeira individual e toque no card para detalhes com dispensa.
- **Confirmação com `AwesomeDialog`:** Modal de advertência com opções "Cancelar" e "Dispensar", removendo fisicamente do banco após confirmação.

#### Arquivo: `lib/ui/page/mission_battle_page.dart` (Slides 10 a 13)
Sala de crise e sistema de combate tático:
1. **Portão de Segurança (Slide 10):** Se o jogador tiver menos de 5 heróis, a tela exibe um aviso bloqueando a missão até que 5 agentes sejam recrutados.
2. **Sorteio da Crise:** Sorteia de **3 a 5 rodadas**.
3. **Mecânica da Rodada (Slide 11):**
   - Apresenta um adversário surpresa e o **atributo desafiado** sorteado (ex: "DESAFIO: COMBATE = 85").
   - **Grade 3x5 de Seleção de Agentes:** Exibe os heróis do esquadrão disponíveis.
   - **Regra de Uso Único:** Cada agente só pode ser utilizado em uma única rodada da missão. Heróis já utilizados ficam opacos e bloqueados para clique.
4. **Resolução do Combate e Evolução Permanente (Slides 12 e 13):**
   - Compara o atributo do agente escolhido com o do vilão (`agentValue >= villainValue`).
   - Se o agente vencer:
     - Ganha o ponto da rodada.
     - Executa `repo.evolveHeroStat(heroId: agent.id, statName: testedStat)`, somando **+1 definitivo no atributo no SQLite**!
     - Exibe `AwesomeDialog` de vitória com a evolução do herói.
   - Se o agente perder: exibe modal de derrota e computa o ponto do vilão.
5. **Encerramento da Missão:** Modal com o placar final e opção para iniciar uma nova missão tática.

---

## 3. Checklist de Implementação do Trabalho 1

- [x] **Domínio Puro:** `lib/domain/hero_model.dart` (CopyWith, Imutabilidade, Funcional `reduce`).
- [x] **Rede (DTOs):** `hero_network_entity.dart`, `http_paged_result.dart` (Defesa de tipos).
- [x] **Rede (Client HTTP):** `lib/data/network/client/api_client.dart` (`Dio`, log interceptors, tratamento de status >= 400).
- [x] **Rede (Mapper):** `lib/data/network/network_mapper.dart` (`MapperException`).
- [x] **Persistência Local (Entidade & Contrato):** `lib/data/database/entity/hero_database_entity.dart` (JSON serialização para atributos multivalorados).
- [x] **Persistência Local (DAOs & BaseDao):** `base_dao.dart` (Batch atômico), `hero_dao.dart` (Transações), `squad_dao.dart` (Contagem, dispensa e incremento de stat).
- [x] **Persistência Local (Mapper):** `database_mapper.dart` (Bidirecional com `MapperException`).
- [x] **Repositório (Offline-First):** `hero_repository.dart` e `hero_repository_impl.dart` (Cache de heróis, controle de 15 agentes e evolução).
- [x] **Injeção de Dependências:** `configure_providers.dart` (Provider com suporte multi-plataforma).
- [x] **Camada Visual - HeroCard:** `hero_card.dart` (`CachedNetworkImage` e especialidade tática).
- [x] **Camada Visual - Home:** `home_page.dart` (4 botões táticos de navegação - Slide 4).
- [x] **Camada Visual - Catálogo:** `heroes_catalog_page.dart` (`infinite_scroll_pagination` - Slide 5).
- [x] **Camada Visual - Detalhes:** `hero_detail_page.dart` (Barras proporcionais e biografia - Slide 6).
- [x] **Camada Visual - Contrato Diário:** `daily_contract_page.dart` (`SharedPreferences`, trava de 15 membros - Slide 7).
- [x] **Camada Visual - Meu Esquadrão:** `my_squad_page.dart` (Listagem, capacidade, `AwesomeDialog` - Slides 8 e 9).
- [x] **Camada Visual - Missões:** `mission_battle_page.dart` (Trava de 5 membros, 3 a 5 rodadas, grade 3x5, 1 uso por missão, combate de atributos, `AwesomeDialog`, evolução permanente +1 no SQLite - Slides 10 a 13).
- [x] **Estabilidade e Qualidade:** `flutter analyze` executando com **Zero erros e Zero warnings**.

