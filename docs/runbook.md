# Runbook: Insulano

Procedimentos operacionais. Cada comando tem a indicação de quando foi **executado** pela última vez;
um comando sem data é proposto e ainda não foi provado.

---

## Como correr

| Objectivo | Comando | Executado |
|---|---|---|
| Instalar o Godot fixado | `mise install` | 2026-09-13 |
| Jogo em janela | `$(mise which godot) --path game` | 2026-09-13 (via captura) |
| Editor | `$(mise which godot) -e --path game` | - |
| Portão completo sem LLM nem export | `scripts/verify.sh --visual` | 2026-09-13 |
| Eval do LLM | `python3 scripts/llm_eval.py --proof` | 2026-09-13 |
| Próxima tarefa | `python3 scripts/backlog.py next` | 2026-09-13 |
| Binário exportado | `dist/linux/insulano.x86_64` | 2026-09-14 (T-004) |
| Modo protector | `dist/linux/insulano.x86_64 -- --screensaver` | - (T-501) |

## Modos de execucao (T-501)

O Insulano suporta dois modos de execucao, escolhidos por argumento de linha de comandos passado apos `--`:

| Modo | Argumento | Comportamento |
|---|---|---|
| Janela (por omissao) | `--windowed` / `-w` ou nenhum | Janela normal; input nao termina o jogo |
| Protector de ecra | `--screensaver` / `-s` | Ecra inteiro, cursor escondido; input termina o jogo apos graca de 1s |
| Creditos | `--credits` | Reservado (T-503) |

Exemplos:

```bash
# Modo janela (qualquer dos seguintes e equivalente)
$(mise which godot) --path game
$(mise which godot) --path game -- --windowed
dist/linux/insulano.x86_64 -- --windowed

# Modo protector de ecra
dist/linux/insulano.x86_64 -- --screensaver
dist/linux/insulano.x86_64 -- -s
```

O autoload `Screensaver` le os argumentos em `_ready()` e configura o `InputWatcher` adequadamente.
Em modo protector, o `InputWatcher` fecha o processo apos 150ms de graca para a animacao de reaccao.

## Variáveis de ambiente

Não há segredos. Variáveis de teste e diagnóstico (sem valores fixos):

- `INSULANO_LLM_URL`: sobrepõe o URL do Ollama
- `INSULANO_FAKE_TIME`: fixa o relógio (formato `AAAA-MM-DDTHH:MM`)
- `INSULANO_FAKE_WEATHER`: força a condição de clima

## Export templates

Necessários para `scripts/export.sh`. Executado e provado em 2026-09-14 (T-004):

```bash
V=4.7.2
DEST="$HOME/.local/share/godot/export_templates/${V}.stable"
TMP="$(mktemp -d)"
curl -L -o "$TMP/templates.tpz" \
  "https://github.com/godotengine/godot-builds/releases/download/${V}-stable/Godot_v${V}-stable_export_templates.tpz"
unzip -q "$TMP/templates.tpz" -d "$TMP"
mkdir -p "$DEST" && mv "$TMP"/templates/* "$DEST"/
scripts/export.sh
```

Resultado (2026-09-14): download de 1,19 GB, `unzip` e `mv` sem erros, templates em
`~/.local/share/godot/export_templates/4.7.2.stable/` (confirmado com `linux_release.x86_64`
presente). `scripts/export.sh` saiu com 0 e imprimiu
`PASSOU: dist/linux/insulano.x86_64 exportado e arrancou 600 frames sem erros de script`.
Binário: `dist/linux/insulano.x86_64`, 73519416 bytes (~70 MiB).

## Monitorização

Aplicação local, sem telemetria. Onde olhar:

- Última verificação: `reports/verify-last.txt`
- Logs das corridas: `reports/*.log`
- Log do jogo em execução: saída padrão do processo (prefixos `[Insulano/...]`)
- Estado do Ollama: `docker ps --filter name=ollama` e `docker exec ollama ollama ps`

## Procedimentos de incidente

### O personagem só diz frases de fallback
- Causa provável: Ollama parado, modelo errado ou timeout.
- Diagnóstico: `curl -s http://127.0.0.1:11434/api/tags`; procurar `[Insulano/LLM]` e o motivo no log.
- Correcção: `docker start ollama` se estiver parado; confirmar `insulano/llm/model` contra a lista de modelos.

### `verify.sh` diz `godot FALHOU: Godot não encontrado`
- Causa: mise sem a ferramenta instalada neste clone.
- Correcção: `mise install` na raiz do repositório.

### `visual INDETERMINADO` ou captura falha
- Causa: sessão sem ecrã (SSH, contentor) ou driver OpenGL indisponível.
- Diagnóstico: `echo $WAYLAND_DISPLAY $DISPLAY`; ver `reports/capture.log`.
- Correcção: correr numa sessão gráfica. Não marcar tarefas visuais como feitas sem imagem.

### `gut FALHOU` com `GUT ERROR: The path [...] does not exist`
- Causa: pasta configurada em `game/.gutconfig.json` que não existe.
- Correcção: criar a pasta com pelo menos um teste, ou retirá-la da configuração.

### `import FALHOU` com `SCRIPT ERROR` numa classe nova
- Causa: erro de parse ou `class_name` duplicada.
- Diagnóstico: `grep -n "SCRIPT ERROR" -A3 reports/import.log`.

### `lint FALHOU`
- Correcção: `uvx --from 'gdtoolkit==4.*' gdformat <ficheiro>` e corrigir o que o `gdlint` ainda reportar.

### `docs FALHOU` com `[componentes] desactualizado`
- Correcção: `python3 scripts/check_docs.py --fix` e commit do `docs/architecture.md`.

## Export Windows (T-507)

### Comando de export

```bash
# Export Windows via scripts/export.sh (exporta Linux + Windows em sequencia)
bash scripts/export.sh
# Saida esperada:
#   PASSOU: dist/linux/insulano.x86_64 exportado e arrancou 600 frames sem erros de script
#   >> export Windows
#   PASSOU: dist/windows/insulano.exe
# Ficheiros gerados: dist/windows/insulano.exe (PE32+ x86_64) + insulano.pck
```

Export directo (so Windows):

```bash
GODOT="$(mise which godot)"
mkdir -p dist/windows reports
"$GODOT" --headless --path game --export-release 'Windows Desktop' dist/windows/insulano.exe \
  2>&1 | tee reports/export-windows.log
ls -lh dist/windows/
```

Resultado (2026-09-15, T-507): `insulano.exe` PE32+ x86_64, 105 MiB; `insulano.pck` 2.0 MiB.
Templates Windows confirmados em `~/.local/share/godot/export_templates/4.7.2.stable/`
(`windows_release_x86_64.exe` presente).

### Como testar com Wine

Wine nao esta instalado nesta maquina (Arch Linux). Para instalar:

```bash
sudo pacman -S wine wine-mono wine-gecko
```

Depois correr:

```bash
WINEDEBUG=-all wine dist/windows/insulano.exe -- --headless --quit-after 60 \
  2>&1 | tee reports/windows-boot.log | head -20
```

Se o jogo arrancar sem `SCRIPT ERROR` no log, o boot esta bom.
Para testar modo protector: `wine dist/windows/insulano.exe -- --screensaver`
(deve abrir em ecra inteiro e fechar ao mover o rato).

### Como testar com a VM QEMU (dockurr/windows)

A maquina tem uma VM Windows golden gerida por `~/VMs/docker/scripts/fleet.sh`.
**Regra: golden e clones nao correm ao mesmo tempo.**

```bash
# Ver estado da VM
~/VMs/docker/scripts/fleet.sh status

# Copiar o exe para a VM (depois de iniciar)
~/VMs/docker/scripts/fleet.sh start golden
# aguardar arranque (~60s)
scp dist/windows/insulano.exe user@<vm-ip>:Desktop/

# Correr na VM (via RDP ou SSH com display)
# Na VM: abrir PowerShell e correr:
#   .\insulano.exe --headless --quit-after 60
# Verificar ausencia de erros na janela de terminal

# Parar a VM apos testes
~/VMs/docker/scripts/fleet.sh stop golden
```

Estado actual (2026-09-15): Wine nao instalado; VM nao iniciada durante este export.
Arranque em Windows: **INDETERMINADO** por falta de ambiente de execucao Windows nesta sessao.
O exe foi verificado como PE32+ valido (`file dist/windows/insulano.exe`).

## Rollback

- Código: `git revert <commit>` (histórico local, sem remoto). Nenhum rollback executado até à data.
- Versões: tags locais `vX.Y.Z` a partir da T-109; binário anterior reconstruível com `git checkout vX.Y.Z && scripts/export.sh`.

## Backups e restauro

- O repositório não tem remoto e `/home` não tem snapshots nesta máquina: **um disco avariado perde tudo**.
  Proposta ao Rodolfo em `docs/threat_model-propostas.md` P-05.
- Nada de dados de utilizador para salvaguardar além de `user://settings.cfg`.

## Escalamento

Rodolfo. Tarefas com `estado: humano` no backlog listam o que espera por ele:
`python3 scripts/backlog.py list | grep humano`.
