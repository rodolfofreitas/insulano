---
id: T-005
titulo: Actualizar o addon Beehave de 2.8.3 para 2.9.3
fase: 0
estado: feito
tipo: infra
depende_de: [T-003]
---

## Objectivo
O addon Beehave fica na última versão estável para Godot 4, sem regressões de comportamento.

## Ler antes
- `game/addons/beehave/plugin.cfg`, notas de versão em `https://github.com/bitbrain/beehave/releases`

## Critérios de aceitação
- [x] `game/addons/beehave/plugin.cfg` indica `version="2.9.3"` (código obtido com `gh release download v2.9.3 -R bitbrain/beehave --archive tar.gz`)
- [x] `scripts/verify.sh --visual` sem FALHOU; screenshot com o personagem a agir
- [x] Mudanças de API que afectem `game/beehave/*.gd` corrigidas e listadas no Relatório
- [x] `docs/assets-licencas.md` e `agent_docs/tech_stack.md` com a versão nova

## Fora de âmbito
- Reescrever a behavior tree

## Prova exigida
- `docs/proof/T-005-beehave-2.9.3.png`

## Relatório

**Origem do código:** `gh release download v2.9.3 -R bitbrain/beehave --archive tar.gz`, extraído para
o scratchpad da sessão. O `plugin.cfg` da release já traz `version="2.9.3"`.

**Método de actualização:** `diff -rq` entre `game/addons/beehave/` (2.8.3) e o tarball (2.9.3) mostrou
o mesmo conjunto de ficheiros (nenhum novo, nenhum removido dentro de `addons/beehave/`); só o
`.gd`/`.cfg`/`.gd` conteúdo mudou. Copiei o conteúdo novo para dentro do repositório com
`rsync -a --exclude='*.uid' --exclude='*.import' <tarball>/addons/beehave/ game/addons/beehave/`,
**sem** tocar nos ficheiros `.uid` nem `.import`: os `.uid` gravam a identidade dos scripts e o
`guy.tscn` referencia vários deles por `uid://...` (`beehave_tree.gd`, `sequence.gd`, `selector.gd`,
`selector_random.gd`, `blackboard.gd`, etc.); a release upstream gera UIDs novos e diferentes a cada
build, e sobrescrever os `.uid` locais teria desligado essas referências da cena sem qualquer aviso
de lint (só apareceria como `Failed to load script` no arranque). Os `.import` são cache local do
Godot, regenerados pelo próprio `--import`; não vêm da release para o repositório.

**Diferença de comportamento nas versões (2.8.3 -> 2.9.3), lida no diff completo dos `.gd`:**
- `BeehaveTree`: `_process_internally()` privado passou a `tick()` público que devolve `int`; ganhou
  `ProcessThread.MANUAL`; `interrupt()` de `Composite` e `Sequence`/`Selector` ficou mais fino (evita
  interromper duas vezes o filho a correr, e interrompe também os filhos "stale" entre ticks); os
  filhos passam a ser chamados via `_safe_tick()` (valida que `tick()` devolve `int`, senão `push_error`
  e assume `FAILURE`); `Blackboard.blackboard` (Dictionary exportado) passa a `duplicate()` no set,
  para não partilhar a mesma Dictionary entre instâncias; `get_debug_data()` sanitiza Nodes/Resources
  antes de os mandar para o depurador (evita erro de marshalling); novo hook `process_interrupt` em
  `BeehaveNode.interrupt()` manda uma mensagem extra ao depurador.
- Nenhuma destas mudanças toca a assinatura que as folhas próprias usam: `ActionLeaf`/`ConditionLeaf`
  continuam a existir, `tick(actor: Node, blackboard: Blackboard) -> int` continua a assinatura
  esperada, as constantes `SUCCESS`/`FAILURE`/`RUNNING` (enum sem nome em `BeehaveNode`) não mudaram
  de posição nem de valor, `Blackboard.get_value`/`set_value`/`erase_value` mantêm a mesma assinatura.

**Mudanças de API que afectem `game/beehave/*.gd`: nenhuma.** Confirmado por leitura do diff completo
dos ficheiros do addon tocados pelas folhas próprias (`blackboard.gd`, `nodes/beehave_node.gd`,
`nodes/leaves/{leaf,action,condition}.gd`, `nodes/composites/{composite,sequence,selector,
selector_random}.gd`) e por `git diff --stat -- game/beehave/` a devolver vazio: nenhum ficheiro
próprio precisou de tocar. Em particular, `find_usable_for_need_condition.gd:90` (o `erase` sem
guarda de tipo da T-006) não foi tocado; confirmei com `git stash` do addon e uma corrida do
`boot_smoke.gd` na versão 2.8.3 antes de reverter o stash que o erro
`Attempted to erase an object into a TypedArray` já existia identicamente na 2.8.3 (mesmo texto,
mesmo `at:`), portanto é o bug pré-existente da T-006, não uma regressão desta tarefa; deixei-o como
está, fora de âmbito.

**Ruído no log, comparado à baseline 2.8.3 (corrida lado a lado com `git stash`):** a 2.9.3 acrescenta
uma nova chamada a `BeehaveDebuggerMessages.process_interrupt()` dentro de `BeehaveNode.interrupt()`
(inexistente na 2.8.3), que em modo headless imprime mais duas linhas `ERROR: Can't send message.
No active debugger` por corrida (22 -> 24 ocorrências no `boot_smoke`). É o mesmo padrão de ruído já
documentado em `AGENTS.md` secção 10 ("O Beehave imprime `Can't send message. No active debugger`
em headless: ruído conhecido, ignorar"), só que agora com mais um sítio de origem; não é um erro novo
de classe diferente e não faz o `verify.sh` falhar (o portão só vigia `SCRIPT ERROR`, `Parse Error`,
`GUT ERROR`, `Failed to load script`, `Invalid call`). As linhas `ERROR: Capture not registered:
'beehave'.` e `WARNING: 6 ObjectDB instances were leaked at exit` também já estavam presentes,
idênticas, na 2.8.3.

**Comandos corridos e resultado:**
- `$(mise which godot) --headless --path game --import`: sem erros, classes novas registadas.
- `scripts/verify.sh --visual`: `VEREDICTO: PASSOU` (docs, backlog, pytest, lint, import, gut 20/20,
  boot, visual).
- `scripts/verify.sh --full`: `VEREDICTO: PASSOU` (inclui `llm` com `pass_rate: 1.0` e `export` com o
  binário Linux a arrancar 600 frames sem erros de script).
- Screenshot: `reports/verify-latest.png`, copiado e inspeccionado em
  `docs/proof/T-005-beehave-2.9.3.png`: personagem visível a meio da ilha, barra de Fome a 95%,
  pose de andar (frame da animação `walk`), confirmando que a árvore de comportamento continua a
  agir com o addon novo.

**Documentação actualizada:** `docs/assets-licencas.md` (Beehave 2.8.3 -> 2.9.3, estado "por registar"
-> "registado"); `agent_docs/tech_stack.md` (linha da tabela e data de verificação no topo).
`CHANGELOG.md` recebeu uma entrada em `[Não lançado] / Alterado`.

**Auto-adversário (Lei 6), 3 ataques:**
1. *A API pública mudou de assinatura de forma a partir uma folha própria?* Não: `git diff --stat --
   game/beehave/` está vazio, e o `import`/`gut`/`boot_smoke` exercitam directamente essas folhas
   (o `boot_smoke` corre a árvore completa durante segundos, os testes de integração chamam
   `FundUsableForNeedCondition.tick()` directamente); se a assinatura tivesse mudado de forma
   incompatível, o `import` teria dado `Failed to load script`/`Parse Error`, apanhado pelo grep de
   erros do `verify.sh`.
2. *Os `.uid` ficaram inconsistentes com o `guy.tscn`?* Não: confirmei por `cat` que os `.uid` dos
   ficheiros referenciados por `uid://` em `guy.tscn` (`beehave_tree.gd`, `sequence.gd`, `selector.gd`,
   `selector_random.gd`, `blackboard.gd`) continuam com o mesmo conteúdo de antes da actualização
   (`git status` não os lista como modificados), e o `--import` e o `verify.sh --visual`/`--full`
   confirmaram a cena a carregar e a correr sem `Failed to load script`.
3. *A actualização escondeu uma regressão de comportamento visível?* Não: o `boot_smoke` continua a
   reportar "fome" a descer (personagem a agir) e deslocação máxima na order dos 400-700 px entre
   corridas (variação esperada, documentada em `AGENTS.md` secção 10:
   `NavigationServer2D.map_get_random_point` não obedece à seed); o `export` corrido a seguir arrancou
   o binário Linux 600 frames sem erro de script; o screenshot mostra o personagem a meio de uma
   animação de movimento.

Pergunta de bolso: se a actualização tivesse partido a árvore de comportamento (ex. uma folha a deixar
de correr, ou a cena a não carregar), a verificação apanhava? Sim: o `import` falharia com
`Failed to load script` se um `.uid` tivesse ficado inconsistente com a cena, o `gut`/`boot_smoke`
falhariam a compilar ou a correr se `ActionLeaf`/`ConditionLeaf`/as constantes tivessem mudado, e o
screenshot mostraria o personagem estático em vez de numa pose de movimento.

**Não verificado:** o editor visual do Beehave (painel de depuração gráfico dentro do editor Godot)
não foi aberto interactivamente; o portão headless não o exercita e a tarefa não o exige. As mudanças
na pasta `debug/` (grafos, blackboard viewer) são só para esse painel e não afectam a árvore em
execução.

**Estado:** `feito`.
