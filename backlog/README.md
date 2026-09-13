# Backlog do Insulano

O backlog é o **estado persistente do loop autónomo**. Cada tarefa é um ficheiro
`T-NNN-slug.md` com frontmatter validado por `scripts/backlog.py check` (corre
dentro do `scripts/verify.sh`). Nada de listas de tarefas soltas noutros sítios:
se não está aqui, não existe.

## Comandos

```bash
python3 scripts/backlog.py list          # todas as tarefas, por fase e estado
python3 scripts/backlog.py next          # a próxima tarefa executável
python3 scripts/backlog.py check         # valida frontmatter, dependências e evidência
python3 scripts/backlog.py show T-105    # imprime uma tarefa
```

## Estados

| Estado | Significado | Quem muda |
|---|---|---|
| `pronto` | pode ser executada quando as dependências estiverem `feito` | quem cria a tarefa |
| `em-curso` | um agente pegou nela (só uma de cada vez) | executor, ao começar |
| `feito` | critérios cumpridos, `verify.sh` verde, secção Relatório preenchida | executor, no commit final |
| `bloqueado` | 3 tentativas falhadas ou falta decisão; motivo escrito no Relatório | executor |
| `humano` | exige o Rodolfo (externo, irreversível, `~/.config`, licenças) | ninguém automático |

Regra de selecção do `next`: menor fase, depois menor id, entre as tarefas
`pronto` cujas dependências estão todas `feito`. Tarefas `humano` nunca são
escolhidas; aparecem na lista para o Rodolfo.

## Formato de uma tarefa

```markdown
---
id: T-105
titulo: LLMBridge assíncrono com timeout e fallback
fase: 1
estado: pronto
tipo: codigo            # codigo | visual | docs | infra
depende_de: [T-101, T-102, T-103, T-104]
---

## Objectivo
Uma ou duas frases: o resultado observável, não a implementação.

## Ler antes
- ficheiros e secções exactas (agent_docs/tech_design.md §3.2, game/beehave/talk_action.gd)

## Critérios de aceitação
- [ ] frase binária e verificável, com o comando ou teste que a prova
- [ ] ...

## Fora de âmbito
- o que NÃO fazer nesta tarefa (evita scope creep)

## Prova exigida
- testes GUT com nome, screenshot em docs/proof/, relatório de eval, etc.

## Relatório
(preenchido pelo executor: o que mudou, ficheiros, comandos corridos com
resultado, desvios ao plano, o que ficou por verificar)
```

## Regras para quem escreve tarefas

1. Um critério de aceitação que não se prova com um comando, um teste ou uma
   imagem não é critério: reescrever até ser binário.
2. Uma tarefa cabe numa sessão: no máximo ~5 ficheiros de código e um conceito.
   Maior do que isso, partir.
3. Tarefas visuais exigem screenshot em `docs/proof/` e inspecção da imagem.
4. Tudo o que toca assets novos, rede externa por defeito, `~/.config/`,
   publicação ou licenças nasce com `estado: humano`.
5. Uma tarefa `feito` nunca volta a `pronto`: regressões viram tarefa nova que
   referencia a antiga.
