# Contribuir para o Insulano

Vale para pessoas e para agentes. O detalhe do método está em [`AGENTS.md`](AGENTS.md).

## Antes de codificar

- Todo o trabalho tem uma tarefa em `backlog/`. Sem tarefa, cria-a primeiro (`/insulano-new-task` ou à mão,
  seguindo [`backlog/README.md`](backlog/README.md)).
- Se a tarefa muda um contrato (nome, sinal, setting, formato de dados), actualiza
  [`agent_docs/tech_design.md`](agent_docs/tech_design.md) no mesmo commit.
- Decisão que outro poderia tomar ao contrário: ADR novo em [`docs/decisions.md`](docs/decisions.md).

## Convenção de commits

Conventional Commits com o id da tarefa: `tipo(T-NNN): descrição curta`.

Tipos aceites: `feat`, `fix`, `test`, `docs`, `refactor`, `chore`. Exemplo:

```
feat(T-105): LLMBridge com timeout e fallback garantido
```

## Fluxo

1. `python3 scripts/backlog.py next`, marcar `em-curso`.
2. Teste primeiro, implementação depois.
3. `scripts/verify.sh` (com `--visual` ou `--llm` quando a tarefa o pede).
4. Relatório da tarefa preenchido, `estado: feito`, commit.

O pre-commit (`git config core.hooksPath .githooks`) corre `scripts/verify.sh --quick`. Não o contornes
com `--no-verify`: se falha, o problema é real ou o portão está errado, e ambos se corrigem.

## Padrão de código

[`agent_docs/code_patterns.md`](agent_docs/code_patterns.md). Formatação com `gdformat`, lint com `gdlint`.

## Documentação obrigatória por commit

- Docstrings `##` em todo o `.gd` novo ou alterado.
- `python3 scripts/check_docs.py --fix` se criaste, renomeaste ou apagaste um `.gd`.
- Entrada em `CHANGELOG.md` na secção `[Não lançado]`.
- Assets novos só com linha em [`docs/assets-licencas.md`](docs/assets-licencas.md) aprovada pelo Rodolfo.
