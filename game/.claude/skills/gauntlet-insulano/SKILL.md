---
name: gauntlet-insulano
description: Gauntlet Loop para o Insulano. Compoe um prompt de polimento com barra Johnny Castaway; nao executa -- devolve o prompt para colar numa sessao fresca. Triggers: gauntlet insulano, polir sprites, melhorar comportamento, gauntlet loop.
---

# Gauntlet Loop -- Insulano

Compoe o prompt. Nao executa. Nao julga o proprio trabalho.
A sessao que recebe o prompt e nova, sem contexto desta.

## Flow

1. Identifica a dimensao: visual | comportamento | narrativa | screensaver-feel
2. Propoe 2-3 barras fetchable para essa dimensao. Para. Espera escolha.
3. Escreve o prompt (~150 palavras, estilo Shumer). Um bloco, sem naracao.
4. Grava em docs/gauntlet/PROMPT-YYYYMMDD-dimensao.md
5. Sugere comando de execucao. Nao corre.

## Barras por dimensao

Ver docs/gauntlet/bars.md -- todas nomeadas, fetchable, comparaveis.
Nunca inventar barras. Nunca usar adjectivos como barra.

## O que invalida uma ronda

- Critico ve o source, nao o artefacto
- Critico e o mesmo agente que construiu
- Score em vez de pick
- Rondas com cap fixo
- Builder julga-se a si proprio

## Template do prompt

```text
Quero que construas [PECA] ao nivel de [REFERENCIA]. Perfeito,
[ASPECTO], cada detalhe com qualidade [TIER], de [AREA_1] a [AREA_2].

Faz fan-out de subagentes, um por peca. Faz loop em cada item.
Um subagente separado, contexto fresco, e um critico duro:
abre o artefacto real, compara lado-a-lado com [REFERENCIA] sem labels,
diz qual e melhor. So devolve o maior gap se o nosso perder.

Nao para ate cada critico estar genuinamente impressionado vs [REFERENCIA].
Comparacao lado-a-lado cega -- pick, nao score.
Stack: [STACK]. Mantem docs/gauntlet/gauntlet-status.html actualizado.
Eu sou o travao.
```
