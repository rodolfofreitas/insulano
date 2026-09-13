---
name: insulano-loop
description: Corre o desenvolvimento autónomo do Insulano de ponta a ponta pelo backlog, tarefa a tarefa, com construtor, verificador e revisor separados, até uma condição de paragem. Usar quando o Rodolfo diz "continua o Insulano", "trabalha no backlog", "modo autónomo", "/insulano-loop", ou quando o Hermes pede várias tarefas seguidas. Argumento opcional: número máximo de tarefas (defeito 5).
---

# Loop autónomo do Insulano

És o orquestrador. Não implementas: escolhes, despachas, julgas pelo verificador, fazes commit e decides
se continuas. O método completo está em `AGENTS.md` §2 a §4; isto é a execução.

## 0. Pré-voo (uma vez)

```bash
cd ~/Programacao/Kaeto/Insulano
git status --short            # alterações alheias por commitar: parar e perguntar
mise which godot              # vazio: mise install
git config core.hooksPath     # deve dizer .githooks; senão: git config core.hooksPath .githooks
scripts/verify.sh --quick     # vermelho antes de começar: primeira tarefa é corrigir, ou parar e reportar
python3 scripts/backlog.py list
```

## 1. Ciclo por tarefa (repetir até ao máximo pedido)

1. `python3 scripts/backlog.py next`. Exit 3: ir para o fecho.
2. Lançar o subagente `insulano-builder` com o caminho da tarefa. Esperar o resultado.
3. Se o builder marcou `bloqueado` ou `humano`: registar e voltar ao passo 1.
4. Lançar em paralelo:
   - `insulano-verifier` com o caminho da tarefa;
   - `insulano-reviewer` com o caminho da tarefa (ele lê o `git diff`).
5. Se o verifier deu FALHOU ou o reviewer tem BLOQUEANTES: reenviar ao `insulano-builder` (via SendMessage, mesmo
   agente) com o output literal de ambos. Voltar ao passo 4. **Máximo 3 voltas**; à terceira,
   `estado: bloqueado` com os dois outputs no Relatório.
6. Se tocou em `.gd`, contratos, comandos ou versões: `insulano-docs-keeper` com a lista de ficheiros alterados.
7. Com verifier PASSOU e reviewer APROVADO: `estado: feito` na tarefa, depois
   ```bash
   git add -A && git commit -m "feat(T-NNN): <titulo curto>"   # o pre-commit corre verify --quick
   ```
   Tipo do commit conforme a tarefa (`feat`, `fix`, `test`, `docs`, `chore`).
8. Voltar ao passo 1.

## 2. Paragens obrigatórias

- `backlog.py next` com exit 3.
- Duas tarefas seguidas `bloqueado`.
- O verifier reporta falha numa área que a tarefa não tocou: criar tarefa `fix` com
  `/insulano-new-task`, torná-la dependência da actual, parar.
- Atingido o número máximo de tarefas.
- Contexto a esgotar: a tarefa em curso fica `em-curso` com o Relatório actualizado; nunca `feito` sem verifier.

## 3. Fecho e relatório ao Rodolfo

```bash
python3 scripts/backlog.py list
git log --oneline -n 10
```

Reportar em pt-PT, sem floreados:

| Tarefa | Resultado | Commit | Prova |
|---|---|---|---|

Seguido de: tarefas `bloqueado` com o motivo numa linha, tarefas `humano` que esperam por ele, a próxima
tarefa executável, e qualquer coisa que não foi possível verificar (INDETERMINADO) e porquê.

## Regras

- O construtor não se julga: nunca marcar `feito` com base só no relato do builder.
- Uma tarefa `em-curso` de cada vez. Sem worktrees paralelas sem ADR nova.
- Nada externo (push, publicar, `ollama pull`, `~/.config`): isso é tarefa `humano`.
