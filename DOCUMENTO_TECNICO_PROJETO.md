# Documento Técnico e Arquitetural do Projeto: Super-Heróis
## Trabalho Prático 1 - Desenvolvimento para Dispositivos Móveis (UFRN 2026)

---

## 1. Visão Geral e Conceito do Projeto

Este documento representa a fonte única da verdade e a especificação completa de engenharia de software para o **Trabalho Prático 1** da disciplina de Desenvolvimento para Dispositivos Móveis.

O aplicativo tem como tema um centro tático de recrutamento, inspeção e combate com super-heróis. O objetivo técnico é construir uma aplicação Flutter **offline-first**, de **alta performance** e **responsiva**, consumindo dados de uma API REST local mockada com `json-server` a partir da base oficial de heróis (`akabab/superhero-api`), persistindo dados em banco relacional SQLite local (`sqflite`), gerenciando cache de imagens em disco/memória e aplicando fielmente a arquitetura ensinada pelo professor baseada em:
- **Repository Pattern**
- **Data Access Objects (DAO)**
- **Mappers Bidirecionais de Domínio, Rede e Banco**
- **Injeção de Dependências com Provider** (`configure_providers.dart`)

---

## 2. Diagnóstico da Base Atual e Mapeamento de Mudanças

O repositório base fornecido implementa um catálogo simples de filmes (`Movie`). Abaixo está o contraste detalhado entre o esqueleto existente e as modificações estruturais que realizaremos para atender 100% aos requisitos do trabalho:

### 2.1 Comparativo Arquitetural de Arquivos

| Camada | Arquivo Atual (Filmes) | Novo Arquivo Planejado (Heróis / Esquadrão) | Modificação Necessária |
| :--- | :--- | :--- | :--- |
| **Domain** | `lib/domain/movie.dart` | `lib/domain/hero_model.dart` | Criar modelo completo de herói: `powerstats`, `appearance`, `biography`, `work`, `connections`, `images`. |
| **Domain** | *(Inexistente)* | `lib/domain/squad_member.dart` | Modelo para membro do esquadrão com atributos mutáveis e papel tático. |
| **Domain** | *(Inexistente)* | `lib/domain/mission.dart` | Modelos para `Mission`, `RoundChallenge`, `CombatResult` e atributos de teste. |
| **Data / Network** | `lib/data/network/client/api_client.dart` | `lib/data/network/client/api_client.dart` | Alterar endpoint para buscar heróis (`/heroes` ou `/all`) com parâmetros `_page` e `_limit`. |
| **Data / Network** | `lib/data/network/entity/movie_network_entity.dart` | `lib/data/network/entity/hero_network_entity.dart` | DTO que espelha exatamente a resposta JSON da Superhero API. |
| **Data / Network** | `lib/data/network/network_mapper.dart` | `lib/data/network/network_mapper.dart` | Converter `HeroNetworkEntity` para `HeroModel` de domínio. |
| **Data / Database** | `lib/data/database/entity/movie_database_entity.dart` | `lib/data/database/entity/hero_database_entity.dart` | Entidade SQLite para a tabela `heroes` (cache local da API). |
| **Data / Database** | *(Inexistente)* | `lib/data/database/entity/squad_database_entity.dart` | Entidade SQLite para a tabela `squad_members` (máximo 15 membros). |
| **Data / Database** | `lib/data/database/dao/movie_dao.dart` | `lib/data/database/dao/hero_dao.dart` | DAO para cache de heróis: inserção em lote, busca paginada, busca por ID e sorteio aleatório. |
| **Data / Database** | *(Inexistente)* | `lib/data/database/dao/squad_dao.dart` | DAO para membros: inserção (com trava <= 15), exclusão, listagem e atualização (+1 powerstat). |
| **Data / Database** | `lib/data/database/database_mapper.dart` | `lib/data/database/database_mapper.dart` | Conversores entre entidades do SQLite e classes de domínio. |
| **Data / Repository** | `lib/data/repository/movie_repository.dart` | `lib/data/repository/hero_repository.dart` | Interface do repositório expondo métodos de API, banco, esquadrão e missões. |
| **Data / Repository** | `lib/data/repository/movie_repository_impl.dart` | `lib/data/repository/hero_repository_impl.dart` | Implementação com lógica **Offline-First**: tenta API e faz cache no SQLite; se falhar/offline, serve do SQLite. |
| **Core / DI** | `lib/core/di/configure_providers.dart` | `lib/core/di/configure_providers.dart` | Injeta `ApiClient`, `HeroDao`, `SquadDao`, `NetworkMapper`, `DatabaseMapper` e `HeroRepositoryImpl`. |
| **UI / Pages** | `lib/ui/page/movies_list_page.dart` | `lib/ui/page/home_page.dart` | Tela inicial (Hub) com 4 botões táticos de acesso aos módulos. |
| **UI / Pages** | *(Inexistente)* | `lib/ui/page/heroes_catalog_page.dart` | Catálogo geral com `infinite_scroll_pagination` e `cached_network_image`. |
| **UI / Pages** | *(Inexistente)* | `lib/ui/page/hero_detail_page.dart` | Detalhes completos com barras de progresso `primer_progress_bar`. |
| **UI / Pages** | *(Inexistente)* | `lib/ui/page/daily_contract_page.dart` | Sorteio 1x ao dia retido via `shared_preferences` com botão de recrutamento. |
| **UI / Pages** | *(Inexistente)* | `lib/ui/page/my_squad_page.dart` | Lista dos até 15 agentes salvos localmente com maior atributo em destaque. |
| **UI / Pages** | *(Inexistente)* | `lib/ui/page/squad_agent_detail_page.dart` | Detalhes do membro e botão de dispensa com diálogo `awesome_dialog`. |
| **UI / Pages** | *(Inexistente)* | `lib/ui/page/mission_battle_page.dart` | Batalha de 3 a 5 rounds, grid 3x5, bloqueio de herói repetido e premiação de +1 stat via `awesome_dialog`. |

---

## 3. Matriz de Dependências Obrigatórias (Conforme o PDF)

Todas as dependências exigidas no PDF da avaliação foram catalogadas com suas respectivas funções:

| Dependência | Versão Recomendada | Finalidade Obrigatória |
| :--- | :--- | :--- |
| `json-server` | `npm` (Local) | Servidor mock REST executando localmente com o payload dos heróis. |
| `infinite_scroll_pagination` | `^5.1.1` | Paginação infinita na tela de Catálogo Geral de Agentes. |
| `cached_network_image` | `^4.0.0` | Cache de imagens em memória e disco com placeholders. |
| `primer_progress_bar` | Mais recente | Barras de progresso proporcionais para os 6 powerstats na tela de detalhes. |
| `awesome_dialog` | Mais recente | Caixas de diálogo modais de confirmação de dispensa e resultado da missão. |
| `shared_preferences` | `^2.3.5` | Persistência leve da data e do identificador do herói sorteado no dia. |
| `sqflite` + `path` | `^2.4.4` | Banco de dados local relacional para o catálogo offline e esquadrão. |
| `provider` | `^6.1.5+1` | Injeção de dependências e reatividade de dados seguindo o modelo do professor. |
| `dio` | `^5.11.1` | Requisições HTTP para a API mock com controle de timeouts. |

---

## 4. Regras de Negócio e Requisitos de Sistema

### 4.1 Catálogo Geral e Funcionamento Offline-First
- O app deve consumir os heróis servidos pelo `json-server` com paginação em lotes (ex.: 10 itens por página).
- Ao receber os dados da API, o aplicativo deve salvá-los imediatamente em cache no SQLite.
- Na ausência de conexão à rede ou com o servidor desligado, o aplicativo deve automaticamente recuperar e exibir os heróis a partir do banco de dados local.
- Os cards devem apresentar: nome, resumo de atributos, características visuais de aparência e miniatura com cache.
- O clique no card deve navegar para a Tela de Detalhes do Agente.

### 4.2 Tela de Detalhes do Agente
- Exibir a imagem do herói em alta resolução com `CachedNetworkImage`.
- Exibir todos os dados disponíveis na API:
  - Biografia (nome completo, alter egos, apelidos, editora, alinhamento).
  - Aparência (gênero, raça, altura, peso, olhos, cabelo).
  - Trabalho e Conexões (ocupação, base, afiliações).
- Apresentar obrigatoriamente barras de progresso via `primer_progress_bar` para cada um dos 6 powerstats:
  - Intelligence
  - Strength
  - Speed
  - Durability
  - Power
  - Combat
- Os dados devem ser lidos preferencialmente da API ou do banco local em modo offline.

### 4.3 Tela de Contrato Diário (Recrutamento)
- Uma vez ao dia, o aplicativo sorteia aleatoriamente um herói da base geral.
- O card de apresentação diária deve conter apenas: nome, imagem e powerstats.
- Utilizar `shared_preferences` (ou SQLite) para salvar a data do sorteio (`YYYY-MM-DD`) e o ID do herói convocado no dia. Reabrir o app na mesma data deve mostrar o mesmo herói sem re-sortear.
- Botão "Recrutar para o Esquadrão":
  - Adiciona o herói à tabela `squad_members` no banco local.
  - O esquadrão suporta no máximo 15 agentes.
  - Se o usuário já possuir 15 agentes, o botão deve ser desabilitado ou exibir mensagem impeditiva informando que a capacidade máxima foi atingida.

### 4.4 Tela Meu Esquadrão e Detalhes do Meu Agente
- Lista exclusivamente os heróis (até 15) recrutados e salvos no banco local.
- Exibe cards com nome, papel tático (ou maior atributo em destaque) e miniatura com `CachedNetworkImage`.
- O toque no card leva à tela de Detalhes do Meu Agente.
- A tela de detalhes exibe a carta do herói e o botão "Dispensar do Esquadrão".
- Ao clicar em dispensar, deve-se disparar obrigatoriamente uma caixa de diálogo personalizada com `awesome_dialog` para confirmação da ação antes da exclusão física no SQLite.

### 4.5 Central Tática de Missões e Motor de Batalha
- O esquadrão precisa ter no mínimo 5 agentes recrutados para autorizar o início de uma missão.
- O sistema sorteia proceduralmente um Desafio de Crise contendo de 3 a 5 rounds.
- Cada round exige um atributo dominante de teste (`Intelligence`, `Strength`, `Speed` ou `Combat`).
- O sistema sorteia um oponente do catálogo geral como o "Inimigo da Rodada". Se o oponente pertencer ao esquadrão do jogador, deve-se sortear novamente para evitar duplicação.
- Apresentação do Desafio: exibir imagem e nome do inimigo (mantendo seus atributos ocultos) e o nome do atributo em disputa.
- Escalação: o jogador seleciona 1 de seus agentes disponíveis em um grid 3x5 de miniaturas com fotos circulares e nomes.
- Regra de Exclusividade: cada agente do esquadrão só pode ser enviado para uma única rodada por missão. Agentes já usados ficam bloqueados para seleção nos próximos rounds da mesma missão.
- Resolução da Rodada:
  - Atributo do Herói > Inimigo = Sucesso/Vitória na rodada.
  - Atributo do Herói < Inimigo = Falha/Derrota na rodada.
  - Atributos iguais = Empate tático.
- O app atualiza o placar e avança para o próximo round até concluir a campanha.
- Fim da Missão e Diálogo com `awesome_dialog`:
  - Exibe sumário com total de vitórias e derrotas.
  - Se venceu mais da metade dos rounds: disparar `awesome_dialog` do tipo `DialogType.success` ("Missão Cumprida!"). É sorteado um dos heróis que participou da vitória, que ganha **+1 permanentemente** em um powerstat aleatório gravado no SQLite. A foto do herói beneficiado é exibida.
  - Se perdeu a maioria: disparar `awesome_dialog` do tipo `DialogType.error` ou `warning` ("Operação Fracassada!") com imagem temática de derrota.

---

## 5. Roteiro Fásico de Implementação e Execução

### Fase 1: Infraestrutura de Dados, Mock API & Modelagem
- **Passo 1:** Baixar o arquivo `all.json` oficial da Superhero API (`https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json`).
- **Passo 2:** Configurar pasta `backend/` contendo o `db.json` preparado para o `json-server`.
- **Passo 3:** Adicionar dependências faltantes ao `pubspec.yaml`:
  - `shared_preferences`
  - `primer_progress_bar`
  - `awesome_dialog`
- **Passo 4:** Criar entidades de domínio em `lib/domain/`:
  - `hero_model.dart` com submodelos imutáveis para powerstats, appearance, biography, images, etc.
- **Passo 5:** Criar DTOs de rede em `lib/data/network/entity/`:
  - `hero_network_entity.dart` com suporte a serialização JSON.
- **Validação:** Subir o `json-server` (`json-server --watch backend/db.json --port 3000`) e testar paginação: `curl "http://localhost:3000/heroes?_page=1&_limit=2"`.

### Fase 2: Arquitetura de Dados, Offline-First & Repositório
- **Passo 1:** Implementar esquema relacional no SQLite com `sqflite`:
  - Tabela `heroes`: cache de heróis baixados da API.
  - Tabela `squad_members`: agentes recrutados (limite 15), armazenando stats com eventuais evoluções de +1.
- **Passo 2:** Criar os DAOs em `lib/data/database/dao/`:
  - `HeroDao`: `insertAll`, `selectAll(limit, offset)`, `selectById`, `count`, `selectRandom(excludedIds)`.
  - `SquadDao`: `insertMember(hero)`, `deleteMember(id)`, `selectAllMembers()`, `countMembers()`, `incrementStat(heroId, statName)`.
- **Passo 3:** Implementar conversores:
  - `NetworkMapper`: DTO -> `HeroModel`.
  - `DatabaseMapper`: `HeroDatabaseEntity` <-> `HeroModel`.
- **Passo 4:** Implementar `HeroRepositoryImpl`:
  - Orquestração de fallback: requisita da API, salva no `HeroDao` e retorna; se houver falha de rede, lê direto do `HeroDao`.
- **Passo 5:** Atualizar `ConfigureProviders.createDependencyTree()` registrando os DAOs, Mappers e o `HeroRepositoryImpl` na árvore do `Provider`.
- **Validação:** Realizar inserção e leitura com simulação de corte de conexão.

### Fase 3: Hub Principal & Catálogo Geral com Paginação
- **Passo 1:** Criar `HomePage` com layout tático e 4 botões de navegação:
  1. Agentes
  2. Contrato Diário
  3. Meu Esquadrão
  4. Missões
- **Passo 2:** Criar tela de Catálogo Geral com `infinite_scroll_pagination` (`PagedListView`).
- **Passo 3:** Criar componente `HeroCard`:
  - Miniatura com `CachedNetworkImage` (`memCacheWidth` e `memCacheHeight` calibrados para economia de memória).
  - Nome, resumo de atributos e detalhes de aparência.
  - Toque navega para a Tela de Detalhes do Agente.
- **Validação:** Rolar a lista continuamente e validar carregamento página a página. Cortar a internet e checar se o catálogo continua renderizando do banco.

### Fase 4: Detalhes do Herói & Recrutamento Diário
- **Passo 1:** Criar Tela de Detalhes do Agente:
  - Imagem em alta resolução com `CachedNetworkImage`.
  - Exibição de todos os dados da API (biografia, conexões, trabalho, aparência).
  - 6 barras de progresso proporcionais usando `primer_progress_bar` para intelligence, strength, speed, durability, power e combat.
- **Passo 2:** Criar Tela de Contrato Diário:
  - Lógica via `shared_preferences`: armazenar data do último sorteio (`daily_date`) e ID do herói (`daily_hero_id`).
  - Card tático contendo apenas nome, imagem e powerstats.
  - Botão "Recrutar para o Esquadrão":
    - Verifica contagem no `SquadDao`. Se já possuir 15 agentes, desabilita o botão ou emite alerta de esquadrão lotado.
    - Se houver vaga, persiste o agente no banco local.
- **Validação:** Conferir a proporção visual das barras no Primer, reabrir o app para validar retenção do sorteio no dia e testar a barreira de 15 agentes.

### Fase 5: Gestão do Esquadrão (Meu Esquadrão & Descarte)
- **Passo 1:** Criar Tela Meu Esquadrão:
  - Listagem dos agentes salvos na tabela `squad_members` (até 15).
  - Indicador numérico de vagas preenchidas.
  - Cálculo e exibição do maior atributo de cada herói como papel tático no card.
- **Passo 2:** Criar Tela de Detalhes do Meu Agente:
  - Apresentação em formato de carta tática com stats atuais.
  - Botão "Dispensar do Esquadrão".
- **Passo 3:** Integração com `awesome_dialog`:
  - Ao clicar em dispensar, acionar modal de confirmação (`DialogType.warning`).
  - Se confirmado pelo usuário, executar a remoção no SQLite e atualizar a tela.
- **Validação:** Recrutar membros, checar cálculo do maior atributo e executar dispensa com cancelamento e confirmação pelo diálogo animado.

### Fase 6: Sistema de Batalha Tática (Missões & Rounds)
- **Passo 1:** Tela de inicialização da Missão:
  - Validação estrita: se o esquadrão tiver menos de 5 agentes, bloquear o início com mensagem instrutiva.
- **Passo 2:** Gerador do Desafio de Crise:
  - Sortear entre 3 e 5 rounds.
  - Para cada round, sortear um atributo dominante (`Intelligence`, `Strength`, `Speed` ou `Combat`) e um oponente da base geral (re-sorteando caso o oponente pertença ao esquadrão do jogador).
- **Passo 3:** Interface de Combate e Escalação:
  - Exibir card do inimigo com foto, nome e atributo em disputa (valores numéricos ocultos).
  - Grid 3x5 de seleção de agentes com fotos circulares e nomes.
  - Trava de agente utilizado: agentes escalados em rounds anteriores ficam desabilitados.
- **Passo 4:** Resolução matemática e avanço de rounds:
  - Comparar atributos, calcular resultado e avançar até o encerramento.
- **Passo 5:** Feedback final com `awesome_dialog`:
  - Se venceu mais da metade dos rounds: modal de sucesso (`DialogType.success`), sorteio de 1 dos heróis vitoriosos, incremento de **+1 permanente** em atributo no SQLite e exibição da foto do herói.
  - Se perdeu a maioria: modal de erro (`DialogType.error` ou `warning`) com imagem de derrota.
- **Validação:** Testar a barreira de 5 membros, o bloqueio de heróis já jogados na rodada e a persistência do stat incrementado após a vitória.

### Fase 7: Polimento Visual, Responsividade, Performance & Validação
- **Passo 1:** Responsividade e Layout:
  - Uso de `LayoutBuilder`, `MediaQuery` e `SingleChildScrollView` para garantir adaptação a telas compactas e grandes sem erros de `RenderFlex overflowed`.
- **Passo 2:** Otimização de Performance:
  - Limitar tamanho de decodificação de imagem em memória nos cards (`memCacheWidth` e `memCacheHeight`).
  - Usar `Provider` com seletores e escuta pontual para evitar rebuilds desnecessários.
- **Passo 3:** Checklist Geral de Avaliação e Simulação de Apresentação.

---

## 6. Checklist de Validação para Apresentação em Sala de Aula

Antes da apresentação individual ao professor, verifique cada um dos pontos abaixo:

- [ ] **Servidor Local Ativo:** O `json-server` roda na máquina e o app conecta via `http://10.0.2.2:3000` (no emulador) ou IP da rede local (no aparelho físico).
- [ ] **Paginação Infinita (`infinite_scroll_pagination`):** A listagem de heróis carrega de 10 em 10 continuamente sem travamentos.
- [ ] **Cache de Mídia (`cached_network_image`):** As fotos dos cards e telas de detalhes abrem instantaneamente após o primeiro carregamento.
- [ ] **Barras de Atributo (`primer_progress_bar`):** A tela de detalhes desenha com clareza as 6 barras de atributos de cada agente.
- [ ] **Diálogos Interativos (`awesome_dialog`):** Diálogo presente na dispensa de agentes do esquadrão e nos resultados (vitória/derrota) da missão.
- [ ] **Controle Diário (`shared_preferences`):** Sorteio de 1 agente por dia retido mesmo após fechar e reabrir o app.
- [ ] **Persistência Local (`sqflite`):** Catálogo de heróis e tabela do esquadrão salvos em banco de dados relacional.
- [ ] **Regra do Esquadrão (Limite de 15):** Botão de recrutamento bloqueado ao atingir 15 agentes.
- [ ] **Regra da Missão (Mínimo de 5):** Bloqueio ao tentar iniciar missão com menos de 5 agentes no time.
- [ ] **Regra do Round (Uso Único):** Heróis já escalados em um round ficam bloqueados para os próximos rounds da mesma missão.
- [ ] **Regra de Evolução (+1 permanente):** Herói sorteado na vitória recebe +1 ponto definitivo em um atributo salvo no SQLite.
- [ ] **Comprovação Offline-First:** Ativar o Modo Avião no celular/emulador e provar que todas as telas e dados continuam navegáveis.
