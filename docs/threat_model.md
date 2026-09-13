# Threat Model — Insulano

Data: 2026-09-13
Revisão: só o Rodolfo altera este ficheiro.

---

## 1. Activos a proteger

| Activo | Valor | Impacto se comprometido |
|--------|-------|------------------------|
| Código fonte | Médio | Perda de trabalho; mitigado por git |
| Licença limpa do projecto | ALTO | Processo legal da Activision |
| Dados do utilizador | Baixo | Não armazenamos dados pessoais |
| Assets CC-BY | Médio | Violação de licença se não creditado |

---

## 2. Ameaças principais

### T-01 — Uso inadvertido de assets Sierra/Activision
Probabilidade: MÉDIA (fácil de cometer por engano)
Impacto: ALTO (DMCA, processo)

Mitigação:
- Regra explícita no AGENTS.md: "NUNCA usar assets Sierra"
- Todos os assets documentados com fonte e licença (README.md)
- Revisão de licença antes de adicionar qualquer asset novo
- Tileset e sprites base: CC0/CC-BY confirmados

Residual: Baixo se as regras forem seguidas.

### T-02 — Frase gerada pelo LLM ofensiva ou inapropriada
Probabilidade: BAIXA (modelos locais são conservadores)
Impacto: MÉDIO (reputação do projecto)

Mitigação:
- Prompt com instrução de contexto claro ("náufrago numa ilha")
- `num_predict: 50` limita o output
- Lista de palavras proibidas no LLMBridge (filtro básico pós-geração)
- Fallback para frases fixas inofensivas

### T-03 — Ollama exposto na rede local
Probabilidade: BAIXA (Ollama por defeito só escuta localhost)
Impacto: MÉDIO (outros dispositivos na rede podem usar a API)

Mitigação:
- Nunca alterar o bind address do Ollama para 0.0.0.0
- O LLMBridge só usa http://localhost:11434 (nunca IP externo)
- Documentado no runbook

### T-04 — Dependência do Beehave descontinuada
Probabilidade: BAIXA (plugin activo e mantido)
Impacto: BAIXO (behavior trees podem ser reimplementadas)

Mitigação:
- Pinned a versão estável no .gitmodules ou addons/
- Fallback: lógica simples sem Beehave se necessário

### T-05 — API wttr.in indisponível (Fase 3)
Probabilidade: MÉDIA (serviço gratuito, sem SLA)
Impacto: BAIXO (funcionalidade bonus, não crítica)

Mitigação:
- Fallback hardcoded: condição "sol" quando API não responde
- Timeout de 3s na chamada HTTP

---

## 3. O que este projecto NÃO faz (por design)

- Não envia dados para a internet (excepto wttr.in opcional e sem dados pessoais)
- Não armazena comportamento do utilizador
- Não tem autenticação (não precisa)
- Não corre com privilégios elevados
- Não acede a ficheiros fora do directório do jogo

---

## 4. Licenças — resumo de conformidade

| Asset | Licença | Obrigação |
|-------|---------|-----------|
| Guy on Island (código base) | MIT | Manter copyright notice |
| Tiny Islands tileset | CC0 | Nenhuma (atribuição apreciada) |
| Character Base sprites | CC-BY 3.0 | Crédito visível no jogo |
| Beehave plugin | MIT | Manter copyright notice |
| Código novo Insulano | MIT | N/A (somos os autores) |

Não usar:
- Assets da Sierra On-Line / Activision (RESOURCE.001, RESOURCE.MAP, sprites originais do Johnny)
- Qualquer asset sem licença explícita identificada
