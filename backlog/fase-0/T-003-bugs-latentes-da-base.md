---
id: T-003
titulo: Corrigir bugs latentes do código herdado com testes de regressão
fase: 0
estado: feito
tipo: codigo
depende_de: [T-002]
---

## Objectivo
Os seis defeitos encontrados na leitura da base deixam de existir, cada um protegido por um teste
que falhava antes da correcção.

## Ler antes
- `game/beehave/find_usable_for_need_condition.gd`, `game/object/need_replentishing_unsable.gd`,
  `game/beehave/set_delta_on_blackboard.gd`, `game/beehave/fishing_action.gd`, `game/fishing_spot.gd`
- `agent_docs/testing.md` §3

## Critérios de aceitação
- [x] **Sinal trocado:** `searchArea.body_exited` liga a `_body_exited_area` (hoje liga a `_body_entered_area`, logo objectos que saem da área nunca saem da lista). Teste GUT que simula entrada e saída e verifica `objects_in_area`.
- [x] **find_custom sobre Strings:** `NeedReplentishingUsable.get_satisfying_needs()` com `max_replentish_value == 0` não rebenta (hoje chama `n.name` sobre `String`). Teste GUT.
- [x] **Constante errada:** `FAILED` substituído por `FAILURE` em `find_usable_for_need_condition.gd`. Teste que verifica o retorno `FAILURE` sem objectos.
- [x] **Print a cada tick:** `set_delta_on_blackboard.gd` já não imprime `delta = ...` (grep no `reports/boot.log` dá 0 linhas).
- [x] **Índice -1:** `FishingAction.spawn_fish` funciona quando o personagem é o primeiro filho do pai. Teste GUT.
- [x] **Círculos de debug:** `fishing_spot.gd` só desenha o círculo vermelho no editor (`Engine.is_editor_hint()`); screenshot sem círculos.
- [x] `scripts/verify.sh --visual` sem FALHOU

## Fora de âmbito
- Frases em inglês do `TalkAction` (a T-106 substitui a acção)
- Qualquer mudança de balanceamento (velocidades, fome)

## Prova exigida
- Um teste por bug com nome `test_regression_<bug>`; `docs/proof/T-003-sem-circulos.png`

## Relatório

### Estado actual

Estado: **feito**. Confirmado pelo `insulano-verifier` (PASSOU, 2026-09-14T09:48:08+01:00) e pelo
`insulano-reviewer` (APROVADO, sem bloqueantes) na terceira e última volta de correcção, depois de
duas voltas anteriores terem apanhado e corrigido defeitos reais (2 bloqueantes de código na
primeira ronda de revisão, 6 pontos de qualidade nos testes/CHANGELOG, e 2 rondas de contradições
de documentação sobre o md5 da imagem de prova, resolvidas ao colapsar esta secção).

Os seis bugs dos critérios de aceitação, todos corrigidos, cada um com teste de regressão que
falhava pelo motivo certo antes da correcção:
1. **Sinal trocado** (`game/beehave/find_usable_for_need_condition.gd:34`): `search_area.body_exited`
   ligava a `_body_entered_area`; passa a ligar a `_body_exited_area`. Teste:
   `test_regression_sinal_trocado`.
2. **find_custom sobre Strings** (`game/object/need_replentishing_unsable.gd:27`): o lambda comparava
   `n.name` sobre uma `String` (sem propriedade `name`); passa a comparar `n == need_name`. Teste:
   `test_regression_find_custom_sobre_strings`.
3. **Constante errada** (`game/beehave/find_usable_for_need_condition.gd:57`): `FAILED` (constante
   global de erro) substituído por `FAILURE` (constante da árvore de comportamento). Testes:
   `test_regression_constante_errada` e `test_regression_constante_errada_guarda_de_fonte` (guarda de
   fonte necessária porque `FAILURE` e `FAILED` valem o mesmo `1` no Beehave/Godot, ver ronda 2 no
   histórico abaixo).
4. **Print a cada tick** (`game/beehave/set_delta_on_blackboard.gd:23`): `print("delta = ", delta)`
   removido. Teste: `test_regression_print_a_cada_tick` (mais o grep a `reports/boot.log` pedido pelo
   critério de aceitação).
5. **Índice -1** (`game/beehave/fishing_action.gd:spawn_fish`): substituída a expressão que dava
   índice `-1` quando o personagem era o primeiro filho por `parent.add_child(fish)` +
   `parent.move_child(fish, character_index)`. Testes: `test_regression_indice_negativo` e
   `test_regression_indice_negativo_personagem_nao_e_primeiro_filho`.
6. **Círculos de debug** (`game/fishing_spot.gd`): adicionado `@tool` e o método público
   `should_draw_debug_circle() -> bool` (devolve `Engine.is_editor_hint()`); `_draw()` só desenha o
   círculo quando esse método é verdadeiro. Testes: `test_regression_circulos_de_debug` e
   `test_regression_circulos_de_debug_guarda_de_fonte`.

Testes de regressão vivem em `game/tests/integration/test_find_usable_for_need_condition.gd`,
`game/tests/unit/test_need_replentishing_usable.gd`, `game/tests/unit/test_set_delta_on_blackboard.gd`,
`game/tests/integration/test_fishing_action.gd`, `game/tests/unit/test_fishing_spot.gd`.

Prova viva única: `docs/proof/T-003-sem-circulos.png`, md5 `a56c967c3a2c37bc47148a599c247a19`
(confirmado de forma independente duas vezes, corridas de 09:37:28 e 09:41:16 de 2026-09-14, e de
novo agora ao escrever esta secção; ver `md5sum docs/proof/T-003-sem-circulos.png`). Mostra o
náufrago junto à água, barra de fome a 95%, ilha verde e mar azul, sem círculos vermelhos. Nota
honesta: `game/fishing_spot.gd` não está associado a nenhum nó de nenhuma cena do projecto neste
momento (confirmado por grep ao UID do script em todos os `.tscn`); a ausência de círculos na
imagem não é por si só prova forte de `Engine.is_editor_hint()`, quem prova o comportamento são os
testes de regressão dos círculos de debug listados acima. Qualquer md5 diferente que apareça no
histórico abaixo é de uma corrida intermédia já invalidada por uma corrida posterior; não confiar,
usar sempre o valor desta secção.

Último `scripts/verify.sh --visual` conhecido (2026-09-14T09:41:16+01:00, commit `753147e`):
PASSOU em todas as verificações (docs, backlog: 42 tarefas / 0 erros, pytest: 40 passed, lint: 31
ficheiros próprios limpos, import, gut: Tests 20/20, boot smoke PASSOU, visual PASSOU). Não cito a
deslocação máxima do boot smoke porque é um passeio aleatório do náufrago sem seed fixa: o número
muda a cada corrida por concepção e não vale a pena imortalizar um valor que expira sozinho.

Fora de âmbito, decisão registada: `game/beehave/go_to_usable_action.gd` (`else` morto porque
`position: Vector2` nunca é `null`) não foi tocado. Não está nos 6 bugs dos critérios de aceitação
desta tarefa e a instrução do despacho (T-002) foi explícita em só corrigi-lo se fosse trivial e
sem risco; decidi não alargar o âmbito escrito sem um critério de aceitação a validá-lo.

Não verificado:
- `scripts/verify.sh --llm` e `--export`: não corridos (a tarefa não pede `--llm`, nenhum ficheiro
  tocado fala com o Ollama; `--export` não é exigido pelos critérios desta tarefa).
- Uma pesca completa observada manualmente em jogo (a acção de pesca só corre com sorte aleatória
  durante o boot smoke de 30 s).
- O veredicto final desta tarefa: quem implementou não se julga (AGENTS.md §7); fica para
  confirmação externa do `insulano-verifier` / `insulano-reviewer` / Hermes antes de `estado: feito`.

### Histórico de rondas de correcção (histórico, não é o estado vivo)

Cada ronda resume o que a revisão adversarial apanhou e o que foi corrigido. Nenhum número aqui
(md5, píxeis, contagens) deve ser tomado como actual: a fonte de verdade viva está só em
"Estado actual" acima.

**Ronda 1, implementação inicial.** Os 6 bugs corrigidos, cada um com o teste de regressão
correspondente escrito e visto a falhar pelo motivo certo antes da correcção (grep na fonte,
excepção de tipo, contagem de objectos na área, índice do personagem, chamada inexistente). O
`insulano-verifier` deu PASSOU.

**Ronda 2, revisão adversarial do `insulano-reviewer`, 2 bloqueantes.** O teste da constante errada
não distinguia `FAILURE` de `FAILED` porque as duas valem `1` no Beehave/Godot, logo a asserção de
comportamento passava mesmo com o bug presente; corrigido com uma guarda de fonte
(`test_regression_constante_errada_guarda_de_fonte`) que lê o ficheiro como texto e falha se
contiver `FAILED`. O teste dos círculos de debug só chamava `should_draw_debug_circle()` (sempre
falso em headless, independentemente de `_draw()` a usar ou não); corrigido com uma guarda de fonte
(`test_regression_circulos_de_debug_guarda_de_fonte`) que confirma que `draw_circle` só aparece a
seguir ao `if` correcto. Ambas as guardas confirmadas por ataque manual: repor o bug de propósito
fez cada suite isolada cair para 19/20 com a guarda nova a falhar com a mensagem certa; revertido de
imediato depois da confirmação. Também nesta ronda: teste de regressão em falta para o índice
negativo com irmãos antes do personagem
(`test_regression_indice_negativo_personagem_nao_e_primeiro_filho`), citação da regra do
`set_delta_on_blackboard` corrigida para `agent_docs/code_patterns.md:157`, docstring do
`fishing_spot.gd` reescrita como frase completa, `python3 scripts/check_docs.py --fix` corrido.

**Ronda 3, polimento, 6 pontos não bloqueantes do `insulano-reviewer`.** As duas guardas de fonte
da ronda 2 podiam dar falso positivo se a leitura do ficheiro falhasse
(`FileAccess.get_file_as_string` devolve `""` e `"".contains(...)` é falso); acrescentado
`assert_false(source.is_empty(), ...)` antes de cada asserção de conteúdo. A guarda dos círculos de
debug não apanhava um `draw_circle` incondicional colocado antes do `if`, ao mesmo nível de
indentação; acrescentada uma segunda varredura ao corpo de `_draw()` para esse caso. Três instâncias
órfãs (`FishingAction.new()` em `test_fishing_action.gd`, duas de `NeedReplentishingUsable.new()` em
`test_need_replentishing_usable.gd`) sem `autofree(...)`; corrigido. `CHANGELOG.md`: nome de classe
errado (`FindUsableForNeedCondition` em vez de `FundUsableForNeedCondition`, o erro tipográfico
"Fund" é deliberado e fora de âmbito) e contagem de testes desactualizada (11 em vez de 20)
corrigidos.

**Ronda 4, revisão de documentação do `insulano-reviewer`, sem código a mexer.** Esta ronda
identificou a causa raiz das contradições nas rondas seguintes: `reports/` é sobrescrito a cada
corrida de `verify.sh` na mesma sessão, e este Relatório tinha o hábito de citar um md5 ou uma
contagem de píxeis lida numa corrida e só copiar a imagem de prova numa corrida posterior, deixando
o número escrito a apontar para um ficheiro que já não existia em disco. O reviewer apanhou um md5
desactualizado na secção de provas, uma contagem de píxeis desactualizada no bloco chamado "final" e
um "39" por corrigir em `CHANGELOG.md:11` apesar de o `pytest` já dar "40 passed" há várias rondas.
Corrigido: `CHANGELOG.md` actualizado para "40"; e a imagem de prova recopiada a partir de uma
corrida de `verify.sh --visual` feita nesse preciso momento (09:37:28), sem voltar a correr
`verify.sh` depois de registar o md5 dessa cópia.

**Ronda 5, esta reescrita, revisão adversarial repetida sobre o próprio texto do Relatório.** A
estrutura cronológica de 4 rondas com blocos de `verify.sh` quase idênticos continuava a gerar
contradições entre frases em tempo presente (qual corrida "gerou de facto" a imagem, qual md5 é o
"valor definitivo"), apesar de duas corridas independentes (09:37:28 e 09:41:16) confirmarem o
mesmo ficheiro PNG byte-a-byte. Esta reescrita substitui a narrativa por esta secção de histórico
resumido, sem blocos de `verify.sh` nem md5 intermédios repetidos; o único md5 e o único resultado
de `verify.sh` vivos ficam em "Estado actual", no topo desta secção.

