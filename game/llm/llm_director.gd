class_name LLMDirector
extends Node
## Director narrativo via Ollama (T-115): satisfaz o contrato IDirector por
## duck typing, exactamente como SimpleDirector (get_directive/is_available).
##
## Cada ciclo faz UMA chamada ao Ollama, sempre através do LLMBridge (AGENTS.md
## §6.2, code_patterns.md §6: só LLMBridge e WeatherService criam HTTPRequest),
## nunca por poll: alguém chama trigger_cycle(reason) quando um dos 3
## gatilhos documentados (TRIGGER_*) acontece. Enquanto o pedido está em
## curso, get_directive() continua a devolver a última directiva decidida
## (ou a de um SimpleDirector interno, antes de qualquer ciclo terminar); um
## trigger_cycle() novo nesse intervalo é ignorado, nunca duas chamadas
## simultâneas (is_thinking()).
##
## A resposta do LLM é validada contra o schema {arc, activity, phrase}
## (validate_directive); qualquer falha -- rede, timeout, JSON inválido,
## schema inválido -- resolve com a directiva do SimpleDirector injectado,
## nunca deixa o jogo sem directiva (mesma garantia de is_available() = true
## sempre).
##
## Mantém as últimas MEMORY_SIZE decisões em memory_path (por defeito
## user://director_memory.json), escrita atómica tmp + rename, mesmo padrão
## de game/world/arc_history.gd.
##
## Fora de âmbito (ver backlog/fase-3/T-115-llm-director.md): o LLM criar
## arcos novos (T-117) e o companheiro imaginário (T-118) -- o campo
## "companheiro" do contexto fica sempre null até essa tarefa existir.

## Emitido sempre que um ciclo termina, com sucesso ou em fallback. source:
## "llm" quando a directiva veio do Ollama e passou validate_directive();
## "fallback" em qualquer outro caso (SimpleDirector decidiu).
signal directive_ready(directive: DirectorDirective, source: String)

## Motivos de disparo documentados na tarefa T-115. Só entram no contexto
## enviado ao LLM (campo "gatilho", para logging/depuração) e no log; não
## mudam o comportamento do ciclo em si.
const TRIGGER_ACTIVITY_COMPLETED: String = "activity_completed"
const TRIGGER_NEED_THRESHOLD: String = "need_threshold_crossed"
const TRIGGER_SESSION_START: String = "session_start"

## Arcos válidos no campo "arc" da resposta do LLM: os mesmos que
## SimpleDirector conhece (fonte única, evita duplicar a lista aqui).
const VALID_ARCS: Array[String] = [
	SimpleDirector.ARC_JANGADA,
	SimpleDirector.ARC_COMPANHEIRO,
	SimpleDirector.ARC_SINALIZACAO,
	SimpleDirector.ARC_DIARIO,
	SimpleDirector.ARC_AVULSO,
]

## Quantos títulos de arcos recentes entram no contexto (critério de
## aceitação da T-115: "5 arcos recentes, só títulos").
const RECENT_ARCS_COUNT: int = 5

const PROMPT_PATH: String = "res://data/prompts/director_prompt.txt"
const DEFAULT_MEMORY_PATH: String = "user://director_memory.json"
const MEMORY_SIZE: int = 10
const LOG_PREFIX: String = "[Insulano/Director]"

## Quantos caracteres do raw_text invalido vao para o log (tech_design.md
## §4.5: "Nunca o prompt inteiro em release"; a mesma regra aplica-se aqui ao
## texto cru devolvido pelo LLM). Chega para depurar sem despejar uma
## resposta inteira no log a cada schema invalido.
const LOG_RAW_TEXT_MAX_CHARS: int = 200

## Tokens pedidos ao Ollama por ciclo. Calibrado por medição manual nesta
## máquina (Ollama em Docker, só CPU, AGENTS.md §9): uma resposta
## {arc, activity, phrase} completa usa tipicamente 40-50 tokens; 100 dá
## margem sem desperdiçar tempo de geração em tokens que nunca saem (o custo
## dominante da latência é a avaliação do prompt, ~400 tokens, não a
## geração -- ver Relatório da T-115 em
## backlog/fase-3/T-115-llm-director.md para os números medidos).
const NUM_PREDICT: int = 100
## Timeout por ciclo: maior do que o timeout_s por defeito de LLMSettings
## (8 s, calibrado para uma frase curta com prompt muito mais pequeno).
## Medido manualmente nesta máquina: uma chamada real ao director demora
## tipicamente 5-12 s com NUM_PREDICT=100; 25 s dá margem confortável sem
## deixar um ciclo preso indefinidamente.
const REQUEST_TIMEOUT_S: float = 25.0
## Tokens pedidos ao Ollama para geracao de arco: resposta JSON com titulo,
## tipo e array de fases e mais longa do que uma directiva {arc, activity,
## phrase}, logo precisa de mais margem para nao ser cortada a meio (T-117).
const ARC_GEN_NUM_PREDICT: int = 300
## Timeout para pedido de geracao de arco, mais alto do que REQUEST_TIMEOUT_S
## porque o prompt de geracao e mais longo (mais tokens de avaliacao).
const ARC_GEN_TIMEOUT_S: float = 40.0
## Objectos fixos presentes na ilha enviados no prompt de geracao de arco
## (narrative-design.md §3): fonte unica de verdade desta lista (T-117).
const ISLAND_OBJECTS: Array[String] = ["palmeira", "pedras", "madeira", "coco", "peixe", "fogueira"]

## NeedsManager a usar; null usa o autoload "/root/NeedsManager" (mesma
## injecção de SimpleDirector.needs_manager).
var needs_manager: Node = null
## ArcHistory a usar (arco activo e títulos recentes); null usa o autoload
## "/root/ArcHistory".
var arc_history: Node = null
## GameClock a usar; null usa o autoload "/root/Clock".
var clock: Node = null
## Ponte LLM a usar; null usa o autoload "/root/LLM" (code_patterns.md §5).
var bridge: Node = null
## Filtro aplicado ao campo "phrase" da resposta do LLM antes de entrar na
## directiva (bloqueante 3 da revisão da T-115: o "phrase" é texto destinado
## ao utilizador, tal como o do fluxo de frases do LLMBridge, por isso passa
## pelas mesmas regras de game/data/phrase_rules.json, nunca aparece cru no
## jogo). null usa PhraseFilter.from_rules_file() (mesmo padrão de injecção
## de needs_manager/arc_history/clock/bridge acima).
var phrase_filter: PhraseFilter = null
## Director determinístico para qualquer fallback; criado lazy (com
## needs_manager partilhado, se injectado) se não for injectado.
var fallback_director: SimpleDirector = null
## Caminho do ficheiro de memória; sobreponível nos testes (mesmo padrão de
## EventDirector._config_path) para nunca escrever por cima do
## user://director_memory.json real. O caminho do tmp deriva-se substituindo
## ".json" por ".tmp.json".
var memory_path: String = DEFAULT_MEMORY_PATH

## Template do prompt, carregado uma vez em _ready() (ver code_patterns.md
## §5: var pública/injectável fica antes desta, que é interna).
var _template: String = ""
## Última directiva decidida por um ciclo (LLM ou fallback); null antes do
## primeiro ciclo terminar.
var _current_directive: DirectorDirective = null
## Verdadeiro enquanto há um pedido ao LLM em curso.
var _is_thinking: bool = false
## request_id do pedido em curso à espera de completion_ready, ou -1.
var _awaiting_request_id: int = -1
## Guardam uma resposta que chegou SINCRONAMENTE dentro da própria chamada a
## request_completion (mesma armadilha documentada em
## game/beehave/say_generated_action.gd: a ponte pode responder antes de
## _awaiting_request_id ficar atribuído quando está desligada, ocupada ou o
## prompt vem vazio).
var _has_result: bool = false
var _result_request_id: int = -1
var _result_raw: String = ""
var _result_source: String = ""
## Último evento livre registado por set_last_event(), para o campo
## "ultimo_evento" do contexto.
var _last_event: String = ""
## Últimas decisões, mais recente no fim; carregadas de memory_path em
## _ready() e persistidas a cada ciclo resolvido.
var _memory: Array = []
## Definicoes de arcos em memoria: os 3 base de arc_definitions.json mais os
## gerados pelo LLM nesta sessao (T-117). Chave: titulo normalizado.
var _arc_definitions_extra: Array = []
## request_id de um pedido de geracao de arco em curso, ou -1. Separado de
## _awaiting_request_id para os dois fluxos (directiva e geracao) nao
## colidirem quando correndo em momentos diferentes.
var _arc_gen_request_id: int = -1
## Dia do ultimo arco que entrou no historico (active ou completed); usado
## pelo criterio dia_desde_ultimo_arco >= 1 de _should_generate_arc().
## -1 significa que ainda nenhum arco foi registado nesta sessao.
var _last_arc_day: int = -1


## Carrega o template do prompt e a memória de decisões do disco.
func _ready() -> void:
	_template = FileAccess.get_file_as_string(PROMPT_PATH)
	if _template.is_empty():
		push_error(LOG_PREFIX + " template do prompt vazio ou inexistente: " + PROMPT_PATH)
	_load_memory()


## Devolve a directiva actual para o EventDirector executar (mesmo contrato
## de SimpleDirector.get_directive()): a última decidida por um ciclo
## terminado, ou a do SimpleDirector de fallback se nenhum ciclo terminou
## ainda (ex.: logo a seguir a session_start, antes da resposta chegar).
func get_directive() -> DirectorDirective:
	if _current_directive == null:
		return _get_fallback_director().get_directive()
	return _current_directive


## Sempre disponível: tal como SimpleDirector, este director nunca deixa o
## jogo sem directiva (fallback garantido em qualquer erro).
func is_available() -> bool:
	return true


## Verdadeiro enquanto há um ciclo (pedido ao LLM) em curso.
func is_thinking() -> bool:
	return _is_thinking


## Regista o último evento livre (ex.: "tentativa_de_pescar_fracassada") para
## entrar no contexto do próximo ciclo, no campo "ultimo_evento".
func set_last_event(event: String) -> void:
	_last_event = event


## Verifica se as condicoes para gerar um arco novo via LLM estao reunidas
## (T-117): TEDIO >= 65, nenhum arco activo e pelo menos 1 dia desde o
## ultimo arco registado. Devolve false se qualquer dependencia estiver
## ausente (sem NeedsManager, sem ArcHistory ou sem Clock).
func _should_generate_arc() -> bool:
	var nm := _get_needs_manager()
	var history := _get_arc_history()
	var game_clock := _get_clock()
	if nm == null or not nm.has_method("get_value"):
		return false
	if history == null or game_clock == null or not game_clock.has_method("now"):
		return false
	if nm.get_value("TEDIO") < 65.0:
		return false
	var active: Dictionary = history.active_arc if "active_arc" in history else {}
	if not active.is_empty():
		return false
	var current_day: int = int(game_clock.now().get("day", 0))
	return current_day >= 1 if _last_arc_day < 0 else (current_day - _last_arc_day) >= 1


## Constroi o prompt de geracao de arco para o Ollama (T-117): inclui os
## titulos dos arcos ja completados (para nao repetir), os objectos
## disponiveis na ilha, o estado actual do naufrago (dias, needs, hora) e a
## instrucao de formato JSON exacto esperado.
func _generate_arc_prompt() -> String:
	var history := _get_arc_history()
	var completed_titles: Array = []
	if history != null and history.has_method("get_recent_titles"):
		completed_titles = history.get_recent_titles(50)

	var nm := _get_needs_manager()
	var needs_snapshot: Dictionary = {}
	if nm != null and nm.has_method("get_snapshot"):
		needs_snapshot = nm.get_snapshot()

	var game_clock := _get_clock()
	var day := 0
	var hour_text := "12:00"
	if game_clock != null and game_clock.has_method("now"):
		var now: Dictionary = game_clock.now()
		day = int(now.get("day", 0))
		hour_text = "%02d:%02d" % [int(now.get("hour", 0)), int(now.get("minute", 0))]

	var ctx := {
		"arcos_completados": completed_titles,
		"objectos_na_ilha": ISLAND_OBJECTS,
		"dias_sobrevividos": day,
		"necessidades": needs_snapshot,
		"hora": hour_text,
	}
	var instrucao := (
		"Inventa um arco narrativo original para um naufrago solitario. "
		+ "Responde APENAS com JSON valido, sem markdown, com exactamente estes campos: "
		+ '{"titulo": string, "tipo": string, "fases": [{"nome": string, '
		+ '"actividade": string, "duracao_ciclos": int}], '
		+ '"necessidade_que_sobe": string}. '
		+ "O arco deve ter no minimo 2 fases. "
		+ "Nao repitas nenhum dos arcos ja completados listados no contexto."
	)
	return instrucao + "\n\nContexto:\n" + JSON.stringify(ctx, "  ")


## Valida o dicionario de um arco gerado pelo LLM (T-117):
## - tem \"titulo\" (string nao vazia)
## - tem \"fases\" (array com >= 2 entradas)
## - titulo nao repete nenhum arco em ArcHistory (case-insensitive normalizado)
## - cada fase tem \"nome\" e \"actividade\"
## Devolve false em qualquer desvio.
func _validate_arc(data: Dictionary) -> bool:
	if not data.has("titulo"):
		return false
	if typeof(data["titulo"]) != TYPE_STRING:
		return false
	var titulo: String = String(data["titulo"]).strip_edges()
	if titulo.is_empty():
		return false
	if not data.has("fases"):
		return false
	if typeof(data["fases"]) != TYPE_ARRAY:
		return false
	var fases: Array = data["fases"]
	if fases.size() < 2:
		return false
	for fase in fases:
		if typeof(fase) != TYPE_DICTIONARY:
			return false
		if not fase.has("nome") or not fase.has("actividade"):
			return false
	var titulo_norm: String = titulo.to_lower()
	var history := _get_arc_history()
	if history != null and "completed_arcs" in history:
		for arc in history.completed_arcs:
			var arc_titulo: String = String(arc.get("titulo", "")).strip_edges().to_lower()
			if arc_titulo == titulo_norm:
				return false
	if "active_arc" in history and not history.active_arc.is_empty():
		var active_titulo: String = (
			String(history.active_arc.get("titulo", "")).strip_edges().to_lower()
		)
		if active_titulo == titulo_norm:
			return false
	return true


## Dispara um ciclo de decisão: monta o contexto, pede ao LLMBridge uma
## conclusão (LLM.request_completion, UMA única chamada) e fica à espera do
## sinal completion_ready para validar e aplicar a resposta. reason é um dos
## TRIGGER_*, só para contexto/log. Um ciclo já em curso ignora o pedido
## novo -- nunca duas chamadas simultâneas ao Ollama.
## Se as condicoes de geracao de arco estiverem reunidas (_should_generate_arc),
## dispara tambem um pedido de geracao em paralelo (T-117).
func trigger_cycle(reason: String) -> void:
	if _is_thinking:
		return
	_is_thinking = true
	_has_result = false

	# T-117: verificar condicao de geracao de arco antes do ciclo de directiva.
	if _should_generate_arc() and _arc_gen_request_id == -1:
		var current_bridge := _get_bridge()
		if current_bridge != null:
			var arc_prompt := _generate_arc_prompt()
			if not arc_prompt.is_empty():
				if not current_bridge.completion_ready.is_connected(_on_arc_gen_ready):
					current_bridge.completion_ready.connect(_on_arc_gen_ready)
				_arc_gen_request_id = current_bridge.request_completion(
					arc_prompt, ARC_GEN_NUM_PREDICT, ARC_GEN_TIMEOUT_S
				)
				print(
					LOG_PREFIX + " geracao de arco disparada (request_id=%d)" % _arc_gen_request_id
				)

	var context := _build_context(reason)
	var prompt := build_prompt(_template, context)
	var current_bridge := _get_bridge()
	if current_bridge == null:
		# Autoload "/root/LLM" ausente (cena de teste sem ele e sem injecção
		# de bridge) e nenhuma ponte injectada: sem este guarda, a chamada a
		# request_completion() abaixo desreferenciava null e is_thinking()
		# ficava preso a true para sempre, porque _resolve() nunca corria
		# (bloqueante apontado na revisão da T-115). Resolve já em fallback,
		# mesma combinação (raw_text="", source="fallback") que o LLMBridge
		# real emite quando não consegue responder.
		_resolve(-1, "", "fallback")
		return
	if not current_bridge.completion_ready.is_connected(_on_completion_ready):
		current_bridge.completion_ready.connect(_on_completion_ready)

	var request_id: int = current_bridge.request_completion(prompt, NUM_PREDICT, REQUEST_TIMEOUT_S)

	# A ponte pode já ter respondido SINCRONAMENTE dentro da chamada acima
	# (desligada, ocupada ou prompt vazio, ver llm_bridge.gd): sem este
	# cheque, _on_completion_ready teria corrido com _awaiting_request_id
	# ainda em -1 e a resposta ficava perdida (armadilha documentada em
	# say_generated_action.gd).
	if _has_result and _result_request_id == request_id:
		_resolve(request_id, _result_raw, _result_source)
		_has_result = false
		return
	_awaiting_request_id = request_id


## Recetor de LLMBridge.completion_ready. Ignora sinais de pedidos que não
## são o actualmente aguardado (guarda o resultado para trigger_cycle()
## consumir, caso a resposta chegue síncrona); resolve directamente quando
## bate com _awaiting_request_id.
func _on_completion_ready(request_id: int, raw_text: String, source: String) -> void:
	if request_id != _awaiting_request_id:
		_has_result = true
		_result_request_id = request_id
		_result_raw = raw_text
		_result_source = source
		return
	_resolve(request_id, raw_text, source)


## Recetor do sinal completion_ready para pedidos de geracao de arco (T-117).
## Ignora request_ids que nao sejam o _arc_gen_request_id em curso.
## Se o arco for valido: guarda em _arc_definitions_extra e em ArcHistory
## com origem="llm". Se invalido (JSON inválido, schema, titulo repetido):
## SimpleDirector escolhe um arco base como fallback.
func _on_arc_gen_ready(request_id: int, raw_text: String, source: String) -> void:
	if request_id != _arc_gen_request_id:
		return
	_arc_gen_request_id = -1
	var current_bridge := _get_bridge()
	if current_bridge != null and current_bridge.completion_ready.is_connected(_on_arc_gen_ready):
		current_bridge.completion_ready.disconnect(_on_arc_gen_ready)
	if source != "llm":
		print(LOG_PREFIX + " geracao de arco: fallback (ponte nao respondeu)")
		_get_fallback_director().get_directive()
		return
	var data := parse_directive(raw_text)
	if _validate_arc(data):
		var titulo: String = String(data["titulo"]).strip_edges()
		data["origem"] = "llm"
		_arc_definitions_extra.append(data)
		var history := _get_arc_history()
		if history != null and history.has_method("add_completed") == false:
			# ArcHistory nao tem add_completed para arcos activos -- registar
			# como active_arc para que o director o possa usar nos proximos ciclos.
			history.active_arc = data
			history.save_history()
		elif history != null:
			# Guardar directamente como active_arc (arco novo, ainda nao completado).
			history.active_arc = data
			if history.has_method("save_history"):
				history.save_history()
		var game_clock := _get_clock()
		if game_clock != null and game_clock.has_method("now"):
			_last_arc_day = int(game_clock.now().get("day", 0))
		print(LOG_PREFIX + ' arco gerado pelo LLM: "' + titulo + '" (origem=llm)')
	else:
		print(
			(
				LOG_PREFIX
				+ " arco gerado invalido, fallback para arco base: "
				+ _truncated_for_log(raw_text)
			)
		)
		_get_fallback_director().get_directive()


## Valida a resposta (quando source = "llm") e decide a directiva final:
## a do LLM se passar o schema, senão a do SimpleDirector de fallback.
## Persiste a decisão em memória e emite directive_ready exactamente uma vez.
func _resolve(_request_id: int, raw_text: String, source: String) -> void:
	_awaiting_request_id = -1

	var directive: DirectorDirective
	var final_source: String

	if source == "llm":
		var data := parse_directive(raw_text)
		if validate_directive(data):
			directive = directive_from_data(data)
			# O "phrase" e texto destinado ao utilizador (o proprio prompt pede
			# "frase curta que o naufrago diria agora em voz alta"), por isso
			# passa pelo mesmo PhraseFilter do fluxo de frases do LLMBridge
			# antes de entrar na directiva (bloqueante 3, revisao da T-115):
			# validate_directive so confirma o TIPO, nunca o conteudo. Uma
			# frase rejeitada (ingles, PT-BR, proibida, etc.) fica vazia com
			# log, mas arc/activity continuam a valer do LLM -- rejeitar a
			# directiva inteira por causa da frase desperdicaria uma decisao
			# de arco/actividade boa por um problema so no texto falado.
			var raw_phrase := String(directive.phrase_context_extra.get("phrase", ""))
			directive.phrase_context_extra["phrase"] = _filter_phrase(raw_phrase)
			final_source = "llm"
		else:
			print(
				LOG_PREFIX + " resposta invalida do LLM, fallback: " + _truncated_for_log(raw_text)
			)
			directive = _get_fallback_director().get_directive()
			final_source = "fallback"
	else:
		directive = _get_fallback_director().get_directive()
		final_source = "fallback"

	_current_directive = directive
	_remember_decision(directive, final_source)
	_is_thinking = false
	directive_ready.emit(directive, final_source)


## Monta o contexto enviado ao LLM (critério de aceitação da T-115): dia,
## hora, estação, as necessidades, o arco activo, os últimos
## RECENT_ARCS_COUNT títulos de arcos, o companheiro (sempre null: T-118
## está fora de âmbito aqui) e o último evento livre.
func _build_context(reason: String) -> Dictionary:
	var nm := _get_needs_manager()
	var needs: Dictionary = {}
	if nm != null and nm.has_method("get_snapshot"):
		needs = nm.get_snapshot()

	var history := _get_arc_history()
	var active_arc: Dictionary = {}
	var recent_titles: Array = []
	if history != null:
		if "active_arc" in history:
			active_arc = history.active_arc
		if history.has_method("get_recent_titles"):
			recent_titles = history.get_recent_titles(RECENT_ARCS_COUNT)

	var day := 0
	var month := 1
	var hour_text := ""
	var game_clock := _get_clock()
	if game_clock != null and game_clock.has_method("now"):
		var now: Dictionary = game_clock.now()
		day = int(now.get("day", 0))
		month = int(now.get("month", 1))
		hour_text = "%02d:%02d" % [int(now.get("hour", 0)), int(now.get("minute", 0))]

	return {
		"gatilho": reason,
		"dia": day,
		"hora": hour_text,
		"estacao": season_for_month(month),
		"necessidades": needs,
		"arco_activo": active_arc,
		"arcos_recentes": recent_titles,
		"companheiro": null,
		"ultimo_evento": _last_event,
	}


## Estação do ano por mês (1-12), hemisfério norte (Portugal): Dez-Fev
## inverno, Mar-Mai primavera, Jun-Ago verão, Set-Nov outono. Mês fora do
## intervalo cai em "Verao" por defeito, nunca "" (o contexto nunca tem
## campos vazios por engano de dados).
static func season_for_month(month: int) -> String:
	match month:
		12, 1, 2:
			return "Inverno"
		3, 4, 5:
			return "Primavera"
		6, 7, 8:
			return "Verao"
		9, 10, 11:
			return "Outono"
		_:
			return "Verao"


## Substitui o marcador "{{CONTEXTO}}" do template pelo contexto em JSON.
## Não usa String.format (PromptBuilder.build): o template do director tem
## chavetas literais no exemplo de JSON pedido ao LLM, que colidiriam com
## esse mecanismo. "" se o template vier vazio (ficheiro em falta).
static func build_prompt(template: String, context: Dictionary) -> String:
	if template.is_empty():
		return ""
	return template.replace("{{CONTEXTO}}", JSON.stringify(context, "  "))


## Extrai um Dictionary do texto cru devolvido pelo LLM. Remove blocos de
## código markdown (```json ... ``` ou ``` ... ```) antes de tentar o parse,
## porque modelos como o llama3.1:8b por vezes envolvem a resposta nessas
## cercas apesar do prompt pedir só JSON. {} em qualquer falha (texto vazio,
## JSON inválido, ou JSON válido mas que não é um objecto).
static func parse_directive(raw_text: String) -> Dictionary:
	var cleaned := raw_text.strip_edges()
	if cleaned.is_empty():
		return {}
	if cleaned.begins_with("```"):
		var lines := cleaned.split("\n")
		if lines.size() >= 2:
			lines.remove_at(0)
			if lines[-1].strip_edges() == "```":
				lines.remove_at(lines.size() - 1)
			cleaned = "\n".join(lines).strip_edges()
	var data: Variant = JSON.parse_string(cleaned)
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	return data


## Schema exigido pelo critério de aceitação da T-115: "arc" (String, um dos
## VALID_ARCS), "activity" (String não vazia) e "phrase" (String, pode ser
## vazia -- nem toda a actividade implica falar). Qualquer desvio (campo em
## falta, tipo errado, arco desconhecido) devolve false.
static func validate_directive(data: Dictionary) -> bool:
	if not (data.has("arc") and data.has("activity") and data.has("phrase")):
		return false
	if typeof(data["arc"]) != TYPE_STRING or not (data["arc"] in VALID_ARCS):
		return false
	if typeof(data["activity"]) != TYPE_STRING or String(data["activity"]).is_empty():
		return false
	if typeof(data["phrase"]) != TYPE_STRING:
		return false
	return true


## Converte um Dictionary já validado (validate_directive() = true) numa
## DirectorDirective. tone fica "neutro": o schema desta tarefa não pede tom
## (ao contrário do SimpleDirector, que o lê de simple_director_phrases.json).
static func directive_from_data(data: Dictionary) -> DirectorDirective:
	var directive := DirectorDirective.new()
	directive.arc_id = data.get("arc", "")
	directive.activity = data.get("activity", "")
	directive.tone = "neutro"
	directive.phrase_context_extra = {"phrase": data.get("phrase", "")}
	return directive


## NeedsManager activo: o injectado, ou o autoload.
func _get_needs_manager() -> Node:
	return needs_manager if needs_manager != null else get_node_or_null("/root/NeedsManager")


## ArcHistory activo: o injectado, ou o autoload.
func _get_arc_history() -> Node:
	return arc_history if arc_history != null else get_node_or_null("/root/ArcHistory")


## GameClock activo: o injectado, ou o autoload.
func _get_clock() -> Node:
	return clock if clock != null else get_node_or_null("/root/Clock")


## Ponte LLM activa: a injectada, ou o autoload.
func _get_bridge() -> Node:
	return bridge if bridge != null else get_node_or_null("/root/LLM")


## PhraseFilter activo: o injectado, ou lido de phrase_rules.json (lazy,
## mesmo padrao do fallback_director abaixo).
func _get_phrase_filter() -> PhraseFilter:
	if phrase_filter == null:
		phrase_filter = PhraseFilter.from_rules_file()
	return phrase_filter


## Limpa e valida raw_phrase contra o PhraseFilter (tech_design.md §4.3):
## "" se raw_phrase ja vier vazio (nem toda actividade implica falar, ver
## validate_directive) ou se o filtro rejeitar; senao o texto limpo. O motivo
## de rejeicao so vai para o log (LOG_PREFIX), nunca para a directiva.
func _filter_phrase(raw_phrase: String) -> String:
	if raw_phrase.is_empty():
		return ""
	var cleaned := _get_phrase_filter().clean(raw_phrase)
	var reason := _get_phrase_filter().rejection_reason(cleaned)
	if reason != "":
		print(
			(
				LOG_PREFIX
				+ (
					" frase rejeitada pelo PhraseFilter (%s): %s"
					% [reason, _truncated_for_log(raw_phrase)]
				)
			)
		)
		return ""
	return cleaned


## SimpleDirector de fallback: o injectado, ou uma instância criada na
## primeira falta, partilhando needs_manager quando este foi injectado (para
## o fallback ver o mesmo estado que o LLMDirector via nos testes).
func _get_fallback_director() -> SimpleDirector:
	if fallback_director == null:
		fallback_director = SimpleDirector.new()
		if needs_manager != null:
			fallback_director.needs_manager = needs_manager
	return fallback_director


## Corta raw_text a LOG_RAW_TEXT_MAX_CHARS para o log, com "..." quando corta
## (nunca esconde SE cortou, para quem le o log nao pensar que a resposta
## inteira era so aquilo).
static func _truncated_for_log(raw_text: String) -> String:
	if raw_text.length() <= LOG_RAW_TEXT_MAX_CHARS:
		return raw_text
	return raw_text.substr(0, LOG_RAW_TEXT_MAX_CHARS) + "..."


## Caminho do ficheiro temporário para a escrita atómica de memory_path.
func _memory_tmp_path() -> String:
	return memory_path.replace(".json", ".tmp.json")


## Carrega decisoes_recentes de memory_path, se existir. Em qualquer erro
## (JSON inválido, formato inesperado) começa vazio -- nunca impede o
## director de arrancar (mesmo critério de ArcHistory.load_history()).
func _load_memory() -> void:
	if not FileAccess.file_exists(memory_path):
		return
	var text := FileAccess.get_file_as_string(memory_path)
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_warning(LOG_PREFIX + " director_memory.json invalido, a comecar vazio")
		return
	var decisions: Variant = data.get("decisoes_recentes", [])
	if decisions is Array:
		_memory = decisions


## Acrescenta a decisão às últimas MEMORY_SIZE (critério de aceitação da
## T-115) e grava de forma atómica (tmp + rename, mesmo padrão de
## arc_history.gd).
func _remember_decision(directive: DirectorDirective, source: String) -> void:
	(
		_memory
		. append(
			{
				"arc": directive.arc_id,
				"activity": directive.activity,
				"source": source,
				"timestamp": Time.get_unix_time_from_system(),
			}
		)
	)
	if _memory.size() > MEMORY_SIZE:
		_memory = _memory.slice(_memory.size() - MEMORY_SIZE)
	_save_memory()


## Escreve _memory em memory_path via tmp + rename.
func _save_memory() -> void:
	var data := {"decisoes_recentes": _memory}
	var f := FileAccess.open(_memory_tmp_path(), FileAccess.WRITE)
	if f == null:
		push_warning(LOG_PREFIX + " nao conseguiu abrir tmp de memoria: " + _memory_tmp_path())
		return
	f.store_string(JSON.stringify(data))
	f.close()
	DirAccess.rename_absolute(
		ProjectSettings.globalize_path(_memory_tmp_path()),
		ProjectSettings.globalize_path(memory_path)
	)
