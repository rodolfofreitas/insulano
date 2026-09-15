---
id: T-122
titulo: Decidir o que fazer com o p50 do LLMDirector acima do pedido pela T-115
fase: 3
estado: humano
tipo: infra
depende_de: [T-115]
---

## Objectivo

A T-115 pedia "p50 < 5s com 1 chamada" para o `LLMDirector`. Medido nesta máquina (Ollama em
Docker, só CPU, sem GPU) o p50 real fica entre 9,5s e 11,6s -- ver `docs/decisions.md` (ADR-014)
e o Relatório de `backlog/fase-3/T-115-llm-director.md`. A revisão adversarial da T-115 bloqueou
a tarefa até esta decisão ficar registada: o `test_llm_director_live.gd` já não falha por isto
(baixou o critério para um tecto de sanidade de 20s, só avisa acima de 5s), mas essa é uma decisão
de produto/infra, não técnica, e cabe ao Rodolfo.

## Ler antes

- `docs/decisions.md` ADR-014 -- contexto completo e o porquê da causa-raiz (CPU, sem GPU)
- `backlog/fase-3/T-115-llm-director.md`, secção Relatório -- números medidos
- `docs/proof/T-115-director-live.log` -- log de uma corrida real com as latências por ciclo
- memória `ollama-docker-exposto-cpu` -- estado actual do Ollama nesta máquina

## Critérios de aceitação

- [ ] Rodolfo escolhe uma das três opções (ou outra) e regista a escolha aqui ou em
      `docs/decisions.md` (ADR-014 actualizada ou nova ADR a substituí-la):
      1. Religar a GPU do contentor Docker do Ollama (mexe no contentor, AGENTS.md §4: "nunca sem
         o Rodolfo").
      2. Encolher o prompt do director (`game/data/prompts/director_prompt.txt` e/ou o contexto
         enviado) para reduzir o custo de avaliação em CPU.
      3. Aceitar o p50 actual (~9,5-11,6s nesta máquina) e reescrever formalmente a "Prova exigida"
         da T-115 para o valor medido, em vez de "< 5s".
- [ ] `backlog/fase-3/T-115-llm-director.md` actualizada com a decisão e, se aplicável, a "Prova
      exigida" reescrita
- [ ] Se a opção escolhida implicar mudança de código (prompt mais curto, timeout, etc.), tarefa
      nova aberta com essa implementação

## Fora de âmbito

- Qualquer alteração ao contentor Docker do Ollama sem esta decisão explícita

## Prova exigida

- A decisão escrita (aqui ou em ADR nova) com a opção escolhida e o porquê

## Relatório

_A preencher após a decisão do Rodolfo._
