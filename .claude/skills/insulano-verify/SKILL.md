---
name: insulano-verify
description: Corre e interpreta o portão de verificação do Insulano (scripts/verify.sh) sem falsos verdes, lendo logs e imagens. Usar antes de afirmar que algo no Insulano funciona, quando o pre-commit falha, quando o Rodolfo pergunta "está a funcionar?" ou "passa os testes?", ou para diagnosticar uma linha FALHOU ou INDETERMINADO.
---

# Verificar o Insulano

## Escolher o modo

| Situação | Comando | Duração aproximada |
|---|---|---|
| Antes de um commit | `scripts/verify.sh --quick` | 5 s |
| Antes de marcar tarefa feita | `scripts/verify.sh` | 30 a 60 s |
| Mudou algo que se vê | `scripts/verify.sh --visual` | + 10 s, abre uma janela |
| Mudou prompt, regras ou ponte | `scripts/verify.sh --llm` | + 1 a 2 min |
| Fecho de fase | `scripts/verify.sh --full` | 3 a 5 min |

## Ler o resultado

`reports/verify-last.txt` tem uma linha por verificação e o veredicto. Cada linha aponta para o log:

| Linha | Log | O que procurar |
|---|---|---|
| docs | `reports/check_docs.log` | linhas `FALHA [check] ficheiro:linha` |
| backlog | `reports/backlog.log` | frontmatter, dependências, Relatório vazio |
| pytest | `reports/pytest.log` | último bloco de falha |
| lint | `reports/gdlint.log` | `Error:` e `would reformat` |
| import | `reports/import.log` | `SCRIPT ERROR`, `Parse Error` |
| gut | `reports/gut.log`, `reports/gut-junit.xml` | `[Failed]`, `GUT ERROR` |
| boot | `reports/boot.log` | `BOOT_SMOKE FALHOU:` e o motivo |
| visual | `reports/verify-latest.png`, `reports/capture.log` | abrir a imagem com o Read |
| llm | `reports/llm_eval.log`, `reports/llm-eval-*.json` | taxa, p50, p95, rejeições |
| export | `reports/export-verify.log`, `reports/export-run.log` | templates, erros no binário |

## Regras contra falsos verdes

1. **INDETERMINADO não é PASSOU.** Diz-se explicitamente o que não foi verificado e porquê.
2. **O Godot sai com 0 com erros de script.** O `verify.sh` procura os padrões nos logs; não substituir por `echo $?`.
3. **A imagem tem de ser vista.** Um PNG que existe mas mostra um ecrã preto ou a cena errada é FALHOU.
4. **Intermitente é bug.** Se passa à segunda, descobre porque falhou à primeira (seed, tempo, estado partilhado).
5. **Ruído conhecido:** `Can't send message. No active debugger` e `ObjectDB instances were leaked` do Beehave e do GUT não são falhas.
6. **Não baixar o portão para passar.** Mudar um limiar em `verify.sh`, `boot_smoke.gd` ou `phrase_rules.json`
   exige motivo escrito numa ADR ou no Relatório da tarefa, e revisão.

## Diagnóstico rápido

Procedimentos por sintoma em `docs/runbook.md`, secção "Procedimentos de incidente".
