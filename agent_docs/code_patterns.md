# Padrões de código: Insulano

Ler antes de escrever GDScript. O `scripts/verify.sh` aplica mecanicamente o que está marcado com
**(portão)**; o resto é revisto pelo `insulano-reviewer`.

---

## 1. Estilo

- GDScript 2 tipado: tipos em variáveis, parâmetros e retornos de tudo o que é novo. Inferência `:=`
  só quando o tipo é óbvio pelo lado direito.
- `snake_case` em variáveis, funções e ficheiros; `PascalCase` em `class_name` e nós; `UPPER_CASE` em constantes.
- Membros privados começam por `_`.
- Formatação `gdformat` e lint `gdlint` com as regras por defeito do gdtoolkit 4 (linha até 100) **(portão)**.
- Ordem num ficheiro: `extends`, `class_name`, docstring `##`, `signal`, `enum`, `const`, `@export`,
  `var` públicas, `var` privadas, `_init`/`_ready`/`_process`, funções públicas, funções privadas.

## 2. Documentação dentro do código

Critério da fábrica para código de produto: um humano que nunca viu o código consegue corrigi-lo daqui
a um ano, sozinho.

- Todo o `.gd` começa (depois de `extends`/`class_name`) com um bloco `##`: responsabilidade, quem o usa,
  e o que **não** faz **(portão)**.
- Toda a função pública tem `##` imediatamente acima (anotações `@` podem ficar no meio) **(portão)**.
- Comentários `#` para o porquê de decisões não óbvias, em português.
- Constantes mágicas têm comentário com a origem do valor.

```gdscript
extends RefCounted
class_name PhraseFilter
## Aceita ou rejeita frases geradas pelo LLM segundo game/data/phrase_rules.json.
##
## Usado pelo LLMBridge antes de emitir phrase_ready. Não chama a rede nem escolhe
## frases de fallback. Tem paridade testada com scripts/llm_eval.py.

## Máximo de palavras aceite; lido das regras, este valor só vale se o ficheiro faltar.
const DEFAULT_MAX_WORDS: int = 15


## Devolve "" se a frase é aceite; senão o motivo (empty, english, ptbr, ...).
func rejection_reason(text: String) -> String:
	...
```

## 3. Estrutura de pastas (por funcionalidade)

A base organiza por funcionalidade e mantemos isso. Não criar `scripts/` nem `scenes/` genéricos dentro de `game/`.

```
game/
├── beehave/      folhas da behavior tree (ActionLeaf, ConditionLeaf)
├── character/    Character, Need, sprites do personagem
├── guy/          cena e script do náufrago, Direction
├── object/       objectos utilizáveis (peixe, contentores)
├── world/        ilha, tileset, GameClock, DayNight, WeatherService, HolidayCalendar
├── llm/          LLMSettings, PhraseContext, PromptBuilder, PhraseFilter, FallbackPhrases, LLMBridge
├── events/       EventDirector, gaivota, barco
├── ui/           SpeechBubble, créditos
├── app/          ScreensaverMode
├── data/         JSON e prompts (fonte única)
├── tests/        unit/, integration/, live/, fixtures/
└── tools/        boot_smoke.gd, capture.gd
```

## 4. Behavior tree (Beehave 2.x)

```gdscript
@tool
extends ActionLeaf
class_name SleepAction
## Faz o personagem dormir até a energia recuperar ou deixar de ser noite.


func tick(actor: Node, blackboard: Blackboard) -> int:
	var character := actor as Character
	if character == null:
		return FAILURE
	blackboard.set_value("current_action", "dormir")
	...
	return RUNNING
```

- Usar `SUCCESS`, `FAILURE`, `RUNNING` (nunca `FAILED`, que é a constante global de erro).
- A árvore **lê** necessidades; só as acções as alteram através de métodos de `Need`.
- Estado temporário de uma acção vive no blackboard com chaves prefixadas pelo nome da acção
  (ex. `sleep_started_at`) e é apagado com `erase_value` quando a acção termina.
- Cada acção escreve `current_action` (verbo em pt-PT) para o contexto do LLM.

## 5. Comunicação entre sistemas

- Sinais para baixo-para-cima e entre sistemas; chamadas directas só para dentro do próprio subsistema.
- Autoloads (`LLM`, `Clock`, `Events`, `Weather`, `Screensaver`) são as únicas dependências globais.
- Para testar, qualquer nó que usa um autoload aceita uma referência injectada:

```gdscript
## Ponte a usar; em testes injecta-se uma falsa, em jogo fica o autoload.
var bridge: Node = null


func _get_bridge() -> Node:
	return bridge if bridge != null else get_node("/root/LLM")
```

## 6. Rede

Só `LLMBridge` e `WeatherService` criam `HTTPRequest` **(revisão)**. Padrão:

```gdscript
var _http := HTTPRequest.new()
_http.timeout = settings.timeout_s
add_child(_http)
_http.request_completed.connect(_on_request_completed)
var err := _http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(payload))
if err != OK:
	_emit_fallback(request_id, "request_error_%d" % err)
```

- URL sempre `127.0.0.1`, nunca `localhost`.
- Toda a falha tem um caminho de fallback e emite o sinal exactamente uma vez.

## 7. Dados

```gdscript
static func _load_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[Insulano/data] JSON inválido: %s" % path)
		return {}
	return data
```

- O `JSON` do Godot devolve números como `float`: `int(rule["month"])`.
- Ficheiros de dados em `res://data/`; preferências do utilizador em `user://settings.cfg`.
- Nunca caminhos absolutos.

## 8. Logging e erros

- Prefixo por subsistema: `[Insulano/LLM]`, `[Insulano/Weather]`, `[Insulano/data]`.
- `push_error` para estados que não deviam acontecer; `print` só para eventos úteis (latência, fallback).
- Nada de `print` dentro de `tick` ou `_process` (inunda o log; ver T-003).

## 9. Testes

- Teste primeiro. Nomes `test_<comportamento_esperado>`; regressões `test_regression_<bug>`.
- Lógica pura em `static func` ou `RefCounted` e testada em `tests/unit`.
- Cenas e sinais em `tests/integration`, com `add_child_autofree`.
- Nunca rede em `tests/unit` ou `tests/integration`: fixtures em `tests/fixtures/`.
- Aleatoriedade com seed fixa. Nada de "correr outra vez até passar".

Detalhe: [`testing.md`](testing.md).
