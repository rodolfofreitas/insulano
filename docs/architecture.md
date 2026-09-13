# Arquitectura — Insulano

## Visão geral

```
┌─────────────────────────────────────────────┐
│                  WORLD (Cena raiz)           │
│                                             │
│  ┌──────────────┐    ┌───────────────────┐  │
│  │   ISLAND     │    │   DAY/NIGHT CYCLE │  │
│  │ TileMap 16x16│    │ (Fase 2)          │  │
│  │ CC0 tileset  │    └───────────────────┘  │
│  └──────────────┘                           │
│                                             │
│  ┌──────────────────────────────────────┐   │
│  │           CHARACTER                  │   │
│  │                                      │   │
│  │  ┌──────────┐  ┌──────────────────┐  │   │
│  │  │  NEEDS   │  │  BEHAVIOR TREE   │  │   │
│  │  │ hunger   │  │  (Beehave)       │  │   │
│  │  │ energy   │  │  Selector        │  │   │
│  │  │ (Fase 2) │  │  ├ fish sequence │  │   │
│  │  └──────────┘  │  ├ say phrase    │  │   │
│  │                │  └ walk random   │  │   │
│  │  ┌──────────┐  └──────────────────┘  │   │
│  │  │ ANIMATOR │                        │   │
│  │  │ walk/fish│                        │   │
│  │  │ idle/eat │                        │   │
│  │  └──────────┘                        │   │
│  └──────────────────────────────────────┘   │
│                                             │
│  ┌──────────────────────────────────────┐   │
│  │           LLM BRIDGE                 │   │
│  │                                      │   │
│  │  HTTPRequest → Ollama :11434         │   │
│  │  Fallback → phrases_fallback.json    │   │
│  │  Signal: phrase_ready(text)          │   │
│  └──────────────────────────────────────┘   │
│                                             │
│  ┌──────────────────────────────────────┐   │
│  │        WEATHER (Fase 3)              │   │
│  │  HTTPRequest → wttr.in              │   │
│  │  Fallback → condição neutral        │   │
│  └──────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Fluxo de decisão do personagem

```
_process(delta)
    │
    ▼
Beehave.tick()
    │
    ├─ hunger < 0.2? → GoFish → Eat → hunger += 0.8
    │
    ├─ llm_response pending? → Say(text) → clear response
    │
    └─ idle → WalkToRandom → (every 30s) → RequestPhrase(context)
                                                   │
                                                   ▼
                                           LLMBridge.request_phrase()
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │ Ollama online?              │
                                    │ SIM → POST /api/generate    │
                                    │ NÃO → phrases_fallback.json │
                                    └──────────────┬──────────────┘
                                                   │
                                                   ▼
                                           signal phrase_ready(text)
                                                   │
                                                   ▼
                                           Blackboard: llm_response = text
```

## Contexto enviado ao Ollama

Cada chamada inclui:
```json
{
  "model": "gemma3:4b",
  "prompt": "Você é um náufrago numa ilha deserta. Diga uma frase curta (máximo 15 palavras). Contexto: está a [acção], são [hora]h, [condição_clima], [feriado se aplicável]. Responda apenas com a frase, sem aspas.",
  "stream": false,
  "options": { "num_predict": 50, "temperature": 0.8 }
}
```

## Gestão de estado

Não há base de dados. Estado em memória, reset ao arranque.
Estado persistente do utilizador (se necessário no futuro): `user://settings.cfg`

| Dado | Onde vive | Persiste? |
|------|-----------|-----------|
| hunger | needs.gd (var) | Não |
| current_action | Blackboard Beehave | Não |
| llm_response | Blackboard Beehave | Não |
| último modelo Ollama | ProjectSettings | Sim |
| frases fallback | data/phrases_fallback.json | Sim (ficheiro) |
| feriados | data/holidays.yaml | Sim (ficheiro) |

## Separação de responsabilidades

| Componente | Responsabilidade | NÃO faz |
|------------|-----------------|---------|
| world.gd | Coordena cena, ciclo dia/noite | Lógica do personagem |
| character.gd | Tick do Beehave, animações | Chamadas HTTP |
| needs.gd | Valores de necessidades, sinais | Decisões de comportamento |
| llm_bridge.gd | Toda a comunicação HTTP com Ollama | Lógica de jogo |
| weather.gd | Chamada wttr.in, estado do clima | Visual de chuva |

## Decisões de design

Ver docs/decisions.md para o registo completo (ADR-001, ADR-002, ADR-003).
