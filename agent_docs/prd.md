# PRD: Insulano

Versão 0.2 · 2026-09-13 · Dono: Rodolfo (Kaeto)

Alterações face à 0.1: critérios de sucesso tornados mensuráveis (latência como p50 medido, ADR-006),
requisitos não funcionais explícitos, "nunca a mesma frase duas vezes" substituído por um critério
verificável, fases ligadas ao backlog.

---

## 1. Problema

Quem cresceu nos anos 90 lembra-se do Johnny Castaway (Sierra, 1992). O original só corre em
Windows 3.1 de 16 bits e o copyright é da Activision, sem continuação há 34 anos. Os remakes
existentes (jc_reborn, Hunter Davis PS1, Guy on Island) são preservação fiel ou protótipos sem
comportamento generativo.

**Lacuna:** não existe um protector de ecrã moderno, legalmente limpo, em que o personagem tenha
comportamento autónomo e fale com um LLM local.

## 2. Proposta de valor

- O náufrago faz coisas por iniciativa própria: pesca quando tem fome, dorme à noite, observa o mar.
- Diz frases geradas por IA local, em português de Portugal, adequadas ao momento.
- Reage ao mundo real: hora, estação, feriados e, se o utilizador quiser, o tempo lá fora.
- Corre 100% local, sem conta, sem chaves, sem custo recorrente.

## 3. Utilizadores

**Primário:** pessoas técnicas, 30 a 50 anos, nostalgia dos anos 90, computador parado durante longos períodos.
**Secundário:** utilizadores Linux e Windows que querem um protector com personalidade.

## 4. Casos de uso

| Id | Caso | Critério observável |
|---|---|---|
| UC-1 | Protector por inactividade | Com `--screensaver`, arranca em fullscreen e sai com tecla ou rato (T-501); no Omarchy é lançado pelo hypridle (T-502) |
| UC-2 | Modo janela | Com `--windowed`, corre numa janela redimensionável enquanto se trabalha (T-501) |
| UC-3 | Fala contextual | A cada `min_interval_s` pode dizer uma frase sobre o que está a fazer, a hora e o tempo (T-106) |
| UC-4 | Sem Ollama | Com o Ollama desligado, fala frases de fallback em pt-PT, sem erros nem esperas visíveis (T-105) |
| UC-5 | Dia e noite | A paleta segue a hora local e o personagem dorme de noite (T-202, T-203) |
| UC-6 | Eventos | Uma gaivota ou um barco aparecem de vez em quando e o náufrago comenta (T-302, T-303) |
| UC-7 | Clima real (opcional) | Se ligado, chove na ilha quando chove na localidade escolhida (T-304, T-305) |
| UC-8 | Feriados | No Natal e no Ano Novo a ilha muda (T-401, T-402) |

## 5. Requisitos não funcionais

| Id | Requisito | Verificação |
|---|---|---|
| RNF-1 | Funciona completo sem rede e sem Ollama | teste de integração com `INSULANO_LLM_URL` inacessível; smoke |
| RNF-2 | Nenhum frame bloqueado por rede | chamadas só por `HTTPRequest` assíncrono; revisão de código |
| RNF-3 | Nada sai da máquina por defeito | clima desligado por defeito (T-306); `docs/threat_model.md` |
| RNF-4 | Frases em pt-PT, 2 a 15 palavras, sem conteúdo proibido | `PhraseFilter` e eval com taxa de aceitação de pelo menos 90% |
| RNF-5 | Latência de frase p50 até 4 s, p95 até 8 s no modelo configurado | `scripts/llm_eval.py` |
| RNF-6 | 60 fps estáveis na máquina de referência em modo protector | medição na T-109 e T-501 |
| RNF-7 | Todos os assets com licença registada e créditos visíveis | `docs/assets-licencas.md`, ecrã de créditos (T-503) |

## 6. Critérios de sucesso por fase

**Fase 1 (LLM), fecha na T-109:**
- [ ] Corre no Omarchy (Hyprland/Wayland) sem crash durante 10 minutos
- [ ] O personagem faz pelo menos 3 acções diferentes (passear, pescar, comer, observar o mar)
- [ ] Frases geradas com p50 até 4 s e taxa de aceitação de pelo menos 90% no eval
- [ ] Sem Ollama, frases de fallback em pt-PT e nenhuma repetição imediata
- [ ] Export Linux `.x86_64` arranca sem erros de script

**Fase 2:** paleta por hora e sono nocturno com screenshots às 08h, 13h, 19h e 23h.
**Fase 3:** eventos com seed reprodutível; clima opcional com fallback `unknown`.
**Fase 4:** Páscoa correcta de 2026 a 2030; cenas de Natal e Ano Novo.
**Fase 5:** modo protector, créditos, build Windows, publicação (com o Rodolfo).

## 7. Fora de âmbito (v0.x)

- Interacção directa com o personagem
- Vários personagens, editor de ilha
- Mobile
- `.scr` nativo do Windows (usa-se `.exe --screensaver`)

## 8. Riscos

Análise completa em [`../docs/threat_model.md`](../docs/threat_model.md) (só o Rodolfo altera) e
propostas em [`../docs/threat_model-propostas.md`](../docs/threat_model-propostas.md).

- Assets de terceiros sem licença: mitigado com registo obrigatório e aprovação humana.
- Latência do LLM em CPU: mitigado com pedido assíncrono, intervalo mínimo e fallback.
- Qualidade das frases de um modelo 8B: mitigado com filtro, eval e revisão amostral (T-108).
