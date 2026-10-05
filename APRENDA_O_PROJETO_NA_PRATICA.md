# APRENDA O PROJETO CALL-HERO NA PRATICA (GUIA DIDATICO DEFINITIVO)

Disciplina: Programacao para Dispositivos Moveis (PDM)  
Professor: Taniro C. Rodrigues  
Objetivo: Compreender a logica e o funcionamento real do aplicativo de forma simples, visual e intuitiva para defender o projeto com total seguranca na entrevista.

---

## 1. O QUEBRA-CABECA DO PROJETO EM 3 MINUTOS

Imagine o aplicativo Call-Hero como se fosse um **Restaurante de Super-Herois**:

1. **A Cozinha (Banco de Dados SQLite e API Externa):**
   - Na despensa local (SQLite), guardamos os herois que ja foram baixados e os herois que você recrutou para o seu esquadrao.
   - No fornecedor externo (API na nuvem / json-server), existem centenas de herois prontos para serem entregues quando a despensa estiver vazia.

2. **O Garcom Chefe (O Repositorio - `HeroRepositoryImpl`):**
   - Quando a tela pede comida ("me da 10 herois para a lista"), ela nao fala com o banco nem com a internet. Ela fala com o Garcom.
   - O Garcom e inteligente: ele primeiro olha na despensa (SQLite). Se ja tiver comida la, ele entrega na hora (funciona ate sem internet). Se a despensa estiver vazia, ele liga para o fornecedor (API), guarda uma copia na despensa para a proxima vez, e entrega o prato para a mesa.

3. **Os Tradutores (Os Mappers):**
   - O fornecedor fala ingles (JSON da API: `HeroNetworkEntity`).
   - A despensa so aceita caixas quadradas (Tabelas do SQLite: `HeroDatabaseEntity`).
   - O cliente na mesa so quer comer comida de verdade (Modelo de Dominio: `HeroModel`).
   - Os Mappers sao os tradutores que convertem de um formato para o outro sem misturar as coisas.

4. **O Salao do Restaurante (A Interface do Usuario - Telas Flutter):**
   - As 4 mesas principais:
     - Mesa 1: Catalogo de Agentes (rolagem infinita).
     - Mesa 2: Contrato Diario (sorteio de 1 heroi por dia).
     - Mesa 3: Meu Esquadrao (gestao dos herois recrutados, maximo 15).
     - Mesa 4: Missoes Taticas (combate de atributos e evolucao +1).

---

## 2. DICIONARIO DESCOMPLICADO: O QUE SIGNIFICA CADA NOME TECNICO?

Se o professor Taniro apontar para uma palavra no codigo, aqui esta a explicacao em portugues simples:

### O que e DTO (Data Transfer Object)?
- E um pacote de entrega. Pense em uma caixa de encomenda da Amazon. A caixa nao e o produto; ela serve apenas para transportar o produto do caminhao da transportadora ate a sua casa.
- No projeto: `HeroNetworkEntity` e o pacote que vem da internet. `HeroDatabaseEntity` e o pacote que vai para o SQLite.

### O que e um Mapper?
- E o conversor. Ele pega a caixa da Amazon (DTO), abre, tira o heroi de dentro e transforma no heroi de verdade (`HeroModel`) que a tela vai desenhar.

### O que e um DAO (Data Access Object)?
- E o funcionario exclusivo do banco de dados. So ele sabe falar SQL (`SELECT`, `INSERT`, `UPDATE`, `DELETE`). Se outra classe quiser mexer no banco, tem que pedir para o DAO.
- No projeto: `HeroDao` cuida da tabela do catalogo; `SquadDao` cuida da tabela do esquadrao.

### O que e o Repository?
- E o gerente geral de dados. A tela nao sabe se o heroi veio da internet, do banco de dados local ou da memoria. A tela so pede: `repository.getHeroes()`. O repositorio decide a melhor estrategia para buscar.

### O que e o Provider?
- E o entregador de servicos da aplicacao. Em vez de cada tela criar uma nova conexao com o banco e com a internet, o Provider entrega o `HeroRepository` pronto para a tela usar atraves do comando:
  `Provider.of<HeroRepository>(context, listen: false)`.

### O que e `copyWith`?
- Como criamos classes imutaveis (onde nada pode ser alterado depois de criado), o `copyWith` serve para fazer um clone do heroi mudando apenas uma coisa (por exemplo, subindo o Speed de 60 para 61).

### O que e `reduce`?
- E uma forma inteligente do Dart de comparar todos os itens de uma lista e ficar apenas com o vencedor. Nos usamos o `reduce` para olhar os 6 atributos do heroi e descobrir qual e o maior (seu papel tatico), sem precisar escrever um monte de `if` e `else`.

### O que e `SharedPreferences`?
- E um pequeno bloco de notas do celular onde guardamos textos curtos e numeros simples. Nos usamos para anotar a data do sorteio de hoje (ex: "2026-10-05") para garantir que o jogador so recrute 1 heroi por dia.

---

## 3. AS 4 CENAS DO JOGO: O QUE ACONTECE NO CODIGO PASSO A PASSO?

### CENA 1: "O usuario abriu a tela de Agentes e rolou para baixo"

O que acontece por tras dos panos:
1. A tela `HeroesCatalogPage` liga o seu `PagingController`.
2. O `PagingController` chama: `repository.getHeroes(page: 1, limit: 10)`.
3. O `HeroRepositoryImpl` calcula o offset: `(1 * 10) - 10 = 0` (pega os primeiros 10 herois).
4. O repositorio pergunta ao `HeroDao`: "Tem esses 10 herois no SQLite?".
   - **Se sim (Modo Offline / Segunda vez que abre):** O `HeroDao` faz `SELECT * FROM heroes LIMIT 10 OFFSET 0`. O `DatabaseMapper` converte e a tela ja desenha na hora, sem gastar internet.
   - **Se nao (Primeira vez que abre):** O `ApiClient` faz um `GET` no servidor. A lista chega em formato JSON (`HeroNetworkEntity`). O `NetworkMapper` converte para `HeroModel`. O `HeroDao.insertAll` salva todos no SQLite em lote (`db.batch`).
5. A tela recebe a lista e o `HeroCard` desenha cada heroi.
6. A foto do heroi e baixada e guardada no disco pelo `CachedNetworkImage`. Se desligar o Wi-Fi agora, a foto continua aparecendo.

---

### CENA 2: "O usuario abriu o Contrato Diario e clicou em Recrutar"

O que acontece por tras dos panos:
1. A tela `DailyContractPage` consulta o `SharedPreferences` e le a chave `daily_contract_last_date`.
2. Ela compara a data do arquivo com a data de hoje (`DateTime.now()`).
   - Se for o mesmo dia: ela le o ID salvo e carrega o mesmo heroi do dia. O usuario nao pode dar sorteio infinito.
   - Se for um novo dia: ela sorteia um numero aleatorio de 1 a 560, busca o heroi, salva a data de hoje no `SharedPreferences` e guarda o ID dele.
3. O usuario ve o card com apenas nome, imagem e os 6 atributos (como exigido no Slide 7).
4. O usuario clica no botao **Recrutar para o Esquadrao**:
   - O codigo chama `squadDao.countMembers()`.
   - Se ja tiver 15 membros: o botao fica travado e exibe o alerta "Esquadrao Cheio".
   - Se tiver menos de 15: o `squadDao.insertMember` grava o heroi na tabela `squad` do SQLite.
   - O contador de vagas atualiza na hora para (ex: `6 / 15`).

---

### CENA 3: "O usuario abriu Meu Esquadrao para ver o time"

O que acontece por tras dos panos:
1. A tela `MySquadPage` chama `repository.getSquadMembers()`.
2. O `SquadDao` executa `SELECT * FROM squad ORDER BY name ASC`.
3. Para cada heroi retornado, o card exibe o **Papel Tatico**. Como ele sabe o papel tatico?
   - O codigo le o getter `hero.highestStatName`.
   - O `highestStatName` pega os valores de Inteligencia, Forca, Velocidade, Durabilidade, Poder e Combate.
   - O operador funcional `reduce` compara os 6 e devolve o nome do maior (ex: se Forca for 100, ele escreve "Papel Tatico: Forca").
4. Se o usuario tocar no icone de lixeira ou entrar nos detalhes e clicar em **Dispensar do Esquadrao**:
   - Um modal do `AwesomeDialog` se abre na tela perguntando: "Deseja dispensar este agente?".
   - Se o usuario confirmar, o `squadDao.deleteMember(id)` apaga o heroi da tabela `squad`, liberando uma vaga imediatamente no esquadrao.

---

### CENA 4: "O usuario iniciou uma Missao Tatica, venceu e ganhou +1 no atributo"

Esta e a regra mais rica do projeto (Slides 10 a 13). Veja o passo a passo:

1. **A Trava de Seguranca:**
   - A tela `MissionBattlePage` checa: `squad.length < 5`.
   - Se o jogador tiver menos de 5 herois, a tela bloqueia o combate com um aviso: "Voce precisa de pelo menos 5 herois para iniciar uma missao".
2. **O Sorteio do Desafio de Crise:**
   - O app sorteia aleatoriamente de 3 a 5 rounds (`_random.nextInt(3) + 3`).
   - Para cada round, ele sorteia um vilao que **obrigatoriamente nao pode ser do esquadrao do jogador**. Como fazemos isso? Com o laco:
     ```dart
     do {
       enemyId = _random.nextInt(560) + 1;
     } while (squadIds.contains(enemyId));
     ```
     Se o ID sorteado for de um heroi seu, ele sorteia outro na hora.
   - Ele sorteia qual atributo sera disputado naquele round (ex: "Speed").
3. **O Confronto do Round:**
   - A tela esconde os numeros do vilao (ele nao mostra quanto de Speed o vilao tem).
   - A tela mostra os herois do seu esquadrao em uma grade 3x5 de fotos circulares.
   - O jogador toca no seu velocista (ex: Flash).
   - O Flash entra no conjunto `_usedHeroIds`. A foto dele fica com opacidade 0.35 e ele nao pode ser usado em mais nenhuma rodada desta missao (regra de uso unico do Slide 12).
4. **O Resultado da Rodada:**
   - Compara o Speed do seu heroi com o do vilao:
     - Se o seu for maior: Exibe "Seu heroi venceu!" (`DialogType.success`), soma +1 vitoria e guarda o heroi na lista de herois que venceram.
     - Se o vilao for maior: Exibe "Seu heroi perdeu!" (`DialogType.error`) e soma +1 derrota.
     - Se empatarem: Exibe "Empate Tatico!" (`DialogType.warning`), soma +1 empate e nao adiciona rodadas extras.
5. **O Fim da Missao e o Bonus:**
   - Quando terminam os rounds, o app analisa: as vitórias foram maiores que as derrotas?
   - Se venceu mais da metade:
     - Dispara o `AwesomeDialog` com "Missao Cumprida!".
     - Sorteia um dos herois que venceu rounds (ex: Flash).
     - Sorteia um atributo aleatorio (ex: Combat).
     - Executa no SQLite:
       ```sql
       UPDATE squad SET combat = combat + 1 WHERE id = 263
       ```
     - O Flash agora tem +1 permanente gravado no banco de dados.
     - O dialogo mostra a foto do Flash e a mensagem: "Bonus: +1 no atributo Combat!".

---

## 4. O QUE RESPONDER SE O PROFESSOR APONTAR PARA UMA LINHA ESPECIFICA?

### Se ele apontar para `hero_database_entity.dart` nas linhas 136-141:
- **Pergunta:** *"Por que tem `jsonDecode` aqui dentro de uma entidade de banco?"*
- **Sua Resposta:**  
  *"Professor, o SQLite so aceita tipos primitivos como texto e numero. Ele nao possui um tipo de Lista nativo. Como os campos de altura (`height`) e peso (`weight`) da API sao listas com as medidas em pes e centimetros, nos convertemos a lista em texto usando `jsonEncode` na hora de salvar, e reconstruimos a lista de volta com `jsonDecode` na hora de ler."*

### Se ele apontar para `base_dao.dart` na linha do `batch`:
- **Pergunta:** *"Para que serve esse `db.batch()` no `onCreate`?"*
- **Sua Resposta:**  
  *"Serve para criar as duas tabelas (`heroes` e `squad`) dentro de uma unica transacao atomica. Em vez de abrir o disco duas vezes, o batch junta os dois comandos e executa tudo junto. Se um falhar, nada pela metade e gravado."*

### Se ele apontar para `hero_repository_impl.dart` no metodo `getHeroes`:
- **Pergunta:** *"Como funciona o seu Offline-First aqui?"*
- **Sua Resposta:**  
  *"Ele faz cache-first, professor. Primeiro ele roda um `SELECT` no SQLite usando o `limit` e `offset` da pagina. Se tiver registros salvos, ele ja devolve direto para a tela sem tocar na internet. Se o banco local estiver vazio, ai sim ele usa o `ApiClient` com Dio para baixar da API, salva tudo no SQLite com o `insertAll` em lote, e entrega para a tela."*

### Se ele apontar para `mission_battle_page.dart` na grade de herois:
- **Pergunta:** *"Como voce garantiu que o heroi so luta uma vez por missao?"*
- **Sua Resposta:**  
  *"Eu criei um conjunto `Set<int> _usedHeroIds`. Quando o usuario confirma o heroi no round, o ID dele entra nesse Set. Na hora de desenhar a grade 3x5, se o ID estiver no Set, o card fica com opacidade reduzida e o evento de clique `onTap` fica nulo, impedindo que o jogador escale o mesmo agente duas vezes."*

### Se ele apontar para o `Provider.of`:
- **Pergunta:** *"Por que voce colocou `listen: false` aqui?"*
- **Sua Resposta:**  
  *"Porque estamos dentro de uma acao pontual (uma busca ou clique de botao). O `listen: true` serve apenas quando queremos que o widget fique escutando mudancas continuas de estado para se reconstruir. Usar `listen: false` evita reconstrucoes desnecessarias e economiza processamento."*

---

## 5. RESUMO FINAL PARA VOCE REVISAR ANTES DE ENTRAR NA SALA

1. O projeto tem **5 telas**: Inicio (Home), Catalogo (Agentes), Contrato Diario, Meu Esquadrao e Missoes.
2. O projeto usa **2 tabelas SQLite**: `heroes` (cache do catalogo) e `squad` (herois que voce recrutou).
3. O projeto tem **2 travas de seguranca**: maximo de 15 agentes no esquadrao e minimo de 5 para iniciar missao.
4. O combate e baseado em **comparacao de atributos**: o maior numero vence; empate nao pontua para ninguem.
5. A recompensa e **definitiva no banco**: o heroi vencedor ganha +1 no SQLite e mantem esse ponto para sempre.

Com este entendimento, voce nao precisa decorar linhas de codigo. Voce agora sabe **como o sistema funciona como um todo** e pode responder a qualquer pergunta com total clareza e autoridade.
