# Testing — Insulano

## Estratégia geral

Protetor de ecrã não tem testes unitários convencionais (não há lógica de negócio crítica).
O foco é em testes manuais por fase + smoke tests automatizados onde possível.

---

## Testes manuais por fase

### Fase 1 — Fundação LLM

| Teste | Critério de sucesso | Como testar |
|-------|---------------------|-------------|
| Arranque sem Ollama | Jogo corre, usa frases fixas | Parar Ollama, correr o jogo |
| Arranque com Ollama | Frase gerada em < 3s | Correr Ollama, observar log |
| Personagem anda | Movimento fluido, sem jank | Observar 2 minutos |
| Pesca funciona | Personagem vai ao spot, aguarda, come | Observar ciclo completo |
| Export Linux | Binário .x86_64 executa no Omarchy | Export → correr binário |
| Wayland compatível | Sem crash, sem artefactos visuais | Correr em sessão Hyprland |

### Fase 2 — Ciclo dia/noite

| Teste | Critério de sucesso |
|-------|---------------------|
| Dia detectado correctamente | Paleta diurna entre 06:00-20:00 |
| Noite detectada correctamente | Paleta nocturna entre 20:00-06:00 |
| Personagem dorme à noite | Animação sleep activa após 21:00 |
| Transição suave | Sem corte abrupto de paleta |

### Fase 3 — Clima e eventos

| Teste | Critério de sucesso |
|-------|---------------------|
| API wttr.in disponível | Clima actualiza ao arranque |
| API indisponível | Fallback para sol sem crash |
| Chuva visual | Partículas de chuva visíveis quando condição = chuva |
| Gaivota aparece | Evento aleatório visível em < 5 min |

---

## Smoke tests automatizados (GDScript)

Criar em `tests/` (executados com `godot --headless --script`):

### smoke_llm_bridge.gd
Testa que o LLMBridge:
1. Retorna frase do fallback quando Ollama offline
2. Não bloqueia mais de 5s
3. Emite signal `phrase_ready`

### smoke_needs.gd
Testa que:
1. `hunger` começa em 1.0
2. Decai com o tempo (simular delta)
3. Signal `need_critical` emite quando < 0.2
4. Não vai abaixo de 0.0

---

## Critérios de regressão

Antes de fechar qualquer fase, verificar que as fases anteriores não partiram:
- [ ] Jogo ainda arranca sem Ollama
- [ ] Personagem ainda anda e pesca
- [ ] Export Linux ainda funciona

---

## O que NÃO testar

- Qualidade das frases geradas pelo LLM — é subjectivo, não testável
- Performance do Ollama — depende do hardware do utilizador
- Visual dos sprites — validação humana por screenshots
