# Backlog do Insulano

O backlog e o **estado persistente do loop autonomo**. Cada tarefa e um ficheiro
`T-NNN-slug.md` com frontmatter validado por `scripts/backlog.py check` (corre
dentro do `scripts/verify.sh`). Nada de listas de tarefas soltas noutros sitios:
se nao esta aqui, nao existe.

> **PRINCIPIO CRITICO:** O naufrago NUNCA morre. Necessidades sao motivadores de
> comportamento e fontes de drama emocional -- nao ameacas de morte. Ver
> `docs/actions-catalogue.md` (95 accoes catalogadas) e `docs/needs-system.md`.

## Comandos

```bash
python3 scripts/backlog.py list          # todas as tarefas, por fase e estado
python3 scripts/backlog.py next          # a proxima tarefa executavel
python3 scripts/backlog.py check         # valida frontmatter, dependencias e evidencia
python3 scripts/backlog.py show T-105    # imprime uma tarefa
```

## Estados

| Estado | Significado | Quem muda |
|---|---|---|
| `pronto` | pode ser executada quando as dependencias estiverem `feito` | quem cria a tarefa |
| `em-curso` | um agente pegou nela (so uma de cada vez) | executor, ao comecar |
| `feito` | criterios cumpridos, `verify.sh` verde, seccao Relatorio preenchida | executor, no commit final |
| `bloqueado` | 3 tentativas falhadas ou falta decisao; motivo escrito no Relatorio | executor |
| `humano` | exige o Rodolfo (externo, irreversivel, `~/.config/`, licencas) | ninguem automatico |

Regra de seleccao do `next`: menor fase, depois menor id, entre as tarefas
`pronto` cujas dependencias estao todas `feito`. Tarefas `humano` nunca sao
escolhidas; aparecem na lista para o Rodolfo.

## Tarefas por Fase

| Fase | Nome | Tarefas | Estado |
|---|---|---|---|
| 0 | Bootstrap e Divida Tecnica | 6 | Completa |
| 1 | LLM, Needs, Director Base | 16 | Maioritariamente feita (T-119/feito, T-120/pronto, T-121/humano) |
| 2 | Tempo, Ciclo Dia/Noite, Energia | 5 | Em curso (T-123/pronto, T-201-T-204) |
| 3 | Eventos, Clima, Accoes (top-20) | 22 | Em curso (T-301/feito, T-302-T-306, T-114-T-118, T-122, T-124-T-133) |
| 4 | Feriados e Cenas Sazonais | 2 | Planeada |
| 5 | Screensaver, Sons, Publicacao | 7 | Planeada (T-505/humano) |
| 6 | Polimento Grafico (Upscale ESRGAN) | 10 | Completa (T-601-T-610) |
| 7 | Redesenho Visual Completo | 10 | Planeada (T-701-T-710) |
| 8 | Novas Necessidades (SEDE, HIGIENE, etc) | 6 | Planeada (T-801-T-806) |
| **Total** | | **84** | |

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
Uma ou duas frases: o resultado observavel, nao a implementacao.

## Ler antes
- ficheiros e seccoes exactas (agent_docs/tech_design.md ss3.2, game/beehave/say_generated_action.gd)

## Criterios de aceitacao
- [ ] frase binaria e verificavel, com o comando ou teste que a prova
- [ ] ...

## Fora de ambito
- o que NAO fazer nesta tarefa (evita scope creep)

## Prova exigida
- testes GUT com nome, screenshot em docs/proof/, relatorio de eval, etc.

## Relatorio
(preenchido pelo executor: o que mudou, ficheiros, comandos corridos com
resultado, desvios ao plano, o que ficou por verificar)
```

## Regras para quem escreve tarefas

1. Um criterio de aceitacao que nao se prova com um comando, um teste ou uma
   imagem nao e criterio: reescrever ate ser binario.
2. Uma tarefa cabe numa sessao: no maximo ~5 ficheiros de codigo e um conceito.
   Maior do que isso, partir.
3. Tarefas visuais exigem screenshot em `docs/proof/` e inspeccao da imagem.
4. Tudo o que toca assets novos, rede externa por defeito, `~/.config/`,
   publicacao ou licencas nasce com `estado: humano`.
5. Uma tarefa `feito` nunca volta a `pronto`: regressoes viram tarefa nova que
   referencia a antiga.

## Referencias

- `docs/actions-catalogue.md` -- 95 accoes catalogadas, top 20 prioridades, sprites necessarios
- `docs/visual-identity.md` -- art direction, paletas, proporcoes, Fase 7 detalhada
- `docs/needs-system.md` -- FOME, SOLIDAO, TEDIO, ESPERANCA, SEDE, HIGIENE, CALOR, FRIO, MOVIMENTO
- `docs/events-catalogue.md` -- 210+ eventos
- `docs/narrative-design.md` -- arcos narrativos, frases
- `CHANGELOG.md` -- historico de mudancas por release
