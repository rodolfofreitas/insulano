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
| Binário exportado | `dist/linux/insulano.x86_64` | - (T-004) |
| Modo protector | `dist/linux/insulano.x86_64 --screensaver` | - (T-501) |

## Variáveis de ambiente

Não há segredos. Variáveis de teste e diagnóstico (sem valores fixos):

- `INSULANO_LLM_URL`: sobrepõe o URL do Ollama
- `INSULANO_FAKE_TIME`: fixa o relógio (formato `AAAA-MM-DDTHH:MM`)
- `INSULANO_FAKE_WEATHER`: força a condição de clima

## Export templates

Necessários para `scripts/export.sh`. Proposto, a executar e datar na T-004:

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
