# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/pt-PT/1.1.0/). Versionamento: SemVer.
Entradas em linguagem de utilizador, não de commit. Cada tarefa acrescenta a sua em `[Não lançado]`.

## [Não lançado]

### Adicionado
- Projecto jogável em `game/`, a partir do Guy on Island, a correr em Godot 4.7.2.
- Portão de verificação único (`scripts/verify.sh`): documentação, backlog, lint, testes, arranque, imagem, LLM e export.
- Export templates 4.7.2 instalados e export Linux provado: `scripts/export.sh` produz
  `dist/linux/insulano.x86_64` e o binário arranca sem `SCRIPT ERROR`, `Parse Error` nem
  `Failed to load script` (os três padrões vigiados pelo portão), tanto headless (600 frames)
  como em modo janela real na sessão Hyprland (10 s, sem crash). Uma regressão latente exposta
  por esta corrida (erro de motor `TypedArray`/`erase`, fora dos três padrões vigiados) ficou
  registada na T-006, ainda não corrigida (fora do âmbito desta entrada).
- Testes automáticos: 20 testes GUT, 40 testes dos scripts, smoke de arranque de 30 s simulados.
- Captura de ecrã real de tamanho fixo, para provas visuais.
- Eval das frases do LLM local (latência, português de Portugal, comprimento, conteúdo proibido).
- Backlog de 33 tarefas em 6 fases, com critérios de aceitação verificáveis.
- Harness para agentes: AGENTS.md, tech design com contratos, agentes e skills do Claude Code.

### Alterado
- Renderer passa a Compatibility (OpenGL 3): mais leve para um protector de ecrã 2D.
- Feriados passam de YAML para JSON, com Carnaval e Páscoa calculados a partir da data da Páscoa.
- Modelo por defeito passa a `llama3.1:8b`, o único instalado, com limiares de latência medidos.
- Addon Beehave actualizado de 2.8.3 para 2.9.3 (código de `gh release download v2.9.3 -R bitbrain/beehave`):
  correcções internas de interrupção de árvore e sanitização do blackboard para o depurador, sem
  mudança de comportamento visível nem de contrato para as folhas próprias em `game/beehave/`.

### Corrigido
- Documentação que indicava modelos, versões e endpoints que não correspondiam à máquina real.
- Lint, formatação e documentação dos 21 ficheiros de GDScript herdados do Guy on Island
  (`scripts/gd_baseline.txt` fica vazia): cabeçalhos e docstrings novos, variáveis exportadas
  `fishingRod`, `searchArea` e `navigationAgent` renomeadas para `snake_case` (cenas actualizadas),
  sem alterar o comportamento do jogo.
- Seis bugs latentes do código herdado, cada um com teste de regressão (`test_regression_<bug>`):
  `search_area.body_exited` ligava ao handler errado e os objectos nunca saíam de
  `objects_in_area`; `NeedReplentishingUsable.get_satisfying_needs()` rebentava com
  `max_replentish_value == 0`; `FundUsableForNeedCondition` devolvia `FAILED` (erro global) em
  vez de `FAILURE` quando não havia objectos; `SetDeltaOnBlackboardAction` imprimia o delta a
  cada tick; `FishingAction.spawn_fish` usava um índice `-1` que apanhava o filho errado quando
  o personagem era o primeiro filho do pai; `fishing_spot.gd` desenhava o círculo de debug
  também fora do editor.
- Erro de motor `TypedArray`/`erase` (T-006): `FundUsableForNeedCondition._body_exited_area`
  chamava `objects_in_area.erase(body)` sem confirmar `body is UsableObject`, o que disparava
  `ERROR: Attempted to erase an object into a TypedArray` sempre que um corpo qualquer (não
  `UsableObject`) saía da área de busca. Regressão exposta pela T-004 depois da T-003 ligar o
  sinal correcto; corrigida com a mesma guarda de tipo que `_body_entered_area` já usava.
