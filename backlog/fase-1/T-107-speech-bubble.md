---
id: T-107
titulo: Balão de fala legível sobre água e relva, com duração proporcional
fase: 1
estado: feito
tipo: visual
depende_de: [T-106]
---

## Objectivo
Qualquer frase até 15 palavras lê-se de relance, a 1080p e 1600p, sobre qualquer fundo da ilha.

## Ler antes
- `agent_docs/tech_design.md` §4.6, `game/character/character.gd` (`speech_bubble`, `talking_text`)

## Critérios de aceitação
- [x] `game/ui/speech_bubble.gd` (`class_name SpeechBubble`) usado pelo personagem em vez do `Label` simples
- [x] Fundo opaco com contraste de texto de pelo menos 4.5:1 (cores e cálculo no Relatório)
- [x] Largura máxima com quebra de linha; frase de 15 palavras não sai do ecrã (screenshot)
- [x] Teste GUT: `display_seconds_for(texto)` segue `clamp(2.5 + 0.35 * palavras, 3, 9)`
- [x] O balão desaparece ao fim da duração (teste GUT com tempo simulado)
- [x] Screenshots `--size=1920x1080` e `--size=2560x1600`, inspeccionados

## Fora de âmbito
- Animações do balão

## Prova exigida
- `docs/proof/T-107-balao-1080p.png`, `docs/proof/T-107-balao-1600p.png`

## Relatório

### O que mudou

- **`game/ui/speech_bubble.gd`** (novo), `class_name SpeechBubble extends PanelContainer`: balão de
  fala com fundo branco opaco, texto quase preto, largura máxima com quebra de linha e
  desaparecimento automático proporcional ao comprimento da frase.
  - `show_text(texto)`: escreve o texto no `Label` interno, chama `reset_size()` para o
    `PanelContainer` se ajustar ao conteúdo (largura fixa em `MAX_WIDTH = 220.0`, altura pelo número
    de linhas que o `autowrap_mode = AUTOWRAP_WORD_SMART` do `Label` precisar) e agenda o
    desaparecimento em `_now_s() + display_seconds_for(texto)`. Texto vazio esconde de imediato.
  - `display_seconds_for(texto) -> float`: `clamp(2.5 + 0.35 * palavras, 3, 9)`, contagem de palavras
    com o mesmo padrão `(*UCP)\S+` de `PhraseFilter._word_pattern` (acentuados e NBSP contam como a
    base Unicode exige, nunca ASCII).
  - `check_hide()`: esconde o balão quando o relógio (`clock: Callable` injectável, mesmo padrão de
    `say_generated_action.gd`) passa do instante agendado; chamado a cada `_process()` no jogo real e
    directamente pelos testes GUT com um relógio falso.
  - **Bug apanhado por inspecção visual, corrigido antes da prova final** (ver "Desvio" abaixo):
    depois de `reset_size()`, reposiciono explicitamente o balão
    (`position = Vector2(-size.x / 2.0, BOTTOM_OFFSET - size.y)`) para ele crescer para CIMA quando
    precisa de mais linhas. `reset_size()` por si só cresce sempre a partir do canto superior
    esquerdo do rectângulo actual (ou seja, para BAIXO); `grow_vertical` só é respeitado pelo motor
    quando o redimensionamento vem do sistema de anchors (ex.: o viewport a mudar de tamanho), nunca
    numa chamada directa a `reset_size()` a partir de código. Sem esta linha o balão crescia por
    cima do próprio personagem e escondia-o por completo (ver secção "Desvio").
- **`game/character/character.gd`**: `speech_bubble` passa de `Label` para `SpeechBubble`. O setter
  de `talking_text` já não manipula `.text`/`.visible` directamente: chama
  `speech_bubble.show_text(value)`, que é quem decide a duração e a visibilidade.
- **`game/beehave/say_generated_action.gd`**: `tick()` já não limpa `character.talking_text` quando
  o intervalo bloqueia a fala (antes fazia-o depois de `MIN_VISIBLE_S`). Agora, bloqueado, esta classe
  NUNCA toca no balão, nem para falar nem para o limpar: quem manda no desaparecimento é o
  `SpeechBubble`. **Superado pela correcção da ronda 1 de revisão** (ver "Correcções da ronda 1 de
  revisão" abaixo): `MIN_VISIBLE_S` (3 s) não ficou como mera constante documental sem uso em
  `tick()`; continua a ser lida, agora como piso do intervalo EFECTIVO
  (`maxf(min_interval_s, MIN_VISIBLE_S)`), para a garantia de "nenhuma frase visível menos de 3 s"
  valer para qualquer `min_interval_s` configurado, incluindo 0. Um teste
  (`test_minimo_do_clamp_e_o_mesmo_valor_do_antigo_min_visible_s`) garante que
  `SpeechBubble.MIN_SECONDS == SayGeneratedAction.MIN_VISIBLE_S`, para os dois números nunca
  divergirem sem ninguém notar.
- **`game/tests/integration/test_say_generated_action.gd`**: `test_respeita_min_interval_s_entre_frases`
  e `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` reescritos: já não esperam que
  o balão seja limpo depois de `MIN_VISIBLE_S`, esperam que **nunca** seja tocado enquanto bloqueado
  pelo intervalo (mesmo muito depois de `MIN_VISIBLE_S`). Os relógios falsos destes dois testes
  passam a começar em `1000.0` (nunca em `0.0`). Na altura em que este parágrafo foi escrito, isto
  ficava pendente da revisão da T-106; essa revisão já aconteceu e o ponto em aberto correspondente
  (o `maxf(min_interval_s, MIN_VISIBLE_S)`) ficou fechado nesta mesma tarefa, na ronda 1 de correcção
  (ver "Ponto em aberto da T-106 fechado" abaixo).
- **`game/tests/integration/test_speech_bubble.gd`** (novo): `display_seconds_for()` contra a
  fórmula (0, 1, 15 e 20 palavras, os dois clamps), `show_text()`/`hide_now()`, o desaparecimento
  automático com relógio simulado (`test_balao_desaparece_ao_fim_da_duracao_simulada`) e que uma
  frase mais longa fica visível mais tempo (`test_frase_mais_longa_fica_visivel_mais_tempo`). Relógio
  falso começa em `1000.0`.
- **`game/guy/guy.tscn`**: nó `SpeechBubble` passa de `Label` para `PanelContainer` com o script
  novo e um `Label` filho (`node_paths=PackedStringArray("label")`). Removido o `StyleBoxFlat`
  antigo (ficou sem uso).
- **`agent_docs/tech_design.md` §4.6**, **`CHANGELOG.md`**, **`docs/architecture.md`** (mapa de
  componentes, `check_docs.py --fix`): actualizados.

### Critérios de aceitação

1. `game/ui/speech_bubble.gd` (`class_name SpeechBubble`) usado pelo personagem em vez do `Label`
   simples: `Character.speech_bubble` é `SpeechBubble` (`character.gd:20`); nó `SpeechBubble` em
   `guy.tscn` é `PanelContainer` com este script.
2. Fundo opaco com contraste de texto de pelo menos 4.5:1: `bg_color = Color(1.0, 1.0, 1.0, 1.0)`
   (`#FFFFFF`, alfa 1.0, opaco) e `font_color = Color(0.08, 0.08, 0.08, 1.0)` (`#141414`).
   **Cálculo (luminância relativa WCAG)**: para um canal sRGB `c`, `c_lin = c/12.92` se
   `c <= 0.03928`, senão `c_lin = ((c+0.055)/1.055)^2.4`; `L = 0.2126*R_lin + 0.7152*G_lin + 0.0722*B_lin`.
   Branco puro: `L_bg = 1.0`. `#141414` (0.08,0.08,0.08): `c_lin ≈ 0.007194`, `L_fg ≈ 0.007194`.
   `contraste = (L_bg + 0.05) / (L_fg + 0.05) = 1.05 / 0.057194 ≈ 18,36:1`, bem acima do mínimo de
   4.5:1. Verificado com script Python (`(L_bg+0.05)/(L_fg+0.05)`), resultado `18.358437704219867`.
3. Largura máxima com quebra de linha, frase de 15 palavras não sai do ecrã: `MAX_WIDTH = 220.0` +
   `label.autowrap_mode = AUTOWRAP_WORD_SMART`. Provado nas duas screenshots (ver "Prova visual"):
   uma frase de 15 palavras ("Hoje o vento trouxe uma gaivota curiosa que pousou perto da fogueira
   antiga e velha") quebra em 3 linhas, bem dentro do ecrã, a 1920x1080 e a 2560x1600.
4. Teste GUT `display_seconds_for(texto)` segue `clamp(2.5 + 0.35 * palavras, 3, 9)`:
   `test_speech_bubble.gd` (0, 1, 15 e 20 palavras: 2.5, 2.85 a clamp em 3.0, 7.75, 9.5 a clamp em
   9.0).
5. O balão desaparece ao fim da duração (teste GUT com tempo simulado):
   `test_balao_desaparece_ao_fim_da_duracao_simulada` e `test_frase_mais_longa_fica_visivel_mais_tempo`,
   ambos com `FakeClock` (começa em 1000.0), sem esperar segundos reais.
6. Screenshots `--size=1920x1080` e `--size=2560x1600`, inspeccionados: ver "Prova visual".

### Ponto de desenho (quem manda na duração do balão)

Decisão tomada: o `SpeechBubble` manda. `show_text()` agenda o próprio desaparecimento; a
`SayGeneratedAction` só escreve texto (via `character.talking_text`), nunca o limpa. Isto elimina o
duplo-dono que existia desde a T-106 (a acção limpava o balão depois de `MIN_VISIBLE_S`, um padrão
"fala antes, limpa depois" copiado do `TalkAction` da base). A garantia "nenhuma frase visível menos
de 3 s" vale porque `tick()` usa `maxf(min_interval_s, MIN_VISIBLE_S)` como intervalo EFECTIVO entre
dois pedidos de frase (nunca `min_interval_s` sozinho) E porque `display_seconds_for()` tem
`MIN_SECONDS = 3.0` como piso do próprio clamp; os dois números (`SpeechBubble.MIN_SECONDS` e
`SayGeneratedAction.MIN_VISIBLE_S`) têm de continuar iguais entre si, verificado por
`test_minimo_do_clamp_e_o_mesmo_valor_do_antigo_min_visible_s`. **Este raciocínio substitui o que
este parágrafo dizia antes da ronda 1 de correcção** (que a igualdade dos dois números bastava por
si só, sem depender de `tick()` ler `MIN_VISIBLE_S`): esse raciocínio foi julgado falso nessa ronda
(ver "Correcções da ronda 1 de revisão" abaixo para a prova por mutação com relógio falso). A
garantia da partilha do `min_interval_s` entre instâncias (T-106) continua provada pelos dois testes
reescritos, agora verificando "nunca toca no balão" em vez de "limpa depois de X segundos".

### Prova visual

Script temporário `game/tools/_tmp_capture_speech.gd` (nunca comitado, apagado logo depois de usar,
mesmo padrão do `_tmp_capture_wait.gd` da T-106): carrega `test_scene.tscn`, espera 10 frames por
`_ready()` e escreve directamente `character.talking_text` com a frase de 15 palavras acima
(bypassa a árvore de comportamento e o `LLMBridge` de propósito, para a captura ser determinística
e não depender de que frase o fallback calhe a dizer), espera mais 20 frames de acomodação e grava
o PNG.

- `godot --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/_tmp_capture_speech.gd
  -- --out=.../T-107-balao-1080p.png --size=1920x1080`: `CAPTURE OK (1920x1080)`. Copiada para
  `docs/proof/T-107-balao-1080p.png` e **aberta com o Read**: balão branco bem legível sobre a
  relva, personagem visível logo abaixo (sem sobreposição), frase em 3 linhas, margens generosas
  até às bordas do ecrã.
- O mesmo comando com `--size=2560x1600`: `CAPTURE OK (2560x1600)`. Copiada para
  `docs/proof/T-107-balao-1600p.png` e **aberta com o Read**: mesmo resultado, balão com o mesmo
  tamanho em pixels (a câmara mantém o mesmo zoom, mais resolução só mostra mais mundo em volta),
  personagem visível, sem overflow.
- **Bug apanhado nesta inspecção, antes da versão final das provas**: a 1ª captura (antes da
  correcção do `position` descrita acima) mostrava o balão a crescer para BAIXO ao ajustar-se ao
  texto, cobrindo por completo o personagem (que ficava escondido debaixo do balão opaco). Debug
  ad-hoc (`print` temporário com `char_pos`/`bubble_pos`/`offset_top`/`offset_bottom`, removido antes
  de terminar) confirmou: `offset_bottom` subia de `-16.0` para `+22.0` depois de `reset_size()`
  (deveria ficar fixo, só `offset_top` deveria mover-se). Corrigido fixando `position` manualmente
  depois de `reset_size()`; capturas refeitas confirmam personagem visível, sem sobreposição.

### Comandos corridos e resultado

- `$(mise which godot) --headless --path game --import`: sem `SCRIPT ERROR`, `SpeechBubble`
  registado.
- `$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd
  -gconfig=res://.gutconfig.json`: **70/70 testes a passar** (19 scripts, 351 asserts): os 61
  anteriores mais os 9 novos de `test_speech_bubble.gd`. Ruído conhecido "Can't send message. No
  active debugger" (AGENTS.md §10), ignorado. "6 ObjectDB leaked"/"1 resources still in use" no fim
  da corrida: confirmado por `git stash` que já existiam na baseline antes desta tarefa (mesma
  contagem, 61/61 antes de repor as alterações), não é regressão desta tarefa.
- `uvx --from 'gdtoolkit==4.*' gdformat/gdlint` nos ficheiros tocados: sem problemas.
- `python3 scripts/check_docs.py --fix`: `check_docs: PASSOU (0 falhas)`; `docs/architecture.md`
  regenerado com a linha de `speech_bubble.gd`.
- `INSULANO_LLM_URL="http://127.0.0.1:9" $(mise which godot) --headless --fixed-fps 60 --path game
  -s res://tools/boot_smoke.gd`: `BOOT_SMOKE PASSOU`.
- `scripts/verify.sh --visual`: **VEREDICTO: PASSOU** em `docs`, `backlog`, `pytest`, `lint`,
  `import`, `gut` (70/70), `boot`, `visual`. Corrido 3 vezes ao longo da tarefa (antes da correcção
  do bug de posição, depois da correcção, e depois do ajuste final ao comentário de contraste),
  as duas últimas **PASSOU** de forma limpa. Carga da máquina durante esta tarefa: `uptime` mostrou
  `load average: 16.87` (3 VMs Windows `dockurr/windows` ligadas); mesmo assim a captura correu sem
  falhar em nenhuma das corridas.
- Mutação em cópia de scratchpad (`$SCRATCH/game-mut`, nunca no repositório real), uma hipótese de
  cada vez, todas revertidas depois (confirmado `Passing Tests 70` depois de cada reversão):
  1. Reposta a limpeza incondicional do balão em `SayGeneratedAction.tick()` (código anterior à
     T-107): falham exactamente `test_respeita_min_interval_s_entre_frases` e
     `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` (`[""] expected to equal
     ["Primeira frase"]` e `[""] expected to equal ["Frase da primeira instância"]`), os outros 68
     continuam a passar.
  2. `SpeechBubble.MIN_SECONDS` alterado de `3.0` para `1.0`: falham exactamente os 4 testes que
     dependem do mínimo do clamp (`test_display_seconds_for_zero_palavras_fica_no_minimo`,
     `test_display_seconds_for_uma_palavra_fica_no_minimo`,
     `test_minimo_do_clamp_e_o_mesmo_valor_do_antigo_min_visible_s` e
     `test_balao_desaparece_ao_fim_da_duracao_simulada`, que usa a duração de "Olá").
  3. `check_hide()` substituído por `pass` (balão nunca se esconde sozinho): falham exactamente
     `test_balao_desaparece_ao_fim_da_duracao_simulada` e
     `test_frase_mais_longa_fica_visivel_mais_tempo`.

### Comandos corridos e resultado (ronda 1 de correcção)

- `uptime` antes de cada corrida do Godot, para medir a carga (as 4 VMs Windows `dockurr/windows`
  ficaram ligadas): entre `load average: 1.89` no início e `16.34`/`10.81` a meio da ronda.
- `$(mise which godot) --headless --path game --import`: sem `SCRIPT ERROR`, `SpeechBubble` e o
  `test_character_speech_bubble.gd` novo registados.
- `$(mise which godot) --headless --path game -s res://addons/gut/gut_cmdln.gd
  -gconfig=res://.gutconfig.json`: **76/76 testes a passar** (20 scripts, 380 asserts): os 70
  anteriores mais os 6 novos (1 em `test_say_generated_action.gd`, 3 em `test_speech_bubble.gd`, 2 em
  `test_character_speech_bubble.gd`). Corrido várias vezes ao longo da correcção, sempre 76/76 depois
  de fechados os dois problemas encontrados a meio (ver abaixo). Ruído conhecido "Can't send message.
  No active debugger" (AGENTS.md §10), ignorado. "6 ObjectDB leaked"/"1 resources still in use" no
  fim da corrida: mesma contagem da ronda anterior, não é regressão desta correcção.
- **Problema encontrado e corrigido a meio desta ronda 1** (Lei 5, causa-raiz): o teste novo do
  bloqueante fez `maxf(min_interval_s, MIN_VISIBLE_S)` subir o intervalo efectivo de
  `test_duas_instancias_partilham_o_intervalo_minimo_pelo_blackboard` (que usava `min_interval_s =
  0.0` e nenhum relógio falso) de facto a 3 s; a 2ª instância deixou de conseguir falar no mesmo
  instante (real) da 1ª. Corrigido injectando um relógio falso partilhado, avançado 3,1 s entre os
  dois `tick()` (ver "Correcções da ronda 1 de revisão" abaixo).
- **Problema encontrado e corrigido a meio desta ronda 1** (teste de ligação personagem-balão): a
  1ª versão do teste chamava `add_child_autofree(guy)` dentro do próprio corpo do teste, e o GUT
  contou o ruído conhecido do Beehave em headless ("Can't send message. No active debugger",
  disparado por `BeehaveTree._ready()` ao registar no depurador visual) como "Unexpected Errors"
  desse teste, porque a janela de erros do GUT (`error_tracker.start_test()`, chamado em
  `gut.gd:618`, até à verificação em `gut.gd:624`) só começa DEPOIS de `before_each()` resolver
  (`gut.gd:612`), não cobre o que acontece dentro do próprio corpo do teste. Movido para um ficheiro
  novo (`test_character_speech_bubble.gd`) com `before_each()` a instanciar `guy.tscn`, mesmo padrão
  de `test_main_scene.gd`; confirmado 2/2 depois da mudança.
- `uvx --from 'gdtoolkit==4.*' gdformat` nos ficheiros tocados: reformatou
  `test_say_generated_action.gd` (concatenação de string reflowed); `gdlint`: "Success: no problems
  found".
- `python3 scripts/check_docs.py --fix`: `check_docs: PASSOU (0 falhas)`.
- `scripts/verify.sh --visual`: **VEREDICTO: PASSOU** em `docs`, `backlog`, `pytest`, `lint`,
  `import`, `gut` (76/76), `boot`, `visual`, numa única corrida (carga `load average: 10.81` na
  altura), sem precisar de repetir.
- `reports/verify-latest.png` aberto com o Read: náufrago sobre relva, barra Hunger a 95%, sem
  balão visível no instante da captura (comportamento esperado: o `verify.sh` não força o
  personagem a falar; o balão só aparece quando `talking_text` é escrito). Não é o mesmo que a prova
  visual dedicada da T-107 (`docs/proof/T-107-balao-*.png`).
- `docs/proof/T-107-balao-1080p.png` e `docs/proof/T-107-balao-1600p.png` (já existentes da ronda
  anterior, não regravadas: o comportamento VISÍVEL do balão não mudou nesta ronda, só a lógica
  interna de `min_interval_s`/`MIN_VISIBLE_S` e texto de documentação) reabertas com o Read: balão
  branco legível sobre relva, 3 linhas, personagem visível por baixo sem sobreposição, em 1920x1080
  e 2560x1600.

### Desvios do tech design

- `MAX_WIDTH` (220 px do mundo) e as cores exactas do balão não estavam especificadas no tech
  design; escolhidas nesta tarefa e documentadas em `speech_bubble.gd` e `tech_design.md` §4.6.
- Ownership da duração: `tech_design.md` §4.6 já dizia "duração visível
  `clamp(2.5 + 0.35 * palavras, 3, 9)` segundos" para o `SpeechBubble`, mas não dizia explicitamente
  que a `SayGeneratedAction` deixava de limpar o balão; isso ficou fechado nesta tarefa (ver "Ponto
  de desenho" acima) e escrito no tech design.

### Correcções da ronda 1 de revisão

O `insulano-reviewer` deu ALTERAÇÕES NECESSÁRIAS com 1 bloqueante. Corrigido sobre o trabalho não
commitado da ronda anterior (mesma tarefa, mesmo estado `em-curso`).

**Bloqueante (garantia de 3 s falsa para `min_interval_s` pequeno)**: `agent_docs/tech_design.md`
§4.6, `game/beehave/say_generated_action.gd:41-45` e o Relatório desta tarefa diziam que "a garantia
de nenhuma frase visível menos de 3 s continua a valer, só que agora vem inteira do balão", mas isso
era falso: `LLMSettings.min_interval_s` aceita qualquer valor vindo de `user://settings.cfg`
(`llm_settings.gd:46`, sem limite), `tick()` falava logo que esse intervalo passasse
(`say_generated_action.gd:104-105` antes da correcção) e `SpeechBubble.show_text()` substitui o
texto sem condição (`speech_bubble.gd:82-100`). A prova do revisor (sonda com relógio falso a
começar em 1000, "Frase A" e 1,5 s depois "Frase B") mostrava a frase A visível só 1,5 s.

**Correcção aplicada**: `tick()` (`game/beehave/say_generated_action.gd`) passa a gatear no
intervalo EFECTIVO `maxf(min_interval_s, MIN_VISIBLE_S)`, nunca em `min_interval_s` sozinho. Como o
`SpeechBubble` substitui o texto sem esperar (não tem lógica própria de "mínimo visível"), garantir
que `tick()` nunca pede uma frase nova antes de `MIN_VISIBLE_S` (3 s) desde a anterior é suficiente
para a garantia valer de verdade, para QUALQUER `min_interval_s` configurado, incluindo 0.

- **Teste novo** (`game/tests/integration/test_say_generated_action.gd`,
  `test_min_interval_s_abaixo_do_minimo_e_elevado_a_min_visible_s`): relógio falso a começar em
  1000.0, `min_interval_s = 1.0`. A 1,5 s a ponte NÃO pode ser chamada de novo (frase A continua
  visível); só a 3,1 s (depois dos 3 s efectivos) é que a 2ª frase é pedida.
- **Prova por mutação** (cópia em `$SCRATCH/game-mut`, nunca no repositório real): repus
  `effective_interval_s = _get_settings().min_interval_s` (sem o `maxf`). O teste novo falhou
  exactamente nas 3 asserções que dependem do piso de 3 s (`bridge.call_count` continuar em 1 aos
  1,5 s, `talking_text` continuar "Primeira frase" aos 1,5 s, `bridge.call_count` subir para 2 só
  aos 3,1 s). Revertido de imediato depois da prova.
- **Efeito colateral corrigido**: `test_duas_instancias_partilham_o_intervalo_minimo_pelo_blackboard`
  (pré-existente, T-106) assumia que `min_interval_s = 0.0` deixava a 2ª instância falar de
  imediato; com o `maxf`, o intervalo efectivo passou a ser sempre pelo menos 3 s. Injectei um
  relógio falso partilhado pelas duas instâncias, avançado 3,1 s entre os dois `tick()`, para manter
  a intenção original do teste (o bloqueio é pelo TEMPO no blackboard, partilhado entre instâncias,
  não um estado por nó) com o comportamento novo e correcto.
- **Docstrings actualizadas** para dizerem exactamente isto (nunca "a garantia continua a valer",
  sempre "a garantia vale para QUALQUER `min_interval_s`, porque o intervalo efectivo nunca é
  inferior a `MIN_VISIBLE_S`"): docstring da classe e de `tick()` em `say_generated_action.gd`,
  docstring de `MIN_VISIBLE_S`, e `tech_design.md` §4.6.
- **Ponto em aberto da T-106 fechado**: `backlog/fase-1/T-106-say-generated-action.md`, secção
  "Pontos em aberto da revisão da ronda 3", linha sobre `maxf(min_interval_s, MIN_VISIBLE_S)`,
  marcada como resolvida nesta tarefa.

**Testes em falta apontados pelo revisor (mutações sobreviviam com 70/70), todos acrescentados e
provados por mutação em `$SCRATCH/game-mut` (nunca no repositório real, sempre revertida depois)**:

1. **Reinício do temporizador** (`test_speech_bubble.gd`,
   `test_show_text_reinicia_o_temporizador_mesmo_com_o_balao_ja_visivel`): frase A, avança 2 s
   (com o mesmo número de palavras que B, para a duração agendada ser igual), frase B; B continua
   visível até `display_seconds_for(B)` contado a partir do 2º `show_text()`. Mutação: guardar
   `reset_size()`/`position`/`_hide_at_s` dentro de `if not visible:` (o padrão que o revisor
   apontou) faz o teste falhar (o balão esconde-se demasiado cedo, com o `_hide_at_s` herdado de A).
2. **Ligação personagem-balão** (novo ficheiro `game/tests/integration/test_character_speech_bubble.gd`,
   com `guy.tscn` real): `talking_text = "..."` mostra o `speech_bubble` real (`visible` e o texto do
   `Label`); `talking_text = ""` esconde-o. Mutação: remover a chamada a `speech_bubble.show_text()`
   do setter de `character.gd` faz os dois testes falhar. Ficou em ficheiro próprio, com
   `add_child_autofree()` no `before_each()` (nunca dentro do corpo do teste): `guy.tscn` tem um
   `BeehaveTree`, cujo `_ready()`/teardown imprime "Can't send message. No active debugger" em
   headless (AGENTS.md §10); posto dentro do corpo do teste, o GUT contava esse ruído conhecido como
   erro inesperado DESTE teste (a janela de erro só começa em `gut.gd:618`, depois de `before_each()`
   terminar em `gut.gd:612`, e só é verificada em `gut.gd:624`; um erro dentro do corpo do teste cai
   sempre dentro dela) e fazia-o falhar à toa. Confirmado experimentalmente (o teste falhava sempre
   com "Unexpected Errors" até mover a instanciação para `before_each()`, tal como
   `test_main_scene.gd` já fazia).
3. **Posição sem captura** (`test_speech_bubble.gd`,
   `test_posicao_fixa_o_fundo_do_balao_para_frases_de_1_e_de_varias_linhas` e
   `test_posicao_fixa_o_fundo_do_balao_mesmo_mostrada_com_o_balao_escondido`): para frases de 1 e de
   várias linhas (1 e 20 palavras; a de 20 mede mais alta, confirmado por `assert_gt` no tamanho),
   incluindo uma mostrada a partir do balão escondido, `position.y + size.y == BOTTOM_OFFSET` e
   `position.x == -size.x / 2`. Mutação: remover a linha `position = Vector2(...)` depois de
   `reset_size()` faz os dois testes falhar (o balão fica na posição por defeito, `position.y +
   size.y` e `position.x` deixam de bater com a fórmula). Isto fecha o ponto "não verificado" da
   ronda anterior sobre não haver cobertura automática para este bug geométrico.

### Correcções de texto (baratas, sem mudança de comportamento)

- `say_generated_action.gd:56-66` (docstring de `MIN_VISIBLE_S`): já não diz "não é lido por `tick()`"
  (agora é, via `maxf`); explica o novo papel (piso do intervalo efectivo).
- `speech_bubble.gd:122-125` (docstring de `_process`): já não diz que os testes o chamam
  directamente; diz que chamam `check_hide()`.
- `speech_bubble.gd:34-36` (comentário de `BOTTOM_OFFSET`): já não aponta
  `docs/proof/T-107-balao-1080p.png` como a captura de "antes da correcção" (essa imagem É a versão
  final, depois da correcção); passa a dizer só que o bug foi apanhado antes da versão final da
  imagem.
- `tech_design.md` §4.6 e `speech_bubble.gd:37-40`: explicação do `grow_vertical` encurtada e
  factual (o `reset_size()` chamado a partir de código mantém o canto superior, sem respeitar
  `grow_vertical`).
- `character.gd` (docstring de `talking_text`): passa a dizer que guarda a última frase dita, mesmo
  depois de o balão a esconder, e que o `boot_smoke.gd` depende disso (confirmado:
  `boot_smoke.gd:83` lê `_character.talking_text` a cada frame para confirmar que a árvore chegou a
  falar).
- `speech_bubble.gd:118`: `clampf` em vez de `clamp` (a função tipada, correcta para `float`).

### Correcções da ronda 2 de revisão

O `insulano-reviewer` confirmou o código e quase todas as mutações da ronda 1, mas deixou 2
bloqueantes baratos, ambos de texto/teste, sem tocar em comportamento de produção.

**Bloqueante 1 (o Relatório ainda afirmava o que a ronda 1 já tinha julgado falso)**: as passagens em
"O que mudou" e "Ponto de desenho" que diziam "a garantia de 3 s continua a valer porque
`SpeechBubble.MIN_SECONDS` é igual a `SayGeneratedAction.MIN_VISIBLE_S`" (sem mencionar o `maxf` em
`tick()`) e "`MIN_VISIBLE_S` já não é lida por `tick()`" foram reescritas: a garantia vale porque
`tick()` usa `maxf(min_interval_s, MIN_VISIBLE_S)` E o clamp de `display_seconds_for()` tem mínimo
3 s, os dois números têm de continuar iguais. Confirmado por `grep -n
"MIN_VISIBLE_S\|continua a valer\|já não é lida"` no ficheiro: as ocorrências de "continua a valer"
que sobram (três, nas secções das rondas 1 e 2) são todas citações entre aspas do que o Relatório
dizia antes, citadas para explicar a correcção, não afirmadas como verdade actual.

**Bloqueante 2 (o teste de ligação prometia mais do que apanhava)**: a docstring de
`test_talking_text_mostra_o_speech_bubble_real_com_o_texto`
(`test_character_speech_bubble.gd`) dizia só "falha se o setter deixar de chamar `show_text()`", mas
o corpo do teste só verificava `visible` e `label.text`, que uma mutação que escrevesse
`speech_bubble.label.text`/`speech_bubble.visible` directamente (M3b) também deixa correctos. Corrigido
injectando um `FakeClock` (a começar em `1000.0`, mesmo padrão de `test_speech_bubble.gd`) em
`_guy.speech_bubble.clock` antes de escrever `talking_text`, avançando o relógio
`display_seconds_for(texto) + 0.1` e chamando `check_hide()`: só quem passou por `show_text()` agenda
`_hide_at_s`, por isso só quem passou por lá se esconde a seguir. A docstring foi reescrita para
prometer exactamente isto.

- **Prova por mutação** (cópia completa do repositório em `$SCRATCH/game-mut`, nunca no repositório
  real, revertida/apagada depois): com `Character.talking_text` mutado para
  `speech_bubble.label.text = value; speech_bubble.visible = value != ""` (M3b, em vez de chamar
  `speech_bubble.show_text(value)`), `test_talking_text_mostra_o_speech_bubble_real_com_o_texto`
  passou a falhar exactamente na 3ª asserção ("passada a duração agendada, o balão real tem de se
  esconder sozinho..."), 1/2 testes deste ficheiro a passar. Com o setter substituído por `pass`
  (M3, a mutação mais antiga, já apanhada antes desta correcção), continua a falhar, agora nas duas
  primeiras asserções, 0/2 a passar. Revertido de imediato depois da prova; o repositório real nunca
  foi tocado por esta mutação.
- `$(mise which godot) --headless --path game --import` e a suite completa de GUT correram sobre a
  versão final do teste (sem mutação) antes e depois desta prova: **76/76** (mesma contagem da ronda
  1, só o conteúdo de um teste mudou, não a contagem).

**Pontos "a melhorar" também corrigidos nesta ronda, todos de texto/documentação**:

- `test_character_speech_bubble.gd:11`: a citação `gut.gd:622-621` era inválida (intervalo invertido
  e sem correspondência com o código); as linhas reais são `gut.gd:612` (fim de `before_each()`),
  `gut.gd:618` (`error_tracker.start_test()`, início da janela de erro) e `gut.gd:624` (verificação).
  A docstring passa a dizê-lo e a explicar que um `SCRIPT ERROR` real disparado pela própria montagem
  da cena dentro de `before_each()` cai fora dessa janela e não faz o GUT falhar; quem o apanharia é o
  `scripts/verify.sh` (`log_has_script_errors`, corrido sobre o log completo da suite). As duas
  citações equivalentes no Relatório desta tarefa (uma na secção "Comandos corridos e resultado
  (ronda 1 de correcção)", outra na secção "Correcções da ronda 1 de revisão", ambas descrevendo o
  mesmo problema do teste de ligação personagem-balão) foram alinhadas com as mesmas três linhas de
  `gut.gd`; os números de linha exactos citados pelo revisor (`:204` e `:293`) já não correspondem à
  posição actual dessas frases neste ficheiro, deslocadas pelas próprias edições desta ronda 2, por
  isso identificam-se aqui pelo conteúdo, não pelo número.
- `test_say_generated_action.gd:240-247`
  (`test_duas_instancias_partilham_o_intervalo_minimo_pelo_blackboard`): a docstring dizia provar a
  partilha do intervalo; quem prova isso é
  `test_segunda_instancia_fica_bloqueada_pelo_intervalo_da_primeira` (a 2ª instância fica BLOQUEADA
  por um tempo escrito pela 1ª no mesmo blackboard, algo que uma instância sem partilha nunca
  sentiria). Este teste prova, isso sim, que esse bloqueio partilhado não é permanente. Docstring
  reescrita a dizer isto e a apontar para o outro teste; nome da função mantido (citado em
  `say_generated_action.gd:63` e três vezes neste Relatório; renomear partiria essas referências, o
  que a tarefa pede para evitar).
- `agent_docs/tech_design.md:46`: a tabela de settings passa a anotar, na linha de
  `insulano/llm/min_interval_s`, que valores abaixo de 3 s sobem a 3 s (o piso `MIN_VISIBLE_S`, ver
  §4.6, que já explicava o mecanismo em detalhe).
- `test_speech_bubble.gd:83-86`: a docstring de
  `test_minimo_do_clamp_e_o_mesmo_valor_do_antigo_min_visible_s` dizia "antigo `MIN_VISIBLE_S`",
  desactualizado desde a ronda 1 (a constante continua activa, lida por `tick()` como piso do
  intervalo efectivo). Reescrita para dizer isso; o nome da função mantém-se, pela mesma razão do
  ponto anterior (citado em `say_generated_action.gd` e no Relatório).
- Na secção "Comandos corridos e resultado (ronda 1 de correcção)": "ver 'Correcções da ronda 1 de
  revisão' acima" apontava para uma secção que vem DEPOIS no ficheiro; corrigido para "abaixo". A
  outra ocorrência de "acima" próxima ("Ponto de desenho acima", perto do fim da secção da ronda 1)
  confirmada como correcta: essa secção vem mesmo antes.
- Na secção "O que mudou": "pendente da revisão da T-106" já não é verdade (essa revisão já
  aconteceu, e o ponto em aberto correspondente, o `maxf`, ficou fechado nesta própria tarefa, na
  ronda 1). Reescrito a apontar para a secção "Ponto em aberto da T-106 fechado" mais abaixo no mesmo
  Relatório.

### Por verificar / não verificado

- Não testei o balão sobre água directamente na screenshot final (o personagem estava sobre relva
  no momento da captura); o objectivo pede "sobre qualquer fundo da ilha" e o fundo opaco cobre
  matematicamente ambos os casos (o cálculo de contraste não depende do fundo do jogo, só do
  `bg_color` do próprio balão), mas não há uma imagem explícita balão-sobre-água nesta prova.
  **Aceite como ponto em aberto** (o revisor não o listou como bloqueante); não corrigido nesta
  ronda por instrução explícita.
- **Duplicação do padrão de contagem de palavras** (`SpeechBubble._word_pattern`,
  `game/ui/speech_bubble.gd`) com `PhraseFilter._word_pattern` (`game/llm/phrase_filter.gd`): os dois
  ficheiros têm a mesma regex `(*UCP)\S+` copiada, em vez de partilhada de um só sítio. **Aceite
  como ponto em aberto** (o revisor não o listou como bloqueante); não corrigido nesta ronda por
  instrução explícita, fica registado para uma tarefa futura de limpeza.
- `scripts/verify.sh --full` (com `--llm`/`--export`) não foi corrido: esta tarefa não toca no
  prompt, nas regras de filtro nem na LLMBridge (AGENTS.md §2, só exige `--llm` quando se toca
  nesses ficheiros).
- **`speech_bubble.gd:126` (`_process()` corre sempre, mesmo com o balão escondido)**: o nó nunca
  chama `set_process(visible)` (nem equivalente), por isso `check_hide()` é chamado a cada frame
  mesmo quando `_hide_at_s < 0.0` e a função devolve de imediato sem fazer nada. Barato de ligar
  (desligar o processamento em `hide_now()` e religar em `show_text()`), mas é uma mudança de
  comportamento de produção fora do âmbito desta ronda (só correcções de texto/teste); apontado pelo
  revisor como ponto em aberto, não bloqueante. Registado aqui, não corrigido.
- **`speech_bubble.gd:68-69` (`find_child("Label", ...)` falha em silêncio)**: se `label` não vier
  atribuído na cena e `find_child` também não encontrar um `Label`, `label` fica `null` e todo o resto
  de `_ready()`/`show_text()` que depende dele (`label.text = ...` protegido por `if label != null`)
  passa a não fazer nada, sem qualquer aviso. Um `push_warning` nesse caso tornaria o problema visível
  em vez de o balão simplesmente nunca mostrar texto. Também é mudança de comportamento de produção
  fora do âmbito desta ronda. Registado aqui, não corrigido.
- **Docstrings com "antigo"** (apontado na 3.ª revisão, registado pelo orquestrador):
  `say_generated_action.gd:56` diz "Antigo limite inferior do clamp de duração desta classe", mas
  esta classe nunca teve clamp (o papel antigo era o tempo mínimo visível antes de um ramo bloqueado
  limpar o balão); `speech_bubble.gd:17-19` diz "igual ao antigo `SayGeneratedAction.MIN_VISIBLE_S`",
  quando a constante continua em uso no `maxf` de `tick()`. Só texto; fica para a próxima tarefa que
  tocar nestes ficheiros. O `CHANGELOG.md` já foi corrigido no commit desta tarefa.
