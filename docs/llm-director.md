# Insulano -- LLM Director: A IA como Directora Narrativa

*Documento de Arquitectura v1.0 (visao original, pre-implementacao)*

**Nota (T-115, 2026-09-15):** este documento descreve a visao inicial (3 chamadas ao LLM por
ciclo, tick de 15 minutos, criacao de arcos pelo LLM, memoria com "padroes detectados"). O que
ficou construido diverge em pontos concretos: uma unica chamada por ciclo devolvendo
`{arc, activity, phrase}`, ciclo event-driven (sem tick timer) e sem criacao de arcos novos
(adiada para a T-117). A API de exemplo na seccao 4 (`LLMBridge.request()`, `max_tokens`) tambem
nao corresponde ao codigo real. Para o contrato e o comportamento tal como existem hoje, ver
`agent_docs/tech_design.md` §4.5-§4.7 e `backlog/fase-3/T-115-llm-director.md`. As seccoes 1
(arcos), 5 (modo degradado) e 7 (director como personagem) continuam validas como visao para
tarefas futuras (T-117, T-118) ainda nao construidas.

## Conceito Central

O Ollama nao e apenas um gerador de frases. E o **director criativo** do Insulano.

Em cada ciclo de decisao, o LLM Director recebe o estado completo do jogo e toma tres tipos de decisao:

1. **Qual arco activar** (ou manter o actual, ou pausar e retomar outro)
2. **Qual actividade/evento disparar agora** dentro do arco activo
3. **O que o naufrago diz** sobre o que esta a acontecer

Isto transforma o Insulano de "screensaver com eventos aleatorios" para "screensaver com um director invisivel que conhece toda a historia e toma decisoes contextuais".

---

## Arquitectura do Loop de Decisao

```
┌─────────────────────────────────────────────────────────┐
│                     GAME STATE                          │
│  necessidades, dia, estacao, arcos, historico,          │
│  companheiro, ultimo evento, fragmentos encontrados     │
└─────────────────────────┬───────────────────────────────┘
                          │ a cada tick (15 min ou evento)
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   LLM DIRECTOR                          │
│                   (Ollama local)                        │
│                                                         │
│  Pergunta 1: Qual arco activar/manter/pausar?           │
│  Pergunta 2: Qual evento/actividade disparar agora?     │
│  Pergunta 3: O que diz o naufrago?                      │
└─────────────────────────┬───────────────────────────────┘
                          │ resposta JSON
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  EVENT DIRECTOR                         │
│  Valida a decisao do LLM                               │
│  Executa o evento escolhido                             │
│  Actualiza GameState e arc_history.json                 │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
                    (volta ao inicio)
```

---

## 1. Decisao de Arco

### O que o LLM Director decide

Em cada ciclo, o LLM pode:

- **MANTER** o arco activo e avanclar para a proxima fase
- **PAUSAR** o arco activo e iniciar outro (retoma depois)
- **TERMINAR** o arco activo (mesmo que nao tenha chegado ao fim previsto)
- **CRIAR** um arco novo (com as fases que ele proprio define)
- **RETOMAR** um arco pausado anteriormente
- **ESPERAR** (nenhum arco, o naufrago vive o quotidiano)

### Contexto enviado ao LLM para decisao de arco

```json
{
  "dia": 47,
  "hora": "16:30",
  "estacao": "Outono",
  "necessidades": {
    "FOME": {"valor": 45, "nivel": "moderada"},
    "SOLIDAO": {"valor": 72, "nivel": "alta"},
    "TEDIO": {"valor": 61, "nivel": "moderado"},
    "ESPERANCA": {"valor": 38, "nivel": "baixa"}
  },
  "arco_activo": {
    "id": "arc_jangada_2",
    "titulo": "A Jangada (2a tentativa)",
    "fase_actual": 2,
    "total_fases": 5,
    "descricao_fase_actual": "A construir a jangada ha 3 dias",
    "pausado": false
  },
  "arcos_pausados": [
    {"id": "arc_companheiro_1", "titulo": "Amizade com o Tabinho", "fase": 3}
  ],
  "arcos_completados": [
    "A Jangada (1a tentativa - afundou no dia 14)",
    "A Teoria do Cozinheiro (criado pela IA, dia 23)",
    "O Calendário na Rocha"
  ],
  "ultimo_evento": "tentativa_de_pescar_fracassada",
  "companheiro": {"nome": "Tabinho", "objecto": "tabua", "ativo": true},
  "fragmentos_encontrados": ["sapato_01", "carta_molhada_01"],
  "ultima_decisao_ia": "MANTER arc_jangada_2",
  "ticks_sem_mudanca_de_arco": 4
}
```

### Resposta esperada do LLM (JSON)

```json
{
  "decisao_arco": "PAUSAR",
  "arco_a_pausar": "arc_jangada_2",
  "razao": "SOLIDAO muito alta, Tabinho foi esquecido ha 4 ticks, retomar a amizade primeiro",
  "proximo_arco": "arc_companheiro_1",
  "criar_arco_novo": false
}
```

Ou, se quiser criar um arco novo:

```json
{
  "decisao_arco": "CRIAR",
  "arco_a_pausar": "arc_jangada_2",
  "razao": "ESPERANCA muito baixa, precisa de momento de leveza",
  "novo_arco": {
    "titulo": "O Festival das Conchas",
    "tipo": "absurdo",
    "fases": [
      "Decide organizar um concurso de beleza entre as suas conchas",
      "Cria categorias: Miss Elegancia, Mr. Robustez, Premo Especial do Jury",
      "Cerimonia solene de entrega de premios (pedrinhas como trofeus)",
      "Discurso de encerramento dirigido ao oceano"
    ],
    "como_termina": "Guarda as conchas premiadas num lugar especial na areia",
    "necessidade_que_sobe": "TEDIO",
    "duracao_estimada_ticks": 3
  }
}
```

---

## 2. Decisao de Actividade

Dentro do arco activo, o LLM decide qual a proxima actividade/evento a disparar.

Cada fase de um arco tem uma lista de actividades possiveis -- o LLM escolhe qual disparar agora com base no estado.

### Exemplo: Arco "O Companheiro" - Fase 3 (Amizade Estabelecida)

Actividades possiveis nesta fase:
```
- conversa_com_companheiro (fala sobre o dia)
- apresenta_companheiro_a_gaivota (evento com animal)
- jantar_a_dois (divide o peixe)
- discussao_com_companheiro (briga sobre decisao de sobrevivencia)
- ensina_companheiro_a_pescar (monologar enquanto pesca)
- conta_historia_ao_companheiro (memoria do passado)
- preocupacao_com_companheiro (vento forte, tem medo que caia)
```

O LLM escolhe baseado no contexto:
- FOME alta? -> "jantar_a_dois" faz sentido narrativamente
- ESPERANCA baixa? -> "conta_historia_ao_companheiro" com tom melancolico
- Acabou de chover? -> "preocupacao_com_companheiro" (e se caiu com a chuva?)

### Resposta do LLM para decisao de actividade

```json
{
  "actividade": "discussao_com_companheiro",
  "razao": "FOME alta e ESPERANCA baixa criam tensao -- o naufrago culpa o Tabinho pela pesca falhada",
  "tom": "comico_frustrado",
  "contexto_para_frase": "O naufrago esta a culpar o Tabinho pela pesca falhada de hoje",
  "resolucao_sugerida": "reconciliacao_dramatica"
}
```

---

## 3. Decisao de Frase

Depois de decidir o arco e a actividade, o LLM gera a frase do naufrago -- mas agora com contexto muito mais rico:

```
Contexto recebido:
- Estou no arco "Amizade com o Tabinho", fase 3
- Actividade actual: discussao_com_companheiro  
- Tom: comico_frustrado
- Razao da discussao: pesca falhada, culpa o Tabinho
- Arcos passados: a jangada afundou, a teoria do cozinheiro...
- Dia 47, Outono, ESPERANCA baixa

Frase gerada:
"Tabinho, foste tu que me disseste para ir pescar ali! 
 Agora nem peixe temos para o jantar. Brilhante estrategia."
```

---

## 4. Implementacao em GDScript

### LLMDirector.gd (autoload)

```gdscript
class_name LLMDirector
extends Node

signal arc_decision_made(decision: Dictionary)
signal activity_decision_made(activity: String, context: Dictionary)
signal phrase_generated(phrase: String)

var _tick_interval: float = 900.0  # 15 minutos
var _tick_timer: float = 0.0
var _is_thinking: bool = false

func _process(delta: float) -> void:
    _tick_timer += delta
    if _tick_timer >= _tick_interval and not _is_thinking:
        _tick_timer = 0.0
        await _run_director_cycle()

func _run_director_cycle() -> void:
    _is_thinking = true
    
    var state = GameState.get_full_snapshot()
    
    # Decisao 1: arco
    var arc_decision = await _decide_arc(state)
    EventDirector.apply_arc_decision(arc_decision)
    emit_signal("arc_decision_made", arc_decision)
    
    # Actualizar estado apos decisao de arco
    state = GameState.get_full_snapshot()
    
    # Decisao 2: actividade
    var activity_decision = await _decide_activity(state)
    emit_signal("activity_decision_made", 
        activity_decision.actividade, 
        activity_decision)
    
    # Decisao 3: frase (se a actividade envolve falar)
    if activity_decision.get("gerar_frase", true):
        var phrase = await _generate_phrase(state, activity_decision)
        emit_signal("phrase_generated", phrase)
    
    _is_thinking = false

func _decide_arc(state: Dictionary) -> Dictionary:
    var prompt = _build_arc_prompt(state)
    var response = await LLMBridge.request(prompt, max_tokens=200)
    
    var decision = _parse_json_safe(response)
    if not _validate_arc_decision(decision):
        # Fallback: MANTER arco actual
        return {"decisao_arco": "MANTER", "razao": "fallback"}
    return decision

func _decide_activity(state: Dictionary) -> Dictionary:
    var prompt = _build_activity_prompt(state)
    var response = await LLMBridge.request(prompt, max_tokens=150)
    
    var decision = _parse_json_safe(response)
    if not _validate_activity_decision(decision, state):
        # Fallback: actividade mais adequada ao estado actual das necessidades
        return _fallback_activity(state)
    return decision

func _generate_phrase(state: Dictionary, activity: Dictionary) -> String:
    var prompt = _build_phrase_prompt(state, activity)
    var response = await LLMBridge.request(prompt, max_tokens=80)
    return PhraseFilter.filter(response)

func _validate_arc_decision(decision: Dictionary) -> bool:
    if not decision.has("decisao_arco"):
        return false
    var valid_decisions = ["MANTER", "PAUSAR", "TERMINAR", "CRIAR", "RETOMAR", "ESPERAR"]
    return decision["decisao_arco"] in valid_decisions

func _validate_activity_decision(decision: Dictionary, state: Dictionary) -> bool:
    if not decision.has("actividade"):
        return false
    # Verificar se a actividade existe no arco actual
    var active_arc = state.get("arco_activo", {})
    if active_arc.is_empty():
        return true  # Sem arco, qualquer actividade avulsa e valida
    var available = EventDirector.get_available_activities(active_arc.id)
    return decision["actividade"] in available

func _fallback_activity(state: Dictionary) -> Dictionary:
    var needs = state.get("necessidades", {})
    # Regra simples: necessidade mais urgente dita a actividade
    var most_urgent = _get_most_urgent_need(needs)
    return {
        "actividade": NEED_DEFAULT_ACTIVITY[most_urgent],
        "razao": "fallback por necessidade urgente",
        "tom": "neutro",
        "gerar_frase": false
    }

const NEED_DEFAULT_ACTIVITY = {
    "FOME": "pescar",
    "SOLIDAO": "falar_com_companheiro",
    "TEDIO": "passear_pela_ilha",
    "ESPERANCA": "olhar_horizonte"
}
```

---

## 5. Modo Degradado (Sem LLM)

Se o Ollama nao estiver disponivel, o EventDirector usa regras deterministas:

```gdscript
func _fallback_director_cycle() -> void:
    # Sem LLM: usar behaviour tree classica com pesos por necessidade
    var activity = BehaviourTree.tick(actor)
    # Frase: usar FallbackPhrases por categoria
    var phrase = FallbackPhrases.get_for_activity(activity)
```

O jogo funciona completamente sem Ollama -- fica menos rico mas nao quebra.

---

## 6. Memoria do Director

O LLM Director mantem memoria propria das suas decisoes passadas:

```json
{
  "decisoes_recentes": [
    {"tick": 45, "decisao": "CRIAR", "arco": "O Festival das Conchas", "resultado": "completado"},
    {"tick": 46, "decisao": "RETOMAR", "arco": "arc_jangada_2", "resultado": "em_curso"},
    {"tick": 47, "decisao": "PAUSAR", "arco": "arc_jangada_2", "razao": "SOLIDAO critica"}
  ],
  "padroes_detectados": [
    "ESPERANCA tende a cair ao fim do dia",
    "Actividades de pesca reduzem TEDIO mais eficazmente que passear"
  ],
  "preferencias_emergentes": [
    "Naufrago responde melhor a arcos comicos quando TEDIO alto",
    "Arcos melancolicos devem ser espacados pelo menos 2 dias"
  ]
}
```

O campo `padroes_detectados` e gerado pelo proprio LLM ao fim de cada sessao longa -- ele aprende o que funciona neste naufrago especifico.

---

## 7. O Director como Personagem

Com o tempo, o LLM Director ganha uma "voz" propria -- nao e apenas um motor de decisao, e quase um segundo personagem invisivel.

As suas decisoes tornam-se reconheciveis:
- Quando SOLIDAO esta alta, ele tende a pausar arcos de accao e criar momentos de conexao
- Quando ESPERANCA esta baixa, ele quase nunca escolhe arcos tragicos (protege o naufrago)
- Quando TEDIO esta muito alto, as suas criações tornam-se mais absurdas e elaboradas

O utilizador que presta atencao durante semanas começa a "conhecer" o director -- mesmo sem saber que existe.

---

## 8. Implicacoes para o Backlog

Este sistema implica as seguintes tarefas novas (a adicionar ao backlog):

| Tarefa | Fase | Dependencias |
|---|---|---|
| LLMDirector.gd com loop de 3 decisoes | F1 | T-105 (LLMBridge) |
| arc_history.json e ArcHistory resource | F1 | T-001 |
| EventDirector com suporte a arcos | F3 | T-301 |
| Arcos pre-definidos (10 base) | F3 | EventDirector |
| Prompt de geracao de arco pela IA | F3 | LLMDirector |
| Prompt de seleccao de actividade pela IA | F3 | LLMDirector |
| Memoria de decisoes do Director | F3 | arc_history.json |
| Validacao e fallback de decisoes LLM | F1 | LLMBridge |
