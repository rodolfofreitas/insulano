# Padrões de Código — Insulano

Ler antes de escrever qualquer GDScript neste projecto.

---

## 1. Linguagem e estilo

- GDScript exclusivamente (não C#, não GDScript 1.x legado)
- Type hints obrigatórios em todas as funções públicas
- snake_case para variáveis e funções
- UPPER_CASE para constantes
- PascalCase para nomes de nós e classes

Exemplo correcto:
```gdscript
const HUNGER_DECAY_RATE: float = 0.1

var current_hunger: float = 1.0

func decrease_hunger(delta: float) -> void:
    current_hunger = clamp(current_hunger - HUNGER_DECAY_RATE * delta, 0.0, 1.0)
```

## 2. Estrutura de ficheiros

```
insulano/                   # projecto Godot (a criar)
├── project.godot
├── addons/beehave/         # plugin behavior trees
├── scenes/
│   ├── world.tscn          # cena principal
│   ├── character.tscn      # personagem
│   └── ui/                 # HUD (mínimo)
├── scripts/
│   ├── character/
│   │   ├── character.gd         # controlador principal
│   │   ├── needs.gd             # sistema de necessidades
│   │   └── behaviors/           # nós behavior tree
│   │       ├── go_fish.gd
│   │       ├── walk_random.gd
│   │       └── say_phrase.gd
│   ├── world/
│   │   ├── world.gd             # controlador da ilha
│   │   ├── day_night.gd         # ciclo dia/noite (Fase 2)
│   │   └── weather.gd           # clima (Fase 3)
│   └── llm/
│       └── llm_bridge.gd        # ponte Ollama
├── assets/
│   ├── tilesets/
│   ├── characters/
│   └── sounds/
└── data/
    ├── phrases_fallback.json    # frases fixas para fallback
    └── holidays.yaml            # feriados (Fase 4)
```

## 3. Padrão LLM Bridge

O ficheiro `llm_bridge.gd` é o único ponto de contacto com o Ollama.
Nenhum outro script faz chamadas HTTP directas.

Interface pública:
```gdscript
# Sinal emitido quando a resposta chega
signal phrase_ready(text: String)

# Pede uma frase ao LLM com contexto
# context: dicionário com o estado actual (acção, hora, fome, etc.)
func request_phrase(context: Dictionary) -> void:
    pass
```

Contrato de comportamento:
- Chamada assíncrona (nunca bloqueia o render loop)
- Se Ollama não responder em 5s, emite signal com frase do fallback
- Fallback: carregar phrases_fallback.json no _ready()
- Nunca expor o URL do Ollama como constante pública — usar ProjectSettings

## 4. Padrão de necessidades (Needs)

Sistema de necessidades em `needs.gd`:
```gdscript
# Cada necessidade é um float 0.0 (crítico) a 1.0 (satisfeito)
var hunger: float = 1.0
var energy: float = 1.0  # Fase 2

signal need_critical(need_name: String)  # emite quando < 0.2
```

Regra: a behavior tree lê os valores mas não os altera directamente.
Só as Actions (go_fish, sleep, etc.) chamam métodos de needs.gd.

## 5. Padrão Behavior Tree (Beehave)

Cada Action é um nó Beehave separado em `scripts/character/behaviors/`.
Cada Action herda de `BTAction` e implementa:

```gdscript
extends BTAction

func tick(actor: Node, blackboard: Blackboard) -> int:
    # Lógica da acção
    # Retorna: SUCCESS, FAILURE, ou RUNNING
    return SUCCESS
```

O blackboard partilha estado entre nós:
- `blackboard.set_value("target_position", pos)`
- `blackboard.get_value("current_action", "")`

## 6. Sinais em vez de chamadas directas

Preferir sinais para comunicação entre camadas:
```gdscript
# BOM: character emite sinal, world responde
character.fishing_started.emit()

# MAU: character chama directamente o world
world.show_fishing_effect(character.position)
```

## 7. Comentários

Comentários em português quando explicam PORQUÊ (decisão de negócio):
```gdscript
# O personagem só fala a cada 30s para não ser intrusivo durante o trabalho
const MIN_PHRASE_INTERVAL: float = 30.0
```

Sem comentários óbvios:
```gdscript
# MAU: incrementa o contador  ← óbvio pelo código
count += 1
```

## 8. Dados externos em JSON/YAML

Frases fixas, feriados e configurações ficam em `data/`, não hard-coded no GDScript.
Carregar no `_ready()` com `FileAccess.open()`.

Exemplo de phrases_fallback.json:
```json
{
  "idle": [
    "Mais um dia nesta ilha...",
    "O oceano parece calmo hoje.",
    "Quando será que passa um barco?"
  ],
  "fishing": [
    "Vamos ver o que o mar tem para oferecer.",
    "Paciência. O peixe aparece."
  ],
  "eating": [
    "Hoje o jantar foi servido.",
    "Não é requintado, mas é nutritivo."
  ]
}
```

## 9. Exportação e portabilidade

- Nunca usar caminhos absolutos — sempre `res://` ou `user://`
- `user://` para dados persistentes (configurações do utilizador)
- `res://` para assets e dados do jogo
- Testar export Linux antes de fechar qualquer fase
