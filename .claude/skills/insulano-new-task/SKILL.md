---
name: insulano-new-task
description: Escreve uma tarefa nova no backlog do Insulano com critérios de aceitação binários, dependências e prova exigida, validada pelo backlog.py. Usar quando aparece trabalho novo ("acrescenta ao backlog", "cria uma tarefa para X"), quando uma regressão é encontrada, quando uma tarefa é grande demais e tem de ser partida, ou quando o loop precisa de uma tarefa fix.
---

# Criar uma tarefa no backlog do Insulano

Formato canónico em `backlog/README.md`. Este é o procedimento.

## 1. Enquadrar

- Qual é o resultado **observável**? (não "criar classe X", mas "o personagem dorme quando é noite")
- Que fase? 0 fundação, 1 voz, 2 tempo, 3 mundo, 4 calendário, 5 produto.
- Toca num contrato? Então a secção do `agent_docs/tech_design.md` existe ou é criada na própria tarefa.
- Precisa do Rodolfo? Asset de terceiros, rede ligada por defeito, `~/.config`, publicar, licenças,
  `ollama pull`: `estado: humano`.

## 2. Numerar e nomear

```bash
ls backlog/fase-N/                       # próximo id livre da fase: T-<fase><NN>, ex. T-206
```

Ficheiro `backlog/fase-N/T-NNN-slug-em-kebab.md`.

## 3. Escrever critérios binários

Cada critério responde "como é que um agente prova isto sozinho?". Reescrever até ter um destes:

| Mau | Bom |
|---|---|
| "o céu fica bonito à noite" | "screenshot com `INSULANO_FAKE_TIME=...T23:00` mostra estrelas; `docs/proof/T-204-noite.png` inspeccionado" |
| "o filtro funciona" | "teste GUT percorre todos os casos de `phrase_filter_cases.json` com `clean` e `reason` iguais" |
| "sem bugs" | "`test_regression_<bug>` falha antes da correcção e passa depois" |
| "rápido" | "`llm_eval.py` p50 até 4 s" |

Inclui sempre: `scripts/verify.sh` (com a flag do tipo) sem FALHOU.

## 4. Tamanho

No máximo ~5 ficheiros de código e um conceito. Maior do que isso: partir em tarefas com dependências.

## 5. Validar

```bash
python3 scripts/backlog.py check
python3 scripts/check_docs.py
python3 scripts/backlog.py list
```

Regressões: nunca reabrir uma tarefa `feito`; a nova tarefa refere a antiga no Objectivo.
