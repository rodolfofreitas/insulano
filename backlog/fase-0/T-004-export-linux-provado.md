---
id: T-004
titulo: Instalar export templates 4.7.2 e provar o export Linux
fase: 0
estado: feito
tipo: infra
depende_de: [T-001]
---

## Objectivo
`scripts/export.sh` produz `dist/linux/insulano.x86_64` e o binário exportado arranca sem erros de script.

## Ler antes
- `scripts/export.sh`, `docs/runbook.md` secção "Export templates", `game/export_presets.cfg`

## Critérios de aceitação
- [x] Templates instalados em `~/.local/share/godot/export_templates/4.7.2.stable/` a partir de
      `https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz`
      (é um zip; o conteúdo da pasta `templates/` vai para o destino)
- [x] `scripts/export.sh` sai com 0 e imprime `PASSOU`
- [x] `scripts/verify.sh --export` dá `export PASSOU`
- [x] O binário exportado corre em modo janela 10 s na sessão Hyprland sem crash (comando e resultado no Relatório)
- [x] `docs/runbook.md` secção "Export templates" tem os comandos exactos corridos e a data

## Fora de âmbito
- Export Windows e Web (T-507)
- Empacotar para distribuição (T-505)

## Prova exigida
- Saída de `scripts/export.sh` e tamanho do binário no Relatório

## Relatório

Estado inicial: `scripts/verify.sh --quick` já estava verde antes de tocar em nada
(docs/backlog/pytest/lint PASSOU); `~/.local/share/godot/export_templates/` estava vazio.

### 1. Templates instalados

Corri o procedimento tal como estava proposto em `docs/runbook.md`:

```bash
V=4.7.2
DEST="$HOME/.local/share/godot/export_templates/${V}.stable"
TMP="$(mktemp -d)"
curl -L -o "$TMP/templates.tpz" \
  "https://github.com/godotengine/godot-builds/releases/download/${V}-stable/Godot_v${V}-stable_export_templates.tpz"
unzip -q "$TMP/templates.tpz" -d "$TMP"
mkdir -p "$DEST" && mv "$TMP"/templates/* "$DEST"/
```

Download de 1,19 GB completo (`curl` saiu 0), `unzip` e `mv` sem erros. Confirmado
`linux_release.x86_64` presente em `~/.local/share/godot/export_templates/4.7.2.stable/`.
Removi a pasta temporária depois (`rm -rf` sobre o `mktemp -d`, mutação reversível
sobre ficheiro criado por mim mesmo nesta corrida).

### 2. `scripts/export.sh`

```
$ scripts/export.sh
PASSOU: dist/linux/insulano.x86_64 exportado e arrancou 600 frames sem erros de script
$ echo $?
0
```

Binário: `dist/linux/insulano.x86_64`, 73519416 bytes (~70 MiB).

### 3. `scripts/verify.sh --export`

```
>> export       PASSOU         PASSOU: dist/linux/insulano.x86_64 exportado e arrancou 600 frames sem erros de script
...
VEREDICTO: PASSOU
```

Corrido duas vezes (antes e depois de actualizar a documentação); ambas vezes `VEREDICTO: PASSOU`
com todas as fases (docs, backlog, pytest, lint, import, gut, boot, export) em PASSOU.

Corrido uma terceira vez em 2026-09-14, depois de aplicar as correcções pedidas pelo
insulano-reviewer (CHANGELOG e Relatório reescritos com honestidade sobre os erros de
`reports/export-run.log`, e a repetição do teste de janela para `reports/window-run.log`):

```
docs         PASSOU         scripts/check_docs.py
backlog      PASSOU         backlog: PASSOU (43 tarefas, 0 erros)
pytest       PASSOU         40 passed in 0.05s
lint         PASSOU         31 ficheiros próprios limpos
import       PASSOU         godot --import
gut          PASSOU         Tests 20;Passing Tests 20
boot         PASSOU         BOOT_SMOKE PASSOU: fome -30.0 pontos, deslocação máxima 614 px
export       PASSOU         PASSOU: dist/linux/insulano.x86_64 exportado e arrancou 600 frames sem erros de script
VEREDICTO: PASSOU
```

Continua `VEREDICTO: PASSOU`; `reports/export-run.log` desta corrida tem exactamente os mesmos
`ERROR`/`WARNING` de motor citados na secção Auto-adversário ponto 2 (o bug da T-006 continua
por corrigir, fora de âmbito aqui), o que confirma que o portão da T-004 mede o que o seu
Objectivo diz (ausência de `SCRIPT ERROR`/`Parse Error`/`Failed to load script`) e não "zero
erros" em sentido lato.

### 4. Modo janela real na sessão Hyprland (10 s, sem crash)

Corrida original (2026-09-14, manhã): guardei a saída num ficheiro `window-run2.log` que
nunca foi movido para `reports/` e já não existe no disco. Isso foi apanhado pelo revisor
(prova não reproduzível, referência a ficheiro inexistente) e corrigido repetindo o teste
uma segunda vez, desta vez com a saída guardada no sítio certo.

Confirmei primeiro que esta sessão bash tem acesso à sessão gráfica viva
(`DISPLAY=:0`, `WAYLAND_DISPLAY=wayland-1`, `XDG_RUNTIME_DIR=/run/user/1000`, e
`hyprctl version` respondeu com a Hyprland 0.56.2 a correr). Corri:

```bash
timeout 10 dist/linux/insulano.x86_64 > reports/window-run.log 2>&1 &
PID=$!
sleep 2
hyprctl clients   # a meio da corrida
kill -0 $PID      # confirma que ainda está vivo
wait $PID; echo $?
cat reports/window-run.log
```

Resultado real desta segunda corrida (2026-09-14, repetida para corrigir a prova):
- Aos 2 s, `hyprctl clients` mostrou uma janela mapeada e visível:
  `class: Insulano`, `title: Insulano`, `initialTitle: Godot`, `mapped: 1`, `visible: 1`,
  `pid: 329311`, `workspace: 1`, `xwayland: 1`.
- `kill -0 $PID` confirmou o processo vivo a meio da corrida.
- O processo correu os 10 s completos e foi terminado pelo `timeout` (exit code 124,
  que é o `timeout` a mandar SIGTERM porque o prazo expirou, não um crash do jogo).
- `reports/window-run.log` ficou vazio (`wc -l` = 0): sem `SCRIPT ERROR`, `Parse Error` nem
  qualquer outra linha.

Critério cumprido com prova real e citável (`reports/window-run.log`, janela mapeada na
compositor viva, processo estável durante os 10 s, log sem erros).

### 5. `docs/runbook.md`

Secção "Export templates" actualizada: já não diz "Proposto, a executar e datar na T-004";
passou a "Executado e provado em 2026-09-14 (T-004)", com os comandos exactos corridos e
um parágrafo de resultado (download, tamanho do binário, saída do `export.sh`). Linha da
tabela "Binário exportado" datada 2026-09-14.

### Outros ficheiros tocados
- `CHANGELOG.md`: entrada em `[Não lançado] > Adicionado` sobre o export Linux provado.
- `python3 scripts/check_docs.py` corrido (sem `--fix`, não foi preciso): `PASSOU (0 falhas)`.
  Não toquei em nenhum `.gd`, não havia nada para regenerar.
- `reports/window-run.log`: saída real da corrida de janela repetida na correcção pós-revisão
  (secção 4).

### Correcção pós-revisão (insulano-reviewer, BLOQUEANTES)

O insulano-reviewer apanhou três problemas nesta tarefa, corrigidos nesta ronda:
1. `CHANGELOG.md` e este Relatório afirmavam "sem erros de script" em sentido lato, quando
   `reports/export-run.log` tem erros reais de motor (`TypedArray`/`erase`, `Capture not
   registered`, `ObjectDB` leaked, `resources still in use`). Reescrevi o `CHANGELOG.md` para
   dizer exactamente o que o portão prova (os três padrões vigiados pelo grep) e acrescentei
   as linhas reais do log à secção Auto-adversário ponto 2, com a nota a apontar para a T-006.
2. `estado: feito` tinha sido posto antes do veredicto do insulano-verifier/reviewer. Voltei
   para `estado: em-curso`; só o orquestrador muda para `feito` depois de confirmado.
3. A secção 4 citava `window-run2.log`, um ficheiro que não existe no repositório. Repeti o
   teste de janela (10 s, sessão Hyprland viva, `hyprctl clients` a meio da corrida) e guardei
   a saída real em `reports/window-run.log` (vazio, 0 linhas), citado agora com caminho real.

Depois destas correcções, `scripts/verify.sh --export` continua `VEREDICTO: PASSOU` (secção 3,
terceira corrida).

### Não verificado / fora de âmbito
- Export Windows e Web (T-507, T-505): fora de âmbito desta tarefa, não tocados.
- Não corri `verify.sh --full` (LLM/visual não fazem parte do âmbito desta tarefa infra).

### Auto-adversário (Lei 6)
1. "O timeout de 10 s podia ter morto o processo antes de a janela aparecer?" Não: o
   `hyprctl clients` a meio da corrida (aos 2 s) já mostrava a janela mapeada e visível,
   antes do timeout disparar.
2. "O log vazio esconde um crash silencioso?" Parcialmente não, mas este ataque falhou na
   primeira ronda: `scripts/export.sh` corre o mesmo binário headless por 600 frames e grava
   em `reports/export-run.log`; esse ficheiro NÃO está vazio e contém erros reais de motor
   que a primeira versão deste Relatório escondeu por dizer só "sem erros de script":

   ```
   ERROR: Attempted to erase an object into a TypedArray, that does not inherit from 'GDScript'.
      at: _internal_validate_object (./core/variant/container_type_validate.h:137)
   ERROR: Condition "!_p->typed.validate(value, "erase")" is true.
      at: erase (core/variant/array.cpp:350)
   ERROR: Capture not registered: 'beehave'.
      at: unregister_message_capture (core/debugger/engine_debugger.cpp:62)
   WARNING: 6 ObjectDB instances were leaked at exit (run with `--verbose` for details).
      at: cleanup (core/object/object.cpp:2536)
   ERROR: 1 resources still in use at exit (run with --verbose for details).
      at: clear (core/io/resource.cpp:822)
   ```

   Causa raiz: `_body_exited_area` em `find_usable_for_need_condition.gd:90` chama
   `objects_in_area.erase(body)` sem a guarda de tipo que `_body_entered_area` já tem, exposta
   pela correcção do sinal na T-003. `scripts/export.sh:31` só faz grep a
   `SCRIPT ERROR|Parse Error|Failed to load script`, por isso o portão continua a dar PASSOU
   apesar destes erros de motor. O critério desta tarefa é literalmente esse grep (ver
   Objectivo), por isso o portão passa correctamente e a correcção do bug em si NÃO é âmbito
   da T-004; ficou registada como T-006
   (`backlog/fase-0/T-006-guarda-tipo-body-exited.md`), com o texto exacto do erro e a linha
   culpada.
3. "O Godot sai com código 0 mesmo com SCRIPT ERROR" (armadilha #1 do AGENTS.md secção
   10): confirmei que não confiei no exit code da corrida em janela (foi 124, do
   `timeout`, e não seria fiável de qualquer forma); a prova real foi o grep ao log
   (vazio) e o estado do processo via `hyprctl`/`kill -0`, não o exit code.

O ataque 2 encontrou um defeito real de reporte (afirmação "sem erros de script" mais forte do
que a prova aguentava); corrigido na secção "Correcção pós-revisão" acima. Os ataques 1 e 3
não encontraram defeito.
