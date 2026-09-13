---
name: insulano-task
description: Executa uma única tarefa do backlog do Insulano na sessão actual, dos testes ao commit, com o veredicto final pedido ao insulano-verifier. Usar quando o pedido é uma tarefa concreta ("faz a T-105", "implementa o GameClock", "/insulano-task T-201") ou quando a célula S8 da fábrica despacha uma tarefa. Sem argumento, usa a próxima de backlog.py next.
---

# Executar uma tarefa do Insulano

## 1. Escolher e preparar

```bash
cd ~/Programacao/Kaeto/Insulano
python3 scripts/backlog.py show T-NNN      # ou: python3 scripts/backlog.py next
python3 scripts/backlog.py list            # dependências todas feito?
scripts/verify.sh --quick                  # tem de estar verde antes de começar
```

Muda `estado: em-curso`. Lê "Ler antes", a secção do componente em `agent_docs/tech_design.md` e
`agent_docs/code_patterns.md`.

## 2. Testes primeiro

Escreve os testes que provam cada critério de aceitação. Corre só esse ficheiro e confirma a falha pelo motivo certo:

```bash
G=$(mise which godot)
$G --headless --path game --import > /dev/null 2>&1
$G --headless --path game -s res://addons/gut/gut_cmdln.gd -gconfig=res://.gutconfig.json -gtest=res://tests/unit/test_<x>.gd
```

Scripts Python: teste em `scripts/tests/` e `uvx pytest -q scripts/tests/test_<x>.py`.

## 3. Implementar

- Nomes e assinaturas exactos do tech design; se tiveres de mudar um contrato, muda o `tech_design.md` agora.
- `##` no cabeçalho e em cada função pública.
- `uvx --from 'gdtoolkit==4.*' gdformat <ficheiros>`.

## 4. Verificar

| Tipo da tarefa | Comando |
|---|---|
| codigo | `scripts/verify.sh` |
| visual | `scripts/verify.sh --visual`, copiar a imagem para `docs/proof/T-NNN-*.png` e abri-la |
| toca LLM | acrescentar `--llm` |
| infra de export | acrescentar `--export` |

Falhou: corrige a causa e repete, no máximo 3 ciclos; depois `estado: bloqueado` com o erro exacto.

## 5. Documentar

```bash
python3 scripts/check_docs.py --fix   # se criaste ou renomeaste .gd
```

Entrada no `CHANGELOG.md` em `[Não lançado]`; ADR em `docs/decisions.md` se decidiste algo discutível.
Relatório preenchido na tarefa: o que mudou, comandos e resultados, desvios, o que não foi verificado.

## 6. Veredicto e commit

Lança o subagente `insulano-verifier` com o caminho da tarefa. Opcionalmente `insulano-reviewer` para diffs
com mais de 3 ficheiros de código. Só com PASSOU:

```bash
# estado: feito na tarefa
git add -A && git commit -m "feat(T-NNN): <titulo curto>"
```

Se a tarefa veio da fábrica, escreve também o `RELATORIO.md` pedido com o conteúdo do Relatório.
